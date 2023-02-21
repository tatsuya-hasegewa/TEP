#include <iostream>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include "Vmain___024root.h"
#include "Vmain.h"

uint64_t main_time = 0;

double sc_time_stamp()
{
    return main_time;
}

class Test
{
private:
    Vmain *top;
    VerilatedVcdC *tfp;
    int reset = 0;
    int p_reset = 0;

public:
    unsigned int m_clock_count = 0;
    Test()
    {
        top = new Vmain;
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
        tfp->open("tep.vcd");
        resetCore();
    }
    ~Test(void)
    {
        tfp->close();
        top->final();
    };
    unsigned long long tick(void)
    {
        top->m_clock = !top->m_clock;
        return m_clock_count++;
    };
    void eval(void)
    {
        top->eval();
        main_time++;
    };
    void dump(void)
    {
        tfp->dump(m_clock_count);
    };
    void step(void)
    {
        tick();
        eval();
        dump();
    };
    void resetCore(void)
    {
        top->p_reset = 0;
        /* assert reset signal for one clock cycle */
        {
            top->p_reset = 1;
            eval();
            dump();

            tick();
            eval();
            dump();
        }
        /* negate reset signal */
        {
            top->p_reset = 0;
            tick();
            eval();
            dump();
        }
    };
};

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    Test *test;
    test = new Test;
    while (Verilated::gotFinish())
    {
        test->step();
    }
    delete test;
}