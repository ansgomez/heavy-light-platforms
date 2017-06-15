#ifndef _IPC_FUNCTIONS
#define _IPC_FUNCTIONS

#include <LPC43xx.h>  

#define MBX_START			0x10000000
#define MBX_STOP			0x10001000	

#ifdef IPC_CONFLICT
/* download a processor image to the SLAVE CPU */
void IPC_downloadSlaveImage(uint32_t , const unsigned char[] , uint32_t );

/* take SLAVE processor out of reset */
void IPC_startSlave(void);

/* put the SLAVE processor back in reset */
void IPC_haltSlave(void);

/* interrupt function for the Slave mailbox */ 
/* interrupt from Master on Slave side */
//void M0_M4CORE_IRQHandler();

/* interrupt function for the master mailbox */
/* interrupt to master from slave */
//void M0CORE_IRQHandler();

#endif

#endif

