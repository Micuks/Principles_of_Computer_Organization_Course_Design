//tb.v
`timescale 1 ns / 1 ps

module cpu_tb;
  `include "top.sv"
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

  localparam period = 200;

  cpu cpu_inst (
      .clr(clr),
      .t3(t3),
      .swa(swa),
      .swb(swb),
      .swc(swc),
      .ir(ir),
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
      .s(s),
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

  // define clock
  always begin
    // t3, w1 rise
    #10 t3 = !t3;
    w1 = !w1;
    // t3, w1 fall
    #10 t3 = !t3;
    w1 = !w1;

    if (!short) begin
      // t3, w2 rise
      #10 t3 = !t3;
      w2 = !w2;
      // t3, w2 fall
      #10 t3 = !t3;
      w2 = !w2;

      if (long) begin
        // t3, w3 rise
        t3 = !t3;
        w3 = !w3;
        // t3, w3 fall
        t3 = !t3;
        w3 = !w3;
      end
    end
  end

  // begin simulate
  initial begin
    clr = 0;
    t3  = 0;
    w1  = 0;
    w2  = 0;
    w3  = 0;

    #20 clr = 1;

    $display("begin simulation");
    swa = 0;
    swb = 0;
    swc = 0;
    ir  = 4'b0001;
    $display("ir[%4b]", ir);
    #period;

    ir = 4'b0010;
    $display("ir[%4b]", ir);
    #period;

    ir = 4'b0011;
    $display("ir[%4b]", ir);
    #period;

    ir = 4'b0100;
    $display("ir[%4b]", ir);
    #period;

    ir = 4'b0101;
    $display("ir[%4b]", ir);
    #period;

    ir = 4'b0110;
    $display("ir[%4b]", ir);
    #period;

    $finish;
  end

endmodule
