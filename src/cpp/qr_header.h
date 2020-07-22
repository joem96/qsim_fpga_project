//Description: Helper file that contains all the functions for main.cpp.

#ifndef SRC_QR_HEADER_H_
#define SRC_QR_HEADER_H_

//some constants--------------------------------------------------------------------------------------------------
Xuint32 *baseaddr_p = (Xuint32 *)XPAR_HW_ACCELERATOR_0_S00_AXI_BASEADDR;
const Xuint32 MASK_0 = 0x0000FFFF;
const Xuint32 MASK_1 = 0xFFFF0000;

//for debug-------------------------------------------------------------------------------------------------------
int x[] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
int z[] = {13, 14, 15, 16};
short a = 0x0028;
short b = 0xFE15;
short v[] = {a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b, a, b};

//print elements in an array given pointer to the first element.
void print_array(short *array, int size)
{
	for(int i=0; i<size; i++)
	{
		xil_printf("#%d: 0x%8x \n\r", i+1, *(array+i));
	}
}

//space allocation for computations-------------------------------------------------------------------------------
short first[16];
short second[16];
short third[256];

//interface w/ hardware-------------------------------------------------------------------------------------------
//configure hardware's vector by sending elements in an array.
void config_vec(short *array)
{
	// Write to activate vec config
	*(baseaddr_p+1) = 1;
	// Write to send vec config data
	for(int i=0; i<32/2; i++)
	{
		int hex_combine = (16*16*16*16)*(*(array+2*i+1)) + *(array+2*i);
		*(baseaddr_p+2) = hex_combine;
	}
}

//activate bram config and then write bram data to hardware.
void config_bram(short *array)
{

	// Write to activate bram config.
	*(baseaddr_p+3) = 1;
	// Write to send bram config data.
	for(int i=0; i<1024/2; i++)
	{
		int hex_combine = (16*16*16*16)*(*(array+2*i+1)) + *(array+2*i);
		*(baseaddr_p+4) = hex_combine;
	}
	*(baseaddr_p+3) = 0;
}

//write the # of comps and start computation.
void initiate_comp(int num_comp)
{
	// Write to configure number of computations.
	*(baseaddr_p+9) = num_comp;
	// Write to start computation
	*(baseaddr_p+10) = 1;
	sleep(1);
	*(baseaddr_p+10) = 0;
}

//read results from hardware and then print to python.
void initiate_read()
{
	//Read the comp result
	Xuint32 data;
	int data0;
	int data1;
	for(int i=0; i<32/2; i++)
	{
		data = *(baseaddr_p+11);
		data0 = (MASK_0 & data);
		data1 = ((MASK_1 & data) >> 16);
		xil_printf("%4x \n", data0);
		xil_printf("%4x \n", data1);
	}
}


//UNUSED QUANTUM CONSTANTS / FUNCTIONS FOR ALTERNATIVE DESIGN-------------------------------------------------------------------------------------------------
//quantum gates definition.
short s0[2] = {0x4000, 0};

short I[4] = {0x4000, 0, 0, 0x4000};

short X[4] = {0, 0x4000, 0x4000, 0};

short Z[4] = {0x4000, 0, 0, (short)0xC000};

short H[4] = {0x2D41, 0x2D41, 0x2D41, (short)0xD2BF};

//convert symbol to actual pointer of the gate / state.
short *symb_to_gate(char symb)
{
	switch(symb)
	{
		case 'S':
			return &s0[0];
		case 'I':
			return &I[0];
		case 'H':
			return &H[0];
		case 'X':
			return &X[0];
		default:
			return &I[0];
	}
}

//multiplication for inputs represented in quantum decimal forms.
Xint16 mult_q(Xint16 input1, Xint16 input2)
{
	Xint32 input1_32 = (Xint32)input1;
	Xint32 input2_32 = (Xint32)input2;

	Xint32 output_32 = (input1_32)*(input2_32);

	Xint32 sign_bit = (output_32 & 0x80000000) >> 4*4;
	output_32 = output_32 >> (3*4+2);
	output_32 = output_32 | sign_bit;

	return (Xint16)output_32;
}

