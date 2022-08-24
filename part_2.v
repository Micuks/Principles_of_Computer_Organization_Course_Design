module part_2 (
    input clr,
    input t3,
    input swa,
    input swb,
    input swc,
    input [7:4] ir,
    input w1,
    input w2,
    input w3,
    input c,
    input z,
    output reg drw,
    output reg pcinc,
    output reg lpc,
    output reg lar,
    output reg pcadd,
    output reg arinc,
    output reg selctl,
    output reg memw,
    output reg stop,
    output reg lir,
    output reg ldz,
    output reg ldc,
    output reg cin,
    output reg [3:0] s,
    output reg m,
    output reg abus,
    output reg sbus,
    output reg mbus,
    output reg short,
    output reg long,
    output reg sel0,
    output reg sel1,
    output reg sel2,
    output reg sel3
);
    
wire [2:0] sw;
reg st0;
reg sst0; 

assign sw = {swc, swb, swa};

always@(t3, clr, w1, w2, w3)
begin
	if(clr == 0)
	begin
        drw <= 0;
        memw <= 0;
		st0 <= 0;
		s <= 4'b0000;
		m <= 0;
		cin <= 0;
		sel3 <= 0;
		sel2 <= 0;
		sel1 <= 0;
		sel0 <= 0;
		selctl <= 0;
		lir <= 0;
		ldc <= 0;
		ldz <= 0;
		lpc <= 0;
		lar <= 0;
		pcinc <= 0;
		pcadd <= 0;
		arinc <= 0;
		long <= 0;
		short <= 0;
		abus <= 0;
		mbus <= 0;
        sbus <= 0;
		stop <= 0;
		sst0 <= 0;
	end
	else if(t3)
	begin
      if(st0 == 1 && w2 == 1 && sw == 3'b100) st0 <= 0; //ѭ��д�Ĵ���
      if(sst0 == 1) st0 <= 1;
    end	
	else
	begin
		case (sw)   
			3'b000: 
			begin
				if(st0 == 0)
				begin
					sbus <= w1;
					short <= w1;
					sst0 <= w1;
					lpc <= w1;
					stop <= w1;
				end
				else
				begin
					lir <= w1;
					pcinc <= w1;
					s[3] <= (w2 & ((~ ir[6] & ir[4]) | 
								   (~ ir[7] & ~ ir[5] & ir[4]) |
								   (~ ir[7] & ir[6] & ir[5] & ~ ir[4])))|
							(w3 & (~ ir[7] & ir[6] & ir[5] & ~ ir[4]));
					s[2] <= w2 & ((~ ir[6] & ir[5] & ~ ir[4]) |
								  (~ ir[7] & ir[5] & ~ ir[4]) |
								  (ir[7] & ~ ir[6] & ir[4]) |
								  (ir[7] & ~ ir[6] & ir[5]));
										
					s[1] <= (w2 & ((~ ir[6] & ir[5]) |
									 (~ ir[7] & ir[5] & ~ ir[4]) |
									 (ir[7] & ~ ir[6] & ir[4]) |
									 (~ ir[7] & ir[6] & ~ ir[5] & ir[4]))) |
							(w3 & (~ ir[7] & ir[6] & ir[5] & ~ ir[4]));
								
					s[0] <= w2 & ((~ ir[6] & ir[4]) | 
									(~ ir[7] & ir[6] & ir[5] & ~ ir[4]));
						
					cin <= w2 & ((~ ir[7] & ~ ir[6] & ~ ir[5] & ir[4]) |
									(ir[7] & ~ ir[6] & ir[5] & ir[4]));
										
					abus <= (w2 & ((~ ir[6] & ir[4]) |
									 (~ ir[6] & ir[5]) |
									 (~ ir[7] & ~ ir[5] & ir[4]) |
									 (~ ir[7] & ir[5] & ~ ir[4]) |
									 (~ ir[7] & ir[6] & ~ ir[4]) |
									 (~ ir[7] & ir[6] & ~ ir[5]))) |
							(w3 & (~ ir[7] & ir[6] & ir[5] & ~ ir[4]));
								
					drw <=  (w2 & ((~ ir[6] & ir[5]) |
									(~ ir[7] & ~ ir[6] & ir[4]) |
									(~ ir[7] & ir[6] & ~ ir[5] & ~ ir[4]))) |
							(w3 & (~ ir[7] & ir[6] & ~ ir[5] & ir[4]));
								
					ldz <= w2 & ( (~ ir[6] & ir[5]) |
									(~ ir[7] & ~ ir[6] & ir[4]) |
									(~ ir[7] & ir[6] & ~ ir[5] & ~ ir[4]));
										
					ldc <= w2 & ( (~ ir[7] & ~ ir[6] & ~ ir[5] & ir[4]) |
									(~ ir[7] & ~ ir[6] & ir[5] & ~ ir[4]) |
									(~ ir[7] & ir[6] & ~ ir[5] & ~ ir[4]) |
									(ir[7] & ~ ir[6] & ir[5] & ir[4]));
										
					m <= (w2 & (  (~ ir[7] & ~ ir[6] & ir[5] & ir[4]) |
									(~ ir[7] & ir[6] & ~ ir[5] & ir[4]) |
									(~ ir[7] & ir[6] & ir[5] & ~ ir[4]) |
									(ir[7] & ~ ir[6] & ~ ir[5] & ir[4]) |
									(ir[7] & ~ ir[6] & ir[5] & ~ ir[4]))) |
						 (w3 & (~ ir[7] & ir[6] & ir[5] & ~ ir[4]));
				end
			end 
			3'b010:
			begin
				sbus <= ~st0 & w1;
				lar <= ~st0 & w1;
				stop <= w1;
				short <= w1;
				selctl <= w1;
				mbus <= st0 & w1;
				arinc <= st0 & w1;
				sst0 <= ~st0 & w1;
			end
			3'b001:
			begin
				sbus <= w1;
				lar <= ~st0 & w1;
				stop <= w1;
				short <= w1;
				selctl <= w1;
				memw <= st0;
				arinc <= st0 & w1;
				sst0 <= ~st0 & w1;
			end
		endcase
	end
end

endmodule