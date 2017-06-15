#ifndef _STATISTICS_H
#define _STATISTICS_H

#include <LPC43xx.h> 

#include "tasks.h"

#define NUM_CORES 2

#define MAX_CORES 4

/*-----------------------------------------------------------------------------
									STRUCT 		ENUM    DEFINITIONS
 *----------------------------------------------------------------------------*/

enum task_state {
	task_idle,
	task_ready,
	task_exe,
	task_done
};

enum core_state {
	core_idle,
	core_busy
};

enum _task {
	_t1,
	_t2,
	_t3
};

typedef struct _core_stat {
	uint8_t id;
	uint8_t freq;
	uint8_t inst_pow;
	enum core_state state;
	enum _task tau;
	uint8_t util;
} core_stat;

typedef struct _task_stat {
	uint8_t id;
	uint8_t per;
	uint8_t jobs;
	enum task_state state;
	uint8_t acet;
	uint8_t wcet;
	uint8_t core;
} task_stat;

/*-----------------------------------------------------------------------------
									FUNCTION 		DEFINITIONS
 *----------------------------------------------------------------------------*/

//This function updates the state of a core to busy
void setBusy(uint8_t , enum _task );

//This function updates the state of a core to idle
void setIdle(uint8_t );

//This function updates the state of a task to active
void setActive(uint8_t , enum _task );
 
//This function updates the state of a task to inactive
void setInactive(uint8_t , enum _task );

#endif
