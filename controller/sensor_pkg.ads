-- Controller Code --
-- Sensor Data Type --

package sensor_pkg is
    type sensor is private;
    type Float_Array is array (1 .. 10) of Float;

    -- Getters and Setters for the sensor record
    procedure setLowerThreshold (Data : in out sensor; Threshold : Float);
    procedure setUpperThreshold (Data : in out sensor; Threshold : Float);
    procedure setSensorID (Data : in out sensor; ID : Integer);
    function getSensorID (Data : sensor) return Integer;
    function getLowerTheshold (Data : sensor) return Float;
    function getUpperThreshold (Data : sensor) return Float;

    -- adds data point ot the end of the array and shifts the rest of the array
    procedure addDataPoint (Data : in out sensor; Point : Float);

    -- returns the array of data points : 'last is newest 'first is oldest
    function getDataPoints (Data : sensor) return Float_Array;

    -- returns the adverge of the past 10 data points
    function getAverage (Data : sensor) return Float;

    -- returns the most recent data point
    function getRecentData (Data : sensor) return Float;
    -- print the sensor data
    procedure printSensor (Data : in sensor; printDataPoints : in Boolean);

private

    type sensor is record
        lowerThreshold : Float;
        upperThreshold : Float;
        sensorID       : Integer;
        recentData     : Float_Array := (others => 0.0);
    end record;

end sensor_pkg;
