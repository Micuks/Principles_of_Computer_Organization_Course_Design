//tb.v

`timescale 1 ns / 10 ps

module cpu_tb;
  `include "top.sv"
  reg [3:0] sw;
  reg [7:4] ir;
  reg [3:0] s;
  reg
      clr,
      t3,
      swa,
      swb,
      swc,
      w1,
      w2,
      w3,
      c,
      z,
      drw,
      pcinc,
      lpc,
      lar,
      pcadd,
      arinc,
      selctl,
      memw,
      stop,
      lir,
      ldz,
      ldc,
      cin,
      m,
      abus,
      sbus,
      mbus,
      short,
      long,
      sel0,
      sel1,
      sel2,
      sel3;

  localparam period = 20;

  cpu cpu_inst (
      .clr(clr),
      .t3(t3),
      .swa(swa),
      .swb(swb),
      .swc(swc),
      .w1(w1),
      .w2(w2),
      .w3(w3),
      .c(c),
      .z(z),
      .drw(drw),
      .pcinc(pcinc),
      .lpc(lpc),
      .lar(lar),
      .pcadd(pcadd),
      .arinc(arinc),
      .selctl(selctl),
      .memw(memw),
      .stop(stop),
      .lir(lir),
      .ldz(ldz),
      .ldc(ldc),
      .cin(cin),
      .m(m),
      .abus(abus),
      .sbus(sbus),
      .mbus(mbus),
      .short(short),
      .long(long),
      .sel0(sel0),
      .sel1(sel1),
      .sel2(sel2),
      .sel3(sel3)
  );

  initial begin
    sw = 3'b000;
    ir = 4'b0001;
    #period;

    ir = 4'b0010;
    #period;

    ir = 4'b0011;
    #period;

    ir = 4'b0100;
    #period;

    ir = 4'b0101;
    #period;

    ir = 4'b0110;
    #period;
  end

endmodule
