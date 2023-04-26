with Ada.Text_IO;

package body sensor_pkg is

   procedure setLowerThreshold (Data : in out sensor; Threshold : Float) is
   begin
      Data.lowerThreshold := Threshold;
   end setLowerThreshold;

   procedure setUpperThreshold (Data : in out sensor; Threshold : Float) is
   begin
      Data.upperThreshold := Threshold;
   end setUpperThreshold;

   function getLowerTheshold (Data : sensor) return Float is
   begin
      return Data.lowerThreshold;
   end getLowerTheshold;

   function getUpperThreshold (Data : sensor) return Float is
   begin
      return Data.upperThreshold;
   end getUpperThreshold;

   procedure setSensorID (Data : in out sensor; ID : Integer) is
   begin
      Data.sensorID := ID;
   end setSensorID;

   function getSensorID (Data : sensor) return Integer is
   begin
      return Data.sensorID;
   end getSensorID;

   procedure addDataPoint (Data : in out sensor; Point : Float) is
   begin
      -- Shift the data array to make room for the new point
      for i in 2..10 loop
         Data.recentData(i-1) := Data.recentData(i);
      end loop;
      -- Add the new point to the end of the array
      Data.recentData(10) := Point;
   end addDataPoint;

   function getDataPoints (Data : sensor) return Float_Array is
   begin
      return Data.recentData;
   end getDataPoints;

   function getAverage (Data : sensor) return Float is 
   sum : Float := 0.0;
   adverage : Float := 0.0;
    begin
        for i in 1..10 loop
            sum := sum + Data.recentData(i);
        end loop;
        adverage := sum / 10.0;
        return adverage;
    end getAverage;

   
    function getRecentData (Data : sensor) return Float is
      begin
         return Data.recentData(10);
      end getRecentData;


    procedure printSensor (Data : in sensor; printDataPoints : in Boolean) is
      begin
         Ada.Text_IO.Put_Line("Sensor ID: " & Integer'Image(Data.sensorID));
         if printDataPoints then
            Ada.Text_IO.Put_Line("Sensor Data Values: ");
            for i in 1..10 loop
                  Ada.Text_IO.Put(Float'Image(Data.recentData(i)));
            end loop;
            Ada.Text_IO.Put_Line("");
         end if;
         Ada.Text_IO.Put_Line("Average: " & Float'Image(getAverage(Data)));
         Ada.Text_IO.Put_Line("Lower Threshold: " & Float'Image(Data.lowerThreshold));
         Ada.Text_IO.Put_Line("Upper Threshold: " & Float'Image(Data.upperThreshold));
      end printSensor;

end sensor_pkg;