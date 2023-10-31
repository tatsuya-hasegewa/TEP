
declare sys
{
    input btn[3], RXD, PS2D, PS2C;
    output TXD, VGA_R, VGA_G, VGA_B, VGA_H, VGA_V;
    output led[8];
    output sseg[8], an[4];
    input sw[8];
    input reset;
    input adrs[16];
    output madr[16];
    output ssr0[2];
    output cmode[2];
}
