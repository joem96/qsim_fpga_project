# Quantum Sim. FPGA Accelerator Project 


## Project Directory
```.
├── questa
│   └── (2 .do scripts to load up waves when simulating testbenches)
│   
├── src
│   ├── cpp (these c++ sources are used in Vivado SDK and ran by Microblaze)
│   │   ├── REGISTER_DEFINITIONS.txt (describes which registers to read/write to from the perspective of the Microblaze)
│   │   ├── main.cpp (main c++ file ran by the Microblaze)
│   │   └── qr_header.h (helper file)
│   │
│   ├── python
│   │   ├── QSim_UserInterface.py (main python file for the user to run)
│   │   └── sup_function.py (helper file)
│   │
│   └── vhdl
│       ├── design
│       │   └── (9 .vhd design files)
│       │
│       └── tb
│           └── (3 .vhd testbench files)
└── vivado 
    └──ip_rep (packaged custom IP's that can be used in Vivado)
       └──HW_Accelerator_1.0 
          └──(vivado-generated files)
 ```

## Simulation
While developing the RTL design in VHDL, I simultaneously tested each new component that I develop by simulating. In my tb (testbench) folder, I have a components_tb.vhd, which tests all of the smaller components that make up the top-level design. The soft_if_tb.vhd tests only soft_if.vhd (final top-level wrapper). In my questa folder, I have the two .do scripts that bring up the important signals for questasim / modelsim.

## Vivado Build
In Vivado, I first created a block diagram and added all the vivado IP's - clock/reset, Microblaze, and UART lite interface. I then added a custom IP (HW_Accelerator) which serves as an AXI peripheral that the Microblaze can talk to. Vivado generates the top level wrapper of this IP and basically deals with the AXI protocol for reading and writing. If you go into the vivado/ip_repo/HW_Accelerator_1.0/hdl, you will see the wrapper files. I customized the ##HW_Accelerator_v1_0_S00_AXI## component by instantiating the soft_if component and basically added logic that maps writing/reading AXI registers to interfacing with the soft_if component. The soft_if component will then instantiate the rest of my hand-written RTL sources (identical to the ones in my vhdl folder). 

## Running the Project
