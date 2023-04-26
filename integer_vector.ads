
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Containers.Vectors;

package integer_vector is new
     Ada.Containers.Vectors (Index_Type => Natural, Element_Type => Integer);
