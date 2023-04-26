with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with sensor;

procedure pressuresensor is    
    pressureSensor : sensor.sensor;
    pressuresensorval :Integer := 18;
    pressurevariance: Integer := 1;
begin 
sensor.setSensorType(pressureSensor, 2); -- 0 is temp, 1 is humidity, 2 is pressure
sensor.setup(pressureSensor);

Put("Setup Complete, Running ");NEW_LINE;
sensor.run(pressureSensor, pressuresensorval, pressurevariance);
end pressuresensor;