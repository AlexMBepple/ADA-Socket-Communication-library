with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with integer_vector;

package utilities_pkg is
    function almostEqual (a : Integer; b : Integer; errorThreshold : Integer) return Boolean;
    procedure convertStringToAscii (str : Unbounded_String; ascii : out integer_vector.vector);
    procedure convertAsciiToString (ascii : integer_vector.vector; str : out Unbounded_String);
end utilities_pkg;