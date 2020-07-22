"""
Description: Helper file that contains all the functions 
for the main interface. 
"""

import numpy;
import math;
import time;
import matplotlib.pyplot as plt;
import matplotlib.colors as mcolors;
from matplotlib.cm import ScalarMappable;

FPGA_CLK_SPD = 100; #100 MHz

# Function to find two's complement 
def findTwoscomplement(str): 
    n = len(str) 
    # Traverse the string to get first  
    # '1' from the last of string 
    i = n - 1
    while(i >= 0): 
        if (str[i] == '1'): 
            break
        i -= 1
    # If there exists no '1' concatenate 1  
    # at the starting of string 
    if (i == -1): 
        return '1'+str
    # Continue traversal after the  
    # position of first '1' 
    k = i - 1
    while(k >= 0): 
        # Just flip the values 
        if (str[k] == '1'): 
            str = list(str) 
            str[k] = '0'
            str = ''.join(str) 
        else: 
            str = list(str) 
            str[k] = '1'
            str = ''.join(str) 
        k -= 1
    # return the modified string 
    return str

#given hex data, return decimal number equivalent. 
def hex_to_frac(hex_data):
    
    sign = 1;
    
    int_data = int(hex_data, 16); #convert to int
    binary_number = int("{0:08b}".format(int_data)) #convert to binary int
    str_binary_number = str(binary_number); #convert to binary string
    #print(str_binary_number);
    
    if(len(str_binary_number) == 16):
        sign = -1;
        str_new = findTwoscomplement(str_binary_number);
    else:
        str_new = str_binary_number;
    
    final = sign*int(str_new,2)/pow(2,14);
    #print(final);
    return final;

#given decimal number, return hex data. 
def frac_to_hex(frac_data):
    
    isNeg = frac_data < 0;  #determine if negative number or not.
    frac_data = abs(frac_data);
    
    int_frac_data = int(frac_data*pow(2,14));   #move binary decimal 14 to the right.   
    binary_frac_data = int("{0:08b}".format(int_frac_data)); #convert to binary.
    str_binary_number = str(binary_frac_data); #get the string version of the binary
    
    str_binary_number = str_binary_number.rjust(16,'0'); #make sure we're still 16 bits
    
    #2's complement if frac data was negative. 
    if(isNeg):
        str_new = findTwoscomplement(str_binary_number);
    else:
        str_new = str_binary_number;
    
    #turn binary into hex.
    
    #final = hex(int(str_new,2));
    final = format(int(str_new,2),"04x");
    
    #print(final);
    return final;


#QUANTUM GATE DEFINITIONS
q0 = numpy.array([[1,
                  0]]);

I = numpy.array([[1, 0],
                 [0, 1]]);    
    
X = numpy.array([[0, 1],
                 [1, 0]]);

Z = numpy.array([[1, 0],
                 [0, -1]]);
    
H = (1/math.sqrt(2))*numpy.array([[1, 1],
                                  [1, -1]]);

#Special Quantum Stages
cZ = numpy.array(['Z', 'C', 'C', 'C', 'C']);

#For Graph.
state_labels  = numpy.array(['00000', '00001', '00010', '00011', '00100', '00101', '00110', '00111',
                             '01000', '01001', '01010', '01011', '01100', '01101', '01110', '01111',
                             '10000', '10001', '10010', '10011', '10100', '10101', '10110', '10111',
                             '11000', '11001', '11010', '11011', '11100', '11101', '11110', '11111']);

state_labels2 = numpy.array(['0', '1', '2', '3', '4', '5', '6', '7',
                             '8', '9', '10', '11', '12', '13', '14', '15',
                             '16', '17', '18', '19', '20', '21', '22', '23',
                             '24', '25', '26', '27', '28', '29', '30', '31']);

#Function to convert symbol to corresponding gate
def symb_to_gate(symb):
    switcher = {
        'I': I,
        'X': X,
        'Z': Z,
        'H': H,
        'S': q0}
    return switcher.get(symb); 

#Given 5 qubit gates, create a stage
def create_stage(s0, s1, s2, s3, s4):
    return numpy.kron(numpy.kron(numpy.kron(s0,s1),numpy.kron(s2,s3)),s4);

#Given stages, create a circuit
def create_circuit(stages):    
     final = create_stage(I,I,I,I,I);
     for stage in stages:         
         #if special stage needs to be made
         if((stage == cZ).all()):
             new = create_stage(I,I,I,I,I);
             new[31][31] = -1;
         #else create standard stage
         else:
             new = create_stage(symb_to_gate(stage[0]), symb_to_gate(stage[1]), symb_to_gate(stage[2]), symb_to_gate(stage[3]), symb_to_gate(stage[4]));
         final = numpy.dot(new,final);
     return final;
 
