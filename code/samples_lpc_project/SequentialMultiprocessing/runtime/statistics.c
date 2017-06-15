#include "statistics.h"

#include "lcd.h"
#include "profiling.h"
#include "xprintf.h"

/*-----------------------------------------------------------------------------
									ARRAY 		VARIABLES
 *----------------------------------------------------------------------------*/

//variables relating to a task's runtime
uint32_t start_time[NUM_TASKS]={0};
uint32_t end_time[NUM_TASKS]={0};
uint32_t runtime[NUM_TASKS]={0};

//variables that group all statistics related to cores and tasks
core_stat core_stats[MAX_CORES];
task_stat task_stats[NUM_TASKS];
 
 
 /*-----------------------------------------------------------------------------
									FUNCTION 		DEFINITIONS
 *----------------------------------------------------------------------------*/
 
//This function updates the state of a core to busy
void setBusy(uint8_t core, enum _task tau) {
	core_stats[core].state = core_busy;
	printCoreStat();
}	

//This function updates the state of a core to idle
void setIdle(uint8_t core) {
	core_stats[core].state = core_idle;
	printCoreStat();
}	

//This function updates the state of a task to active
void setActive(uint8_t core, enum _task tau) {
	setBusy(core,tau);
	 
	task_stats[tau].core = core;
	task_stats[tau].state = task_exe;
	 
	start_time[tau] = getTimer();
}
 
//This function updates the state of a task to inactive
void setInactive(uint8_t core, enum _task tau) {
	end_time[tau] = getTimer();	
	runtime[tau] = end_time[tau] - start_time[tau];
	
	setIdle(core);
	
	task_stats[tau].core = core;
	task_stats[tau].state = task_done;
}
