#ifndef _TASKS_H
#define _TASKS_H

#include <LPC43xx.h> 

#define NUM_TASKS 5

//Define the ticks variable depending on the core, for task activation
#if CORE_ID==1
	extern volatile uint32_t ticks;
	#define ticks ticks
#endif

#if CORE_ID==2
	extern volatile uint32_t m0_ticks;
	#define ticks m0_ticks
#endif

/*-----------------------------------------------------------------------------
									TASK 		VARIABLES
 *----------------------------------------------------------------------------*/

//empty

/*-----------------------------------------------------------------------------
									TASK 		INITIALIZATION    FUNCTIONS
 *----------------------------------------------------------------------------*/

//Define the task parameters
void task_init(void);

//Save the mapping of task function memory address
void task_mapping(void);

/*-----------------------------------------------------------------------------
									TASK 		ACTIVATION    FUNCTIONS
 *----------------------------------------------------------------------------*/

//Handle job arrivals (based on the ticks variable)
void registerArrivals(void);

//This function calls the sequential dispatch based on the arrival variable
void arrivalHandlerSeq(void);

/*-----------------------------------------------------------------------------
									TASK 		DEFINTION    FUNCTIONS
 *----------------------------------------------------------------------------*/

void task1(void);
void task2(void);
void task3(void);

#endif
