#include <iostream>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include "Vmain___024root.h"
#include "Vmain.h"
#include <unistd.h>
#include <getopt.h>

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
        resetCore();
    }
    ~Test(void)
    {
        if (tfp->isOpen())
        {
            tfp->close();
        }
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
        if (tfp->isOpen())
        {
            tfp->dump(m_clock_count);
        }
    };
    void step(void)
    {
        tick();
        eval();
        dump();
    };
    void parseLogOpts(int argc, char **argv)
    {
        int opt, longindex;
        char *Darg = NULL, *aarg = NULL, *symfile = NULL;
        struct option longopts[] = {
            {"dump", no_argument, NULL, 'd'},
            {0, 0, 0, 0},
        };
        while ((opt = getopt_long(argc, argv, "d", longopts, &longindex)) != -1)
        {
            switch (opt)
            {
            case 'd':
                tfp->open("tep.vcd");
                break;
            default:
                exit(1);
                break;
            }
        }
    }
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
    test->parseLogOpts(argc, argv);
    while (Verilated::gotFinish())
    {
        test->step();
    }
    delete test;
}