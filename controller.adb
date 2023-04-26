-- import basic output libraries
with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Exceptions;      use Ada.Exceptions;
with Ada.Float_Text_IO;
-- import socket libraries
with GNAT.Sockets;        use GNAT.Sockets;
with Ada.Streams;       use Ada.Streams;

with controller_pkg;

procedure controller is
begin
    Initialize (Process_Blocking_IO => False);
        controller_pkg.setup;
        controller_pkg.run;
    Finalize;
    exception
      when E : others =>
         Put_Line (Exception_Name (E) & ": " & Exception_Message (E));
end controller;
