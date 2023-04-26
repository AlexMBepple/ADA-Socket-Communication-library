with Ada.Text_IO;
with sensor_pkg;
with utilities_pkg;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body controller_pkg is
   
   function checkIfValuesAreInRange (cont : controller) return Unbounded_String is 
        message : Unbounded_String := Null_Unbounded_String;
        temp : Unbounded_String := Null_Unbounded_String;
        begin
             for i in cont.sensorArray'First .. cont.numSensors loop
                if sensor_pkg.getRecentData(cont.sensorArray(i)) < sensor_pkg.getLowerTheshold(cont.sensorArray(i)) then
                 temp := temp & " " & Integer'Image(sensor_pkg.getSensorID(cont.sensorArray(i)));
                end if;
                if sensor_pkg.getRecentData(cont.sensorArray(i)) > sensor_pkg.getUpperThreshold(cont.sensorArray(i)) then
                 temp := temp & " " & Integer'Image(sensor_pkg.getSensorID(cont.sensorArray(i)));
                end if;
             end loop;
             if temp /= Null_Unbounded_String then
                message := "ERROR: Sensor(s) ID(s):" & temp & " are out of range";
             else
                message := message & "INFO: All sensors are in range";
             end if;
             return message;
        end checkIfValuesAreInRange;

   procedure addSensor(cont : in out controller; newSensor : sensor_pkg.sensor) is
   begin
      if cont.numSensors < 10 then
         cont.numSensors := cont.numSensors + 1;
         cont.sensorArray(cont.numSensors) := newSensor;
         Ada.Text_IO.Put_Line("Sensor added");
      else
         Ada.Text_IO.Put_Line("Error: Too many sensor_pkg");
      end if;
   end addSensor;

   procedure printControllerData (cont : in controller) is
    begin
        Ada.Text_IO.Put_Line("Controller Data");
        Ada.Text_IO.Put_Line("Number Of attached Sensors : " & Integer'Image(cont.numSensors));
        for i in cont.sensorArray'First .. cont.numSensors loop
            Ada.Text_IO.Put_Line("Sensor " & Integer'Image(i) & " Data");
            sensor_pkg.printSensor(cont.sensorArray(i), False);
        end loop;
    end printControllerData;

    -- Returns the value by which the majority of the sensor voted for and if the majority is valid
    function sensorVote(cont : controller; value : out Float; errorThreshold : Float) return Unbounded_String is
        arry : array (1 .. 10) of Integer := (others => 0);
        indexOfBestValue : Integer;
        a : Float;
        b : Float;
        message : Unbounded_String := Null_Unbounded_String;
        temp : Unbounded_String := Null_Unbounded_String;
        begin
        -- count how many times each value is repeated
        for i in cont.sensorArray'First .. cont.numSensors loop
            for j in cont.sensorArray'First .. cont.numSensors loop
                if i /= j then
                    a := sensor_pkg.getRecentData(cont.sensorArray(i));
                    b := sensor_pkg.getRecentData(cont.sensorArray(j));
                    if utilities_pkg.almostEqual(a, b, errorThreshold) then
                        arry(i) := arry(i) + 1;
                    end if;
                end if;
            end loop;
        end loop;

        -- find the value that is repeated the most
        for i in cont.sensorArray'First .. cont.numSensors loop
            if arry(i) > arry(i + 1) then
                value := sensor_pkg.getRecentData(cont.sensorArray(i));
                indexOfBestValue := i;
            end if;
        end loop;

        -- list the sensors which voted the same, and which voted differently
        for i in cont.sensorArray'First .. cont.numSensors loop
            Ada.Text_IO.Put_Line("Sensor ID:" & Integer'Image(sensor_pkg.getSensorID(cont.sensorArray(i)))  & " shared " & Integer'Image(arry(i)) & " votes with other sensors");
        end loop;

        if (Float(arry(indexOfBestValue) + 1)/Float(cont.numSensors)) < 0.5 then
            message := message & "ERROR: Majority of sensors are NOT in agreement. List of sensor IDs:";
            for i in cont.sensorArray'First .. cont.numSensors loop
                message := message & " " & Integer'Image(sensor_pkg.getSensorID(cont.sensorArray(i)));
            end loop;
            return message;
        end if;

        if arry(indexOfBestValue) = (cont.numSensors - 1) then
            message := message & "INFO: All Sensors Agree";
            return message;
        end if;

        for i in cont.sensorArray'First .. cont.numSensors loop
            if arry(i) < arry(indexOfBestValue) then
                temp := temp & " " & Integer'Image(sensor_pkg.getSensorID(cont.sensorArray(i)));
            end if;
        end loop;
        message := "WARNING: Sensors ID(s): " & temp & " are in disagreement with the majority";
        return message;
    end sensorVote;
 
end controller_pkg;