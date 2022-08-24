function bool_func(input [7:4] ir, input [7:4] sign);
  integer i;
  reg result = 0;
  begin
    for (i = 7; i > 3; i = i + 1) begin
      result = result && (sign[i]) ? ir[i] : !ir[i];
      $display("sign[%0d] = %0b", i, sign[i]);
    end
    bool_func = result;
  end
endfunction

task pick_ir_st0_1(input [7:4] ir, input lir, pcinc, input [3:0] s, input cin, abus, drw, ldz, ldc,
                   m, lar, long, c, pcadd, z, lpc, stop, mbus, memw);


  lir <= w1;
  pcinc <= w1;
  s[3] <= ((w2 && (
    (!ir[7] && !ir[6] && ir[4]) || //0001,0010,0101,0110(w3),1001,1011
    (!ir[7] && ir[6] && !ir[5] && ir[4]) ||
                (!ir[7] && ir[6] && ir[5] && !ir[4]) ||
    (ir[7] && !ir[6] && ir[4]))) ||
    (w3 && (
    !ir[7] && ir[6] && ir[5] && !ir[4])
    )
    );

  s[2] <= (w2 && ((!ir[7] && !ir[6] && ir[5] && !ir[4]) ||  // 0010
  (!ir[7] && ir[6] && ir[5] && !ir[4]) ||  //0110
  (ir[7] && !ir[6] && !ir[5] && ir[4]) ||  //1001
  (bool_func(
      ir, 1010
  )) ||  //1010
  (bool_func(
      ir, 1011
  ))  //1011
  ));

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
      1001
  ) || bool_func(
      1011
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

  c <= w2 && bool_func(ir, 0111);

  pcadd <= w2 && (bool_func(ir, 0111) || bool_func(ir, 1000));

  z <= w2 && bool_func(ir, 1000);

  lpc <= w2 && bool_func(ir, 1001);

  stop <= w2 && bool_func(ir, 1110);

  mbus <= w3 && bool_func(ir, 0101);

  memw <= w3 && bool_func(ir, 0110);
endtask
