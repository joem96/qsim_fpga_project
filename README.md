# Quantum Sim. FPGA Accelerator Project 

## In-Depth Explanation on Project
I wrote a blog on Medium explaning the purpose, design, overall process and results of this project. 
Link: https://medium.com/@josephmeng96/accelerating-quantum-simulations-w-fpgas-84b09569ad0f

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
 
## Hardware & Software
- Arty A7 FPGA Development Board
- Vivado 2017.2
- QuestaSim / Modelsim
- Python 3

Note: These are the hardware & software I used for this project and other tools can definitely work. 
- Boards with more powerful FPGAs than Artix 7 (Virtex 7, Kintex 7, Ultrascale... etc) will definitely work. Zynq boards will also work but you will need to make some changes in the vivado design flow like replacing the Microblaze in the block diagram with the Zynq IP and possibly dealing with clock domain crossing since the Zynq will probably run at a higher speed. 
- Any Vivado version will work as long as Xilinx SDK is included (we need this for the software c++ development and loading of program into the Microblaze or Zynq).
- Simulators like Questa / Modelsim are used during development but they are not needed if you want to rebuild the project. Nevertheless, I included testbenches that I designed and also scripts for QuestaSim. 

## RTL Simulation
While developing the RTL design in VHDL, I simultaneously tested each new component that I developed by simulating them in QuestaSim. In **src/vhdl/tb**, I have a **components_tb.vhd**, which tests all of the smaller components that make up the top-level design while the **soft_if_tb.vhd** tests only **soft_if** (final top-level wrapper). In my **questa** folder, I have the two .do scripts that bring up the important signals for simulation if you are using questasim / modelsim as simulators. 

## Vivado Build
In Vivado, I first created a block diagram, selecting arty7 board file, and added all the vivado IP's - clock/reset, Microblaze, and UART lite interface. I then added a custom IP (HW_Accelerator) which serves as an AXI peripheral that the Microblaze can talk to. Vivado generateed the top level wrapper of this IP and basically handles the AXI protocol of reading and writing for us. **vivado/ip_repo/HW_Accelerator_1.0/hdl** shows the generated wrapper files. I customized the **HW_Accelerator_v1_0_S00_AXI** component by instantiating the **soft_if** entity (my own custom block) and basically added logic that maps reading/writing of AXI registers to interfacing with the **soft_if** component. The **soft_if** component instantiates the rest of my hand-written RTL sources (identical to the ones in my vhdl folder). After that, Vivado generated the top wrapper file for the whole board, synthesized, place & routed, and generated the bit stream. I programmed my Arty A7 Board with my bitstream. I also exported the hardware files to SDK. Within SDK, I created an application project which has two c++ files (see **src/cpp**). I ran the project and Vivado automatically loads the compiled c++ program into the Microblaze. 

For now, to replicate this entire build, you will need to create the block diagram in Vivado yourself but I have provided the **HW_Accelerator** custom IP in **vivado/ip_repo** that is part of the block diagram. The bulk of my hardware/rtl design exists in this **HW_Accelerator** IP. You will also need to create the SDK application project manually. Hopefully, in the future, I will provide a tcl script that will build the whole Vivado project.

## Running the Project
To run the project, 
- make sure your FPGA board is configured and connected to the computer through USB.
- open **src/python/QSim_UserInterface.py** and construct desired quantum circuit using symbols. 
- make sure your computer has access to the serial port connected to the FPGA board.
- run **QSim_UserInterface.py**.
- wait few seconds and results will show up. 

In **QSim_UserInterface.py**, I left an example circuit that implements the 5-qubit Grover's Algorithm (w/ 3 iterations). 


