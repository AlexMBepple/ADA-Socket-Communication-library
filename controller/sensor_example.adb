with Ada.Text_IO;
with sensor_pkg;

procedure sensor_test_client is
    exampleSensor  : sensor_pkg.sensor;
    lowerThreshold : constant Float := 0.0;
    upperThreshold : constant Float := 100.0;
    recentData     : sensor_pkg.Float_Array;

begin
    -- Set the lower and upper thresholds for the sensor exampleSensor
    sensor_pkg.setLowerThreshold (exampleSensor, lowerThreshold);
    sensor_pkg.setUpperThreshold (exampleSensor, upperThreshold);
    sensor_pkg.setSensorID (exampleSensor, 1);
    
    -- Generate some sample exampleSensor points
    for I in 1 .. 10 loop
        sensor_pkg.addDataPoint (exampleSensor, Float (I) * 1.0);
    end loop;
    
    -- Get the most recent exampleSensor points and print them out
    recentData := sensor_pkg.getDataPoints (exampleSensor);
    
    -- Print the first and last data points
    Ada.Text_IO.Put_Line ("Newest data point: " & Float'Image(recentData (recentData'Last)));
    Ada.Text_IO.Put_Line("Oldest data point: " & Float'Image(recentData (recentData'First)));

    -- Print the average of the data points
    Ada.Text_IO.Put_Line ("Average data point: " & Float'Image(sensor_pkg.getAverage(exampleSensor)));

    sensor_pkg.printSensor (exampleSensor, True);

    sensor_pkg.printSensor (exampleSensor, False);

    Ada.Text_IO.Put_Line("Recent data points: " &  Float'Image(sensor_pkg.getRecentData (exampleSensor))) ;

    

end sensor_test_client;
