//Description: Main program that is uploaded onto the Microblaze.

#include "xbasic_types.h"
#include "xparameters.h"
#include "xil_printf.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <xuartlite.h>
#include "xuartlite_l.h"
#include "qr_header.h"

using namespace std;

int main()
{
	//set number of computations
	int num_vec_ele = 32;
	int num_stg_ele = 1024;
	unsigned char data0;
	unsigned char data1;
	short vec[num_vec_ele];
	short stage[num_stg_ele];
	unsigned char num_reps;

	//receive vec data from python
	for(int i=0; i<num_vec_ele; i++)
	{
		data0 = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
		data1 = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
		vec[i] = short(data0 << 8 | data1);
	}

	//receive stage data from python
	for(int i=0; i<num_stg_ele; i++)
	{
		data0 = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
		data1 = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);
		stage[i] = short(data0 << 8 | data1);
	}

	//receive number of reps
	num_reps = XUartLite_RecvByte(XPAR_AXI_UARTLITE_0_BASEADDR);

	//configure hardware with data & initiate computation
	config_vec(&vec[0]);
	config_bram(&stage[0]);
	initiate_comp((int)num_reps);

	//signal to python that results are ready.
	xil_printf("Results \n");

	//sleep(1);

	//initiate result read from hardware followed by print to python.
	initiate_read();

	//read stop watch followed by print time to python.
	Xuint32 stop_watch;
	stop_watch = *(baseaddr_p+8);
	xil_printf("%8x \n", stop_watch);


	xil_printf("End of test \n\n\r");

}


