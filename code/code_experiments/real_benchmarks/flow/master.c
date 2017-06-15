/*
 * @brief Multicore blinky example (Master)
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

/** @defgroup PERIPH_M4MASTER_5410X Multicore blinky example (M4 core as master)
 * @ingroup EXAMPLES_CORE_5410X
 * @include "multicore\m4master_blinky\readme.txt"
 */

/**
 * @}
 */

/*****************************************************************************
 * Private types/enumerations/variables
 ****************************************************************************/

/* Select a mode of type 'POWER_MODE_T' for this example: mode available are
   POWER_SLEEP, POWER_DEEP_SLEEP,
   POWER_POWER_DOWN, POWER_DEEP_POWER_DOWN */
#define PDOWNMODE   (POWER_SLEEP)
#define TIME_1s_100MHZ 100000000
#define PERIOD_ms 100
#define F_LC_MAX 100
#define F_LC_MIN 50
#define F_LC_STEP 10
#define ITERATIONS 100
#define ALLOCATION_ALG 2 //PERFORMANCE = 1, ENERGY = 2
/*  if commented -> energy experiment
    if uncommented -> performance experiment */
//#define PERFORMANCE

static MBOX_IDX_T myCoreBox, otherCoreBox;

#ifdef __CODE_RED
extern uint32_t __core_m0slave_START__[];
#define M0_BOOT_STACKADDR &__core_m0slave_START__[0]
#define M0_BOOT_ENTRYADDR &__core_m0slave_START__[1]

#else
/* The M0 slave core's boot code is loaded to execute at address 0x2000.
   These address contain the needed M0 boot entry point and the M0 stack
     pointer that the M4 master core sets up for boot. */
#define M0_BOOT_STACKADDR           0x20000
#define M0_BOOT_ENTRYADDR           0x20004
#endif

/*****************************************************************************
 * Public types/enumerations/variables
 ****************************************************************************/

int master;
int slave;
float PERIOD_s;
float Delta;
float P_hc_active, P_hc_sleep;
float P_lc_active, P_lc_sleep;
float P_per_active, P_per_sleep;
float P_lc_active_platform, P_lc_sleep_platform;
int f_hc;
int f_lc;
volatile unsigned int go_to_sleep_M4;
volatile unsigned int go_to_sleep_M0;
static const float P_lc_active_freq[] = {
	11.2938,
	12.7561,
	14.7504,
	16.5795,
	18.1573,
	20.5898
};


static const float M0_time_ms[] = {
	43.91,
	44.53
};

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
		while(Chip_RIT_GetCounter(LPC_RITIMER) <= PERIOD_s * TIME_1s_100MHZ){}
		while(Chip_RIT_GetCounter(LPC_RITIMER) < rit_timer_stop){}
	}
}

void performance_allocation_policy(void)
{
	master= 2;
	slave = 0;
}

void energy_oriented_policy(void)
{
	float cutoff = (f_hc - f_lc) * 100000 / (f_hc + f_lc) * 0.00001;

	if(Delta >= cutoff)
	{
		float f_cutoff_numerator = (P_lc_active - P_lc_sleep) * Delta + (P_per_active - P_per_sleep) * (1 + Delta) * 0.5;
		float f_cutoff_denominator = (P_hc_active - P_hc_sleep) * Delta + (P_per_active - P_per_sleep) * (1 + Delta) * 0.5;
		float f_cutoff = f_cutoff_numerator * 100000 / f_cutoff_denominator * 0.00001 * f_hc;

		if(f_lc <= f_cutoff)
		{
			master = 2;
			slave = 0;
		}
		else
		{
			master = 1;
			slave = 1;
		}
	}
	else
	{
		float f_cutoff_numerator = P_lc_active - P_lc_sleep + P_per_active - P_per_sleep;
		float f_cutoff_denominator = P_hc_active - P_hc_sleep;
		float f_cutoff = f_cutoff_numerator * 100000 / f_cutoff_denominator * 0.00001 * f_hc;

		if(f_lc <= f_cutoff)
		{
			master = 2;
			slave = 0;
		}
		else
		{
			master = 1;
			slave = 1;
		}
	}

}

