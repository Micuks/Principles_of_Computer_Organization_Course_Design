// pick_ir.sv

function bool_func;

  input [7:0] ir;
  input [7:0] sign;

  begin
    bool_func = (ir[7:0] == sign[7:0]) ? 1'b1 : 1'b0;
    if (bool_func) begin
      //   $display("ir[%4b] == sign[%4b] ? %1b", ir, sign, bool_func);
    end
  end
endfunction

task pick_ir_st0_1(input [7:0] ir, output lir, pcinc, output [3:0] s, output cin, abus, drw, ldz,
                   ldc, m, lar, long, arinc, sbus, short, sel3, sel2, sel1, sel0, selctl, sst0,
                   input c, output pcadd, input z, output lpc, stop, mbus, memw, input w1, w2, w3);

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
  localparam wsto1 = 8'b00000010;
  localparam wsto2 = 8'b00000011;
  localparam rsto1 = 8'b00000100;
  localparam rsto2 = 8'b00000101;
  localparam pc = 8'b00000000;
  localparam spc = 8'b00000001;

  lir <= (w1 && (bool_func(
      ir, add
  ) || bool_func(
      ir, sub
  ) || bool_func(
      ir, aand
  ) || bool_func(
      ir, inc
  ) || bool_func(
      ir, ld
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jc
  ) || bool_func(
      ir, jz
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, axor
  ) || bool_func(
      ir, dec
  ) || bool_func(
      ir, stp
  ) || bool_func(
      ir, spc
  )));

  pcinc <= (w1 && (bool_func(
      ir, add
  ) || bool_func(
      ir, sub
  ) || bool_func(
      ir, aand
  ) || bool_func(
      ir, inc
  ) || bool_func(
      ir, ld
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jc
  ) || bool_func(
      ir, jz
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, axor
  ) || bool_func(
      ir, dec
  ) || bool_func(
      ir, stp
  ) || bool_func(
      ir, spc
  )));

  s[3] <= ((w2 && (bool_func(
      ir, add
  ) || bool_func(
      ir, aand
  ) || bool_func(
      ir, ld
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, dec
  ))) || (w3 && bool_func(
      ir, st
  )));

  s[2] <= (w2 && (bool_func(
      ir, sub
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, axor
  ) || bool_func(
      ir, dec
  )));

  s[2] <= (w2 && (bool_func(
      ir, sub
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, axor
  ) || bool_func(
      ir, dec
  )));

  s[1] <= ((w2 && (bool_func(
      ir, sub
  ) || bool_func(
      ir, aand
  ) || bool_func(
      ir, ld
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, axor
  ) || bool_func(
      ir, dec
  )) || (w3 && (bool_func(
      ir, st
  )))));

  s[0] <= (w2 && (bool_func(
      ir, add
  ) || bool_func(
      ir, aand
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, dec
  )));

  cin <= (w2 && (bool_func(ir, add) || bool_func(ir, dec)));

  abus <= ((w2 && (bool_func(
      ir, add
  ) || bool_func(
      ir, sub
  ) || bool_func(
      ir, aand
  ) || bool_func(
      ir, inc
  ) || bool_func(
      ir, ld
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, axor
  ) || bool_func(
      ir, dec
  ))) || (w3 && (bool_func(
      ir, st
  ))));

  drw <= ((w1 && (bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  ))) || (w2 && (bool_func(
      ir, add
  ) || bool_func(
      ir, sub
  ) || bool_func(
      ir, aand
  ) || bool_func(
      ir, inc
  ) || bool_func(
      ir, axor
  ) || bool_func(
      ir, dec
  ) || bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  ))) || (w3 && (bool_func(
      ir, ld
  ))));

  ldz <= (w2 && (bool_func(
      ir, add
  ) || bool_func(
      ir, sub
  ) || bool_func(
      ir, aand
  ) || bool_func(
      ir, inc
  ) || bool_func(
      ir, axor
  ) || bool_func(
      ir, dec
  )));

  ldc <= (w2 && (bool_func(
      ir, add
  ) || bool_func(
      ir, sub
  ) || bool_func(
      ir, inc
  ) || bool_func(
      ir, dec
  )));
  //   $display("w2[%1b] ldc[%1b] ir[%4b] b_f(sub)[%1b]", w2, ldc, ir, bool_func(ir, sub));

  m <= ((w2 && (bool_func(
      ir, aand
  ) || bool_func(
      ir, ld
  ) || bool_func(
      ir, st
  ) || bool_func(
      ir, jmp
  ) || bool_func(
      ir, axor
  ))) || (w3 && (bool_func(
      ir, st
  ))));
  //   $display("w2[%1b] m[%1b] ir[%4b] b_f(sub)[%1b]", w2, m, ir, bool_func(ir, sub));

  lar <= (w1 && (bool_func(
      ir, wsto1
  ) || bool_func(
      ir, rsto1
  ))) || (w2 && (bool_func(
      ir, ld
  ) || bool_func(
      ir, st
  )));

  long <= (w2 && (bool_func(ir, ld) || bool_func(ir, st)));

  pcadd <= w2 && ((bool_func(ir, jc) && c) || (bool_func(ir, jz) && z));

  lpc <= (w1 && bool_func(ir, pc)) || (w2 && bool_func(ir, jmp));

  stop <= (w1 && (bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  ) || bool_func(
      ir, rreg
  ) || bool_func(
      ir, wsto1
  ) || bool_func(
      ir, wsto2
  ) || bool_func(
      ir, rsto1
  ) || bool_func(
      ir, rsto2
  ) || bool_func(
      ir, pc
  ))) || (w2 && (bool_func(
      ir, stp
  ) || bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  ) || bool_func(
      ir, rreg
  )));

  mbus <= (w1 && bool_func(ir, rsto2)) || (w3 && bool_func(ir, ld));

  memw <= (w1 && bool_func(ir, wsto2)) || (w3 && bool_func(ir, st));

  arinc <= (w1 && bool_func(ir, rsto2) || bool_func(ir, wsto2));

  selctl <= (w1 && (bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  ) || bool_func(
      ir, rreg
  ))) || (w2 && (bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  ) || bool_func(
      ir, rreg
  )));

  sbus <= (w1 && (bool_func(
      ir, wsto1
  ) || bool_func(
      ir, rsto1
  ) || bool_func(
      ir, wsto2
  ) || bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  ) || bool_func(
      ir, pc
  ))) || (w2 && (bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  )));

  short <= (w1 && (bool_func(
      ir, wsto1
  ) || bool_func(
      ir, wsto2
  ) || bool_func(
      ir, rsto1
  ) || bool_func(
      ir, rsto2
  ) || bool_func(
      ir, pc
  )));

  sel3 <= (w1 && (bool_func(ir, wreg2))) ||
  (w2 && (bool_func(ir, wreg2) ||
  bool_func(ir, rreg)));

  sel2 <= (w2 && (bool_func(ir, wreg2) || bool_func(ir, wreg1)));

  sel1 <= (w1 && (bool_func(ir, wreg1))) || (w2 && (bool_func(ir, wreg2) || bool_func(ir, rreg)));

  sel0 <= (w1 && (bool_func(
      ir, wreg1
  ) || bool_func(
      ir, wreg2
  ) || bool_func(
      ir, rreg
  ))) || (w2 && (bool_func(
      ir, rreg
  )));

  sst0 <= (w1 && (bool_func(
      ir, wsto1
  ) || bool_func(
      ir, rsto1
  ) || bool_func(
      ir, pc
  ))) || (w2 && bool_func(
      ir, wreg1
  ));
endtask
