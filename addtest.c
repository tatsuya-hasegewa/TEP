volatile unsigned char *flag = (unsigned char *)0xe001;
volatile unsigned char *data = (unsigned char *)0xe000;

void putchar(w) char w;
{
	while ((*flag & 0x40))
		;
	*data = w;
	if (w == '\n')
		putchar('\r');
}

int main(){
    int c=5;
		int a=9;

    c=c+a;

    putchar(c) ;

    return 0;
}
