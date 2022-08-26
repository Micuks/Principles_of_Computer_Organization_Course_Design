/*
--------------------------------------------------------------------
 CLR  复位
 Z,C  Z是运算结果为0标志 C是运算进位标志
--------------------------------------------------------------------
 IR   指令高四位
 SW   控制台设置的操作模式
 W    三个节拍
 T3   节拍脉冲
--------------------------------------------------------------------
 SELCTL,              R0~3选择 为1时由控制台选中寄存器 为0时由IR低位选中寄存器
 DRW,                 R0~3控制
 LPC, PCINC, PCADD,   PC 控制
 LAR, ARINC,          AR 控制
 STOP,                停机控制
 LIR,                 IR 控制
 LDZ, LDC,            载入Z C标志位
 CIN, M,              运算控制
 MEMW,                内存控制
 ABUS, SBUS, MBUS,    总线控制
 SHORT, LONG,         拍数控制
--------------------------------------------------------------------
-- S                    S3~S0选择ALU计算模式
-- SEL                  选择R和MUX
-- --------------------------------------------------------------------
*/

module cpu(
	input CLR,T3,C,Z,
	input [7:4] IR,
	input [3:1] SW,
	input [3:1] W,

	output SELCTL,DRW,
			LPC,PCINC,PCADD,
			LAR,ARINC,
			LIR,
			LDZ,LDC,
			CIN,M,
			MEMW,
			ABUS,SBUS,MBUS,
			STOP,SHORT,LONG,
	output [3:0] S,
	output [3:0] SEL);
	
	// 由SWC SWB SWA决定现在执行什么任务
	wire write_reg,read_reg,write_mem,read_mem,ins_fetch; 
	// 现在执行哪条指令
	wire ADD,SUB,AND,INC,LD,ST,JC,JZ,JMP,STP;
	// wire NOP,OUT,OR,CMP,MOV; // 附加指令

	reg ST0;
	wire ST0_next;
	reg is_clr;

	always @(CLR) begin
		if(CLR == 1)
			is_clr <= 0;
		else
			is_clr <= 1;
	end
	
	always @(negedge T3) begin
		ST0 <= ST0_next;
		// if((write_reg && W[2]) || ((read_mem || write_mem) && W[1]))
		// 	ST0 <= 1;
		// else
		// 	ST0 <= 0;
	end

	assign ST0_next = (write_reg && ST0 == 0 && W[2]) || ((read_mem || write_mem) && ST0 == 0 && W[1]) 
	|| (write_reg && ST0 == 1 && W[1]) || (ins_fetch && ST0 == 0 && W[1]) || ((read_mem || write_mem) && ST0 && W[1])
	|| (ins_fetch && (W[2] || W[3]));

	// 控制台操作模式
	assign write_reg = (SW == 3'b100 && !is_clr );
	assign read_reg = (SW == 3'b011 && !is_clr) ;
	assign write_mem = (SW == 3'b001 && !is_clr) ;
	assign read_mem = (SW == 3'b010 && !is_clr) ;
	assign ins_fetch = (SW == 3'b000 && !is_clr) ;

	// 各操作信号产生逻辑
	assign STOP = is_clr || (!ins_fetch) || (ins_fetch && STP && W[2]); //(!(ins_fetch && STP && W[2]) && !(W[1] && ins_fetch && ST0));
	// 选择寄存器
	assign SEL[0] = ((write_reg || read_reg) && W[1]) || (read_reg && W[2]) ;
	assign SEL[1] = (write_reg && !ST0 && W[1]) || (W[2] && write_reg && ST0) || (read_reg && W[2] );
	assign SEL[2] = (write_reg && W[2]);
	assign SEL[3] = (write_reg && ST0 ) || (read_reg && W[2]) ;

	assign DRW = write_reg || ((ADD || SUB || AND || INC ) && W[2]) || (LD && W[3]);
	assign SBUS = write_reg || (ins_fetch && !ST0 && W[1]) || (read_mem && !ST0 && W[1]) || (write_mem && W[1]);
	assign SELCTL = SW != 3'b000;

	assign SHORT = (read_mem || write_mem) || (ins_fetch && !ST0 && W[1]);
	assign LONG = (LD || ST) && W[2];

	assign LPC = (ins_fetch && !ST0 && W[1]) || (JMP && W[2]);
	assign PCINC = ins_fetch && ST0 && W[1];
	assign PCADD = ((JC && C) || (JZ && Z)) && W[2];
	assign LAR = ((LD || ST) && W[2] ) || ((read_mem||write_mem) && !ST0 && W[1]);
	assign ARINC = (read_mem || write_mem) && ST0;
	assign LIR = ins_fetch && W[1] && ST0;
	assign LDZ = ins_fetch && (ADD || SUB || AND || INC) && W[2];
	assign LDC = ins_fetch && (ADD || SUB || INC) && W[2];
	assign CIN = (ins_fetch && ADD && W[2]);
	assign M = ins_fetch && (((AND || LD || ST || JMP ) && W[2]) || (ST && W[3]));
	assign MEMW = (ins_fetch && ST && W[3]) || (write_mem && ST0 && W[1]);
	assign ABUS = (ins_fetch && (ADD  || SUB || AND || LD || ST || JMP) && W[2]) || (ins_fetch && ST && W[3]);
	assign MBUS = (ins_fetch && LD && W[3]) || (read_mem && ST0);
	
	reg [7:4]S_temp;
	always @(IR) begin
		
		case (IR)
			4'b0001: S_temp <= 4'b1001;
			4'b0010: S_temp <= 4'b0110;
			4'b0011: S_temp <= 4'b1011;
			4'b0100: S_temp <= 4'b0000;
			4'b0101: S_temp <= 4'b1010;
			4'b0110: S_temp <= 4'b1010;
			
			4'b1001: S_temp <= 4'b1111;
			default: S_temp <= 4'b1111;
		endcase
	
	end
	assign S = S_temp;

	// 各个指令状态
	assign ADD = IR == 4'b0001;
	assign SUB = IR == 4'b0010;
	assign AND = IR == 4'b0011;
	assign INC = IR == 4'b0100;
	assign LD = IR == 4'b101;
	assign ST = IR == 4'b0110;
	assign JC = IR == 4'b0111;
	assign JZ = IR == 4'b1000;
	assign JMP = IR == 4'b1001;
	assign STP = IR == 4'b1110;


endmodule

