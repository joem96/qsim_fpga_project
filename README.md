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

## Vivado Build

## Running the Project
