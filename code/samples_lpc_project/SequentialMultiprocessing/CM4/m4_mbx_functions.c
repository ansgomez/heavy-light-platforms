#include "m4_mbx_functions.h"

#include <LPC43xx.h>

#include "lcd.h"
#include "statistics.h"

/*-----------------------------------------
	  MAILBOX   VARIABLES  
 *-----------------------------------------*/

msgId_t idA;
msgId_t idB;
msgId_t idC;

mbxParam_t parameterA = 0;
mbxParam_t parameterB = 0;
mbxParam_t parameterC = 0;

uint8_t *c, *paramStringA;
uint8_t *c, *paramStringB;
uint8_t *c, *paramStringC;

uint8_t msg_id=0;
enum _task last_tau;

/*-----------------------------------------
	  MAILBOX   FUNCTIONS
 *-----------------------------------------*/

//This function send a task to the M0 slave core
void mbxSend(enum _task tau) {
	//send task tau to slave core (m0)
	if(IPC_queryRemoteMbx(SLAVE_MBX_TASKD) == READY) {
		IPC_sendMsg(SLAVE_MBX_TASKD, DATA_RESULT, (msgId_t) msg_id++, (mbxParam_t) tau);
		last_tau = tau;
	}					
	setActive(2,tau);
}

//This is blocking function that waits for a response from the M0 slave core
void mbxRead(void) {
	while(mbxFlags[MASTER_MBX_TASKA] != MSG_PENDING);
	setInactive(2,last_tau);
	
	IPC_lockMbx(MASTER_MBX_TASKA);
	
	printTaskStat(last_tau);
	/* check the query we got */
	if(REQUEST_PROCESS_DATA == IPC_getMsgType(MASTER_MBX_TASKA)) {
		//JOB WAS EXECUTED!
	}
	
	IPC_freeMbx(MASTER_MBX_TASKA);
}

//This is non-blocking function that checks for a response from the M0 slave core
void mbxPeek(void) {
	if(mbxFlags[MASTER_MBX_TASKA] == MSG_PENDING) {
		IPC_lockMbx(MASTER_MBX_TASKA);

		/* check the query we got */
		if(REQUEST_PROCESS_DATA == IPC_getMsgType(MASTER_MBX_TASKA)) {
			//idA = IPC_getMsgId(MASTER_MBX_TASKA);				
			//paramStringA = (char*) IPC_getMbxParameter(MASTER_MBX_TASKA);;
			//printWin(5,30,paramStringA);
			//dispatchSeq(_t1);
			//mbxSend(_t1);
		}
		
		IPC_freeMbx(MASTER_MBX_TASKA);
	}	
}
