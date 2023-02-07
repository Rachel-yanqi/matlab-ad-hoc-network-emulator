/*Parameters*/
Network conmunication parameters can be set in config.ini file

/*Initialization*/
All "test_xxx" files have initialized the node's position, sender, and receivers. 
The node's positions in "test_halo" are pre-defined, and saved in ‘Movement' folder

/*How to run the code*/
1. In config.ini, set the parameters 

2. In config,ini, choose the MAC layer protocol: omni/directional/halo/userhalo
	omni： antenna RF range is 1400m, 360 degrees
	directional: antenna txPower, degree
	halo: create phantom halo (relays' distance lesser than halo_cutoff); delete halo if lesser than two relays are in the halo; omni antenna
	userhalo: create user halo (centered at the user); find the gate

3. In config.ini, set the Network layer protocol: benchmark/tsp/tree_opm/halo/userhalo
	benchmark: shortest path for each user node
	tsp: find the shortest path to connect all user nodes (distances between each pair of nodes are lesser than RF range, otherwise, find a relay
		root chooses the closet user node
	tree_opm: 
	halo: simplified the tree (a virtual halo tree), the center of halo is selected as the relay
	userhalo: users form halo and select the gate node, which is responsible for inter-halo (it becomes as a virtual user)
		and intra-halo communication (the shortest path to real user)

4. addpath('function')		
   addpath('classes')		
   addpath('./Movement/halo_movement')
   addpath('./matlab-tsp-ga-master')
   addpath('./function/ant colony')

5. Run the "test_xxx" files