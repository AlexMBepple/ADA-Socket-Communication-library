with Ada.Text_IO;
with sensor_pkg;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package controller_pkg is
    type sensor_array is array (1 .. 10) of sensor_pkg.sensor;
    type controller is private;

    function checkIfValuesAreInRange (cont : controller) return Unbounded_String ;
    -- Add a sensor to the controller
    procedure addSensor (cont : in out controller; newSensor : sensor_pkg.sensor);

    -- Returns the value by which the majority of the sensor voted for and if the majority is valid
    function sensorVote(cont : controller; value : out Float; errorThreshold : Float) return Unbounded_String;

    procedure printControllerData (cont : in controller);

private
    type controller is record
        sensorArray : sensor_array;
        numSensors : Integer := 0;
    end record;

end controller_pkg;

-- ip address 
-- number of sensor_pkg 
-- threshold for each sensor 
    -- minor adverage major
--  list of actions to take when go beyond threshold
