#ifndef __LCD_LIB_H
#define __LCD_LIB_H

#include "lpc43xx_lcd.h"
#include "lpc43xx_gpio.h"
#include "lpc43xx_scu.h"
#include "lpc43xx_libcfg.h"
#include "lpc43xx_cgu.h"
#include "lpc43xx_i2c.h"

#include "lpc_swim.h"

#include "statistics.h"

/*-----------------------------------------------------------------------------
									CONSTANT 		DEFINITIONS
 *----------------------------------------------------------------------------*/

#ifndef CORE_ID
#define CORE_ID 1
#endif

enum WIN_POS {
	///// HALF SCREEN DEFINITIONS
	W_TOP,
	W_RIGHT,
	W_BOTTOM,
	W_LEFT,
	///// QUARTER SCREEN DEFINITIONS
	W_TOPLEFT,
	W_TOPRIGHT,
	W_BOTTOMRIGHT,
	W_BOTTOMLEFT
};

#define FONT  font_x6x13 // font_rom8x16 font_rom8x16 font_winfreesys14x16
#define WIN_NUM 3

#define LCD_WIDTH			480
#define LCD_HEIGHT		272
#define LOGO_WIDTH		110
#define LOGO_HEIGHT		42

#define SDRAM_BASE      0x28F00000 ///0x1AA00000 //0x28000000 
#define SDRAM_SIZE      0x2000000  	//32MB

#define FRAMEBUFFER_ADDR        0x28000000
#define FRAMEBUFFER_ADDR2       0x3000000

/*-----------------------------------------------------------------------------
									LCD 		FUNCTIONS
 *----------------------------------------------------------------------------*/

//Standard print functions
void showTicks(void);
void printWin(uint16_t x, uint16_t y, char *str);

//Specific stat update print functions
void updateTaskTable(void);
void printTaskStat(uint8_t);
void printCoreStat(void);

/*-----------------------------------------------------------------------------
									INIT 		FUNCTIONS
 *----------------------------------------------------------------------------*/

//basic initialization
int lcd_init (void);
void swim_init(void);
void setTitle(SWIM_WINDOW_T*, uint8_t);

//initialize window in a specific position
void initTopLeft(SWIM_WINDOW_T*, uint8_t);
void initTopRight(SWIM_WINDOW_T*, uint8_t);
void initBottom(SWIM_WINDOW_T*, uint8_t);
void initQuadrant(SWIM_WINDOW_T*, uint8_t, enum WIN_POS);


#endif