long smart_expansion_factor(long slave_time, float master_t)
{
	float t1 = (P_lc_active - P_lc_sleep + P_per_active - P_per_sleep) * 10000 / (P_lc_active_platform - P_lc_sleep_platform + P_per_active - P_per_sleep) * 0.0001 * slave_time;
	float t2 = slave_time;
	float t3 = (P_lc_active - P_lc_sleep)*10000/(P_lc_active_platform - P_lc_sleep_platform)*0.0001*slave_time;
	float master_time = master_t * TIME_1s_100MHZ * 0.001;

	if(master_time <= t1 && master_time <= t2)
	{
		float numerator = P_lc_active - P_lc_sleep + P_per_active - P_per_sleep;
		float denominator = P_lc_active_platform - P_lc_sleep_platform + P_per_active - P_per_sleep;
		slave_time = numerator * 100000 / denominator * 0.00001 * slave_time;
	}
	else if(t1 <= master_time && master_time <= t2)
	{
		float numerator = (P_lc_active - P_lc_sleep) * slave_time  - (P_per_active - P_per_sleep) * (master_time - slave_time);
		float denominator = P_lc_active_platform - P_lc_sleep_platform;
		slave_time = numerator * 100000 / denominator * 0.00001;
	}
	else if(master_time >= t2 && master_time <= t3)
	{
		float numerator = (P_lc_active - P_lc_sleep)*slave_time + (P_per_active - P_per_sleep) * master_time;
		float denominator = P_lc_active_platform - P_lc_sleep_platform + P_per_active - P_per_sleep;
		slave_time = numerator * 100000 / denominator * 0.00001;
	}
	else if(master_time >= t3 && master_time >= t2)
	{
		float numerator = P_lc_active - P_lc_sleep;
		float denominator = P_lc_active_platform - P_lc_sleep_platform;
		slave_time = numerator * 100000 / denominator * 0.00001 * slave_time;
	}

	return slave_time;
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

	if(go_to_sleep_M4 == 1 || go_to_sleep_M0 == 1) {
		//Board_LED_Toggle(0);
	}
}

/**
 * @brief	Handle interrupt from mailbox
 * @return	Nothing
 */
void MAILBOX_IRQHandler(void)
{
	/* Clear this MCU's mailbox */
	Chip_MBOX_ClearValueBits(LPC_MBOX, myCoreBox, 0xFFFFFFFF);
	go_to_sleep_M0 = 1;
}

/**
 * @brief	main routine for blinky example
 * @return	Function should not exit.
 */
