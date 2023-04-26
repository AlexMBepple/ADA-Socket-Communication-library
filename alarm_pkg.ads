-- import basic output libraries
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Exceptions;      use Ada.Exceptions;
with Ada.Float_Text_IO;
-- import socket libraries
with GNAT.Sockets;          use GNAT.Sockets;
with Ada.Streams;           use Ada.Streams;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Numerics.Discrete_Random;

package alarm_pkg is
    type incomingMessages is record
        sourceIP    : Inet_Addr_Type;
        sourceIpIsSet : Boolean := False;
        message     : Unbounded_String :=  To_Unbounded_String("");
    end record;
    type controllerArray is array (0..10) of incomingMessages;
    task type listen_to_alarms is 
        entry StartListening(setPort: Port_Type);
    end listen_to_alarms;
end alarm_pkg;
