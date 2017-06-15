#include "tasks.h"

#include "lcd.h"
#include "runtime.h"
#include "statistics.h"
#include "xprintf.h"

/*-----------------------------------------------------------------------------
									TASK 		VARIABLES
 *----------------------------------------------------------------------------*/

enum _task t_task[NUM_TASKS];
volatile uint32_t t_period_ticks[NUM_TASKS]={0};
volatile uint32_t t_arrivals[NUM_TASKS]={0};
volatile uint32_t t_executions[NUM_TASKS]={0};

//M4 binary - Enum Task mapping variables
void (*m4_tasks[NUM_TASKS])(void);

//M0 binary - Enum Task mapping variables
void (*m0_tasks[NUM_TASKS])(void);

/*-----------------------------------------------------------------------------
									TASK 		INITIALIZATION    FUNCTIONS
 *----------------------------------------------------------------------------*/

//Define the task parameters
void task_init(void) {
	
	//FIRST TASK
	t_period_ticks[0] 	= 5000;
	t_task[0] 					= _t1;
	
	//SECOND TASK
	t_period_ticks[1] 	= 5000;
	t_task[1] 					= _t2;
}

//Save the mapping of task function memory address
void task_mapping(void) {
	#if CORE_ID == 1
	m4_tasks[0] = task1;
	m4_tasks[1] = task2;
	#endif
	
	#if CORE_ID == 2
	m0_tasks[0] = task1;
	m0_tasks[1] = task2;
	#endif
}

/*-----------------------------------------------------------------------------
									TASK 		ACTIVATION    FUNCTIONS
 *----------------------------------------------------------------------------*/

//Handle job arrivals (based on the ticks variable)
void registerArrivals(void) {
	uint8_t i=0;
	
	for(i=0;i<2;i++) {
		if(ticks%t_period_ticks[i] == 0) {
			t_arrivals[i]++;
			printTaskStat(i);
		}
	}
}

//This function calls the sequential dispatch based on the arrival variable
void arrivalHandlerSeq(void) {
	uint8_t i;
	
	for(i=0;i<2;i++) {
		if(t_arrivals[i] > t_executions[i]) {
			dispatchSeq(t_task[i]);
			t_executions[i]++;
			printTaskStat(i);
		}
	}
}

/*-----------------------------------------------------------------------------
									TASK 		DEFINTION    FUNCTIONS
 *----------------------------------------------------------------------------*/

void task1(void) {
	uint32_t i;

	for(i=0;i<20000000;i++);
}

void task2(void) {
	uint32_t i;

	for(i=0;i<20000000;i++);
}

void task3(void) {
	uint32_t i;

	for(i=0;i<20000000;i++);
}
