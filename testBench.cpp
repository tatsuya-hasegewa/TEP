#include <iostream>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include "Vmain___024root.h"
#include "Vmain.h"
#include <unistd.h>
#include <getopt.h>

char *Iinst[] = {"CNST", "LD1", "LD2", "ST1", "ST2", "JUMP", "CALL", "JEQ", "JGEI", "JGEU", "JGTI", "JGTU", "JLEI", "JLEU", "JLTI", "JLTU", "JNE"};
char *Rinst[] = {"MUL", "CVI2", "ADD", "SUB", "NEG", "BAND", "BOR", "BXOR", "BCOM", "DINT", "EINT", "RINT"};
char *RSinst[] = {"LSHL", "RSHA", "RSHL", "HLT"};

double sc_time_stamp()
{
    return 0;
}

unsigned int bitTest(unsigned int x, int bit_position)
{
    // テスト対象のビット位置を 1 にセットしたマスクを作成する
    unsigned int mask = 1 << bit_position;

    // x とマスクを AND 演算することで、テスト対象のビット値を取得する
    unsigned int bit_value = x & mask;

    // テスト対象のビット値が 0 でなければ、ビットがセットされていることになる
    if (bit_value != 0)
    {
        return 1; // ビットがセットされている場合は 1 を返す
    }
    else
    {
        return 0; // ビットがセットされていない場合は 0 を返す
    }
}

unsigned int bitExtract(unsigned int x, int msb, int lsb)
{
    // 計算に使用するマスクを作成する
    unsigned int mask = ((1 << (msb - lsb + 1)) - 1) << lsb;

    // x の該当するビット範囲を取り出す
    unsigned int extracted_bits = (x & mask) >> lsb;

    return extracted_bits;
}

class Test
{
private:
    Vmain *top;
    VerilatedVcdC *tfp;
    FILE *logfile = NULL;
    int reset = 0;
    int p_reset = 0;

public:
    unsigned int m_clock_count = 0;
    Test()
    {
        top = new Vmain;
        tfp = new VerilatedVcdC;
        top->trace(tfp, 99);
    }
    ~Test(void)
    {
        if (tfp->isOpen())
        {
            tfp->close();
        }
        if (logfile)
        {
            fclose(logfile);
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
    };
    void dump(void)
    {
        if (tfp->isOpen())
        {
            tfp->dump(m_clock_count);
        }
    };
    void logging(void)
    {
        if (top->m_clock && top->wb && logfile)
        {
            disasmTEP();
        }
    }
    void step(void)
    {
        tick();
        eval();
        dump();
        logging();
    };
    void parseLogOpts(int argc, char **argv)
    {
        FILE *fp;
        int opt, longindex;
        char *Darg = NULL, *aarg = NULL, *symfile = NULL;
        struct option longopts[] = {
            {"dump", no_argument, NULL, 'd'},
            {"log", no_argument, NULL, 'l'},
            {0, 0, 0, 0},
        };
        while ((opt = getopt_long(argc, argv, "dl", longopts, &longindex)) != -1)
        {
            switch (opt)
            {
            case 'd':
                tfp->open("tep.vcd");
                break;
            case 'l':
                fp = fopen("tep.log", "w");
                if (fp)
                {
                    logfile = fp;
                }
                break;
            default:
                exit(1);
                break;
            }
        }
    }
    void resetCore(void)
    {
        /* assert reset signal for one clock cycle */
        while (tick() <= 10)
        {
            eval();
            dump();
        }
        top->p_reset = 1;
        top->reset = 1;
        eval();
        dump();
        tick();
        eval();
        dump();
        tick();
        /* negate reset signal */
        top->reset = 0;
        eval();
        dump();
    };
    void disasmTEP()
    {
        uint16_t opcode, pc, r1, r1_val, r2, r2_val, imm, shiftval, alu_out;
        char *inst;
        VlUnpacked<SData /*15:0*/, 16> *regs;
        pc = top->rootp->main__DOT__sys__DOT__cpu__DOT__pc;
        pc -= 2; // writeback時は素手にカウント済みなので戻す
        opcode = top->rootp->main__DOT__sys__DOT__cpu__DOT__opreg;
        imm = top->rootp->main__DOT__sys__DOT__cpu__DOT__I;
        regs = &top->rootp->main__DOT__sys__DOT__cpu__DOT__rf__DOT__r;
        alu_out = top->rootp->main__DOT__sys__DOT__cpu__DOT___alu_out;
        r1 = bitExtract(opcode, 7, 4);
        r2 = bitExtract(opcode, 3, 0);
        r1_val = (*regs)[r1];
        r2_val = (*regs)[r2];
        if (!bitTest(opcode, 15)) // Itype
        {
            inst = Iinst[bitExtract(opcode, 14, 8)];
            fprintf(logfile, "%04X: %-5s$%02d,$%02d,%04x\t\t$%02d=$%04X,\t$%02d=$%04X,\taluOUT=%04X\n", pc, inst, r2, r1, imm, r2, r2_val, r1, r1_val, alu_out);
        }
        else if (!bitTest(opcode, 14))
        {                                            // Rtype
            inst = Rinst[bitExtract(opcode, 11, 8)]; // 本来instは13:8だが、DINT,EINT,RINTをRinstのインデクスと対応付けるために切り出し範囲を縮小
            fprintf(logfile, "%04X: %-5s$%02d,$%02d%*s\t\t$%02d=$%04X,\t$%02d=$%04X,\taluOUT=%04X\n", pc, inst, r2, r1, 5, "", r2, r2_val, r1, r1_val, alu_out);
        }
        else
        { // RStype
            shiftval = (*regs)[bitExtract(opcode, 11, 8)];
            inst = RSinst[bitExtract(opcode, 13, 12)];
            fprintf(logfile, "%04X: %-5s$%02d,$%02d,%04x\t\t$%02d=$%04X,\t$%02d=$%04X,\taluOUT=%04X\n", pc, inst, r2, r1, shiftval, r2, r2_val, r1, r1_val, alu_out);
        }
    }
};

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    Test *test;
    test = new Test;
    test->parseLogOpts(argc, argv);
    test->resetCore();
    while (!Verilated::gotFinish())
    {
        test->step();
    }
    delete test;
}