/*
 * @brief Blinky example using SysTick and interrupt
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

/** @defgroup PERIPH_BLINKY_5410X Simple blinky example
 * @ingroup EXAMPLES_PERIPH_5410X
 * @include "periph\blinky\readme.txt"
 */

/**
 * @}
 */

/*****************************************************************************
 * Private types/enumerations/variables
 ****************************************************************************/

#define TICKRATE_HZ (10)	/* 10 ticks per second */
/* Select a mode of type 'POWER_MODE_T' for this example: mode available are
   POWER_SLEEP, POWER_DEEP_SLEEP,
   POWER_POWER_DOWN, POWER_DEEP_POWER_DOWN */
#define PDOWNMODE   (POWER_SLEEP)
#define TIME_1s_100MHZ 100000000
#define PERIOD_ms 100
#define UTIL_MAX_PER_CENT 100
#define UTIL_MIN_PER_CENT 10
#define UTIL_STEP_PER_CENT 10
#define ITERATIONS 10
/*  if commented -> energy experiment
    if uncommented -> performance experiment */
//#define PERFORMANCE

/*****************************************************************************
 * Public types/enumerations/variables
 ****************************************************************************/
volatile unsigned int go_to_sleep_M4;
float single_core_workload;
float P_hc_active, P_hc_sleep;
float P_lc_active, P_lc_sleep;
float P_per_active, P_per_sleep;
float PERIOD_s;

/*****************************************************************************
 * Private functions
 ****************************************************************************/

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
		while(Chip_RIT_GetCounter(LPC_RITIMER) <= PERIOD_s * TIME_1s_100MHZ){}
		while(Chip_RIT_GetCounter(LPC_RITIMER) < rit_timer_stop){}
	}
}

void smart_expansion_factor(void)
{
	float numerator = (P_hc_active - P_hc_sleep)*single_core_workload + (P_per_active - P_per_sleep)*single_core_workload - P_lc_sleep*PERIOD_s;
	float denominator = P_hc_active - P_hc_sleep + P_per_active - P_per_sleep;
	single_core_workload = numerator * 100000 / denominator * 0.00001;
}

/*****************************************************************************
 * Public functions
 ****************************************************************************/

/**
 * @brief	Handle interrupt from SysTick timer
 * @return	Nothing
 */
void RTC_IRQHandler(void)
{
	uint32_t rtcStatus;

	/* Get RTC status register */
	rtcStatus = Chip_RTC_GetStatus(LPC_RTC);

	/* Clear only latched RTC status */
	Chip_RTC_ClearStatus(LPC_RTC, (rtcStatus & (RTC_CTRL_WAKE1KHZ | RTC_CTRL_ALARM1HZ)));
}

/**
 * @brief	main routine for blinky example
 * @return	Function should not exit.
 */
