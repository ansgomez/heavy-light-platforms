#include "lcd.h"

#include "lpc_rom8x16.h" 
#include "lpc_swim_font.h"
#include "lpc_swim.h"
#include "lpc_winfreesystem14x16.h"
#include "lpc_x6x13.h"

#include "tasks.h"
#include "statistics.h"
#include "xprintf.h"

extern volatile uint32_t t_period_ticks[NUM_TASKS];
extern volatile uint32_t t_arrivals[NUM_TASKS];
extern volatile uint32_t t_executions[NUM_TASKS];

extern core_stat core_stats[MAX_CORES];
extern task_stat task_stats[NUM_TASKS];

extern uint32_t runtime[NUM_TASKS];

/*-----------------------------------------------------------------------------
									VARIABLE 		DEFINITIONS
 *----------------------------------------------------------------------------*/
 
uint32_t msec;
int oldballx,oldbally,ballx,bally,balldx,balldy,aux;

SWIM_WINDOW_T win[WIN_NUM];

extern void SDRAM_Init (void);

/* pointer to frame buffer */
volatile uint32_t *framebuffer = (uint32_t *)FRAMEBUFFER_ADDR;

/* LCD configured struct */
const LCD_CFG_Type Sharp = {
	LCD_WIDTH,
	LCD_HEIGHT,
	{5,40},
	{8,8},
	10,
	5,
	1,
	LCD_SIGNAL_ACTIVE_LOW,
	LCD_SIGNAL_ACTIVE_LOW,
	LCD_CLK_RISING,
	LCD_SIGNAL_ACTIVE_HIGH,
	10,
	LCD_BPP24,
	LCD_TFT,
	LCD_COLOR_FORMAT_RGB,
	FALSE
};

/*-----------------------------------------------------------------------------
									FUNCTION 		DEFINITIONS
 *----------------------------------------------------------------------------*/

void showTicks(void) {
	char aux_str[50];
	
	xsprintf(aux_str, "c%u: Tick #%u", CORE_ID, ticks);
	swim_set_xy(&win[CORE_ID], 5, 0);
	swim_put_text(&win[CORE_ID], aux_str);
}

void move_ball(void) {
	uint8_t y_margin = 60;
	uint8_t margins = 15;
	
	ballx += balldx;
	if(ballx >= win[CORE_ID].xvsize-margins)
		balldx*=-1,ballx+=balldx;
	if(ballx < margins)
		balldx*=-1,ballx+=balldx;

	bally += balldy;
	if(bally >= win[CORE_ID].yvsize-margins)
		balldy*=-1,bally+=balldy;
	if(bally < y_margin )
		balldy*=-1,bally+=balldy;

	swim_set_pen_color(&win[CORE_ID], BLACK);
	swim_set_fill_color(&win[CORE_ID], BLACK);
	swim_put_diamond(&win[CORE_ID], oldballx, oldbally, 7, 7);
	swim_set_pen_color(&win[CORE_ID], WHITE);
	swim_set_fill_color(&win[CORE_ID], BLACK);
	swim_put_diamond(&win[CORE_ID], ballx, bally, 7, 7);

	oldballx = ballx;
	oldbally = bally;	
}

void printWin(uint16_t x, uint16_t y, char *str) {
	swim_set_xy(&win[CORE_ID], x, y);	
	swim_put_text(&win[CORE_ID], str);	
}

void printTaskStat(uint8_t id) {
	SWIM_WINDOW_T *win2 = win;
	uint8_t y = (id+1)*20;
	char aux[100];
	
	xsprintf(aux,"Task id=%1d p=%5d   arrivals=%4d   execs=%4d   exec. time(cc)=%1d", id+1, t_period_ticks[id], t_arrivals[id], t_executions[id], runtime[id]);
	swim_set_xy(win2, 5, y);
	swim_put_text(win2, aux);
}

void updateTaskTable(void) {
	uint8_t i = 0;
	
	for(i=0;i<2;i++) {
		printTaskStat(i);
	}
}

void printCoreStat() {
	char aux_str[50], state[10], msg_str[30];
	
	if(core_stats[CORE_ID].state == core_idle) {
		xsprintf(state,"idle");
		xsprintf(msg_str,"                         ");
	}
	else {
		xsprintf(state,"busy");
		xsprintf(msg_str,"Core is executing a Task!");
	}
	
	//Core State
	swim_set_xy(&win[CORE_ID], 5, 20);
	xsprintf(aux_str,"util: x%%  temp: xC  state: %s", state);
	swim_put_text(&win[CORE_ID], aux_str);
	
	//Message
	swim_set_xy(&win[CORE_ID], 20, 60);
	
	swim_put_text(&win[CORE_ID], msg_str);	
}

void setTitle(SWIM_WINDOW_T *win, uint8_t id) {
	char title_str[30];
  
  if(id > 0) {
		xsprintf(title_str,"Core %u Statistics", id);
    /* Add a title bar */
    swim_set_title(win, title_str, BLACK);
    printCoreStat();
  }
	else {
		xsprintf(title_str,"Task Statistics");
    /* Add a title bar */
    swim_set_title(win, title_str, BLACK);
		updateTaskTable();
  }

  swim_set_xy(win, 5, 5);
}

