#ifndef DEBUG
#define DEBUG 0
#endif
#ifndef __BCC__
char n2c(short n);
void w2x(short n);
void w2x(short n);
short x2w();
#endif
#if DEBUG
#include <stdio.h>
#define _putchar(w) putchar(w)
#define _getchar() getchar()
#else
volatile unsigned char *flag = (unsigned char *)0xe001;
volatile unsigned char *data = (unsigned char *)0xe000;

void _putchar(w) char w;
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
#endif

char n2c(n)
short n;
{
	static char *tbl = "0123456789ABCDEF";
	return (tbl[n & 0xf]);
}
short c2n(c)
char c;
{
	if (c > 'A')
		c = c & 0x5f;
	return ((c > '@') ? c - 'A' + 10 : c - '0');
}
void w2x(n) short n;
{
	short i;
	char w[4];
	for (i = 0; i < 4; i++)
	{
		w[i] = n2c(n);
		n >>= 4;
	}
	for (i = 3; i >= 0; i--)
		_putchar(w[i]);
}
short x2w()
{
	short i, w, c;
	w = 0;
	for (i = 0; i < 4; i++)
	{
		w <<= 4;
		do
		{
			c = _getchar();
		} while (c < '0' || c > 'f' || c > '9' && c < 'A' || c > 'F' && c < 'a');
		w += c2n(c);
	}
	return w;
}

#if DEBUG
char mem[65536];
#define DEBUG_OFF (long)mem
#else
#define DEBUG_OFF 0
#endif

main()
{
	union
	{
		long i; // 16bit
		short *p;
		void (*f)();
	} x;
	char c;
	short i, j, w;
	char *stmsg = "Hello, TEP-16 Debug Monitor\n";
	while (*stmsg)
	{
		_putchar(stmsg[0]);
		stmsg++;
	}
	while (1)
	{
		_putchar('\n');
		_putchar('-');
		_putchar(' ');
		while ((c = _getchar()) < ' ')
			;
		switch (c)
		{
		case 'e':
		case 'E':
			x.i = x2w() + DEBUG_OFF;
			do
			{
				w2x(x.i - DEBUG_OFF);
				_putchar(':');
				w2x(*x.p);
				_putchar(' ');
				w = x2w();
				*x.p = w;
				x.i += 2;
				_putchar('\n');
			} while ((c = _getchar()) != '.');
			break;
		case 'd':
		case 'D':
			x.i = x2w() + DEBUG_OFF;
			for (i = 0; i < 8; i++)
			{
				w2x(x.i + i * 16 - DEBUG_OFF);
				_putchar(':');
				for (j = 0; j < 8; j++)
				{
					w2x((x.p[i * 8 + j]) & 0xffff);
					_putchar(' ');
				}
				_putchar('\n');
			}
			break;
		case 'g':
		case 'G':
			x.i = x2w() + DEBUG_OFF;
			x.f();
			break;
		}
	}
}