#Given a state represented with symbols, create a corresponding stage. 
def create_vector(state):
    new = create_stage(symb_to_gate(state[0]), symb_to_gate(state[1]), symb_to_gate(state[2]), symb_to_gate(state[3]), symb_to_gate(state[4]));
    return new;

#Convert stopwatch hex data from Microblaze into the equivalent microsecond time
def watch_time(data):
    return (pow(10,-6)/FPGA_CLK_SPD)*int(data,16)*pow(10,6);

#Send circuit data one-by-one(1 byte) to serial. 
def send_vals(ser,circuit):
    for row in circuit:
        for value in row:
            value_hex = frac_to_hex(value);
            str_value_hex = str(value_hex);
            #print(str_value_hex);
            
            value0_str = str_value_hex[0:2];
            value1_str = str_value_hex[2:4];
            
            value0_int = int(value0_str,16);
            value1_int = int(value1_str,16);
            
            packet = bytearray();
            
            packet.append(value0_int);
            packet.append(value1_int);
            
            ser.write(packet);
            
#Send number of reps (1 byte) to serial. 
def send_num_rep(ser,reps):

        packet = bytearray();
        packet.append(reps);
        ser.write(packet);

#Run the exact computation that is ran in Hardware but using numpy. 
def run_numpy_comp(rep_circuit_g, vec, reps):
    results = vec;
    t0 = time.clock();
    for i in range(0,reps):
        results = numpy.dot(rep_circuit_g,results);
    tf = time.clock();
    
    elap_micro = (tf-t0)*pow(10,6);
    results = numpy.multiply(numpy.multiply(results,results),100);
    results = numpy.transpose(results);
    
    return results[0], elap_micro;

#Run the computation in numpy but iteratively, each time with an increasing 
#number of reps (0 to rep_range). At each iteration, run the same computation 
#20 times and average the computation time. Return an array of the average 
#computation times. 
def run_all_numpy_comp(rep_circuit_g, vec, rep_range):
    
    num_runs = 20;
    
    elap_micro_all = numpy.zeros(rep_range);
    for i in range(0,rep_range):
        values = numpy.zeros(num_runs);
        for k in range(0, num_runs):
            results = vec;
            t0 = time.clock();
            for j in range(0, i):
                results = numpy.dot(rep_circuit_g,results);
            tf = time.clock();
            values[k] = (tf-t0)*pow(10,6);
        elap_micro_all[i] = numpy.average(values);
                
    return elap_micro_all;

#Give two vectors, find the average percent error between the two.
def calc_perc_error(theo, exp):
    errors = abs(theo-exp)/theo*100;
    return numpy.average(errors);

#This is called inorder to get a vector of computation times for FPGA. These
#values are estimated and only plotted inorder to compare against numpy 
#computation times. The values are chosen from a few actual measurements 
#of the hardware computation. 
def run_all_fpga_comp(rep_range):
    x = numpy.array(range(1,rep_range));
    elap_micro_all = x*0.24+0.01;
    return elap_micro_all;

#Given the initial state, initial circuit, repetitive circuit, all of which 
#are given in symbols, and the number of 
#reps, run the program: construct the vector and send it to Microblaze / 
#Hardware. Construct the repetitive circuit and send it to Microblaze / 
#Hardware. Wait for hardware to finish running and then start receiving 
#and storing the results. In addition, run the same computation without 
#hardware and instead just in software (numpy-powered) and store the 
#results. Return the results from both hardware comp and python comp, including
#the computation time measurements for both. 
def start_program(ser,state,init_circuit,rep_circuit,num_reps):
    
    #create starting state 
    state_g = create_vector(state);
    
    #create initial circuit
    init_circuit_g = create_circuit(init_circuit);
    
    #multiply starting state w/ initial circuit to get vec & send to Microblaze
    vec = numpy.dot(init_circuit_g, numpy.transpose(state_g));\
    print("Sending vector data... \n");
    send_vals(ser,vec);
    
    #creating repetitive circuit and send to Microblaze
    rep_circuit_g = create_circuit(rep_circuit);
    print("Sending repeating circuit data... \n");
    send_vals(ser,rep_circuit_g);
    
    #send number of repetitions
    send_num_rep(ser,num_reps);
    
    #create a result array to store computation results & comp time measurements
    results = numpy.zeros(32);
    time_meas = numpy.zeros(2);
    
    #wait for results from Microblaze and read/store results + time measurement
    while(True):
        line_rd = ser.readline();
        #print(line_rd);   
        
        if(line_rd[0:7] == b'Results'):
            #print("\n--------------Results---------------\n")
            #read results
            for i in range (0,32):
                line_rd = ser.readline();
                while(line_rd == b''):
                    line_rd = ser.readline();
                hex_data = line_rd[0:4];
                #print(hex_data);
                
                results[i] = hex_to_frac(hex_data);
            
            #read stopwatch data
            line_rd = ser.readline();
            hex_data = line_rd[0:8];
            #print(hex_data);
            time_meas[0] = watch_time(hex_data);
            
            #print("\n---------------END----------------\n")
            
            break;
    
    #do the equivalent numpy computation inorder to compare computation times
    results_np_p, time_meas[1] = run_numpy_comp(rep_circuit_g, vec, num_reps);
    
    #convert results into percentages
    results_p = numpy.multiply(numpy.multiply(results,results),100);
        
    
    return results_p, results_np_p, time_meas;
 
