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
    bool_func = (ir == sign);
  end
endfunction

task pick_ir_st0_1(input [7:4] ir, output lir, pcinc, output [3:0] s, output cin, abus, drw, ldz,
                   ldc, m, lar, long, input c, output pcadd, input z, output lpc, stop, mbus, memw,
                   input w1, w2, w3, output short);
  lir <= w1;
  pcinc <= w1;
  short <= 0;

  s[3] <= ((w2 && (bool_func(  //0001,0010,0101,0110(w3),1001,1011
      ir, 0001
  ) || bool_func(
      ir, 0010
  ) || bool_func(
      ir, 0101
  ) || bool_func(
      ir, 0110
  ) || bool_func(
      ir, 1001
  ) || bool_func(
      ir, 1011
  ))) || w3 && bool_func(
      ir, 0110
  ));

  s[2] <= (w2 && (bool_func(
      ir, 0010
  ) || bool_func(
      ir, 0110
  ) || bool_func(
      ir, 1001
  ) || bool_func(
      ir, 1010
  ) || bool_func(
      ir, 1011
  )));

  s[1] <= ((w2 && (bool_func(
      ir, 0010
  ) || bool_func(
      ir, 0011
  ) || bool_func(
      ir, 0101
  ) || bool_func(
      ir, 0110
  ) || bool_func(
      ir, 1001
  ) || bool_func(
      ir, 1010
  ) || bool_func(
      ir, 1011
  )) || (w3 && (bool_func(
      ir, 0110
  )))));

  s[0] <= (w2 && (bool_func(
      ir, 0001
  ) || bool_func(
      ir, 0011
  ) || bool_func(
      ir, 0110
  ) || bool_func(
      ir, 1001
  ) || bool_func(
      ir, 1011
  )));

  cin <= (w2 && (bool_func(ir, 0001) || bool_func(ir, 1011)));

  abus <= ((w2 && (bool_func(
      ir, 0001
  ) || bool_func(
      ir, 0010
  ) || bool_func(
      ir, 0011
  ) || bool_func(
      ir, 0100
  ) || bool_func(
      ir, 0101
  ) || bool_func(
      ir, 0110
  ) || bool_func(
      ir, 1001
  ) || bool_func(
      ir, 1010
  ) || bool_func(
      ir, 1011
  ))) || (w3 && (bool_func(
      ir, 0110
  ))));

  drw <= ((w2 && (bool_func(
      ir, 0001
  ) || bool_func(
      ir, 0010
  ) || bool_func(
      ir, 0011
  ) || bool_func(
      ir, 0100
  ) || bool_func(
      ir, 1010
  ) || bool_func(
      ir, 1011
  ))) || (w3 && (bool_func(
      ir, 0101
  ))));

  ldz <= (w2 && (bool_func(
      ir, 0001
  ) || bool_func(
      ir, 0010
  ) || bool_func(
      ir, 0011
  ) || bool_func(
      ir, 0100
  ) || bool_func(
      ir, 1010
  ) || bool_func(
      ir, 1011
  )));

  ldc <= (w2 && (bool_func(
      ir, 0001
  ) || bool_func(
      ir, 0010
  ) || bool_func(
      ir, 0100
  ) || bool_func(
      ir, 1011
  )));

  m <= ((w2 && (bool_func(
      ir, 0011
  ) || bool_func(
      ir, 0101
  ) || bool_func(
      ir, 0110
  ) || bool_func(
      ir, 1001
  ) || bool_func(
      ir, 1010
  ))) || (w3 && (bool_func(
      ir, 0110
  ))));

  lar <= (w2 && (bool_func(ir, 0101) || bool_func(ir, 0110)));

  long <= (w2 && (bool_func(ir, 0101) || bool_func(ir, 0110)));

  pcadd <= w2 && (c || z) && (bool_func(ir, 0111) || bool_func(ir, 1000));

  lpc <= w2 && bool_func(ir, 1001);

  stop <= w2 && bool_func(ir, 1110);

  mbus <= w3 && bool_func(ir, 0101);

  memw <= w3 && bool_func(ir, 0110);
endtask