/*-----------------------------------------------------------------------------
									INIT 		FUNCTIONS
 *----------------------------------------------------------------------------*/

void swim_init() {
  oldballx = ballx = 50;
  oldbally = bally = 90;
  balldx = balldy = 1;  
	
	#if CORE_ID == 1
	initQuadrant(&win[1], 1, W_TOPLEFT);
	initQuadrant(&win[0], 0, W_BOTTOM); //init tasks
	#endif
	
	#if CORE_ID == 2
	initQuadrant(&win[2], 2, W_TOPRIGHT);
	#endif
}

void initQuadrant(SWIM_WINDOW_T *win, uint8_t id, enum WIN_POS pos) {
  
  COLOR_T *fblog;
	      
  /* Set LCD frame buffer address */
  fblog = (COLOR_T *)FRAMEBUFFER_ADDR;
  
  switch(pos) {
    case W_TOP: 
        swim_window_open(win, LCD_WIDTH, LCD_HEIGHT, fblog,0, 0, (LCD_WIDTH - 1),(LCD_HEIGHT/2 - 1), 1, WHITE, BLACK, BLACK);
        break;
    case W_BOTTOM:
        swim_window_open(win, LCD_WIDTH, LCD_HEIGHT, fblog,0,(LCD_HEIGHT/2 - 1),(LCD_WIDTH - 1),(LCD_HEIGHT - 1), 1, WHITE, BLACK, BLACK);
        break;
    case W_LEFT:
        swim_window_open(win, LCD_WIDTH, LCD_HEIGHT, fblog,0, 0, (LCD_WIDTH/2 - 1), (LCD_HEIGHT/2 - 1),1, WHITE, BLACK, BLACK);
        break;
    case W_RIGHT:
        swim_window_open(win, LCD_WIDTH, LCD_HEIGHT, fblog,(LCD_WIDTH/2 - 1), 0,(LCD_WIDTH - 1), (LCD_HEIGHT - 1),1, WHITE, BLACK, BLACK);
        break;
    case W_TOPLEFT:
        swim_window_open(win, LCD_WIDTH, LCD_HEIGHT, fblog,0, 0, (LCD_WIDTH/2 - 1), (LCD_HEIGHT/2 - 1),1, WHITE, BLACK, BLACK);
        break;
    case W_TOPRIGHT:
        swim_window_open(win, LCD_WIDTH, LCD_HEIGHT, fblog,(LCD_WIDTH/2 - 1), 0,(LCD_WIDTH - 1), (LCD_HEIGHT/2 - 1),1, WHITE, BLACK, BLACK);
        break;
    case W_BOTTOMRIGHT:
        swim_window_open(win, LCD_WIDTH, LCD_HEIGHT, fblog,(LCD_WIDTH/2 - 1), 0, (LCD_WIDTH - 1), (LCD_HEIGHT/2 - 1),1, WHITE, BLACK, BLACK);
        break;
    case W_BOTTOMLEFT:
        swim_window_open(win, LCD_WIDTH, LCD_HEIGHT, fblog,(LCD_WIDTH/2 - 1), (LCD_HEIGHT/2 - 1),(LCD_WIDTH - 1), (LCD_HEIGHT - 1),1, WHITE, BLACK, BLACK);
        break;
  }
  
  setTitle(win, id);
  /* select the font to use */
  swim_set_font(win, (FONT_T *)&FONT );
  /* set the pen color to use */
  swim_set_pen_color(win, WHITE);	
}

/*-----------------------------------------------------------------------------
									LCD 		INIT
 *----------------------------------------------------------------------------*/
uint32_t tempx, tempy;

