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

package controller_pkg is
    type incomingSensorMessage is record
        sensorType : Integer;
        sensorIP : Inet_Addr_Type;
        sensorValue : Integer := -1;
    end record;
    type messageArray is array (0..10) of incomingSensorMessage;
    
    type datatypeThreashold is record
        min : Integer;
        max : Integer;
    end record;


    successfulConnectionsWith : array (0 .. 2) of Inet_Addr_Type :=
           (No_Inet_Addr, No_Inet_Addr, No_Inet_Addr);

    -- network settings
    myTCPSensorAddress : Sock_Addr_Type := (Addr => Any_Inet_Addr, port => 4310, family => Family_Inet);
    myUDPSensorAddress : Sock_Addr_Type := (Addr => Any_Inet_Addr, port => 777, family => Family_Inet);
    myUDPAlarmAddress  : Sock_Addr_Type := (Addr => Any_Inet_Addr, port => 2319, family => Family_Inet);

    -- Alarm IP address 
    alarmIP : constant String := "173.19.0.7";
    alarmCommunicationPort : Port_Type := 4320;

    -- sensor data
    communicationSensors : array (0 .. 2) of Sock_Addr_Type :=
       ((Addr   => Inet_Addr ("173.19.0.3"), port => 4310,
         family => Family_Inet),
        (Addr   => Inet_Addr ("173.19.0.4"), port => 4310,
         family => Family_Inet),
        (Addr   => Inet_Addr ("173.19.0.5"), port => 4310,
         family => Family_Inet));

    type datatypeThreasholdArray is array (0..2) of datatypeThreashold;

    datatypeThreasholdConfigurations : datatypeThreasholdArray := (
        (min => 150, max => 255),
        (min => 0, max => 255),
        (min => 10, max => 30));

    -- sockets
    myTCPSensorSocket : Socket_Type;
    myUDPSensorSocket : Socket_Type;
    myTCPAlarmSocket  : Socket_Type;

    -- streams
    SensorChannel : Stream_Access;
    -- AlarmChannel : Ada.Streams.Stream_Access;
    -- threaskholds array of ranges
    -- recent data of sensors

    procedure setup;
    procedure run;
end controller_pkg;
