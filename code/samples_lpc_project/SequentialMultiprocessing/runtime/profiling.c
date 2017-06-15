#include "profiling.h"

#include <LPC43xx.h> 

void initTimer(void) {
	
  #if PROFILING_TIMER == 2
	LPC_TIMER2->TCR = 2; // Stop and reset timer
	LPC_TIMER2->PR  = 0; // increment TC every PCLK
	LPC_TIMER2->MCR = 0; // Do not stop, reset or interrupt on any Match
	LPC_TIMER2->TCR = 1; // Start timer
  #endif
	
  #if PROFILING_TIMER == 1
	LPC_TIMER1->TCR = 2; // Stop and reset timer
	LPC_TIMER1->PR  = 0; // increment TC every PCLK
	LPC_TIMER1->MCR = 0; // Do not stop, reset or interrupt on any Match
	LPC_TIMER1->TCR = 1; // Start timer
	#endif
	
  #if PROFILING_TIMER == 0
	LPC_TIMER0->TCR = 2; // Stop and reset timer
	LPC_TIMER0->PR  = 0; // increment TC every PCLK
	LPC_TIMER0->MCR = 0; // Do not stop, reset or interrupt on any Match
	LPC_TIMER0->TCR = 1; // Start timer
  #endif
}

unsigned getTimer(void) {
  #if PROFILING_TIMER == 2
  return LPC_TIMER2->TC;
	#endif
	
  #if PROFILING_TIMER == 1
  return LPC_TIMER1->TC;
	#endif
	
  #if PROFILING_TIMER == 0
  return LPC_TIMER0->TC;
  #endif
}
