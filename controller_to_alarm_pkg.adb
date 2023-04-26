with utilities_pkg;
with integer_vector;

package body controller_to_alarm_pkg is
    procedure setUpTcpConnection (c_to_a : in out controller_to_alarm) is
    begin
        -- create sockets
        -- TCP Sensor socket
        Create_Socket
           (Socket => c_to_a.myTCPAlarmSocket,  -- name of socket
            Family => Family_Inet,  -- IPv4
            Mode   =>Socket_Stream -- TCP
            );

        -- Set Socket Options
        -- TCP Sensor Socket
        Set_Socket_Option
           (Socket => c_to_a.myTCPAlarmSocket, level => Socket_Level,
            Option => (name => Reuse_Address, enabled => True));
    end setUpTcpConnection;

    procedure sendAlarm (c_to_a : in out controller_to_alarm; message : Unbounded_String) is
        asciiVector : integer_vector.Vector;
    begin
        -- convert string to ascii
        utilities_pkg.convertStringToAscii (message, asciiVector);
        -- Send message
        Connect_Socket (c_to_a.myTcpAlarmSocket, c_to_a.myTcpAlarmAddress);
        c_to_a.SensorChannel := Stream (c_to_a.myTcpAlarmSocket);
        for i in 0 .. Integer(asciiVector.Length) - 1 loop
            Integer'Output(c_to_a.SensorChannel, asciiVector(i));
            delay 0.01;
        end loop;
        Integer'Output(c_to_a.SensorChannel, -1);
        Close_Socket (c_to_a.myTcpAlarmSocket);
    end sendAlarm;
end controller_to_alarm_pkg;
