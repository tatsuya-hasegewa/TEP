module main(p_reset,m_clock);
parameter STEP=10;
integer i,j,vcd,conindex;
input p_reset, m_clock;
wire p_reset, m_clock;
reg int_signal;	//割り込みレジスタ
reg [7:0] mem [0:4091];
reg [7:0] conin [0:255];
reg [15:0] datai;

wire [15:0]	datao,adrs;

wire	memory_read,memory_write,memory_write_byte,wb,hlt;
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
sys sys(.p_reset(p_reset),.m_clock(m_clock),.PS2C(PS2C),.PS2D(PS2D),.RXD(RXD),.btn(btn),.VGA_V(VGA_V),.VGA_H(VGA_H),.VGA_B(VGA_B),.VGA_G(VGA_G),.VGA_R(VGA_R),.TXD(TXD),.led(led),.an(an),.sseg(sseg),.sw(sw));
wire sim_rxd;
wire done;
wire rxready;
wire port_read;
wire [7:0] data;
serial_in sim_serrx (.p_reset( p_reset), .m_clock(m_clock), .rxd(sim_rxd), .rxready(rxready), .port_read(port_read), .data(data), .done(done));
assign wb = sys.cpu.wb;
assign hlt = sys.cpu.hlt;
assign sim_rxd = p_reset ? 1 : TXD;

//always #(STEP/2) m_clock=~m_clock;
//ここで割り込みのON,OFFを設定する。
always #(STEP) int_signal=1;			//割り込みレジスタの値

always @(negedge sys.cpu.m_clock)
begin
   if(sim_serrx.done)
	begin
	$write("%c",data);
	end
end
always @(negedge sys.cpu.m_clock)
begin
if(wb)

 #(STEP)
 if(j != 8)
  begin
  $write("pc:%x ",sys.cpu.pc);
  case (sys.cpu.opreg[15])
  'b0:
   begin
	case (sys.cpu.opreg[14:8])	// Itype
	'b0000000: $write("CNST ");
	'b0000001: $write("LD1  ");
	'b0000010: $write("LD2  ");
	'b0000011: $write("ST1  ");
	'b0000100: $write("ST2  ");
	'b0000101: $write("JUMP ");
	'b0000110: $write("CALL ");
	'b0000111: $write("JEQ  ");
	'b0001000: $write("JGEI ");
	'b0001001: $write("JGEU ");
	'b0001010: $write("JGTI ");
	'b0001011: $write("JGTU ");
	'b0001100: $write("JLEI ");
	'b0001101: $write("JLEU ");
	'b0001110: $write("JLTI ");
	'b0001111: $write("JLTU ");
	'b0010000: $write("JNE  ");
	endcase
	$display(" OP1:%b %b %b %b OP2:%b %b %b %b \n  R01:%x R02:%x R03:%x R04:%x R05:%x R06:%x R07:%x R08:%x R09:%x R10:%x R11:%x R12:%x R13:%x R14:%x R15:%x I:%x"
	,sys.cpu.opreg[15:12],
	sys.cpu.opreg[11:8], sys.cpu.opreg[7:4], sys.cpu.opreg[3:0],
	sys.cpu.I[15:12], sys.cpu.I[11:8], sys.cpu.I[7:4], sys.cpu.I[3:0], 
	sys.cpu.rf.r[01], sys.cpu.rf.r[02], sys.cpu.rf.r[03], sys.cpu.rf.r[04], 
	sys.cpu.rf.r[05], sys.cpu.rf.r[06], sys.cpu.rf.r[07], sys.cpu.rf.r[08], 
	sys.cpu.rf.r[09], sys.cpu.rf.r[10], sys.cpu.rf.r[11], sys.cpu.rf.r[12], 
	sys.cpu.rf.r[13], sys.cpu.rf.r[14], sys.cpu.rf.r[15], sys.cpu.I);
   end
