
declare alt_ram4k
{
    input datai[16];
    input adrs[12];
    output datao[16];
    func_in ube(), lbe();
    func_out memory_ack();
    func_in memory_read(adrs);
    func_in memory_write(adrs, datai);
}

#ifdef SYNTHE declare altera_bram4k interface #else declare altera_bram4k #endif
{
    input address[11];
    input byteena[2];
    input clock;
    input data[16];
    input wren;
    output q[16];
}