//Kronecker product for quantum decimal matrices.
void kron_prod_q(short *c, short *a, short *b, int Ra, int Ca, int Rb, int Cb)
{
	int size_a = Ra*Ca;
	int size_b = Rb*Cb;

	for(int Pa=0; Pa<size_a; Pa++)
	{
		for(int Pb=0; Pb<size_b; Pb++)
		{
			int Pc = (Rb*(Ca*Cb))*(Pa/Ca)+(Cb)*(Pa%Ca)+(Ca*Cb)*(Pb/Cb)+(Pb%Cb);

			*(c+Pc) = mult_q((*(a+Pa)),(*(b+Pb)));
		}
	}
}

//create one big state vector given all the individual qubit states (5 in total).
void create_state(short *stage, short *q0, short *q1, short *q2, short *q3, short *q4)
{
	short first[4];
	short *first_p = &first[0];
	kron_prod_q(first_p, q0, q1, 2, 1, 2, 1);

	short second[4];
	short *second_p = &second[0];
	kron_prod_q(second_p, q2, q3, 2, 1, 2, 1);

	short third[32];
	short *third_p = &third[0];
	kron_prod_q(third_p, first_p, second_p, 4, 1, 4, 1);

	kron_prod_q(stage, third_p, q4, 16, 1, 2, 1);
}

//determine if stage is a special case given the symbols.
bool is_special_stage(char symb0, char symb1, char symb2, char symb3, char symb4)
{
	return (symb0 == 'Z' && symb1 == 'C' && symb2 == 'C' && symb3 == 'C' && symb4 == 'C');
}

//create one big matrix given all the individual quantum gates (5 in total).
void create_stage(short *stage, short *gate0, short *gate1, short *gate2, short *gate3, short *gate4)
{
	//short first[16];
	short *first_p = &first[0];
	kron_prod_q(first_p, gate0, gate1, 2, 2, 2, 2);

	//short second[16];
	short *second_p = &second[0];
	kron_prod_q(second_p, gate2, gate3, 2, 2, 2, 2);

	//short third[256];
	short *third_p = &third[0];
	kron_prod_q(third_p, first_p, second_p, 4, 4, 4, 4);

	kron_prod_q(stage, third_p, gate4, 16, 16, 2, 2);
}

//same as create_stage but also does additional processing given the symbols.
void create_special_stage(short *stage, char symb0, char symb1, char symb2, char symb3, char symb4)
{
	if (symb0 == 'Z' && symb1 == 'C' && symb2 == 'C' && symb3 == 'C' && symb4 == 'C')
	{
		create_stage(stage, &I[0], &I[0], &I[0], &I[0], &I[0]);
		*(stage+1023) = 0xC000;
	}
	else
	{
		create_stage(stage, &I[0], &I[0], &I[0], &I[0], &I[0]);
	}
}

//builds a whole stage given the individual symbols.
void build_stage(short *stage, char symb0, char symb1, char symb2, char symb3, char symb4)
{
	if (is_special_stage(symb0, symb1, symb2, symb3, symb4))
		create_special_stage(stage, symb0, symb1, symb2, symb3, symb4);
	else
	{
		create_stage(stage, symb_to_gate(symb0), symb_to_gate(symb1), symb_to_gate(symb2), symb_to_gate(symb3), symb_to_gate(symb4));
	}
}
//Receive state/vec data from python and build the state (have the given pointer point to it too).
void receive_build_state(short *vec)
{
	char state[5];
	for(int i=0; i<5; i++)
	{
		state[i] = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
	}
	create_stage(vec, symb_to_gate(state[0]), symb_to_gate(state[1]), symb_to_gate(state[2]), symb_to_gate(state[3]), symb_to_gate(state[4]));
}


#endif /* SRC_QR_HEADER_H_ */
