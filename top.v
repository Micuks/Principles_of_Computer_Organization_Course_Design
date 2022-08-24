module cpu (
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

  `include "pick_ir.sv"
  reg st0 = 0;
  reg sst0 = 0;
  wire [2:0] sw;

  assign sw = {swc, swb, swa};

  always @(t3, clr, w1, w2, w3) begin
    if (!clr) begin
      st0 <= 0;
    end else if (t3) begin
      if (st0 == 1 && w2 == 1 && sw == 3'b100) begin
        st0 <= 0;
      end
      if (sst0 == 1) begin
        st0 <= 1;
      end
    end

    s      <= 4'b0000;
    m      <= 1'b0;
    cin    <= 1'b0;
    sel3   <= 1'b0;
    sel2   <= 1'b0;
    sel1   <= 1'b0;
    sel0   <= 1'b0;
    selctl <= 1'b0;
    lir    <= 1'b0;
    ldc    <= 1'b0;
    ldz    <= 1'b0;
    lpc    <= 1'b0;
    lar    <= 1'b0;
    pcinc  <= 1'b0;
    pcadd  <= 1'b0;
    arinc  <= 1'b0;
    long   <= 1'b0;
    short  <= 1'b0;
    abus   <= 1'b0;
    mbus   <= 1'b0;
    sbus   <= 1'b0;
    drw    <= 1'b0;
    memw   <= 1'b0;
    stop   <= 1'b0;
    //	 sst0   <= 1'b0;


    case (sw)
      3'b100: begin
        $display("sw[%3b]", sw);
        sbus <= 1;
        sel0 <= w1;
        sel1 <= w1 & !st0;
        sel2 <= w2 & st0;
        sel3 <= st0;
      end
      3'b011: begin
        $display("sw[%3b]", sw);
        if(w1) begin
          {sel3,sel2,sel1,sel0} <= 4'b0001;
        end else begin
          {sel3,sel2,sel1,sel0} <= 4'b1011;
        end
      end
      3'b010: begin
        sbus <= ~st0 & w1;
        lar <= ~st0 & w1;
        stop <= w1;
        short <= w1;
        selctl <= w1;
        mbus <= st0 & w1;
        arinc <= st0 & w1;
        sst0 <= ~st0 & w1;
      end
      3'b001: begin
        sbus <= w1;
        lar <= ~st0 & w1;
        stop <= w1;
        short <= w1;
        selctl <= w1;
        memw <= st0;
        arinc <= st0 & w1;
        sst0 <= ~st0 & w1;
      end
      3'b000: begin
        $display("sw[%3b]", sw);
        if (st0 == 0) begin
          sbus  <= w1;
          lpc   <= w1;
          short <= w1;
          sst0  <= w1;
          stop  <= w1;
        end else if (st0 == 1) begin
          pick_ir_st0_1(ir, lir, pcinc, s, cin, abus, drw, ldz, ldc, m, lar, long, c, pcadd, z, lpc,
                        stop, mbus, memw, w1, w2, w3, short);
        end
      end
      default: begin
      end
    endcase
  end
endmodule