int lcd_init (void) { 
	uint32_t i;
	
	CGU_Init(); 
	CGU_SetDIV(CGU_CLKSRC_IDIVE, 3);	 //was 15 //optional
	CGU_EntityConnect(CGU_CLKSRC_PLL1, CGU_CLKSRC_IDIVE); //optional
	CGU_EntityConnect(CGU_CLKSRC_IDIVE,CGU_BASE_LCD); //optional
	SDRAM_Init();

	/*pin set up for LCD */
	//scu_pinmux(0x07, 7, MD_PUP, FUNC3); 	/* LCD_PWR @ P7.7 */

	scu_pinmux(0x0c, 0, MD_PUP, FUNC4);		/* LCD_DCLK @ P4.7 */
	scu_pinmux(0x04, 5, MD_PUP, FUNC2);		/* LCD_FP @ P4.5 */
	scu_pinmux(0x04, 6, MD_PUP, FUNC2); 	/* LCD_ENAB_M @ P4.6 */
	scu_pinmux(0x07, 6, MD_PUP, FUNC3);		/* LCD_LP @ P7.6 */
	scu_pinmux(0x04, 1, MD_PUP, FUNC2);		/* LCD_VD_0 @ P4.1 */
	scu_pinmux(0x04, 4, MD_PUP, FUNC2);		/* LCD_VD_1 @ P4.4 */
	scu_pinmux(0x04, 3, MD_PUP, FUNC2);		/* LCD_VD_2 @ P4.3 */
	scu_pinmux(0x04, 2, MD_PUP, FUNC2);		/* LCD_VD_3 @ P4.2 */
	scu_pinmux(0x08, 7, MD_PUP, FUNC3);		/* LCD_VD_4 @ P8.7 */
	scu_pinmux(0x08, 6, MD_PUP, FUNC3);		/* LCD_VD_5 @ P8.6 */
	scu_pinmux(0x08, 5, MD_PUP, FUNC3);		/* LCD_VD_6 @ P8.5 */
	scu_pinmux(0x08, 4, MD_PUP, FUNC3);		/* LCD_VD_7 @ P8.4 */
	
	scu_pinmux(0x07, 5, MD_PUP, FUNC3);		/* LCD_VD_8 @ P7.5 */
	scu_pinmux(0x04, 8, MD_PUP, FUNC2);		/* LCD_VD_9 @ P4.8 */
	
	scu_pinmux(0x04, 10, MD_PUP, FUNC2);	/* LCD_VD_10 @ P4.10 */
	scu_pinmux(0x04, 9, MD_PUP, FUNC2); 	/* LCD_VD_11 @ P4.9 */
	scu_pinmux(0x08, 3, MD_PUP, FUNC3); 	/* LCD_VD_12 @ P8.3 */
	scu_pinmux(0x0B, 6, MD_PUP, FUNC2); 	/* LCD_VD_13 @ PB.6 */
	scu_pinmux(0x0B, 5, MD_PUP, FUNC2); 	/* LCD_VD_14 @ PB.5 */
	scu_pinmux(0x0B, 4, MD_PUP, FUNC2); 	/* LCD_VD_15 @ PB.4 */
	
	scu_pinmux(0x07, 4, MD_PUP, FUNC3);		/* LCD_VD_16 @ P7.4 */
	scu_pinmux(0x07, 3, MD_PUP, FUNC3);		/* LCD_VD_17 @ P7.3 */
	
	scu_pinmux(0x07, 2, MD_PUP, FUNC3); 	/* LCD_VD_18 @ P7.2 */
	scu_pinmux(0x07, 1, MD_PUP, FUNC3); 	/* LCD_VD_19 @ P7.1 */
	scu_pinmux(0x0B, 3, MD_PUP, FUNC2); 	/* LCD_VD_20 @ PB.3 */
	scu_pinmux(0x0B, 2, MD_PUP, FUNC2); 	/* LCD_VD_21 @ PB.2 */
	scu_pinmux(0x0B, 1, MD_PUP, FUNC2); 	/* LCD_VD_22 @ PB.1 */
	scu_pinmux(0x0B, 0, MD_PUP, FUNC2); 	/* LCD_VD_23 @ PB.0 */
	
	scu_pinmux(0x07, 7, MD_PUP, FUNC0);		/* LCD_PWR @ P7.7 */
	LPC_GPIO_PORT->DIR[3] |= (1 << 15);
	LPC_GPIO_PORT->CLR[3] = (1<<15);
	  
	scu_pinmux(0x07, 0, MD_PUP, FUNC0);		/* LCD_LE @ P7.0 */
	GPIO_SetDir(3,1<<8, 1);	/*LCDLE*/

	scu_pinmux(0x06, 2, MD_PUP, FUNC0);   /*LCD_DISP*/
	LPC_GPIO_PORT->DIR[3] |= (1 << 1);
	LPC_GPIO_PORT->SET[3] = (1<<1);
	
	GPIO_ClearValue(3, 1<<8);
	
	LPC_SCU->SFSPE_7   =  4;              /* GPIO7[7]     LED(D6)                     */
    LPC_GPIO_PORT->DIR[7] |= (1<<7);
	LPC_GPIO_PORT->CLR[7] = (1<<7);

	
	scu_pinmux(0x0A, 3, MD_PUP, FUNC0);
	LPC_GPIO_PORT->DIR[4] |= (1 << 10);		//(1 << 10);		/*LCD_BL*/
		
	for(i=0;i<1000000;i++);
		
	LPC_RGU->RESET_CTRL0 = (1UL << 16);

	LCD_Init(LPC_LCD, (LCD_CFG_Type*)&Sharp); 
	LCD_SetFrameBuffer(LPC_LCD, (void*)framebuffer);
	LCD_Power(LPC_LCD, ENABLE);

	/* Enable Backlight */
	LPC_GPIO_PORT->SET[4]  = (1 << 10); //(1 << 10);

	// M4Frequency is automatically set when SetClock(BASE_M4_CLK... was called.
	//SysTick_Config(CGU_GetPCLKFrequency(CGU_PERIPHERAL_M4CORE)/1000); // Generate interrupt @ 1000 Hz

	return 1;
}

#ifdef  DEBUG
void check_failed(uint8_t *file, uint32_t line)
{
	/* User can add his own implementation to report the file name and line number,
	 ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

	/* Infinite loop */
	while(1);
}
#endif

/**
 * @}
 */

