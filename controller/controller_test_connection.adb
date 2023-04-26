-- import basic output libraries
with Ada.Text_IO;         
with Ada.Exceptions;        use Ada.Exceptions;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
-- import socket libraries
with GNAT.Sockets; use GNAT.Sockets;
with Ada.Streams;  use Ada.Streams;
-- custom packages
with controller_pkg;
with sensor_pkg;
with controller_to_alarm_pkg;

procedure controller_test_connection is
    --  CONFIGURATION VARIABLES --
    -- Alarm IP address 
    alarmIP : constant String := "173.19.0.3";
    alarmCommunicationPort : Port_Type := 4310;
    --  END CONFIGURATION VARIABLES --

    message : Unbounded_String := Null_Unbounded_String;
    controllerToAlarm : controller_to_alarm_pkg.controller_to_alarm;
begin
    message := message & "Hello Message From The Controler";
    controllerToAlarm.myTcpAlarmAddress := (Addr   => Inet_Addr (alarmIP), port => alarmCommunicationPort, family => Family_Inet); Initialize (Process_Blocking_IO => False);
    controller_to_alarm_pkg.setUpTcpConnection (controllerToAlarm);
    controller_to_alarm_pkg.sendAlarm (controllerToAlarm, message);
    Finalize;

exception
    when E : others =>
        Ada.Text_IO.Put_Line (Exception_Name (E) & ": " & Exception_Message (E));


end controller_test_connection;
