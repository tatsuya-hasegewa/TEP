
declare tep
{
    input datai[16];
    output datao[16];
    output adrs[16];
    func_out memory_write(adrs, datao);
    func_out memory_read(adrs);
    func_out ube, lbe;
    func_in memory_ack;
    func_in int_signal; // 割り込み信号
    func_in start;
    func_out wb;
    func_out hlt;
}

declare inc16
{
    input in[16];
    output out[16];
    func_in do(in);
}

declare cla16
{
    input cin, in1[16], in2[16];
    output out[16], co, of;
    func_in do(cin, in1, in2);
}

declare reg16
{
    input regin[16];
    input portareg[4], portbreg[4], wtreg[4];
    output porta[16], portb[16];
    func_in wt(wtreg, regin);
    func_in ra(portareg);
    func_in rb(portbreg);
}

declare alu16
{
    input a[16], b[16];
    output out[16], co, of, z;

    func_in do_add(a, b);
    func_in do_and(a, b);
    func_in do_bcom(b);
    func_in do_cvi(b);
    func_in do_bor(a, b);
    func_in do_bxor(a, b);
    func_in do_sub(a, b);
    func_in do_neg(b);
    func_in do_lshl(b, a);
    func_in do_rshl(b, a);
    func_in do_rsha(b, a);
    func_in do_mul(a, b);
}