#This is called to plot the results from the computations. 
def plot_all(results_p, results_np_p, time_meas, num_reps):
    
    def autolabel(rects):
        """Attach a text label above each bar in *rects*, displaying its height."""
        for rect in rects:
            width = rect.get_width();
            text = '{}'.format(width) + '%';
            ax.annotate(text,
                        xy=(rect.get_x() + width, rect.get_y()),
                        xytext=(25, 0),  # 3 points vertical offset
                        textcoords="offset points",
                        ha='center', va='bottom', color='#63fff7');
    
    avg_perc_error = calc_perc_error(results_np_p, results_p);
    
    y = numpy.arange(len(state_labels2));  
    width = 0.85  

    #set up colors and bar graph
    plt.style.use('dark_background');
    fig, ax = plt.subplots(figsize=(14,8));
    cmap = mcolors.LinearSegmentedColormap.from_list("", ["yellow", "green"]);
    results_col = results_p/100; #color for each bar
    data = numpy.round(results_p,4);  #rounded value to show
    rects1 = ax.barh(y, data, width, color=cmap(results_col)) #bar plot
    plt.xlim(0,100);
    ax.spines['right'].set_visible(False);
    ax.spines['left'].set_visible(False);
    ax.spines['top'].set_visible(False);
    plt.subplots_adjust(left=0.065, right=0.775);
    plt.show();

    #set up color map
    sm = ScalarMappable(cmap=cmap, norm=plt.Normalize(0,100));
    sm.set_array([]);
    cbar_ax = fig.add_axes([0.065, 0.075, 0.7105, 0.02]);
    cbar = plt.colorbar(sm, orientation='horizontal', cax=cbar_ax, drawedges = False);
    cbar.outline.set_edgecolor('Black');
    cbar.set_label('Percentage (%)');

    #set up titles & labels
    ax.set_title('Output State Result');
    ax.set_ylabel('States');
    ax.set_yticks(y);
    ax.set_xticks([]);
    ax.set_yticklabels(state_labels2);
    
    #set up percentage labels
    autolabel(rects1);
    
    #set up stats
    textstr = '\n'.join((
    'Circuit Repetitions:',
    '%d' % (num_reps, ),
    ' ',
    'FPGA  Comp Time:',
    '%.4f \u03BCs' % (time_meas[0], ),
    ' ',
    'Numpy Comp Time:',
    '%.4f \u03BCs' % (time_meas[1], ),
    ' ',
    'Avg Error:',
    '%.4f %%' % (avg_perc_error, ),
    ));            
    ax.text(1.12, 0.95, textstr, transform=ax.transAxes, fontsize=12,
        verticalalignment='top');    
    plt.show();
    
#This is called to plot a graph that compares the computation time between
#hardware/FPGA & software/Numpy by varying the number of repetitions for 
#the repetitive circuit.
def plot_stats(state,init_circuit,rep_circuit,rep_range):
    
    state_g = create_vector(state);
    init_circuit_g = create_circuit(init_circuit);
    vec = numpy.dot(init_circuit_g, numpy.transpose(state_g));
    rep_circuit_g = create_circuit(rep_circuit);

    elap_micro_all = run_all_fpga_comp(rep_range);
    np_elap_micro_all = run_all_numpy_comp(rep_circuit_g,vec,rep_range);
    
    fig, ax = plt.subplots(figsize=(14,8));
    
    plt.plot(elap_micro_all, "#2dd4e3", label = 'FPGA');
    plt.plot(np_elap_micro_all, "#30fc03", label = 'Numpy');
    plt.legend(loc="upper right");
    
    ax.set_title('FPGA vs Numpy Computation');
    ax.set_xlabel('# Circuit Repetitions');
    ax.set_ylabel('Time (Microsecond)');
    
    plt.show();
    
    
  
    
    
   
    

    
    

    
    
    
    

