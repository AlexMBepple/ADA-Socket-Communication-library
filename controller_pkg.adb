with utilities_pkg;
with integer_vector;
with controller_to_alarm_pkg;

package body controller_pkg is

    procedure setup is
    begin
-- create sockets

        -- UDP Alarms Socket
        Create_Socket
           (Socket => myTCPAlarmSocket,  -- name of socket
            Family => Family_Inet,  -- IPv4
            Mode   =>
               Socket_Datagram -- UDP
        );

        -- UDP Sensor Socket
        Create_Socket
           (Socket => myUDPSensorSocket,  -- name of socket
            Family => Family_Inet,  -- IPv4
            Mode   =>
               Socket_Datagram -- UDP
        );

        -- TCP Alarm Socket
        Set_Socket_Option
           (Socket => myTCPAlarmSocket,  -- name of socket
            level  => Socket_Level,  -- socket level
            Option =>
               (name    => Reuse_Address, -- reuse address
                enabled =>
                   True -- true
        ));

        -- UDP Sensor Socket
        Set_Socket_Option
           (Socket => myUDPSensorSocket,  -- name of socket
            level  => Socket_Level,  -- socket level
            Option =>
               (name    => Reuse_Address, -- reuse address
                enabled =>
                   True -- true
        ));
    end setup;

    procedure run is
        -- tcp connection variables
        --      port x, frequency y
        ConnectionData : array (0 .. 1) of Integer := (777, 5);
        -- udp connection variables
        Data           : Ada.Streams.Stream_Element_Array (1 .. 2);
        from           : Sock_Addr_Type;
        last           : Stream_Element_Offset;

        task controllerTCP;
        task controllerUDP;

        
        successfulConnections     : Integer                          := 0;
        continue                  : Boolean;

        task body controllerTCP is
        begin
            while successfulConnections < communicationSensors'Length loop
                for i in 0 .. communicationSensors'Length - 1 loop
                    continue := True;
                    for j in 0 .. successfulConnectionsWith'Length - 1 loop
                        if (Image (communicationSensors (i).Addr) =
                            Image (successfulConnectionsWith (j)) and
                            continue)
                        then
                            continue := False;
                        end if;
                    end loop;
                    if (continue) then
                        begin
                            Create_Socket (myTCPSensorSocket);
                            -- make connection
                            Connect_Socket
                               (myTCPSensorSocket, -- socket
                                communicationSensors
                                   (i) -- address
                            );
                            -- create stream
                            SensorChannel := Stream (myTCPSensorSocket);
                            -- send all data in array
                            for y in 0 .. ConnectionData'Length - 1 loop
                                Put_Line
                                   ("Sending: " & ConnectionData (y)'Img);
                                NEW_LINE;
                                Integer'Output
                                   (SensorChannel, ConnectionData (y));
                                if (Integer'Input (SensorChannel) /=
                                    ConnectionData (y))
                                then
                                    Put_Line ("Error in data transmission");
                                    NEW_LINE;
                                end if;
                            end loop; -- end sendData loop
                            -- increase successful connections

                            successfulConnectionsWith
                               (successfulConnections) :=
                               communicationSensors (i).Addr;
                            successfulConnections := successfulConnections + 1;
                        exception
                            when SOCKET_ERROR =>
                                Put_Line ("Connection Refused from: " & Image (communicationSensors (i).Addr));
                            when others       =>
                                Put_Line ("Other Error");
                        end;
                    end if;
                    Close_Socket
                       (myTCPSensorSocket); -- must close socket to connect elsewhere
                end loop; -- end communicationSensors loop
                delay Duration (1); -- if there was a connection error we will wait before trying again
            end loop;
        end controllerTCP;

        function isNewSensor( msgArray : messageArray; sensorAddress : Inet_Addr_Type) return Boolean is
            isNew : Boolean := True;
        begin
            for i in msgArray'Range loop
                if (msgArray(i).sensorIP = sensorAddress) then
                    isNew := False;
                    exit;
                end if;
            end loop;
            return isNew;
        end isNewSensor;

        procedure addSenorToArray( msgArray : in out messageArray; sensorAddress : Inet_Addr_Type; data : Ada.Streams.Stream_Element_Array) is
        begin
            Put_Line ("New Sensor: " & Image (sensorAddress));
            for i in msgArray'Range loop
                if (msgArray(i).sensorIP = No_Inet_Addr) then
                    msgArray(i).sensorIP := sensorAddress;
                    msgArray(i).sensorValue := Integer(data(1));
                    msgArray(i).sensorType := Integer(data(2));
                    exit;
                end if;
            end loop;
        end addSenorToArray;

        -- checks value of sensor and returns true if it is a valid value already
        function shouldVote( msgArray : messageArray; address : Inet_Addr_Type) return Boolean is
            shouldVote : Boolean := True;
        begin
            Put_Line ("Checking if should vote: " & Image (address));
            for i in msgArray'Range loop
                if (msgArray(i).sensorIP = address) then
                    if msgArray(i).sensorValue = -1 then 
                        shouldVote := False;
                        exit;
                    end if;
                end if;
            end loop;
            return shouldVote;
        end shouldVote;

        procedure controllerToAlarm(message: in out Unbounded_String) is
                controllerToAlarm : controller_to_alarm_pkg.controller_to_alarm;
            begin
                Put_Line("----- Sending message to alarm: " & To_String(message));
                message := message;
                controllerToAlarm.myTcpAlarmAddress := (Addr   => Inet_Addr (alarmIP), port => alarmCommunicationPort, family => Family_Inet); Initialize (Process_Blocking_IO => False);
                controller_to_alarm_pkg.setUpTcpConnection (controllerToAlarm);
                controller_to_alarm_pkg.sendAlarm (controllerToAlarm, message);
                Finalize;
            exception
                when E : others =>
                    Ada.Text_IO.Put_Line (Exception_Name (E) & ": " & Exception_Message (E));
        end controllerToAlarm;

        procedure vote( msgArray : in out messageArray) is
            type voteTracker is record
                votes : Integer;
                value : Integer;
                totalVotes : Integer;
            end record;

            emptyVoteTracker : voteTracker := (value => -1, votes => 0, totalVotes => 0);
            mostVotedValue : array (0 .. 2) of voteTracker := (others => emptyVoteTracker); -- 0 = Temperature, 1= Humidity, 2 = Pressure
            tempVotes : Integer;

            almostEqThres : Integer := 2;
            a : Integer;
            b : Integer;
            message : Unbounded_String := Null_Unbounded_String;
            temp : Unbounded_String := Null_Unbounded_String;
            numberOfConnectedSensors : Integer := 0;
            numberOfVotes : Integer := 0;
            allSensorsVoted : Boolean := True;
        begin
            Put_Line("  ");
            Put_Line(" ---- Update ----");

            for i in msgArray'Range loop
                -- valid connection? 
                if (msgArray(i).sensorIP /= No_Inet_Addr) then
                    numberOfConnectedSensors := numberOfConnectedSensors + 1;
                    -- valid value?
                    if (msgArray(i).sensorValue /= -1) then
                        numberOfVotes := numberOfVotes + 1;
                        mostVotedValue(msgArray(i).sensorType).totalVotes := mostVotedValue(msgArray(i).sensorType).totalVotes + 1;
                        -- Compare with same datatypes values
                        if(mostVotedValue(msgArray(i).sensorType).value /= -1) then -- checks if the datatype has a voted value
                            tempVotes := 0;
                            -- almost equal?
                            for j in msgArray'Range loop
                                if (msgArray(j).sensorType = msgArray(i).sensorType) then -- compare same datatypes values 
                                    a := msgArray(j).sensorValue;
                                    b := mostVotedValue(msgArray(i).sensorType).value;
                                    if utilities_pkg.almostEqual(a, b, almostEqThres) then
                                        tempVotes := tempVotes + 1;
                                    end if;
                                end if;
                            end loop;
                            if (tempVotes > mostVotedValue(msgArray(i).sensorType).votes) then
                                mostVotedValue(msgArray(i).sensorType).votes := tempVotes;
                                mostVotedValue(msgArray(i).sensorType).value := msgArray(i).sensorValue;
                            end if;
                        else -- update value
                            mostVotedValue(msgArray(i).sensorType).value := msgArray(i).sensorValue;
                            mostVotedValue(msgArray(i).sensorType).votes := 1;
                        end if;
                    else -- sensor did not vote but is connected. Disconnect the sensor
                        Put_Line("WARNING: Sensor " & Image(msgArray(i).sensorIP) & " did not vote.");
                        message := message & "WARNING: Sensor " & Image(msgArray(i).sensorIP) & " did not vote. ";
                        allSensorsVoted := False;
                        --  DROP THIS SENSOR FROM THE CONNECTIONS LIST SO IT CAN RECONNECT VIA TCP -- 
                        for j in successfulConnectionsWith'Range loop
                            if (successfulConnectionsWith(j) = msgArray(i).sensorIP) then
                                successfulConnectionsWith(j) := No_Inet_Addr;
                                exit;
                            end if;                              
                        end loop;
                    end if;
                end if;
            end loop;
        -- we have our votetrackers complete we can now do analytics

            -- Check if all sensors voted
            if allSensorsVoted then
                Put_Line("INFO: All sensors voted.");
                message := message & "INFO: All sensors voted. ";
            end if;

            -- Check if majority of sensors are in agreement
            for i in mostVotedValue'Range loop
                -- Check if majority of sensors are in agreement
                if ((Float(mostVotedValue(i).votes) / Float(mostVotedValue(i).totalVotes)) <= 0.5) then
                    message := message & "ERROR: Majority of sensors are NOT in agreement. Type: ";
                    if i = 0 then
                        message := message & "Temperature ";
                    elsif i = 1 then
                        message := message & "Humidity ";
                    elsif i = 2 then        
                        message := message & "Pressure ";
                    end if;
                end if;
                -- Check if sensors are out of threashold
                if ((mostVotedValue(i).value /= -1) 
                    and (mostVotedValue(i).value < datatypeThreasholdConfigurations(i).min or mostVotedValue(i).value > datatypeThreasholdConfigurations(i).max))
                    then
                        message := message & "ERROR: Sensors are out of threashold. Type: "; 
                else 
                    message := message & "INFO: Sensors are in range. Type: ";
                end if;
                 if i = 0 then
                    message := message & "Temperature ";
                elsif i = 1 then
                    message := message & "Humidity ";
                elsif i = 2 then        
                    message := message & "Pressure ";
                end if;
            end loop;

            -- Print values
            Put_Line ("Number of connected sensors: " & Integer'Image(numberOfConnectedSensors));
            Put_Line ("Number of votes: " & Integer'Image(numberOfVotes));
            Put_Line("Temperature: ");
            Put_Line("Total votes: " & Integer'Image(mostVotedValue(0).totalVotes));
            Put_Line("Value: " & Integer'Image(mostVotedValue(0).value));
            Put_Line("# of votes: " & Integer'Image(mostVotedValue(0).votes));
            Put_Line("  ");
            
            Put_Line("Humidity: ");
            Put_Line("Total votes: " & Integer'Image(mostVotedValue(1).totalVotes));
            Put_Line("Value: " & Integer'Image(mostVotedValue(1).value));
            Put_Line("# of votes: " & Integer'Image(mostVotedValue(1).votes));
            Put_Line("  ");

            Put_Line("Pressure: ");
            Put_Line("Total votes: " & Integer'Image(mostVotedValue(2).totalVotes));
            Put_Line("Value: " & Integer'Image(mostVotedValue(2).value));
            Put_Line("# of votes: " & Integer'Image(mostVotedValue(2).votes));
            Put_Line("  ");


            -- Print message if not null
            if message /= Null_Unbounded_String then
                Put_Line ("Message to alarms: " & To_String(message));
            end if;

            -- Reset values
            for i in msgArray'Range loop
                msgArray(i).sensorValue := -1;

            end loop;

            for i in mostVotedValue'Range loop
                mostVotedValue(i).value := -1;
                mostVotedValue(i).votes := 0;
                mostVotedValue(i).totalVotes := 0;
            end loop;

            -- Send message to alarm
            controllerToAlarm(message);

        end vote;

        procedure updateValues( msgArray : in out messageArray; address : Inet_Addr_Type; data : Ada.Streams.Stream_Element_Array) is
        begin
            for i in msgArray'Range loop
                if (msgArray(i).sensorIP = address) then
                    msgArray(i).sensorValue := Integer(data(1));
                    msgArray(i).sensorType := Integer(data(2));
                    exit;
                end if;
            end loop;
        end updateValues;


        task body controllerUDP is
            msgArray : messageArray := (others => (sensorIP => No_Inet_Addr, sensorValue => -1, sensorType => -1));
        begin
            -- bind our address to the udp sensor reception location
            Bind_Socket
               (Socket  => myUDPSensorSocket, --S socket
                address =>
                   myUDPSensorAddress -- address
            );

            loop
                -- get data from sensors
                Receive_Socket (myUDPSensorSocket, Data, last, from);

                if isNewSensor (msgArray, from.Addr) then 
                    addSenorToArray (msgArray, from.Addr, Data);
                end if;

                if shouldVote (msgArray, from.Addr) then 
                    vote(msgArray);
                end if;

                updateValues (msgArray, from.Addr, Data);

            end loop;
        end controllerUDP;
    begin
        Put ("Running controller");
        NEW_LINE;
    end run;
end controller_pkg;
