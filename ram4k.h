#define WIDTH 16
#define DEPTH 16384
#define ADDR_MSB (_int(_log10(_real(DEPTH * (WIDTH / 8))) / _log10(_real(2))) - 1)
#define ADDR_LSB (_int(_log10(_real(WIDTH)) / _log10(_real(2))) - _int(_log10(_real(8)) / _log10(_real(2))))
#define LENGTH (ADDR_MSB - ADDR_LSB + 1)

declare alt_ram4k
{
    input datai[WIDTH];
    input adrs[WIDTH];
    output datao[WIDTH];
    func_in ube(), lbe();
    func_out memory_ack();
    func_in memory_read(adrs);
    func_in memory_write(adrs, datai);
}

#ifdef SYNTHE declare altera_bram4k interface #else declare altera_bram4k #endif
{
    input address[LENGTH];
    input byteena[2];
    input clock;
    input data[WIDTH];
    input wren;
    output q[WIDTH];
}
