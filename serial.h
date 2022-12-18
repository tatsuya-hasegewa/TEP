
// 50MHz
#define BAUD_9600 651
#define BAUD_38400 162
#define BAUD_115200 54
#define BAUD_CNT BAUD_38400

// 25MHz
// #define BAUD_CNT (BAUD_38400 / 2)

// 12.5MHz
// #define BAUD_CNT (BAUD_38400 / 4)

declare serial_clkfix
{
    func_out baud;
    func_in sync;
}