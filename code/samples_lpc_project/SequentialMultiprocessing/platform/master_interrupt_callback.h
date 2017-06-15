/**********************************************************************
* $Id$		master_interrupt_callback.h			2012-03-16
*//**
* @file		master_interrupt_callback.h
* @brief	LPC43xx interrupt callback function
* @version	1.0
* @date		03. March. 2012
* @author	NXP MCU SW Application Team
*
* Copyright(C) 2012, NXP Semiconductor
* All rights reserved.
*
***********************************************************************
* Software that is described herein is for illustrative purposes only
* which provides customers with programming information regarding the
* products. This software is supplied "AS IS" without any warranties.
* NXP Semiconductors assumes no responsibility or liability for the
* use of the software, conveys no license or title under any patent,
* copyright, or mask work right to the product. NXP Semiconductors
* reserves the right to make changes in the software without
* notification. NXP Semiconductors also make no representation or
* warranty that such application will be suitable for the specified
* use without further testing or modification.
**********************************************************************/
#ifndef __M4_INT_CBACK_H__
#define __M4_INT_CBACK_H__

// external function which is called by the M4 within the interrupt context
void masterInterruptCallback(void);

#endif

