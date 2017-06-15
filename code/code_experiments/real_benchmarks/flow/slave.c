/*
 * @brief Multicore blinky example (Master or slave
 *
 * @note
 * Copyright(C) NXP Semiconductors, 2014
 * All rights reserved.
 *
 * @par
 * Software that is described herein is for illustrative purposes only
 * which provides customers with programming information regarding the
 * LPC products.  This software is supplied "AS IS" without any warranties of
 * any kind, and NXP Semiconductors and its licensor disclaim any and
 * all warranties, express or implied, including all implied warranties of
 * merchantability, fitness for a particular purpose and non-infringement of
 * intellectual property rights.  NXP Semiconductors assumes no responsibility
 * or liability for the use of the software, conveys no license or rights under any
 * patent, copyright, mask work right, or any other intellectual property rights in
 * or to any products. NXP Semiconductors reserves the right to make changes
 * in the software without notification. NXP Semiconductors also makes no
 * representation or warranty that such application will be suitable for the
 * specified use without further testing or modification.
 *
 * @par
 * Permission to use, copy, modify, and distribute this software and its
 * documentation is hereby granted, under NXP Semiconductors' and its
 * licensor's relevant copyrights in the software, without fee, provided that it
 * is used in conjunction with NXP Semiconductors microcontrollers.  This
 * copyright, permission, and disclaimer notice must appear in all copies of
 * this code.
 */


#include "board.h"
#include "flow.h"
#include "openshoe.h"

/** @defgroup PERIPH_M0SLAVE_5410X Multicore blinky example (M0 as slave)
 * @ingroup EXAMPLES_CORE_5410X
 * @include "multicore\m0slave_blinky\readme.txt"
 */

/**
 * @}
 */

#define TIME_1s_100MHZ 100000000
#define PERIOD_ms 500
#define PERFORMANCE


/*****************************************************************************
 * Private types/enumerations/variables
 ****************************************************************************/

static MBOX_IDX_T myCoreBox, otherCoreBox;

/*****************************************************************************
 * Public types/enumerations/variables
 ****************************************************************************/

/* Clock rate on the CLKIN pin */
const uint32_t ExtClockIn = 12000000;
float PERIOD_s;
extern uint32_t __Vectors;

/*****************************************************************************
 * Private functions
 ****************************************************************************/

/* Hardware mutex take function */
static void mutexTake(void)
{
	/* Wait forever until we can get the mutex */
	while (Chip_MBOX_GetMutex(LPC_MBOX) == 0) {}
}

/* Hardware mutex put function */
static void mutexGive(void)
{
	Chip_MBOX_SetMutex(LPC_MBOX);
}

void task(float time)
{
	uint32_t rit_timer_stop = Chip_RIT_GetCounter(LPC_RITIMER) + time;
	if(rit_timer_stop <= PERIOD_s * TIME_1s_100MHZ)
	{
		while(Chip_RIT_GetCounter(LPC_RITIMER) < rit_timer_stop){}
	}
	else
	{
		rit_timer_stop = rit_timer_stop - PERIOD_s * TIME_1s_100MHZ;
		int bill;
		while(Chip_RIT_GetCounter(LPC_RITIMER) > rit_timer_stop){}
		int bill1;
		while(Chip_RIT_GetCounter(LPC_RITIMER) < rit_timer_stop){}
	}
}
/*****************************************************************************
 * Public functions
 ****************************************************************************/

/**
 * @brief	Handle interrupt from mailbox
 * @return	Nothing
 */
void MAILBOX_IRQHandler(void)
{
#ifdef PERFORMANCE
	Chip_GPIO_SetPinState(LPC_GPIO, 0, 22, true);
#endif

	mutexTake();
	uint32_t slave_time = Chip_MBOX_GetValue(LPC_MBOX, myCoreBox);
	mutexGive();

	task(slave_time);

	/* Clear this MCU's mailbox */
	Chip_MBOX_ClearValueBits(LPC_MBOX, myCoreBox, 0xFFFFFFFF);

	/* Signal master code about the change */
	Chip_MBOX_SetValue(LPC_MBOX, otherCoreBox, 1);

#ifdef PERFORMANCE
	Chip_GPIO_SetPinState(LPC_GPIO, 0, 22, false);
#endif
}

/**
 * @brief	main routine for blinky example
 * @return	Function should not exit.
 */
int main(void)
{
	SystemCoreClockUpdate();
	PERIOD_s = PERIOD_ms * 0.001;
#ifdef PERFORMANCE
	Chip_GPIO_SetPinDIR(LPC_GPIO,0,22,true);
#endif
	/* Get the mailbox identifiers to the core this code is running and the
	   other core */
	myCoreBox = MAILBOX_CM0PLUS;
	otherCoreBox = MAILBOX_CM4;

	/* M4 core initializes the mailbox */
	/* ROM will setup VTOR to point to the M0 vector table in FLASH
	   prior to booting the M0 image. */

	/* Enable mailbox interrupt */
	NVIC_EnableIRQ(MAILBOX_IRQn);


	while (1) {

		/* Put chip to sleep via WFI instruction */
		__WFI();

	}

	return 0;
}
