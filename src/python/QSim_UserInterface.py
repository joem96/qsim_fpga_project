"""
Description: This is the python interface that the user uses. Users construct
the quantum circuit here using symbols that represent quantum gates. state
holds the starting states of the qubits. init_circuit represents the circuit
that the qubits propagate through once. rep_circuit is the circuit that the
qubits propagate through multiple times (user defines how many times by
initializing num_reps).

Below is the example quantum circuit build for a 5-qubit Grover's Algorithm.
"""

#import serial
import numpy
import serial
import sup_functions

#set up serial communication
ser = serial.Serial(
    port='COM5',\
    baudrate=9600,\
    parity=serial.PARITY_NONE,\
    stopbits=serial.STOPBITS_ONE,\
    bytesize=serial.EIGHTBITS,\
        timeout=1)


#USER INTERFACE: QUANTUM CIRCUIT SET UP
state        = numpy.array( ['S', 'S', 'S', 'S','S']);

init_circuit = numpy.array([['H', 'H', 'H', 'H', 'H']
                           ]);

rep_circuit  = numpy.array([['I', 'X', 'I', 'I', 'I']  #marked
                           ,['Z', 'C', 'C', 'C', 'C']  #control z
                           ,['I', 'X', 'I', 'I', 'I']  #marked
                           ,['H', 'H', 'H', 'H', 'H']  #init
                           ,['X', 'X', 'X', 'X', 'X']  #X
                           ,['Z', 'C', 'C', 'C', 'C']  #control z
                           ,['X', 'X', 'X', 'X', 'X']  #X
                           ,['H', 'H', 'H', 'H', 'H']  #init
                            ]);

#range: 0 to 255 (num_reps = byte of data sent to Microblaze)
num_reps         = 3;


#start the program & get results + time measurements
results_p, results_np_p, time_meas = sup_functions.start_program(ser,state,init_circuit,rep_circuit,num_reps);

#plot
sup_functions.plot_all(results_p, results_np_p, time_meas, num_reps);
sup_functions.plot_stats(state,init_circuit,rep_circuit,1000);


ser.close();
