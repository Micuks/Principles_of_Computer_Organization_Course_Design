// pick_ir.sv

function bool_func;

  input [7:4] ir;
  input [7:4] sign;

  //   integer i;
  //   reg result = 1;
  begin
    // for (i = 7; i > 3; i = i - 1) begin
    //   result = result && (sign[i]) ? ir[i] : !ir[i];
    //   $display("sign[%0d] = %0b", i, sign[i]);
    // end
    // bool_func = result;
    bool_func = (ir[7:4] == sign[7:4]) ? 1 : 0;
    if (bool_func) begin
      $display("ir[%4b] == sign[%4b] ? %1b", ir, sign, bool_func);
    end
  end
endfunction

task pick_ir_st0_1(input [7:4] ir, output lir, pcinc, output [3:0] s, output cin, abus, drw, ldz,
                   ldc, m, lar, long, input c, output pcadd, input z, output lpc, stop, mbus, memw,
                   input w1, w2, w3, output short);

  // instruction name and ir
  localparam add = 4'b0001;
  localparam sub = 4'b0010;
  localparam aand = 4'b0011;
  localparam inc = 4'b0100;
  localparam ld = 4'b0101;
  localparam st = 4'b0110;
  localparam jc = 4'b0111;
  localparam jz = 4'b1000;
  localparam jmp = 4'b1001;
  localparam axor = 4'b1010;
  localparam dec = 4'b1011;
  localparam stp = 4'b1110;

  lir   <= w1;
  pcinc <= w1;
  short <= 0;

  $display("lir[%b] pcinc[%b] short[%b]", lir, pcinc, short);

  s[3] <= ((w2 && (bool_func(  //add,aand,ld,st(w3),jmp,dec
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
  ))) || w3 && bool_func(
      ir, st
  ));

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

  drw <= ((w2 && (bool_func(
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
  $display("w2[%1b] ldc[%1b] ir[%4b] b_f(sub)[%1b]", w2, ldc, ir, bool_func(ir, sub));

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
  $display("w2[%1b] m[%1b] ir[%4b] b_f(sub)[%1b]", w2, m, ir, bool_func(ir, sub));

  lar   <= (w2 && (bool_func(ir, ld) || bool_func(ir, st)));

  long  <= (w2 && (bool_func(ir, ld) || bool_func(ir, st)));

  pcadd <= w2 && (c || z) && (bool_func(ir, jc) || bool_func(ir, jz));

  lpc   <= w2 && bool_func(ir, jmp);

  stop  <= w2 && bool_func(ir, stp);

  mbus  <= w3 && bool_func(ir, ld);

  memw  <= w3 && bool_func(ir, st);
endtask
