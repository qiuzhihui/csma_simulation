# csma_simulation

This is a CSMA/CA simulation in MATLAB. I can't find one from the Internet, so I code it on my own. 

Free free to play with it.



Development timeline:

1. 5 slaves talk to master with fixed data size
	Algorithm:CSMA/CA(Carrier sense multiple access with collision avoidance)
		- waiting period before sending(check if channel is idle)
		- collision happend random backoff
	Simulation:Matlab Version simulation
		- 8 states in CSMA/CA

	when will this algorithm fails:
		- the collision slaves always random backoff for the same amount of time


2. support different data size
	Algorithm:
		- add 1 receiving state in the simulation
		- when only 1 node is sending data trigger receiving states of receiver
	when will this algorithm fails:
		- Almost never

3. support priority and prevent low priority slaves from starving 
	Algorithm:
		- max waiting time before sending depends on the priority, the higher priority the shorter max waiting time
		- backoff time also depends on priority, the higher priority the shorter max waiting time 
		- to prevent starves low priority slaves, we make all the waiting time as random number from a range