-- import socket libraries
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Streams;  use Ada.Streams;

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package controller_to_alarm_pkg is
    type controller_to_alarm is record
        myTcpAlarmAddress : Sock_Addr_Type;
        myTcpAlarmSocket : Socket_Type;
        SensorChannel     : Stream_Access;
    end record;

    procedure setUpTcpConnection (c_to_a : in out controller_to_alarm);
    procedure sendAlarm (c_to_a : in out controller_to_alarm; message : Unbounded_String);
end controller_to_alarm_pkg;