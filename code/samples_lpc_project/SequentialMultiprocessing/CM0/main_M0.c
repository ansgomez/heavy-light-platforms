/*-----------------------------------------------------------------------------
 * Name:    CM0 Blinky.c
 * Purpose: Cortex M0 Core LED Flasher for MCB4300
 * Note(s):
 *-----------------------------------------------------------------------------
 * This file is part of the uVision/ARM development tools.
 * This software may only be used under the terms of a valid, current,
 * end user licence from KEIL for a compatible version of KEIL software
 * development tools. Nothing else gives you the right to use this software.
 *
 * This software is supplied "AS IS" without warranties of any kind.
 *
 * Copyright (c) 2004-2012 Keil - An ARM Company. All rights reserved.
 *----------------------------------------------------------------------------*/

#include <LPC43xx.h>

#define CORE_ID 2

#include "LED.h"
#include "IPCFunctions.h"
#include "ipc_int.h"
#include "ipc_mbx.h"

#include "lcd.h"
#include "m0_mbx_functions.h"
#include "profiling.h"
#include "runtime.h"
#include "statistics.h"
#include "tasks.h"
#include "xprintf.h"

volatile uint32_t m0_ticks; 

/*-----------------------------------------------------------------------------
  Repetitive Interrupt Timer IRQ Handler @ 50ms
 *----------------------------------------------------------------------------*/
void M0_RIT_OR_WWDT_IRQHandler (void) {

  LPC_RITIMER->CTRL |= 1;
    
  m0_ticks++;
	if(m0_ticks >= 0xffffff)
		m0_ticks = 0;
}

#define CLOCK_M4 96000000

/*-----------------------------------------------------------------------------
  Repetitive Interrupt Timer Init
 *----------------------------------------------------------------------------*/
void RIT_Init (void) {
  LPC_RITIMER->COMPVAL = CLOCK_M4/1000-1; /* Set compare value (50ms)           */
  LPC_RITIMER->COUNTER = 0;
  LPC_RITIMER->CTRL    = (1 << 3) |
                         (1 << 2) |
                         (1 << 1) ;

  NVIC_EnableIRQ (M0_RITIMER_OR_WWDT_IRQn);                           
}

/*-----------------------------------------------------------------------------
  Main function
 *----------------------------------------------------------------------------*/

int main (void) {
  char aux[50];
	  
  RIT_Init();                           /* Repetitive Interrupt Timer Init    */
  LED_Init();                           /* LED Initialization                 */
	task_mapping();
	//WARNING: LCD should have been initialized by M4!
	//lcd_init();
	
	IPC_slaveInitInterrupt(slaveInterruptCallback);
	
	//Initialize local mailbox system 
	IPC_initSlaveMbx(&Slave_CbackTable[0], (Mbx*) MBX_START, (Mbx*) MBX_STOP);
	//Signal back to M4 we are now ready
	IPC_sendMsg(MASTER_MBX_CMD, NOTIFY_SLAVE_STARTED, (msgId_t) 0, (mbxParam_t) 1);
	
	swim_init();
	
	initTimer();
	
  while (1)
	{
		__WFI();
		
		//peek at mailbox, if a job is received, it will be executed
		mbxPeek();
		
		//print tick counter
		xsprintf(aux, "Ticks:%d",m0_ticks);
		printWin(5,5,aux);
  }
}
