#define TIMER_INTREQ 0x0080
#define TIMER_LOAD 0x0008
#define TIMER_READ 0x0004
#define TIMER_INTEN 0x0002
#define TIMER_CNTEN 0x0001

volatile int *timer_base = (int *)0xf000;
volatile unsigned char *flag = (unsigned char *)0xe001;
volatile unsigned char *data = (unsigned char *)0xe000;
