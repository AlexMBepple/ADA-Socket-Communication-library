with Ada.Text_IO;
with controller_pkg;
with sensor_pkg;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

procedure controller_test_client is
    exampleSensor     : sensor_pkg.sensor;
    lowerThreshold    : constant Float := 0.0;
    upperThreshold    : constant Float := 100.0;
    exampleController : controller_pkg.controller;
    votedValue        : Float;
    message           : Unbounded_String;
begin
    -- Create 3 sensors 
    -- sensor 1
    sensor_pkg.setLowerThreshold (exampleSensor, lowerThreshold);
    sensor_pkg.setUpperThreshold (exampleSensor, upperThreshold);
    sensor_pkg.setSensorID (exampleSensor, 1);
    for I in 1 .. 10 loop
        sensor_pkg.addDataPoint (exampleSensor, Float (I) * 100.0);
    end loop;
    controller_pkg.addSensor (exampleController, exampleSensor);

    -- sensor 2
    sensor_pkg.setSensorID (exampleSensor, 2);
    for I in 1 .. 10 loop
        sensor_pkg.addDataPoint (exampleSensor, Float (I) * 2.0);
    end loop;
    controller_pkg.addSensor (exampleController, exampleSensor);

    -- sensor 3
    sensor_pkg.setSensorID (exampleSensor, 3);
    for I in 1 .. 10 loop
        sensor_pkg.addDataPoint (exampleSensor, Float (I) * 2.0);
    end loop;
    controller_pkg.addSensor (exampleController, exampleSensor);

    -- Print the controller's data
    controller_pkg.printControllerData (exampleController);
    
    -- test voting function sensorVote(cont : controller; value : out Float; errorThreshold : Float) return Boolean;
    message := controller_pkg.sensorVote (exampleController, votedValue, 1.0);

    -- print message 
    Ada.Text_IO.Put_Line ( To_String(message));

    message := controller_pkg.checkIfValuesAreInRange(exampleController);
    Ada.Text_IO.Put_Line ( To_String(message));
end controller_test_client;