'b1:
   begin
   case (sys.cpu.opreg[14]) 		// Rtype or RStype
	'b0:
        begin
           case (sys.cpu.opreg[13:8]) 		// Rtype
		'b000000: $write("MUL  ");
		'b000001: $write("CVI2 ");
		'b000010: $write("ADD  ");
		'b000011: $write("SUB  ");
		'b000100: $write("NEG  ");
		'b000101: $write("BAND ");
		'b000110: $write("BOR  ");
		'b000111: $write("BXOR ");
		'b001000: $write("BCOM ");
		'b101001: $write("DINT ");
		'b101010: $write("EINT ");
		'b101011: $write("RINT ");
	endcase
	$display("  OP :%b %b %b %b\n  R01:%x R02:%x R03:%x R04:%x R05:%x R06:%x R07:%x R08:%x R09:%x R10:%x R11:%x R12:%x R13:%x R14:%x R15:%x I:%x"
	,sys.cpu.opreg[15:12],sys.cpu.opreg[11:8],sys.cpu.opreg[7:4],sys.cpu.opreg[3:0],
	sys.cpu.rf.r[01], sys.cpu.rf.r[02], sys.cpu.rf.r[03], sys.cpu.rf.r[04],
	sys.cpu.rf.r[05], sys.cpu.rf.r[06], sys.cpu.rf.r[07], sys.cpu.rf.r[08],
	sys.cpu.rf.r[09], sys.cpu.rf.r[10], sys.cpu.rf.r[11], sys.cpu.rf.r[12],
	sys.cpu.rf.r[13], sys.cpu.rf.r[14], sys.cpu.rf.r[15], sys.cpu.I);
        end
  'b1:begin
      case (sys.cpu.opreg[13:12]) 		//  RStype
	'b00: $write("LSHL ");
	'b01: $write("RSHA ");
	'b10: $write("RSHL ");
	'b11: $write("HLT  ");
      endcase
	$display("OP :%b %b %b %b  \n  R01:%x R02:%x R03:%x R04:%x R05:%x R06:%x R07:%x R08:%x R09:%x R10:%x R11:%x R12:%x R13:%x R14:%x R15:%x I:%x"
	,sys.cpu.opreg[15:12],sys.cpu.opreg[11:8],sys.cpu.opreg[7:4],sys.cpu.opreg[3:0], sys.cpu.rf.r[01], sys.cpu.rf.r[02], sys.cpu.rf.r[03], sys.cpu.rf.r[04], sys.cpu.rf.r[05], sys.cpu.rf.r[06], sys.cpu.rf.r[07], sys.cpu.rf.r[08], sys.cpu.rf.r[09], sys.cpu.rf.r[10], sys.cpu.rf.r[11], sys.cpu.rf.r[12], sys.cpu.rf.r[13], sys.cpu.rf.r[14], sys.cpu.rf.r[15], sys.cpu.I);
	  end
	endcase
	  end
	endcase
	//endcase  
	j=j+1;
  end
  
if(hlt)
  begin 
  $display("\npc:%x HLT   OP :%b %b %b %b\n  R01:%x R02:%x R03:%x R04:%x R05:%x R06:%x R07:%x R08:%x R09:%x R10:%x R11:%x R12:%x R13:%x R14:%x R15:%x I:%x"
		 			,sys.cpu.pc,sys.cpu.opreg[15:12],sys.cpu.opreg[11:8],sys.cpu.opreg[7:4],sys.cpu.opreg[3:0], sys.cpu.rf.r[01], sys.cpu.rf.r[02], sys.cpu.rf.r[03], sys.cpu.rf.r[04], sys.cpu.rf.r[05], sys.cpu.rf.r[06], sys.cpu.rf.r[07], sys.cpu.rf.r[08], sys.cpu.rf.r[09], sys.cpu.rf.r[10], sys.cpu.rf.r[11], sys.cpu.rf.r[12], sys.cpu.rf.r[13], sys.cpu.rf.r[14], sys.cpu.rf.r[15], sys.cpu.I);

  $display("\nHALTED at %8d clock", $time/STEP);
  /*
   for(i=0; i<1024; i=i+16)
    begin
     $write("%4x: ",i);
       for(j=0; j<16; j=j+1)
         if(j&1) $write("%x ",sys.mainmem.ramo.ram[i+j]);
         else $write("%x ",sys.mainmem.rame.ram[i+j]);
       $display;
      end
	*/
   $finish;
  end
end



initial begin		//初期化
 $readmemh("tep.mem", sys.mainmem.memory.ram);
 
 for(i=0; i<8; i=i+1)
 begin
	 $display("%x ",sys.mainmem.memory.ram[i]);
 end
 
 int_signal=0;		//割り込みレジスタ
 sys.interval = 'hfffc;

#(10000*STEP+(STEP/2)) $finish;
end
endmodule


