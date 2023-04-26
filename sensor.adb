package body sensor is

    procedure setSensorType(s : in out sensor; sensorType : in Integer) is
    begin
        s.sensorType := sensorType;
    end setSensorType;  

    procedure setup (s : in out sensor) is
    begin
        s.myTCPSensorAddress := (Addr => Any_Inet_Addr, Port => s.myTCPPort, family => Family_Inet);
        -- create sockets
        Create_Socket(s.myTCPSocket); -- TCP socket (TCP is default Mode)
        Create_Socket(
            Socket => s.myUDPSocket, -- socket variable
            Family => Family_Inet,  -- IPv4
            Mode => Socket_Datagram -- UDP mode needs to be set 
            );
        -- set socket options
        Set_Socket_Option(s.myTCPSocket, Socket_Level, (Reuse_Address, True));
        -- bind socket to address
        Bind_Socket (s.myTCPSocket, s.myTCPSensorAddress);
        -- listen for connections
        Listen_Socket (s.myTCPSocket); -- listen for connections with a default connection queue of 15
    end setup;
    
    procedure run(s : in out sensor; avg: in out Integer; variance: in out Integer) is
        -- tcp variables
        tempIP : Inet_Addr_Type;
        tempPortNumber : Integer;
        tempPort: Port_Type;
        tempAddress: Sock_Addr_Type;

        connectionSocket : Socket_Type;
        connectionAddress : Sock_Addr_Type;
        connectionChannel : Stream_Access;
        task TaskTCP;
        
        -- udp variables
        Data : Stream_Element_Array (1 .. 2) := (others => Stream_Element(s.sensorType));
        Last : Stream_Element_Offset := 1;    
        task TaskUDP;

        task body TaskTCP is
        begin
            
            Put("Starting TCP task"); NEW_LINE;
            loop
                -- accept connection
                Accept_Socket (s.myTCPSocket, connectionSocket, connectionAddress); -- accept a socket from our listener
                connectionChannel := Stream (connectionSocket); -- create stream channel

                -- output the serverTCPAddress address
                Put("Accepted TCP connection from socket IP: "); Put(Image(connectionAddress.Addr)); NEW_LINE;
                
                --set temp IP from connetion
                    tempIP := connectionAddress.Addr;
                -- read port number for our UDP connection
                    tempPortNumber := Integer'Input(connectionChannel);
                    tempPort := Port_Type (tempPortNumber);
                    Integer'Output (connectionChannel, tempPortNumber);
                -- set temp address 
                    tempAddress := (Addr => tempIP, Port => tempPort, family => Family_Inet);
                -- append address to server UDPs
                    s.serverUDPsArray(s.serverUDPsArraySize) := tempAddress; -- add to list of server addresses
                    s.serverUDPsArraySize := s.serverUDPsArraySize + 1; -- increase size_of_array count
                -- read wait time
                    s.waitTime := Integer'Input (connectionChannel);
                    Integer'Output (connectionChannel, s.waitTime);
                -- close connection
                Close_Socket (connectionSocket); -- close the connection for our temporary server controller tcp connection
            end loop;
        end TaskTCP;

        task body TaskUDP is
        begin
            Put("Starting UDP task"); NEW_LINE;
            loop
                -- create new data
                Data(1) := Stream_Element(value(avg,variance));
                -- For each server observer, send the datagram
                if s.serverUDPsArraySize > 0 then
                    -- view it
                    Put("Sending: "); Put(Data(1)'Img); NEW_LINE;
                    Put_Line("Last: " & Last'Img);
                    for i in 0..s.serverUDPsArraySize-1 loop
                        Send_Socket (s.myUDPSocket, Data, Last, s.serverUDPsArray(i));
                    end loop;
                    Put("Sent "); Put(s.serverUDPsArraySize); Put(" datagrams"); NEW_LINE;
                else
                    Put_Line("No server addresses to send to");
                end if;
                delay Duration(s.waitTime); -- this sets our frequency of 
            end loop;
        end TaskUDP;
    begin
        Put("Running sensor"); NEW_LINE;
    end run;
    

    function value(avg: in out Integer; variance: in out Integer) return Integer is
        type upordown is (lower,higher);
        package moreorless is new Ada.Numerics.Discrete_Random(upordown);
        use moreorless;
        Generate: Generator;
        Result: Integer;
    begin
        Reset(Generate);
        case Random(Generate) is
            when lower =>
                Result := avg-variance;
            when higher =>
                Result := avg+variance;
            end case;
            -- check if result is in range
            if Result < 0 then
                Result := 0;
            elsif  Result > 255 then
                Result := 255;
            end if;

            avg := Result;
        return Result;
    end value;

end sensor;
