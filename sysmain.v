module main(reset,p_reset,m_clock,wb);
parameter STEP=10;
integer i,j,vcd,conindex;
input reset, p_reset, m_clock;
wire reset, p_reset, m_clock;
output wb;
wire wb;
reg int_signal;	//割り込みレジスタ
reg [7:0] mem [0:4091];
reg [7:0] conin [0:255];
reg [15:0] datai;

wire [15:0]	datao,adrs;

wire	memory_read,memory_write,memory_write_byte,hlt;
wire	txd,in3,baudin;

reg PS2C; 
reg PS2D; 
reg RXD; 
reg [2:0] btn; 
reg [7:0] sw; 
wire VGA_V; 
wire VGA_H; 
wire VGA_B; 
wire VGA_G; 
wire VGA_R; 
wire TXD; 
wire [7:0] led; 
wire [3:0] an; 
wire [7:0] sseg; 
sys sys(.p_reset(p_reset),.m_clock(m_clock),.PS2C(PS2C),.PS2D(PS2D),.RXD(RXD),.btn(btn),.VGA_V(VGA_V),.VGA_H(VGA_H),.VGA_B(VGA_B),.VGA_G(VGA_G),.VGA_R(VGA_R),.TXD(TXD),.led(led),.an(an),.sseg(sseg),.sw(sw),.reset(reset));
wire sim_rxd;
wire done;
wire rxready;
wire port_read;
wire [7:0] data;
serial_in sim_serrx (.p_reset( p_reset), .m_clock(m_clock), .rxd(sim_rxd), .rxready(rxready), .port_read(port_read), .data(data), .done(done));

assign wb = sys.cpu.wb;
assign hlt = sys.cpu.hlt;
assign sim_rxd = TXD;


always @(negedge sys.cpu.m_clock)
begin
   if(sim_serrx.done)
	begin
	$write("%c",data);
	end
end
always @(negedge sys.cpu.m_clock)
begin

if(hlt)
  begin 
  $display("\npc:%x HLT   OP :%b %b %b %b\n  R01:%x R02:%x R03:%x R04:%x R05:%x R06:%x R07:%x R08:%x R09:%x R10:%x R11:%x R12:%x R13:%x R14:%x R15:%x I:%x"
		 			,sys.cpu.pc,sys.cpu.opreg[15:12],sys.cpu.opreg[11:8],sys.cpu.opreg[7:4],sys.cpu.opreg[3:0], sys.cpu.rf.r[01], sys.cpu.rf.r[02], sys.cpu.rf.r[03], sys.cpu.rf.r[04], sys.cpu.rf.r[05], sys.cpu.rf.r[06], sys.cpu.rf.r[07], sys.cpu.rf.r[08], sys.cpu.rf.r[09], sys.cpu.rf.r[10], sys.cpu.rf.r[11], sys.cpu.rf.r[12], sys.cpu.rf.r[13], sys.cpu.rf.r[14], sys.cpu.rf.r[15], sys.cpu.I);

  $display("\nHALTED at %8d clock", $time/STEP);
   $finish;
  end
end



initial begin		//初期化
 $readmemh("tep.mem", sys.mainmem.memory.ram);
 int_signal=0;		//割り込みレジスタ
end
endmodule


