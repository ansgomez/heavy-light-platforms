#ifndef _M4_MBX_FUNCTIONS
#define _M4_MBX_FUNCTIONS

#include "IPCFunctions.h"
#include "ipc_int.h"
#include "ipc_mbx.h"

#include "runtime.h"
#include "statistics.h"

/*-----------------------------------------------------------------------------
      MAILBOX    IPC    FUNCTIONS
 *----------------------------------------------------------------------------*/

//This function send a task to the M0 slave core
void mbxSend(enum _task);

//This is blocking function that waits for a response from the M0 slave core
void mbxRead(void);

//This is non-blocking function that checks for a response from the M0 slave core
void mbxPeek(void);

#endif
