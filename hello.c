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

main()
{
	char *stmsg = "Hello, TEP-16 Debug Monitor\n";
	while (*stmsg)
	{
		_putchar(stmsg[0]);
		stmsg++;
	}
	return;
}
