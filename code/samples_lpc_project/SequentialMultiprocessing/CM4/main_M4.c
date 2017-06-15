/*-----------------------------------------------------------------------------
 * Name:    Blinky.c
 * Purpose: Dual Core LED Flasher Example for MCB4300
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
#include "LED.h"
#include "lpc43xx_cgu.h"
#include "lpc43xx_gpio.h"

#ifndef CORE_ID
#define CORE_ID 1
#endif

#include "lcd.h"
#include "m4_mbx_functions.h"
#include "profiling.h"
#include "runtime.h"
#include "statistics.h"
#include "tasks.h"
#include "xprintf.h"

#define MEM_M0   			0x10080000  //0x10080000

#include "CM0_Image.c"     /* Cortex M0 image reference          */

volatile uint32_t ticks;
uint8_t slaveStarted;

/*-----------------------------------------------------------------------------
  SysTick IRQ Handler 
 *----------------------------------------------------------------------------*/
void SysTick_Handler (void) {
  ticks++;
	
	registerArrivals();
	
	if(ticks >=0xffffff)
		ticks = 0;
}


/*-----------------------------------------------------------------------------
  Load Cortex M0 Application Image
 *----------------------------------------------------------------------------*/
void Load_CM0_Image (uint32_t DestAddr, const uint8_t *Image, uint32_t Sz) {
  uint32_t i;
  uint8_t *dp = (uint8_t *)DestAddr;

  /* Copy application image */
  for (i = 0; i < Sz; i++) {
    dp[i] = Image[i];
  }
  /* Set shadow pointer to beginning of the CM0 application */
  LPC_CREG->M0APPMEMMAP = DestAddr;
}

/*-----------------------------------------------------------------------------
  Main function
 *----------------------------------------------------------------------------*/
int main (void) {
	char aux[50];

	SystemInit();
	CGU_Init();
	lcd_init();
	task_init();
	swim_init();
	task_mapping();
	
  //SystemCoreClockUpdate ();                  /* Update system core clock       */
  SysTick_Config(SystemCoreClock/1000-1);      /* Generate interrupt each 50 ms  */
  LED_Init();                                  /* LED Initialization             */
	NVIC_DisableIRQ (M0CORE_IRQn);               /* Enable IRQ from the M4 Core    */
	NVIC_SetPriority((IRQn_Type)M0CORE_IRQn, 7); /* Set the default priority for the interrupt */
  NVIC_EnableIRQ (M0CORE_IRQn);                /* Enable IRQ from the M4 Core    */

  /* Stop CM0 core */
  LPC_RGU->RESET_CTRL1 = (1 << 24);
	
	IPC_masterInitInterrupt(masterInterruptCallback);
  IPC_initMasterMbx(&Master_CbackTable[0], (Mbx*) MBX_START, (Mbx*) MBX_STOP);

  /* Download CM0 application */
  Load_CM0_Image (MEM_M0, LR0, sizeof (LR0)); 
  
  /* Start CM0 core */
  LPC_RGU->RESET_CTRL1 = 0;

  //Wait for the M0 to signal being ready via a message to the command queue
	while(mbxFlags[MASTER_MBX_CMD] != MSG_PENDING) __WFE();

	if(NOTIFY_SLAVE_STARTED == IPC_getMsgType(MASTER_MBX_CMD)) {
		slaveStarted = 1;   /* just track the M0 is alive */
		/* free our mbx */
		IPC_freeMbx(MASTER_MBX_CMD);
	};
	
	initTimer();
	updateTaskTable();
	
  while (1)	{
		__WFI();
		
		//handle any job arrivals
		arrivalHandlerSeq();

		//print tick counter
		xsprintf(aux, "Ticks:%d",ticks);
		printWin(5,5,aux);
  }
}
