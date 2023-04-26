# FinalProject

### FinalProject test run results
<img src="resultExample.png">

## Info

The project is a simulation of a security system. The system consists of a controller, sensors, and an alarm. The controller is responsible for receiving data from the sensors and sending it to the alarm. The alarm is responsible for receiving data from the controller and displaying it to the user. The sensors are responsible for sending data to the controller. The controller and sensors communicate over UDP and TCP connections. The controller and alarm communicate over TCP. 

The connections are all made on concurrent threads created by processes that run on separate containers in a docker network.

This project was completed uising the ADA programming language, which has a remarkably low amount of documentation. This project is here to serve as a reference for anyone who is interested in learning ADA and using it for socket communication programming.

-- The project was completed by:
- [x] Alex Bepple
- [x] Benjamin Lea
- [x] Sanyam Gupta

Future work would be to improve the UI, and ensure that there is no chance of data read write errors using adas protected types implementation that we learned in the last week of class.

# How to run the project
## 1. Run the docker network command first
docker network create -d bridge DockNet --subnet=173.19.0.0/16

## 2. Run the docker container command second
docker-compose up 

## 3. Read the output from the Text File
 A file in will be created in the bild directory called Alam.txt this is where you will see the UI.

## 4. To stop the docker container
(CTRL + C) to stop the docker container

# Description of the project

The project connects sensors with a controller which relays information to an alarm. 

The processes run on separate containers in a docker network and connect and communicate over TCP and UDP connections using sockets.



# Need help with the network connection between the containers?
https://docs.docker.com/config/containers/container-networking/

## to view the network
docker network ls

docker network inspect DockNet