int main(void)
{
	CHIP_SYSCON_MAINCLKSRC_T saved_clksrc;
	SystemCoreClockUpdate();
	Board_Init();

#ifdef PERFORMANCE
	Chip_GPIO_SetPinDIR(LPC_GPIO,0,4,true);
	Chip_GPIO_SetPinState(LPC_GPIO, 0, 4, true);
#endif

	uint32_t *jumpAddr, *stackAddr;
	int i;
	float average_time = (M0_time_ms[0] + M0_time_ms[1])*0.5;

	Delta = (M0_time_ms[1] - average_time)* 1000 / average_time * 0.001;
	PERIOD_s = 0.001*PERIOD_ms;
	master = 0;
	slave = 0;

	f_hc = 100;

	P_hc_active = 29.414;
	P_hc_sleep = 1.977;
	P_lc_sleep = 0.989;
	P_per_active = 16.617;
	P_per_sleep = 1.977;
	P_lc_active_platform = 10.963;
	P_lc_sleep_platform = 0.989;

	/* Get the mailbox identifiers to the core this code is running and the
	   other core */
	myCoreBox = MAILBOX_CM4;
	otherCoreBox = MAILBOX_CM0PLUS;

	/* Initialize mailbox with initial mutex free (master core only) */
	Chip_MBOX_Init(LPC_MBOX);
	mutexGive();

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

	/* Boot M0 core, using reset vector and stack pointer from the CM0+
	image in FLASH. */
	stackAddr = (uint32_t *) (*(uint32_t *) M0_BOOT_STACKADDR);
	jumpAddr = (uint32_t *) (*(uint32_t *) M0_BOOT_ENTRYADDR);
	Chip_CPU_CM0Boot(jumpAddr, stackAddr);

	for(f_lc = F_LC_MIN; f_lc <= F_LC_MAX; f_lc+=F_LC_STEP)
	{
		P_lc_active = P_lc_active_freq[(int) (f_lc - 50) / 10] +
				(P_lc_active_freq[(int) (f_lc - 50) / 10 + 1] - P_lc_active_freq[(int) (f_lc - 50) / 10]) *
				10000 / 10 * ((int) f_lc % 10) * 0.0001;
		float expansion_factor = f_hc * 1000 / f_lc * 0.001;
		go_to_sleep_M4 = 0;
		go_to_sleep_M0 = 0;

		if(ALLOCATION_ALG == 1)
			performance_allocation_policy();
		else if(ALLOCATION_ALG == 2)
			energy_oriented_policy();


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

			/* Enable mailbox interrupt */
			NVIC_EnableIRQ(MAILBOX_IRQn);

			/* Enable wakeup for RIT */
			Chip_SYSCON_EnableWakeup(SYSCON_STARTER_RIT);
			Chip_SYSCON_EnableWakeup(SYSCON_STARTER_MAILBOX);

			for(i=0; i<ITERATIONS+1; i++)
			{

				if(master == 1)
				{
					long slave_t =  M0_time_ms[slave] * TIME_1s_100MHZ * expansion_factor*0.001;
#ifndef PERFORMANCE
					slave_t = smart_expansion_factor(slave_t, M0_time_ms[0]);
#endif
					if(i==0)
					{
						slave_t = slave_t*0.1;
					}
					mutexTake();
					Chip_MBOX_SetValue(LPC_MBOX, otherCoreBox, slave_t);
					mutexGive();
					compute_flow();
				}
				else if(master == 2)
				{
					long slave_t =  M0_time_ms[slave] * TIME_1s_100MHZ * expansion_factor*0.001;
#ifndef PERFORMANCE
					slave_t = smart_expansion_factor(slave_t, M0_time_ms[1]);
#endif
					if(i==0)
					{
						slave_t = slave_t*0.1;
					}
					mutexTake();
					Chip_MBOX_SetValue(LPC_MBOX, otherCoreBox, slave_t);
					mutexGive();
					compute_flow2();
				}


				go_to_sleep_M4 = 1;

	#ifdef PERFORMANCE
				Chip_GPIO_SetPinState(LPC_GPIO, 0, 4, false);
	#endif
				while(go_to_sleep_M0 == 0) {
					__WFI();
				}

	#ifdef PERFORMANCE
				Chip_GPIO_SetPinState(LPC_GPIO, 0, 4, true);
	#endif
				uint32_t rit_timer_stop = Chip_RIT_GetCounter(LPC_RITIMER);
				float time_left = PERIOD_s - rit_timer_stop/(TIME_1s_100MHZ * 0.001) * 0.001;
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

				/* On wakeup, restore PLL power if needed */
				if (saved_clksrc == SYSCON_MAINCLKSRC_PLLOUT) {
					Chip_SYSCON_PowerUp(SYSCON_PDRUNCFG_PD_SYS_PLL);

					/* Wait for PLL lock */
					while (!Chip_Clock_IsSystemPLLLocked()) {}

					Chip_POWER_SetVoltage(POWER_LOW_POWER_MODE, Chip_Clock_GetSystemPLLOutClockRate(false));

					/* Use PLL for system clock */
					Chip_Clock_SetMainClockSource(SYSCON_MAINCLKSRC_PLLOUT);
				}


				go_to_sleep_M0 = 0;
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



			}
		}
	return 0;
}
