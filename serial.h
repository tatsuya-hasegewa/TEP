declare serial_in {
 input rxd;
 output data[8];
 func_in port_read;
 func_out rxready;
 func_in baud;
}
declare serial_out {
 output txd;
 input data[8];
 func_out txbusy;
 func_in baud;
 func_in port_write(data);
}
declare serial_clkfix {
 func_out baud;
}
