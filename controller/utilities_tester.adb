with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with integer_vector;
with utilities_pkg;

procedure utilities_tester is
   --  use Integer_Vectors;
   asciiVector : integer_vector.Vector;
   str : Unbounded_String := To_Unbounded_String("Hello, world!");
   vectorSize : Integer := 0;
   str2 : Unbounded_String;
begin
   -- convert the string to an ascii vector
   utilities_pkg.convertStringToAscii (str, asciiVector);
   vectorSize := Integer(asciiVector.Length) - 1;
   -- iterate over the vector
   for i in 0 .. vectorSize loop
      Put_Line("The vector element is: " & Integer'Image(asciiVector(i)));
   end loop;

   utilities_pkg.convertAsciiToString (asciiVector, str2);
   Put_Line("The string is: " & To_String(str2));
end utilities_tester;
