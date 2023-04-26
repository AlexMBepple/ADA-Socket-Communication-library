-- import basic output libraries
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Exceptions;      use Ada.Exceptions;
with Ada.Float_Text_IO;
-- import socket libraries
with GNAT.Sockets;        use GNAT.Sockets;
with Ada.Streams;      use Ada.Streams;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Numerics.Discrete_Random;


package sensor is
    type udpAddressArray is array (0..15) of Sock_Addr_Type; -- arbirary size, can be changed
    type sensor is private;
    procedure setSensorType(s : in out sensor; sensorType : Integer);
    procedure setup(s : in out sensor); 
    procedure run(s : in out sensor; avg: in out Integer; variance: in out Integer);
    function value(avg: in out Integer; variance: in out Integer) return Integer;

private
type sensor is record 
    sensorType : Integer := 0; -- 0 = temperature, 1 = humidity, 2 = pressure
    -- socket variables
    myTCPSocket : Socket_Type; -- our side of the TCP connection
    myUDPSocket : Socket_Type; -- our side of the UDP connection

    -- sensor variables
    myIP : Inet_Addr_Type; -- is set before setup
    myTCPPort : Port_Type := 4310; -- arbitrary port number (4310 just kinda looks like helo)
    myTCPSensorAddress : Sock_Addr_Type; -- is made from our ip and port after ip is set
    
    serverUDPsArray : udpAddressArray; -- array of udp addresses of the servers
    serverUDPsArraySize : Integer := 0; -- size of the udp address array

    waitTime: Integer := 5; -- will act as frequency but initially is the delay between checking if there servers to send to

end record; -- end of sensor record
end sensor; -- end of sensor package

