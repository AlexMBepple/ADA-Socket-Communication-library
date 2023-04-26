with utilities_pkg;
with integer_vector;
with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body alarm_pkg is

    function isNewController
       (controllers : controllerArray; addres : Inet_Addr_Type) return Boolean
    is
        result : Boolean := True;
    begin
        for i in controllers'First .. controllers'Last loop
            if controllers (i).sourceIP = addres then
                result := False;
                exit;
            end if;
        end loop;
        return result;
    end isNewController;

    procedure addControllerToArray(controllers : in out controllerArray; addres : Inet_Addr_Type)
    is
    begin
        Put_Line ("NEW CONTROLLER ADDED TO ARRAY: " & Image (addres));
        for i in controllers'First .. controllers'Last loop
            if controllers (i).sourceIpIsSet /= True then
                controllers (i).sourceIP      := addres;
                controllers (i).sourceIpIsSet := True;
                exit;
            end if;
        end loop;
    end addControllerToArray;

    function shouldCountVotes (controllers : controllerArray; address : Inet_Addr_Type) return Boolean
    is
        result : Boolean := True;
    begin
        for i in controllers'First .. controllers'Last loop
            if controllers (i).sourceIP = address then
                if To_String (controllers (i).message) = "" then
                    result := False;
                    exit;
                end if;
            end if;
        end loop;
        return result;
    end shouldCountVotes;

    procedure voteAndPrintResults (controllers : in out controllerArray) is
        mostVotedMessage      : Unbounded_String;
        mostVotedIndex        : Integer;
        voteCount             : array (0 .. 10) of Integer := (others => 0);
        didAllControllersVote : Boolean                    := True;
        controllerCount       : Integer                    := 0;
        AlarmsFile            : File_Type;
    begin
        Open (AlarmsFile, Append_File, "Alarms.txt");
        Put_Line (AlarmsFile, " ");
        Put_Line (AlarmsFile, " - - UPDATE - - ");
        -- PRINT NUMBER OF CONNECTED CONTROLLERS --
        for i in controllers'First .. controllers'Last loop
            if controllers (i).sourceIpIsSet then
                controllerCount := controllerCount + 1;
            end if;
        end loop;
        Put_Line ("    Number of connected controllers: " & Integer'Image (controllerCount));
        Put_Line (AlarmsFile, "    Number of connected controllers: " & Integer'Image (controllerCount));

        for i in controllers'First .. controllers'Last loop
            if controllers (i).sourceIpIsSet then
                if controllers (i).message = "" then
                    didAllControllersVote := False;
                    Put_Line ("    WARNING: Did not receive alarm from controller: " & Image (controllers (i).sourceIP) & " it is possible that it has lost connection.");
                    Put_Line (AlarmsFile, "    WARNING: Did not receive alarm from controller: " & Image (controllers (i).sourceIP) & " it is possible that it has lost connection.");
                end if;
            end if;
        end loop;
        if didAllControllersVote then
            Put_Line ("    INFO: All controllers have voted");
            Put_Line (AlarmsFile, "    INFO: All controllers have voted");
        end if;

        for i in controllers'First .. controllers'Last loop
            for j in controllers'First .. controllers'Last loop
                if controllers (i).message /= "" then
                    if controllers (i).message = controllers (j).message then
                        voteCount (i) := voteCount (i) + 1;
                    end if;
                end if;
            end loop;
        end loop;

        for i in voteCount'First .. voteCount'Last - 1 loop
            if voteCount (i) > voteCount (i + 1) then
                mostVotedMessage := controllers (i).message;
                mostVotedIndex   := i;
            end if;
        end loop;

        if(Float(voteCount (mostVotedIndex)) / Float(controllerCount)) < 0.5 then
            Put_Line ("    ERROR: Majority of controllers did not vote for the same alarm");
            Put_Line (AlarmsFile, "    ERROR: Majority of controllers did not vote for the same alarm");
            for i in controllers'First .. controllers'Last loop
                if controllers (i).sourceIpIsSet then
                    Put_Line ("        Controller: " & Image (controllers (i).sourceIP));
                    Put_Line (AlarmsFile, "        Controller: " & Image (controllers (i).sourceIP));
                end if;
            end loop;
        elsif voteCount (mostVotedIndex) = controllerCount then
            Put_Line ("    INFO: All controllers voted for the same alarm");
            Put_Line (AlarmsFile, "    INFO: All controllers voted for the same alarm");        
        else
            Put_Line ("    NEW MESSAGE: " & To_String (mostVotedMessage));
            Put_Line (AlarmsFile,"    NEW MESSAGE: " & To_String (mostVotedMessage));
            for i in controllers'First .. controllers'Last loop
                if controllers (i).sourceIpIsSet then
                    Put_Line ("        WARNING: Controller: " & Image (controllers (i).sourceIP) & " did not vote for majority");
                    Put_Line (AlarmsFile, "        WARNING: Controller: " & Image (controllers (i).sourceIP) & " did not vote for majority");
                end if;
            end loop;
        end if;
        Put_Line ("    NEW MESSAGE: " & To_String (mostVotedMessage));
        Put_Line (AlarmsFile,"    NEW MESSAGE: " & To_String (mostVotedMessage));
        
        Close (AlarmsFile);

        controllers (0).message := To_Unbounded_String ("");
        for i in controllers'First .. controllers'Last loop
            controllers (i).message := To_Unbounded_String ("");
        end loop;
    end voteAndPrintResults;

    procedure updateMessage (controllers : in out controllerArray; address : Inet_Addr_Type; message : Unbounded_String)
    is
    begin
        for i in controllers'First .. controllers'Last loop
            if controllers (i).sourceIP = address then
                controllers (i).message := message;
                exit;
            end if;
        end loop;
    end updateMessage;

    task body listen_to_alarms is
        port                : Port_Type;
        address             : Sock_Addr_Type;
        TCPSocket           : Socket_Type;
        serverTCPConnection : Socket_Type;
        serverTCPChannel    : Stream_Access;
        arrayOfMessages : controllerArray;
        message     : Unbounded_String;
        asciiVector : integer_vector.Vector;
        C           : integer_vector.Cursor;

    begin
        -- INITIALIZE THE ALARM LISTENER
        accept StartListening (setPort : Port_Type) do
            port     := setPort;
        end StartListening;
        -- SET UP THE ALARM CONNECTION
        address := (Addr => Any_Inet_Addr, Port => port, family => Family_Inet);
        Create_Socket (TCPSocket);
        Set_Socket_Option (TCPSocket, Socket_Level, (Reuse_Address, True));
        Bind_Socket (TCPSocket, address);

        -- LISTEN FOR ALARMS
        loop
            Listen_Socket (TCPSocket, 1);
            Accept_Socket (TCPSocket, serverTCPConnection, address);
            serverTCPChannel := Stream (serverTCPConnection);
            loop
                asciiVector.append (Integer'Input (serverTCPChannel));
                exit when asciiVector.Last_Element = -1;
            end loop;
            C := asciiVector.Find (-1);
            asciiVector.Delete (C);
            utilities_pkg.convertAsciiToString (asciiVector, message);
            Put_Line ("Received message: " & To_String (message));
            asciiVector.Clear;

            if isNewController (arrayOfMessages, address.Addr) then
                addControllerToArray (arrayOfMessages, address.Addr);
            end if;

            if shouldCountVotes (arrayOfMessages, address.Addr) then
                voteAndPrintResults (arrayOfMessages);
            end if;

            updateMessage (arrayOfMessages, address.Addr, message);

        end loop;
    end listen_to_alarms;

end alarm_pkg;