int main(void)
{
	float utilization;
	int util_per_cent;
	int i;

	SystemCoreClockUpdate();
	Board_Init();

#ifdef PERFORMANCE
	Chip_GPIO_SetPinDIR(LPC_GPIO,0,4,true);
	Chip_GPIO_SetPinState(LPC_GPIO, 0, 4, true);
#endif

	PERIOD_s = PERIOD_ms * 0.001;
	P_hc_active = 22.061;
	P_hc_sleep = 1.977;
	P_lc_active = 10.963;
	P_lc_sleep = 1.385;
	P_per_active = 16.617;
	P_per_sleep = 1.977;

	CHIP_SYSCON_MAINCLKSRC_T saved_clksrc;

	/* Switch main system clock to IRC and power down PLL */
	saved_clksrc = Chip_Clock_GetMainClockSource();

	/* Turn on the RTC 32K Oscillator */
	Chip_SYSCON_PowerUp(SYSCON_PDRUNCFG_PD_32K_OSC);

	/* Enable the RTC oscillator, oscillator rate can be determined by
	   calling Chip_Clock_GetRTCOscRate()	*/
	Chip_Clock_EnableRTCOsc();

	/* Initialize RTC driver (enables RTC clocking) */
	Chip_RTC_Init(LPC_RTC);

	/* Enable RTC as a peripheral wakeup event */
	Chip_SYSCON_EnableWakeup(SYSCON_STARTER_RTC);

	/* RTC reset */
	Chip_RTC_Reset(LPC_RTC);

	/* Start RTC at a count of 0 when RTC is disabled. If the RTC is enabled, you
	   need to disable it before setting the initial RTC count. */
	Chip_RTC_Disable(LPC_RTC);
	Chip_RTC_SetCount(LPC_RTC, 0);

	/* Enable RTC and high resolution timer - this can be done in a single
	   call with Chip_RTC_EnableOptions(LPC_RTC, (RTC_CTRL_RTC1KHZ_EN | RTC_CTRL_RTC_EN)); */
	Chip_RTC_Enable1KHZ(LPC_RTC);
	Chip_RTC_Enable(LPC_RTC);

	/* Clear latched RTC interrupt statuses */
	Chip_RTC_ClearStatus(LPC_RTC, (RTC_CTRL_OFD | RTC_CTRL_ALARM1HZ | RTC_CTRL_WAKE1KHZ));

	/* Enable RTC interrupt */
	NVIC_EnableIRQ(RTC_IRQn);


	/* Enable RTC alarm interrupt */
	Chip_RTC_EnableWakeup(LPC_RTC, (RTC_CTRL_ALARMDPD_EN | RTC_CTRL_WAKEDPD_EN));

	for(util_per_cent = UTIL_MIN_PER_CENT; util_per_cent <= UTIL_MAX_PER_CENT; util_per_cent+=UTIL_STEP_PER_CENT)
	{

		utilization = util_per_cent * 0.01;
		single_core_workload = utilization * PERIOD_s;
#ifndef PERFORMANCE
		smart_expansion_factor();
#endif
		go_to_sleep_M4 = 0;

		/**** Setup RITimer ****/
		/* Initialize RI Timer */
		Chip_RIT_Init(LPC_RITIMER);

		/* Setup wakeup period to 5s */
		Chip_RIT_SetTimerInterval(LPC_RITIMER, (PERIOD_s * 1000));

		/* Enable RI Timer and clear on compare match or ....
		   use Chip_RIT_EnableCTRL(LPC_RITIMER, RIT_CTRL_ENCLR | RIT_CTRL_TEN);
		   to save space. */
		Chip_RIT_Enable(LPC_RITIMER);
		Chip_RIT_CompClearEnable(LPC_RITIMER);

		/* Enable RI Timer */
		NVIC_EnableIRQ(RIT_IRQn);

		/* Enable wakeup for RIT */
		Chip_SYSCON_EnableWakeup(SYSCON_STARTER_RIT);

		for(i=0; i<ITERATIONS+1; i++)
		{

			task(single_core_workload*TIME_1s_100MHZ);
			go_to_sleep_M4 = 1;

			uint32_t rit_timer_stop = Chip_RIT_GetCounter(LPC_RITIMER);

			float time_left = PERIOD_s - rit_timer_stop/100000*0.001;
			Chip_RTC_SetWake(LPC_RTC, time_left*1000);

			/* Disable PLL, if previously enabled, prior to sleep */
			if (saved_clksrc == SYSCON_MAINCLKSRC_PLLOUT) {
				Chip_Clock_SetMainClockSource(SYSCON_MAINCLKSRC_IRC);
				Chip_SYSCON_PowerDown(SYSCON_PDRUNCFG_PD_SYS_PLL);
			}

#ifdef PERFORMANCE
	Chip_GPIO_SetPinState(LPC_GPIO, 0, 4, false);
#endif

			/* Lower system voltages to current lock (likely IRC) */
			Chip_POWER_SetVoltage(POWER_LOW_POWER_MODE, Chip_Clock_GetMainClockRate());

			/* Go to sleep leaving SRAM powered during sleep. Use lower
				voltage during sleep. */
			Chip_POWER_EnterPowerMode(PDOWNMODE, (SYSCON_PDRUNCFG_PD_SRAM0A | SYSCON_PDRUNCFG_PD_SRAM0B | SYSCON_PDRUNCFG_PD_32K_OSC));

#ifdef PERFORMANCE
	Chip_GPIO_SetPinState(LPC_GPIO, 0, 4, true);
#endif
			go_to_sleep_M4 = 0;

			/* On wakeup, restore PLL power if needed */
			if (saved_clksrc == SYSCON_MAINCLKSRC_PLLOUT) {
				Chip_SYSCON_PowerUp(SYSCON_PDRUNCFG_PD_SYS_PLL);

				/* Wait for PLL lock */
				while (!Chip_Clock_IsSystemPLLLocked()) {}

				Chip_POWER_SetVoltage(POWER_LOW_POWER_MODE, Chip_Clock_GetSystemPLLOutClockRate(false));

				/* Use PLL for system clock */
				Chip_Clock_SetMainClockSource(SYSCON_MAINCLKSRC_PLLOUT);
			}


			/**** Setup RITimer ****/
			/* Initialize RI Timer */
			Chip_RIT_Init(LPC_RITIMER);

			/* Setup wakeup period to 5s */
			Chip_RIT_SetTimerInterval(LPC_RITIMER, (PERIOD_s * 1000));

			/* Enable RI Timer and clear on compare match or ....
			   use Chip_RIT_EnableCTRL(LPC_RITIMER, RIT_CTRL_ENCLR | RIT_CTRL_TEN);
			   to save space. */
			Chip_RIT_Enable(LPC_RITIMER);
			Chip_RIT_CompClearEnable(LPC_RITIMER);

			/* Enable wakeup for RIT */
			Chip_SYSCON_EnableWakeup(SYSCON_STARTER_RIT);
		}
	}
	return 0;
}
