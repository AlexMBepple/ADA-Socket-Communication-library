with Ada.Text_IO; use Ada.Text_IO;
package body utilities_pkg is
    function almostEqual (a : Integer; b : Integer; errorThreshold : Integer) return Boolean is
        diff : Integer := 0;
    begin
        diff := a - b;
        if (abs diff) < errorThreshold then
            return True;
        else
            return False;
        end if;
    end almostEqual;

    procedure convertStringToAscii (str : Unbounded_String; ascii : out integer_vector.vector) is
    begin
        for i in 1 .. To_String(str)'Length loop
            ascii.append(Character'Pos(To_String(str)(i)));
        end loop;
    end convertStringToAscii;

    procedure convertAsciiToString (ascii : integer_vector.vector; str : out Unbounded_String) is
    begin
        str := To_Unbounded_String("");
        for i in 0 .. Integer(ascii.Length)-1 loop
            str := str & Character'Val(ascii(i));
        end loop;
    end convertAsciiToString;

end utilities_pkg;