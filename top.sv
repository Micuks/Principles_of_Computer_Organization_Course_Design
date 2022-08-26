function bool_func;

  input [7:0] ir;
  input [7:0] sign;

  begin
    bool_func = (ir[7:0] == sign[7:0]) ? 1'b1 : 1'b0;
  end
endfunction

module cpu (
    input clr,
    t3,
    swa,
    swb,
    swc,
    input [7:4] ir,
    input w1,
    w2,
    w3,
    c,
    z,
    output drw,
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
    output reg [3:0] s,
    output reg m,
    abus,
    sbus,
    mbus,
    short,
    long,
    sel0,
    sel1,
    sel2,
    sel3
);

  // `include "pick_ir.sv"
  reg st0;
  reg sst0;
  wire [2:0] sw;
  wire [7:0] union_ir;

  assign sw = {swc, swb, swa};

  assign union_ir = {ir[7:4], sw[2:0], st0};

  always @(negedge clr, negedge t3) begin
    if (!clr) begin
      st0 <= 1'b0;
    end else if (!t3) begin
      if (st0 == 1'b1 && w2 == 1'b1 && sw == 3'b100) begin
        st0 <= 1'b0;
      end
      if (sst0 == 1'b1) begin
        $display("sst0[%1b]", sst0);
        st0 <= 1'b1;
      end
    end else begin
      st0 <= st0;
    end
    $display("st0[%1b]", st0);
    // pick_ir_st0_1({ir, sw, st0}, lir, pcinc, s, cin, abus, drw, ldz, ldc, m, lar, long, arinc, sbus,
    //               short, sel3, sel2, sel1, sel0, selctl, sst0, c, pcadd, z, lpc, stop, mbus, memw,
    //               w1, w2, w3);
  end

  // instruction name and ir
  localparam add = 8'b00010001;
  localparam sub = 8'b00100001;
  localparam aand = 8'b00110001;
  localparam inc = 8'b01000001;
  localparam ld = 8'b01010001;
  localparam st = 8'b01100001;
  localparam jc = 8'b01110001;
  localparam jz = 8'b10000001;
  localparam jmp = 8'b10010001;
  localparam axor = 8'b10100001;
  localparam dec = 8'b10110001;
  localparam stp = 8'b11100001;
  localparam wreg1 = 8'b00001000;
  localparam wreg2 = 8'b00001001;
  localparam rreg = 8'b00000110;
  localparam wsto1 = 8'b00000100;
  localparam wsto2 = 8'b00000101;
  localparam rsto1 = 8'b00000010;
  localparam rsto2 = 8'b00000011;
  localparam pc = 8'b00000000;
  localparam spc = 8'b00000001;

  assign lir = (w1 && (bool_func(
      union_ir, add
  ) || bool_func(
      union_ir, sub
  ) || bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, inc
  ) || bool_func(
      union_ir, ld
  ) || bool_func(
      union_ir, st
  ) || bool_func(
      union_ir, jc
  ) || bool_func(
      union_ir, jz
  ) || bool_func(
      union_ir, jmp
  ) || bool_func(
      union_ir, axor
  ) || bool_func(
      union_ir, dec
  ) || bool_func(
      union_ir, stp
  ) || bool_func(
      union_ir, spc
  )));

  assign pcinc = (w1 && (bool_func(
      union_ir, add
  ) || bool_func(
      union_ir, sub
  ) || bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, inc
  ) || bool_func(
      union_ir, ld
  ) || bool_func(
      union_ir, st
  ) || bool_func(
      union_ir, jc
  ) || bool_func(
      union_ir, jz
  ) || bool_func(
      union_ir, jmp
  ) || bool_func(
      union_ir, axor
  ) || bool_func(
      union_ir, dec
  ) || bool_func(
      union_ir, stp
  ) || bool_func(
      union_ir, spc
  )));


  assign s[3] = ((w2 && (bool_func(
      union_ir, add
  ) || bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, ld
  ) || bool_func(
      union_ir, st
  ) || bool_func(
      union_ir, jmp
  ) || bool_func(
      union_ir, dec
  ))) || (w3 && bool_func(
      union_ir, st
  )));


  assign s[2] = (w2 && (bool_func(
      union_ir, sub
  ) || bool_func(
      union_ir, st
  ) || bool_func(
      union_ir, jmp
  ) || bool_func(
      union_ir, axor
  ) || bool_func(
      union_ir, dec
  )));

  assign s[1] = ((w2 && (bool_func(
      union_ir, sub
  ) || bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, ld
  ) || bool_func(
      union_ir, st
  ) || bool_func(
      union_ir, jmp
  ) || bool_func(
      union_ir, axor
  ) || bool_func(
      union_ir, dec
  ))) || (w3 && (bool_func(
      union_ir, st
  ))));

  assign s[0] = (w2 && (bool_func(
      union_ir, add
  ) || bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, st
  ) || bool_func(
      union_ir, jmp
  ) || bool_func(
      union_ir, dec
  )));

  assign cin = (w2 && (bool_func(union_ir, add) || bool_func(union_ir, dec)));

  assign abus = ((w2 && (bool_func(
      union_ir, add
  ) || bool_func(
      union_ir, sub
  ) || bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, inc
  ) || bool_func(
      union_ir, ld
  ) || bool_func(
      union_ir, st
  ) || bool_func(
      union_ir, jmp
  ) || bool_func(
      union_ir, axor
  ) || bool_func(
      union_ir, dec
  ))) || (w3 && (bool_func(
      union_ir, st
  ))));

  assign drw = ((w1 && (bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  ))) || (w2 && (bool_func(
      union_ir, add
  ) || bool_func(
      union_ir, sub
  ) || bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, inc
  ) || bool_func(
      union_ir, axor
  ) || bool_func(
      union_ir, dec
  ) || bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  ))) || (w3 && (bool_func(
      union_ir, ld
  ))));

  assign ldz = (w2 && (bool_func(
      union_ir, add
  ) || bool_func(
      union_ir, sub
  ) || bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, inc
  ) || bool_func(
      union_ir, axor
  ) || bool_func(
      union_ir, dec
  )));

  assign ldc = (w2 && (bool_func(
      union_ir, add
  ) || bool_func(
      union_ir, sub
  ) || bool_func(
      union_ir, inc
  ) || bool_func(
      union_ir, dec
  )));
  //   $display("w2[%1b] ldc[%1b] union_ir[%4b] b_f(sub)[%1b]", w2, ldc, union_ir, bool_func(union_ir, sub));

  assign m = ((w2 && (bool_func(
      union_ir, aand
  ) || bool_func(
      union_ir, ld
  ) || bool_func(
      union_ir, st
  ) || bool_func(
      union_ir, jmp
  ) || bool_func(
      union_ir, axor
  ))) || (w3 && (bool_func(
      union_ir, st
  ))));
  //   $display("w2[%1b] m[%1b] union_ir[%4b] b_f(sub)[%1b]", w2, m, union_ir, bool_func(union_ir, sub));

  assign lar = (w1 && (bool_func(
      union_ir, wsto1
  ) || bool_func(
      union_ir, rsto1
  ))) || (w2 && (bool_func(
      union_ir, ld
  ) || bool_func(
      union_ir, st
  )));

  assign long = (w2 && (bool_func(union_ir, ld) || bool_func(union_ir, st)));

  assign pcadd = w2 && ((bool_func(union_ir, jc) && c) || (bool_func(union_ir, jz) && z));

  assign lpc = (w1 && bool_func(union_ir, pc)) || (w2 && bool_func(union_ir, jmp));

  assign stop = (w1 && (bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  ) || bool_func(
      union_ir, rreg
  ) || bool_func(
      union_ir, wsto1
  ) || bool_func(
      union_ir, wsto2
  ) || bool_func(
      union_ir, rsto1
  ) || bool_func(
      union_ir, rsto2
  ) || bool_func(
      union_ir, pc
  ))) || (w2 && (bool_func(
      union_ir, stp
  ) || bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  ) || bool_func(
      union_ir, rreg
  )));

  assign mbus = (w1 && bool_func(union_ir, wsto2)) || (w3 && bool_func(union_ir, ld));

  assign memw = (w1 && bool_func(union_ir, rsto2)) || (w3 && bool_func(union_ir, st));

  assign arinc = (w1 && (bool_func(union_ir, rsto2) || bool_func(union_ir, wsto2)));

  assign selctl = (w1 && (bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  ) || bool_func(
      union_ir, rreg
  ))) || (w2 && (bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  ) || bool_func(
      union_ir, rreg
  )));

  assign sbus = (w1 && (bool_func(
      union_ir, wsto1
  ) || bool_func(
      union_ir, rsto1
  ) || bool_func(
      union_ir, wsto2
  ) || bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  ) || bool_func(
      union_ir, pc
  ) || bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  )));

  assign short = (w1 && (bool_func(
      union_ir, wsto1
  ) || bool_func(
      union_ir, wsto2
  ) || bool_func(
      union_ir, rsto1
  ) || bool_func(
      union_ir, rsto2
  ) || bool_func(
      union_ir, pc
  )));

  assign sel3 = (w1 && (bool_func(
      union_ir, wreg2
  ))) || (w2 && (bool_func(
      union_ir, wreg2
  ) || bool_func(
      union_ir, rreg
  )));

  assign sel2 = (w2 && (bool_func(union_ir, wreg2) || bool_func(union_ir, wreg1)));

  assign sel1 = (w1 && (bool_func(
      union_ir, wreg1
  ))) || (w2 && (bool_func(
      union_ir, wreg2
  ) || bool_func(
      union_ir, rreg
  )));

  assign sel0 = (w1 && (bool_func(
      union_ir, wreg1
  ) || bool_func(
      union_ir, wreg2
  ) || bool_func(
      union_ir, rreg
  ))) || (w2 && (bool_func(
      union_ir, rreg
  )));

  assign sst0 = (w1 && (bool_func(
      union_ir, wsto1
  ) || bool_func(
      union_ir, rsto1
  ) || bool_func(
      union_ir, pc
  ))) || (w2 && bool_func(
      union_ir, wreg1
  ));
endmodule
