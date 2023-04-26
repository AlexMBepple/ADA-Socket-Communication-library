with Ada.Float_Text_IO;
use Ada.Float_Text_IO;
with ada.Text_IO; use ada.Text_IO;
with sensor;

procedure tempsensor is
    tempSensor : sensor.sensor;
    tempvariance:Integer := 5;
    tempsensorval :Integer := 200;
begin 
-- call setup
sensor.setSensorType(tempSensor, 0); -- 0 is temp, 1 is humidity, 2 is pressure
sensor.setup(tempSensor);
Put("Setup Complete, Running ");NEW_LINE;

sensor.run(tempSensor,tempsensorval,tempvariance);

end tempsensor; 