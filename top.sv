function bool_func;

  input [8:0] ir;
  input [8:0] sign;

  begin
    bool_func = (ir[8:0] == sign[8:0]) ? 1'b1 : 1'b0;
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
    output [3:0] s,
    output m,
    abus,
    sbus,
    mbus,
    short,
    long,
    sel0,
    sel1,
    sel2,
    sel3,
    input pulse,
    output dbg_led
);

  reg st0;
  wire sst0;
  wire [2:0] sw;
  wire [8:0] union_ir;  // {ir[7:4], sw[2:0], st0, st1}

  // interrupt part
  reg int0;  // interrupt flag
  wire inten;  // let en_int = 1 when inten == 1
  wire intdi;  // let en_int = 0 when intdi == 1
  reg en_int;  // allow interrupt flag
  reg st1;  // interrupt stage flag

  assign sw = {swc, swb, swa};

  assign union_ir = {ir[7:4], sw[2:0], st0, st1};

  // instruction name and ir {ir[7:4], sw[2:0], st0, st1}
  // interrupt instructions
  localparam iret = 9'b111100010;

  // pc modifier instructions
  localparam pc = 9'b000000000;
  localparam spc = 9'b000000010;  // equals to nop instruction
  localparam nop = 9'b000000010;  // equals to spc instruction

  // basic instructions
  localparam add = 9'b000100010;
  localparam sub = 9'b001000010;
  localparam aand = 9'b001100010;
  localparam inc = 9'b010000010;
  localparam ld = 9'b010100010;
  localparam st = 9'b011000010;
  localparam jc = 9'b011100010;
  localparam jz = 9'b100000010;
  localparam jmp = 9'b100100010;

  // added instructions
  localparam axor = 9'b101000010;
  localparam dec = 9'b101100010;
  localparam stp = 9'b111000010;

  // register ans storage instructions
  localparam wreg1 = 9'b000010000;
  localparam wreg2 = 9'b000010010;
  localparam rreg = 9'b000001100;
  localparam rsto1 = 9'b000001000;
  localparam rsto2 = 9'b000001010;
  localparam wsto1 = 9'b000000100;
  localparam wsto2 = 9'b000000110;


  // st0 sequential logic part
  always @(negedge clr, negedge t3) begin
    if (~clr) begin
      st0 <= 1'b0;
    end else if (~t3) begin
      if (st0 == 1'b1 & w2 == 1'b1 & sw == 3'b100) begin
        st0 <= 1'b0;
      end
      if (sst0 == 1'b1) begin
        // $display("sst0[%1b]", sst0);
        st0 <= 1'b1;
      end
    end else begin
      st0 <= st0;
    end
    // $display("st0[%1b]", st0);
  end

  // st1 sequential logic part
  always @(negedge clr, negedge t3) begin  // pulse is unsure
    if (~clr) begin
      st1 <= 1'b0;
    end else if (~t3) begin
      if (~st1 & int0 & ((w2 & (bool_func(
              union_ir, spc  // spc == nop
          ) | bool_func(
              union_ir, add
          ) | bool_func(
              union_ir, sub
          ) | bool_func(
              union_ir, aand
          ) | bool_func(
              union_ir, inc
          ) | bool_func(
              union_ir, jc
          ) | bool_func(
              union_ir, jz
          ) | bool_func(
              union_ir, jc
          ) | bool_func(
              union_ir, jmp
          ) | bool_func(
              union_ir, axor
          ) | bool_func(
              union_ir, dec
          ) | bool_func(
              union_ir, stp
          ))) | (w3 & (bool_func(
              union_ir, ld
          ) | bool_func(
              union_ir, st
          ))))) begin
        st1 <= 1'b1;
      end else if (st1 & ~int0 & w2) begin
        st1 <= 1'b0;
      end
    end else begin
      st1 <= st1;
    end
    $display("st1[%1b]", st1);
  end

  // en_int enable interrupt sequential logic part
  always @(negedge clr, negedge t3) begin
    if (~clr) begin
      en_int <= 1'b1;
    end else if (~t3) begin
      en_int <= (inten | (en_int & ~intdi));
    end else begin
      en_int <= en_int;  // unpredicted corner case
    end
    $display("en_int[%1b]", en_int);
  end

  // int0 interrupt flag
  always @(negedge clr, posedge pulse, negedge en_int) begin
    if (~clr) begin
      int0 <= 1'b0;
    end
    if (pulse) begin
      int0 <= en_int;
    end
    if (!en_int) begin
      int0 <= 1'b0;
    end
  end

  // combinational logic part
  assign intdi = st1 & w1;

  assign inten = bool_func(union_ir, iret) & w2;

  assign lir = (w1 & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jc
  ) | bool_func(
      union_ir, jz
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ) | bool_func(
      union_ir, stp
  ) | bool_func(
      union_ir, spc
  )));

  assign pcinc = (w1 & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jc
  ) | bool_func(
      union_ir, jz
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ) | bool_func(
      union_ir, stp
  ) | bool_func(
      union_ir, spc
  )));


  assign s[3] = ((w2 & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, dec
  ))) | (w3 & (bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, iret
  ))));


  assign s[2] = (w2 & (bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  )));

  assign s[1] = ((w2 & (bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ))) | (w3 & (bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, iret
  ))));

  assign s[0] = (w2 & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, dec
  )));

  assign cin = (w2 & (bool_func(union_ir, add) | bool_func(union_ir, dec)));

  assign abus = ((w1 & (en_int & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jc
  ) | bool_func(
      union_ir, jz
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ) | bool_func(
      union_ir, stp
  ) | bool_func(
      union_ir, spc
  )))) | (w2 & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ))) | (w3 & (bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, iret
  ))));

  assign drw = (w1 & (bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, pc
  ) | (en_int & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jc
  ) | bool_func(
      union_ir, jz
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ) | bool_func(
      union_ir, stp
  ) | bool_func(
      union_ir, spc
  ))))) | (w2 & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ) | bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  )) | (en_int & bool_func(
      union_ir, jmp
  ))) | (w3 & (bool_func(
      union_ir, ld
  )));

  assign ldz = (w2 & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  )));

  assign ldc = (w2 & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, dec
  )));
  //   $display("w2[%1b] ldc[%1b] union_ir[%4b] b_f(sub)[%1b]", w2, ldc, union_ir, bool_func(union_ir, sub));

  assign m = ((w2 & (bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ))) | (w3 & (bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, iret
  ))));
  //   $display("w2[%1b] m[%1b] union_ir[%4b] b_f(sub)[%1b]", w2, m, union_ir, bool_func(union_ir, sub));

  assign lar = (w1 & (bool_func(
      union_ir, wsto1
  ) | bool_func(
      union_ir, rsto1
  ))) | (w2 & (bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  )));

  assign long = (w2 & (bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, iret
  )));

  assign pcadd = w2 & ((bool_func(union_ir, jc) & c) | (bool_func(union_ir, jz) & z));

  assign lpc = (w1 & bool_func(
      union_ir, pc
  )) | (w2 & (bool_func(
      union_ir, jmp
  ) | st1)) | (w3 & bool_func(
      union_ir, iret
  ));

  assign stop = (w1 & (bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, rreg
  ) | bool_func(
      union_ir, wsto1
  ) | bool_func(
      union_ir, wsto2
  ) | bool_func(
      union_ir, rsto1
  ) | bool_func(
      union_ir, rsto2
  ) | bool_func(
      union_ir, pc
  ) | st1)) | (w2 & (bool_func(
      union_ir, stp
  ) | bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, rreg
  )));

  assign mbus = (w1 & bool_func(union_ir, rsto2)) | (w3 & bool_func(union_ir, ld));

  assign memw = (w1 & bool_func(union_ir, wsto2)) | (w3 & bool_func(union_ir, st));

  assign arinc = (w1 & (bool_func(union_ir, rsto2) | bool_func(union_ir, wsto2)));

  assign selctl = (w1 & (bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, rreg
  ) | bool_func(
      union_ir, wsto1
  ) | bool_func(
      union_ir, wsto2
  ) | bool_func(
      union_ir, rsto1
  ) | bool_func(
      union_ir, rsto2
  ) | bool_func(
      union_ir, pc
  ) | (en_int & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jc
  ) | bool_func(
      union_ir, jz
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ) | bool_func(
      union_ir, stp
  ) | bool_func(
      union_ir, spc
  ))))) | (w2 & (bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, rreg
  ))) | (w3 & (bool_func(
      union_ir, iret
  )));

  assign sbus = (w1 & (bool_func(
      union_ir, wsto1
  ) | bool_func(
      union_ir, wsto2
  ) | bool_func(
      union_ir, rsto1
  ) | bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, pc
  ))) | (w2 & (bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  ))) | (st1 & w2);

  assign short = (w1 & (bool_func(
      union_ir, wsto1
  ) | bool_func(
      union_ir, wsto2
  ) | bool_func(
      union_ir, rsto1
  ) | bool_func(
      union_ir, rsto2
  ) | bool_func(
      union_ir, pc
  )));

  assign sel3 = (w1 & (bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, pc
  )) | ((bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jc
  ) | bool_func(
      union_ir, jz
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ) | bool_func(
      union_ir, stp
  ) | bool_func(
      union_ir, spc
  )) & en_int)) | (w2 & (bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, rreg
  )));

  assign sel2 = (w2 & (bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, wreg1
  ))) | (w1 & bool_func(
      union_ir, pc
  ) | (en_int & (bool_func(
      union_ir, add
  ) | bool_func(
      union_ir, sub
  ) | bool_func(
      union_ir, aand
  ) | bool_func(
      union_ir, inc
  ) | bool_func(
      union_ir, ld
  ) | bool_func(
      union_ir, st
  ) | bool_func(
      union_ir, jc
  ) | bool_func(
      union_ir, jz
  ) | bool_func(
      union_ir, jmp
  ) | bool_func(
      union_ir, axor
  ) | bool_func(
      union_ir, dec
  ) | bool_func(
      union_ir, stp
  ) | bool_func(
      union_ir, spc
  ))));

  assign sel1 = (w1 & (bool_func(
      union_ir, wreg1
  ))) | (w2 & (bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, rreg
  ))) | (w3 & (bool_func(
      union_ir, iret
  )));

  assign sel0 = (w1 & (bool_func(
      union_ir, wreg1
  ) | bool_func(
      union_ir, wreg2
  ) | bool_func(
      union_ir, rreg
  ))) | (w2 & (bool_func(
      union_ir, rreg
  ))) | (w3 & (bool_func(
      union_ir, iret
  )));

  assign sst0 = (w1 & (bool_func(
      union_ir, wsto1
  ) | bool_func(
      union_ir, rsto1
  ) | bool_func(
      union_ir, pc
  ))) | (w2 & bool_func(
      union_ir, wreg1
  ));

  assign dbg_led = en_int;

endmodule
