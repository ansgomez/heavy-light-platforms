#ifndef _RUNTIME_H
#define _RUNTIME_H

#include <LPC43xx.h> 

#include "statistics.h"

/*-----------------------------------------------------------------------------
									RUNTIME 		VARIABLES
 *----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
									DISPATCH 		FUNCTIONS
 *----------------------------------------------------------------------------*/

//This is a non-blocking function to dispatch (parallel) tasks according to
//predefined allocation policy
void dispatch(enum _task);

//This is a blocking function to dispatch a sequential task according to a
//predefined allocation policy
void dispatchSeq(enum _task);

//This is a non-blocking function to dispatch (parallel) tasks in a specific core
void dispatchHere(unsigned int, enum _task);

//This is a blocking function to dispatch a sequential task in a specific core
void dispatchHereSeq(unsigned int, enum _task);

/*-----------------------------------------------------------------------------
									ALLOCATE 		FUNCTIONS
 *----------------------------------------------------------------------------*/

//This allocation policy alternates between all of the available cores (similar
//to round robin). Returns the core id (1 to NUM_CORES)
uint8_t allocateAlternate(enum _task);

/*-----------------------------------------------------------------------------
									EXECUTE 		FUNCTIONS
 *----------------------------------------------------------------------------*/

//This is a blocking function to execute (sequential) tasks in a specific core
//by using the mbx IPC to communicate with the target core
void executeSeq(unsigned int, enum _task);

//This is a non-blocking function to execute (parallel) tasks in a specific core
//by using the mbx IPC to communicate with the target core
void execute(unsigned int, enum _task);

/*-----------------------------------------------------------------------------
									SCHEDULER 		FUNCTIONS
 *----------------------------------------------------------------------------*/
//This is a non-blocking function to perform maintance on the task management
//data structures and to dispatch any newly unblocked tasks
void scheduler(void);

#endif
