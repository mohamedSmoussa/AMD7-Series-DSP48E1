package DSP48E1_P;
class DSP48E1_Stimulus;
  // Inputs
  rand logic signed [29:0] A, ACIN;
  rand logic signed [17:0] B, BCIN;
  rand logic signed [47:0] C, PCIN;
  rand logic signed [24:0] D;
  rand logic [6:0]  OPMODE;
  rand logic [3:0]  ALUMODE;
  rand logic        CARRYIN;
  rand logic [2:0]  CARRYINSEL;
  rand logic [4:0]  INMODE;
  rand logic CARRYCASCIN;
  rand logic MULTISIGNIN;
  constraint OP{
    OPMODE[6:4] inside {[0:6]};
    CARRYINSEL inside{[0:5],7};
  }
  function new();
      A = '0;
      B = '0;
      C = '0;
      D = '0;
      ACIN = '0;
      BCIN = '0;
      PCIN = '0;
      OPMODE = 7'd0;
      ALUMODE = 4'd0;
      CARRYIN = 1'b0;
      CARRYINSEL = 3'd0;
      INMODE = 5'd0;
      CARRYCASCIN = 1'b0;
      MULTISIGNIN = 1'b0;
    endfunction
endclass
endpackage