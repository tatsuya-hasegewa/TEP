#include "timerTest.h"

void _putchar(char w)
{
    while ((*flag & 0x40))
        ;
    *data = w;
    if (w == '\n')
        _putchar('\r');
}

unsigned char _getchar()
{
    unsigned char tmp;
    while (!(*flag & 0x80))
        ;
    tmp = *data;
    _putchar(tmp);
    return tmp;
}

void trap()
{
    char *notify = "interrupted!\n";
    *(timer_base + 2) = *(timer_base + 2) & ~TIMER_INTREQ;
    while (*notify)
    {
        _putchar(notify[0]);
        notify++;
    }
}

main()
{
    char *str = "Timer test\nInterval: 0x00040000 clock\n";
    while (*str)
    {
        _putchar(str[0]);
        str++;
    }
    *(timer_base + 1) = 0x0004;
    *(timer_base) = 0x0000;
    *(timer_base + 2) = *(timer_base + 2) | TIMER_LOAD | TIMER_INTEN | TIMER_CNTEN;
    while (1)
        ;
    return 0;
}
