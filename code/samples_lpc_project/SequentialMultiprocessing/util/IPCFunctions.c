#include "IPCFunctions.h"

#include "LED.h"
#include <platform_init.h>
#include "ipc_mbx.h"

/* definitions */
/* perform a callback when mailbox flag gets signaled - within IRQ - */
void _mbxProcess(mbxId_t mbxNum);

/*-----------------------------------------
	Mailbox variables
 *-----------------------------------------*/

extern msgId_t idA;
extern msgId_t idB;
extern msgId_t idC;

extern mbxParam_t parameterA;
extern mbxParam_t parameterB;
extern mbxParam_t parameterC;

extern uint8_t *c, *paramStringA;
extern uint8_t *c, *paramStringB;
extern uint8_t *c, *paramStringC;

#ifdef IPC_CONFLICT

/* download a processor image to the SLAVE CPU */
void IPC_downloadSlaveImage(uint32_t slaveRomStart, const unsigned char slaveImage[], uint32_t imageSize)
{
  uint32_t i;
	volatile uint8_t *pu8SRAM;

	IPC_haltSlave();

    /* Copy initialized sections into Slave code / constdata area */
	pu8SRAM = (uint8_t *) slaveRomStart;
	for (i = 0; i < imageSize; i++)
	{
		pu8SRAM[i] = slaveImage[i];
	 }

	/* Set Slave shadow pointer to begining of rom (where application is located) */
	SET_SLAVE_SHADOWREG(slaveRomStart);
}


/* take SLAVE processor out of reset */
void IPC_startSlave(void)
{
	volatile uint32_t u32REG, u32Val;
	
	/* Release Slave from reset, first read status */
	/* Notice, this is a read only register !!! */
	u32REG = LPC_RGU->RESET_ACTIVE_STATUS1;
			
	/* If the M0 is being held in reset, release it */
	/* 1 = no reset, 0 = reset */
	while(!(u32REG & (1u << 24)))
	{
		u32Val = (~(u32REG) & (~(1 << 24)));
		LPC_RGU->RESET_CTRL1 = u32Val;
		u32REG = LPC_RGU->RESET_ACTIVE_STATUS1;
	};
}

/* put the SLAVE processor back in reset */
void IPC_haltSlave(void) {

	volatile uint32_t u32REG, u32Val;
	
	/* Check if M0 is reset by reading status */
	u32REG = LPC_RGU->RESET_ACTIVE_STATUS1;
			
	/* If the M0 has reset not asserted, halt it... */
	/* in u32REG, status register, 1 = no reset */
	while ((u32REG & (1u << 24)))
	{
		u32Val = ( (~u32REG) | (1 << 24));
		LPC_RGU->RESET_CTRL1 = u32Val;
		u32REG = LPC_RGU->RESET_ACTIVE_STATUS1;			
	}
}
	
/* interrupt function for the Slave mailbox */ 
/* interrupt from Master on Slave side */
void M0_M4CORE_IRQHandler() {		

	#ifdef MBX_IPC
	mbxId_t i;		
	// quit the interrupt
	MASTER_TXEV_QUIT();

	for(i=(mbxId_t)0; i<NUM_SLAVE_MBX;i++) {
	
		if(PROCESS == IPC_queryLocalMbx(i)) {
			_mbxProcess(i);
			mbxFlags[i] = MSG_PENDING;
		}
	};
	#endif
	
	#ifdef INT_IPC
		#if CORE_ID == 2
			//LPC_CREG->M4TXEVENT = 0;
			LED_On();	
		#endif
	#endif
}


/* interrupt function for the master mailbox */
/* interrupt to master from slave */
void M0CORE_IRQHandler() {
	
	#ifdef MBX_IPC
		mbxId_t i;
		// acknowledge the interrupt
		SLAVE_TXEV_QUIT();
		for(i=(mbxId_t)0;i<NUM_MASTER_MBX;i++) {
			if(PROCESS == IPC_queryLocalMbx(i)) {

				_mbxProcess(i);

				mbxFlags[i] = MSG_PENDING;			
			}
		}
	#endif
	
	#ifdef INT_IPC
		#if CORE_ID == 1
			//LPC_CREG->M0TXEVENT = 0;
			LED_Off();	
		#endif
	#endif
}

#endif
