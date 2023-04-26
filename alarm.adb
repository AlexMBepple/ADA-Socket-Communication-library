with GNAT.Sockets;          use GNAT.Sockets;
with Ada.Streams;           use Ada.Streams;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Numerics.Discrete_Random;
with Ada.Float_Text_IO;     use Ada.Float_Text_IO;
with ada.Text_IO;          use ada.Text_IO;
with alarm_pkg;

procedure alarm_test_connection is
    --  CONFIGURATION VARIABLES --
    alarmsPort     : Port_Type := 4320;

    --   VARIABLES --
    listen    :  alarm_pkg.listen_to_alarms;

    -- LISTEN TO ALARMS TASK --
    AlarmsFile : File_Type;
begin
    -- Start the task to listen to the alarms
    null; -- Optionally delay a bit before starting the task
    Ada.Text_IO.Put_Line ("Alarms Starting Up! ");
    Create (AlarmsFile, Out_File, "Alarms.txt");
    Close(AlarmsFile);

    listen.StartListening(alarmsPort);

    loop
        delay(10.0);
    end loop;

end alarm_test_connection;
