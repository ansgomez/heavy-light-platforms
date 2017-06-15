#include "m0_mbx_functions.h"

extern volatile uint32_t m0_ticks;

/*-----------------------------------------
	  MAILBOX   VARIABLES  
 *-----------------------------------------*/

#define BUFFERSIZE 100

uint8_t userbuffers1[BUFFERSIZE];
uint8_t userbuffers2[BUFFERSIZE];
uint8_t userbuffers3[BUFFERSIZE];

/*-----------------------------------------
	  MAILBOX   FUNCTIONS
 *-----------------------------------------*/

void mbxSend() {
	xsprintf((char*)userbuffers1, "Hello, world! (%d)", m0_ticks);
	// query if we can send back another task to M4
	if(IPC_queryRemoteMbx(MASTER_MBX_TASKA) == READY) {
		IPC_sendMsg(MASTER_MBX_TASKA, REQUEST_PROCESS_DATA, (msgId_t) 1, (mbxParam_t) &userbuffers1[0]);
	}
}

void mbxPeek() {
	enum _task tau;
	if(mbxFlags[SLAVE_MBX_TASKD] == MSG_PENDING)
	{
		IPC_lockMbx(SLAVE_MBX_TASKD);
		//id = IPC_getMsgId(SLAVE_MBX_TASKD);

		// get the converted string
		if (DATA_RESULT == IPC_getMsgType(SLAVE_MBX_TASKD))
		{
			//paramStringA = (char*) IPC_getMbxParameter(MASTER_MBX_TASKA);
			tau = (enum _task) IPC_getMbxParameter(SLAVE_MBX_TASKD);
			executeSeq(CORE_ID,tau);
			mbxSend();
		}

		IPC_freeMbx(SLAVE_MBX_TASKD);
	}	
}

void mbxRead() {
	while(mbxFlags[SLAVE_MBX_TASKD] != MSG_PENDING);

	IPC_lockMbx(SLAVE_MBX_TASKD);
	//id = IPC_getMsgId(SLAVE_MBX_TASKD);

	//get the converted string
	if (DATA_RESULT == IPC_getMsgType(SLAVE_MBX_TASKD)) {
		//paramStringA = (char*) IPC_getMbxParameter(MASTER_MBX_TASKA);
		dispatchSeq(_t1);
		mbxSend();
	}

	IPC_freeMbx(SLAVE_MBX_TASKD);
}
