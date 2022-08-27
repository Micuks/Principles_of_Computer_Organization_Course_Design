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
 S                    S3~S0选择ALU计算模式
 SEL                  选择R和MUX
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
	wire NOP,OUT,OR,CMP,MOV; // 附加指令

	reg ST0;
	wire ST0_next;
	reg is_clr;

	// 设置is_clr
	// is_clr 置1后 write_reg read_reg write_mem read_mem ins_fetch 均为0
	always @(CLR) begin
		if(CLR == 1)
			is_clr <= 0;
		else
			is_clr <= 1;
	end
	
	// 状态转换
	always @(negedge T3) begin
		ST0 <= ST0_next;	
	end

	// ST0次态逻辑
	assign ST0_next = (write_reg && !ST0 && W[2]) || (write_reg && ST0 && W[1]) 
				|| (read_mem || write_mem)
				|| (ins_fetch && !ST0 && W[1])
				|| (ins_fetch && ST0);

	// 控制台操作模式
	assign write_reg = (SW == 3'b100 && !is_clr );
	assign read_reg = (SW == 3'b011 && !is_clr) ;
	assign write_mem = (SW == 3'b001 && !is_clr) ;
	assign read_mem = (SW == 3'b010 && !is_clr) ;
	assign ins_fetch = (SW == 3'b000 && !is_clr) ;

	// 选择寄存器
	assign SEL[0] = ((write_reg || read_reg) && W[1]) || (read_reg && W[2]) ;
	assign SEL[1] = (write_reg && !ST0 && W[1]) || (W[2] && write_reg && ST0) || (read_reg && W[2] );
	assign SEL[2] = (write_reg && W[2]);
	assign SEL[3] = (write_reg && ST0 ) || (read_reg && W[2]) ;
	
	// 各操作信号产生逻辑
	assign STOP = is_clr || (!ins_fetch) || (ins_fetch && STP && W[1]);

	assign DRW = write_reg || ((ADD || SUB || AND || INC || OR || MOV) && W[1]) || (LD && W[1]);
	assign SBUS = write_reg || (ins_fetch && !ST0 && W[1]) || (read_mem && !ST0 && W[1]) || (write_mem && W[1]);
	assign SELCTL = SW != 3'b000;

	assign LPC = (ins_fetch && !ST0 && W[1]) || (JMP && W[1]);
	assign PCADD = ((JC && C) || (JZ && Z)) && W[1];
	assign LAR = ((LD || ST) && W[1] ) || ((read_mem||write_mem) && !ST0 && W[1]);
	assign ARINC = (read_mem || write_mem) && ST0;
	assign LDZ = (ADD || SUB || AND || INC || OR || CMP) && W[1];
	assign LDC = (ADD || SUB || INC || CMP) && W[1];
	assign CIN = ADD && W[1];
	assign M =  ((AND || LD || ST || JMP || OUT || OR || MOV) && W[1]) || (ST && W[2]);
	assign MEMW = (ST && W[2]) || (write_mem && ST0 && W[1]);
	assign ABUS = ((ADD  || SUB || AND || INC || LD || ST || JMP || OUT || OR || MOV) && W[1]) || (ST && W[2]);
	assign MBUS = (LD && W[2]) || (read_mem && ST0);
    // --------------------------
	// 取指令
	assign PCINC = (ST0 && W[1] && (NOP || ADD || SUB || AND || INC || (JC && !C) || (JZ && !Z))) 
					|| (ST0 && W[2] && (LD || ST || (JC && C) || (JZ && Z) || JMP));
	assign LIR = (ST0 && W[1] && (NOP || ADD || SUB || AND || INC || (JC && !C) || (JZ && !Z))) 
					|| (ST0 && W[2] && (LD || ST || (JC && C) || (JZ && Z) || JMP));
	
	// 节拍脉冲信号逻辑
	assign SHORT = (read_mem || write_mem) || (ins_fetch && !ST0 && W[1])
					|| (ST0 && W[1] && (NOP || ADD || SUB || AND || INC || (JC && !C) || (JZ && !Z))) ;
	assign LONG = 0;



	// 运算器模式
	reg [7:4]S_temp;
	always @(IR or W) begin
		if(W[2]) begin
			case (IR)
				4'b0000: S_temp <= 4'b0000;
				4'b0001: S_temp <= 4'b1001;
				4'b0010: S_temp <= 4'b0110;
				4'b0011: S_temp <= 4'b1011;
				4'b0100: S_temp <= 4'b0000;
				4'b0101: S_temp <= 4'b1010;
				4'b0110: S_temp <= 4'b1111;
				
				4'b1010: S_temp <= 4'b1010;
				4'b1011: S_temp <= 4'b1110;
				4'b1100: S_temp <= 4'b0110;
				4'b1101: S_temp <= 4'b1010;

				4'b1001: S_temp <= 4'b1111;
				default: S_temp <= 4'b1111;
			endcase
		end
		if(W[3]) begin
			case (IR)
				4'b0110: S_temp <= 4'b1010;
				default: S_temp <= 4'b1111;
			endcase
		end
	end
	assign S = S_temp;

	// 各个指令状态
	assign ADD = (IR == 4'b0001) && ins_fetch;
	assign SUB = (IR == 4'b0010) && ins_fetch;
	assign AND = (IR == 4'b0011) && ins_fetch;
	assign INC = (IR == 4'b0100) && ins_fetch;
	assign LD = (IR == 4'b0101) && ins_fetch;
	assign ST = (IR == 4'b0110) && ins_fetch;
	assign JC = (IR == 4'b0111) && ins_fetch;
	assign JZ = (IR == 4'b1000) && ins_fetch;
	assign JMP = (IR == 4'b1001) && ins_fetch;
	assign STP = (IR == 4'b1110) && ins_fetch;

	// 附加指令
	assign NOP = (IR == 4'b0000) && ins_fetch;
	assign OUT = (IR == 4'b1010) && ins_fetch;
	assign OR = (IR == 4'b1011) && ins_fetch;
	assign CMP = (IR == 4'b1100) && ins_fetch;
	assign MOV = (IR == 4'b1101) && ins_fetch;

endmodule

