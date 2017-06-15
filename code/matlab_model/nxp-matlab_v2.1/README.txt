 Matlab (folder nxp_matlab)
----------------------------

- This folder contains all the code written in Matlab. The main subfolders are:

   a) allocators - this folder contains the different allocator definitions
   b) core - this folder contains the main class files for the architecture model
   c) gui - this folder contains the gui class file
   d) tasks - this folder contains the classes related to Tasks
   e) util - this folder contains utility classes needed to perform the full evaluation of the allocators in different operating conditions.

All of the previous folders have to be included in the Matlab path in order for the simulation framework to run correctly. Furthermore, on the main folder (nxp_matlab), there are a number of example scripts which run certain specific experiments. For example:

   1) run_sleep_p.m -> This script runs with default conditions: sleep power, high system power, low and high variabilities. 
   2) run_system_half.m -> This scripts runs with default conditions, except for Psys = 0.5 Pwc.

In order to run a the GUI, simply double click the file nxp_matlab/gui/interface.fig

Created by Andres Gomez
Modified by Andres Gomez to provide performance plots