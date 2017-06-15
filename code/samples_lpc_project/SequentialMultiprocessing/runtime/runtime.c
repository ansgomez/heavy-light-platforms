#include "runtime.h"

#include <LPC43xx.h>

#include "lcd.h"
#include "m4_mbx_functions.h"
#include "profiling.h"
#include "statistics.h"
#include "xprintf.h"

//M4 binary - Enum Task mapping variables
extern void (*m4_tasks[NUM_TASKS])(void);

//M0 binary - Enum Task mapping variables
extern void (*m0_tasks[NUM_TASKS])(void);

extern uint32_t runtime[NUM_TASKS];

/*-----------------------------------------------------------------------------
									RUNTIME 		VARIABLES
 *----------------------------------------------------------------------------*/

//auxiliary variable for the alternating allocator
uint8_t alloc_core=0;

/*-----------------------------------------------------------------------------
									DISPATCH 		FUNCTIONS
 *----------------------------------------------------------------------------*/

//This is a non-blocking function to dispatch (parallel) tasks according to
//predefined allocation policy
void dispatch(enum _task tau);

//This is a blocking function to dispatch a sequential task according to a
//predefined allocation policy
void dispatchSeq(enum _task tau) {
	//call the allocator
	uint8_t core = allocateAlternate(tau);
	
	//execute task on allocated core
	executeSeq(core, tau);
}

//This is a non-blocking function to dispatch (parallel) tasks in a specific core
void dispatchHere(unsigned int, enum _task);

//This is a blocking function to dispatch a sequential task in a specific core
void dispatchHereSeq(unsigned int core, enum _task tau) {
	//directly execute task on predefined core
	executeSeq(core,tau);
}

/*-----------------------------------------------------------------------------
									ALLOCATE 		FUNCTIONS
 *----------------------------------------------------------------------------*/
 
//This allocation policy alternates between all of the available cores (similar
//to round robin)
uint8_t allocateAlternate(enum _task tau) {
	 alloc_core = (alloc_core+1)%NUM_CORES;
	 return alloc_core;
}
 
/*-----------------------------------------------------------------------------
									EXECUTE 		FUNCTIONS
 *----------------------------------------------------------------------------*/

//This is a blocking function to execute (sequential) tasks in a specific core
//by using the mbx IPC to communicate with the target core
void executeSeq(unsigned int core, enum _task tau) {
	char aux[50];
	
	//if M4, load the M4 pointers to tasks
	#if CORE_ID == 1
	void (*task)(void) = m4_tasks[tau];
	#endif
	
	//if M0, load the M0 pointers to tasks
	#if CORE_ID == 2
	void (*task)(void) = m0_tasks[tau];
	#endif
	
	//if task is allocated to this core, simple call the task
	if(core == CORE_ID) {
		printWin(5,90,"                          "); //clear last runtime
		
		setActive(core,tau);
		//execute task by calling the function pointer
		(*task)();
		setInactive(core,tau);
		
		xsprintf(aux,"Last Exec. Time: %d", runtime[tau]); //show last runtime
		printWin(5,90,aux);
	}
	//otherwise send it to the other core via mbx
	else {
		mbxSend(tau);
		mbxRead();
	}
}

//This is a non-blocking function to execute (parallel) tasks in a specific core
//by using the mbx IPC to communicate with the target core
void execute(unsigned int core, enum _task tau);

/*-----------------------------------------------------------------------------
									SCHEDULER 		FUNCTIONS
 *----------------------------------------------------------------------------*/

//This is a non-blocking function to perform maintance on the task management
//data structures and to dispatch any newly unblocked tasks
void scheduler(void);
