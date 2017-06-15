#ifndef _M0_MBX_FUNCTIONS
#define _M0_MBX_FUNCTIONS

#include <LPC43xx.h> 

#include "IPCFunctions.h"
#include "ipc_int.h"
#include "ipc_mbx.h"

#include "runtime.h"
#include "statistics.h"
#include "xprintf.h"

/*-----------------------------------------------------------------------------
      MAILBOX    IPC    FUNCTIONS
 *----------------------------------------------------------------------------*/

void mbxSend(void);

void mbxRead(void);

void mbxPeek(void);

#endif
