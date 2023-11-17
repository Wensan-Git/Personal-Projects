How to run the project and note on runnning and input:

Before running the project, inside the project folder, type

sudo chmod 777 ChatApp

Then for starting the server, type

./ChatApp -s <port-num>

For starting the client, type: 

./ChatApp -c <name> <server-ip> <server-port> <client-port>

Once starting, you can type in the desired commands for client terminal. Once done, you can press control-C on mac to exit the client (press twice if once is not enough)


Functionalities:

1. Client registration with the server


2. Type in "send #client name# #message#" to send direct message


3. A client can deregister by typing 'dereg'


4. A client's message to an offline client will be kept by the server and delivered to client upon the server coming back online


5. A client can send group message by typing "send_all #message#"


6. An offline client can go back online by typing in 'reg'
