module DSP48E1 (A,B,C,D,OPMODE,ALUMODE,CARRYIN,CARRYINSEL,INMODE,CEA1,CEA2,CEB1,CEB2,CEC,CED,CEM,CEP,CEAD
,CEALUMODE,CECTRL,CECARRYIN,CEINMODE,RSTA,RSTB,RSTC,RSTD,RSTM,RSTP,RSTCTRL,RSTALLCARRYIN,RSTALUMODE,RSTINMODE
,CLK,ACIN,BCIN,PCIN,CARRYCASCIN,MULTISIGNIN,ACOUT,BCOUT,PCOUT,P,CARRYOUT,CARRYCASCOUT,MULTISIGNOUT
,PATTERNDETECT,PATTERNBDETECT,OVERFLOW,UNDERFLOW);
// ===== Pipeline / Register Control =====
parameter  ACASCREG      = 1; // (0,1,2) Num of A cascade pipeline regs; must be <= AREG
parameter  ADREG         = 1; // (0,1) Num of AD pipeline regs
parameter  ALUMODEREG    = 1; // (0,1) Num of ALUMODE pipeline regs
parameter  AREG          = 2; // (0,1,2) Num of A input pipeline regs
parameter  BCASCREG      = 1; // (0,1,2) Num of B cascade pipeline regs; must be <= BREG
parameter  BREG          = 2; // (0,1,2) Num of B input pipeline regs
parameter  CARRYINREG    = 1; // (0,1) Num of CARRYIN pipeline regs
parameter  CARRYINSELREG = 1; // (0,1) Num of CARRYINSEL pipeline regs
parameter  CREG          = 1; // (0,1) Num of C input pipeline regs
parameter  DREG          = 1; // (0,1) Num of D input pipeline regs
parameter  INMODEREG     = 1; // (0,1) Num of INMODE pipeline regs
parameter  MREG          = 1; // (0,1) Num of multiplier (M) pipeline regs
parameter  OPMODEREG     = 1; // (0,1) Num of OPMODE pipeline regs
parameter  PREG          = 1; // (0,1) Num of P output pipeline regs (also affects CARRYOUT, PATTERNDETECT, etc.)
// ===== Input Selection =====
parameter  A_INPUT        = "DIRECT";  // "DIRECT" or "CASCADE"
parameter  B_INPUT        = "DIRECT";  // "DIRECT" or "CASCADE"
// ===== D-Port / Multiplier / SIMD =====
parameter  USE_DPORT      = "TRUE";   // "TRUE" or "FALSE" (enable pre-adder D port)
parameter  USE_MULT       = "MULTIPLY";// "NONE", "MULTIPLY", "DYNAMIC"
parameter  USE_SIMD       = "ONE48";   // "ONE48", "TWO24", "FOUR12"
// ===== Pattern Detector =====
parameter  AUTORESET_PATDET = "RESET_MATCH";  // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
parameter  [47:0] MASK             = 48'hFFFFFFFFF000; // 48-bit mask (1=ignore bit, 0=compare bit)
parameter  [47:0] PATTERN          = 48'h000000000740; // 48-bit pattern for detect
parameter  SEL_MASK         = "MASK";          // "MASK", "C", "ROUNDING_MODE1", "ROUNDING_MODE2"
parameter  SEL_PATTERN      = "PATTERN";       // "PATTERN" or "C"
parameter  USE_PATTERN_DETECT = "PATDET";   // "NO_PATDET" or "PATDET"
input signed [29:0] A;                // 30-bit input
input signed [17:0] B;                // 18-bit input
input signed [47:0] C;                // 48-bit input
input signed [24:0] D;                // 25-bit input
input   [6:0] OPMODE;           // 7-bit operation mode
input   [3:0] ALUMODE;          // 4-bit ALU mode
input         CARRYIN;          // 1-bit carry-in
input   [2:0] CARRYINSEL;       // 3-bit carry-in select
input   [4:0] INMODE;           // 5-bit input mode
// Clock Enables
input CEA1, CEA2, CEB1, CEB2, CEC, CED, CEM, CEP;
input CEAD, CEALUMODE, CECTRL, CECARRYIN, CEINMODE;
// Resets
input RSTA, RSTB, RSTC, RSTD, RSTM, RSTP;
input RSTCTRL, RSTALLCARRYIN, RSTALUMODE, RSTINMODE;
// Clock
input CLK;
// Cascade Inputs
input signed [29:0] ACIN;              // 30-bit A cascade in
input signed [17:0] BCIN;              // 18-bit B cascade in
input signed [47:0] PCIN;              // 48-bit P cascade in
input        CARRYCASCIN;       // Carry cascade in
input        MULTISIGNIN;       // Multiplier sign cascade in
// ===== Outputs =====
output signed [29:0] ACOUT;            // 30-bit A cascade out
output signed [17:0] BCOUT;            // 18-bit B cascade out
output signed [47:0] PCOUT;            // 48-bit P cascade out
output signed [47:0] P;                // 48-bit result
output  [3:0] CARRYOUT;         // 4-bit carry-out bus
output        CARRYCASCOUT;     // Carry cascade out
output        MULTISIGNOUT;     // Multiplier sign cascade out
// Status Outputs
output PATTERNDETECT;           // Pattern detect
output PATTERNBDETECT;          // Pattern bar detect
output OVERFLOW;                // Overflow detect
output UNDERFLOW;               // Underflow detect 
// Internal Wires
wire [2:0] CARRYINSEL_R;
wire [4:0] INMODE_R;            // INMODE OUT OF REG
wire [6:0] OPMODE_R;            // OPMODE OUT OF REG
wire signed [17:0] B_MULT,X_MUX_B; // OUT FROM DUAL B REG BLOCK
wire CARRYIN_R,CIN;                 // CARRYIN OUT OF REG 
wire signed [47:0] C_R;         // C OUT OF REG
wire [3:0] ALUMODE_R,CARRYOUT_IN;           // ALUMODE OUT OF REG
wire signed [24:0] A_MULT;      // OUT FROM DUAL A,D,PRE_ADDER MODULE
wire signed [29:0] X_MUX_A;     // OUT FROM DUAL A,D,PRE_ADDER MODULE
wire signed [42:0] MULT_OUT,MULT_OUT_R,raw_mult;
wire signed  [47:0] X_OUT,Y_OUT,Z_OUT,P_IN;
wire AB_ROUND,AB_ROUND_R,MULTISIGNOUT_IN;
wire [47:0] Final_MASK;
wire signed [47:0] FINAL_PATTERN;
wire PD,PBD,PATTERNBDETECTPAST,PATTERNDETECTPAST;
reg signed [47:0] P_OUT; //// for AUTO RESET LOGIC 
///// connected wires 
assign AB_ROUND=~(A_MULT[24]^B_MULT[17]);
assign PCOUT=P;
assign MULTISIGNOUT_IN=MULTISIGNIN;  /// ignire becuase we use Only one Slice
assign CARRYCASCOUT=CARRYOUT[3];
generate
    //// Optional Pipeline For INMODE BUS
    if(INMODEREG) D_REG #(.N(5)) INMODE_REG(INMODE,RSTINMODE,CLK,INMODE_R,CEINMODE);
    else  assign INMODE_R=INMODE;
    //// Optional Pipeline For OPMODE BUS
    if(OPMODEREG) D_REG #(.N(7)) OPMODE_REG(OPMODE,RSTCTRL,CLK,OPMODE_R,CECTRL);
    else  assign OPMODE_R=OPMODE;
    //// Optional Pipeline For CARRYIN WIRE
    if (CARRYINREG) D_REG #(.N(1)) CARRYIN_REG(CARRYIN,RSTALLCARRYIN,CLK,CARRYIN_R,CECARRYIN);
    else assign CARRYIN_R=CARRYIN;
    //// Optional Pipeline For C BUS
    if (CREG) D_REG #(.N(48)) C_REG(C,RSTC,CLK,C_R,CEC);
    else assign C_R=C;
    //// Optional Pipeline For ALUMODE BUS
    if (ALUMODEREG) D_REG #(.N(4)) ALUMODE_REG(ALUMODE,RSTALUMODE,CLK,ALUMODE_R,CEALUMODE);
    else assign ALUMODE_R=ALUMODE;
    //// Optional Pipeline For CARRYINSEL BUS
    if(CARRYINSELREG) D_REG #(.N(3)) CARRYINSEL_REG(CARRYINSEL,RSTCTRL,CLK,CARRYINSEL_R,CECTRL);
    else assign CARRYINSEL_R=CARRYINSEL;
    //// optional pipeline for A[24] XOR B[17] WIRE
    if(MREG) D_REG #(.N(1)) ROUND_REG (~(A_MULT[24]^B_MULT[17]),RSTALLCARRYIN,CLK,AB_ROUND_R,CEM);
    else assign AB_ROUND_R=AB_ROUND;
    //// optional pipeline for MUltiply Output Bus 
    if(MREG) D_REG #(.N(43)) M_REG (MULT_OUT,RSTM,CLK,MULT_OUT_R,CEM);
    else assign MULT_OUT_R=MULT_OUT;
    //// optional pipeline for output P Bus
    if(PREG) D_REG #(.N(48)) P_REG (P_OUT,RSTP,CLK,P,CEP); 
    else assign P=P_OUT; 
    //// optional pipeline for Carry out Bus 
    if(PREG) D_REG #(.N(4)) COUT_REG (CARRYOUT_IN,RSTP,CLK,CARRYOUT,CEP);
    else assign CARRYOUT=CARRYOUT_IN;
    //// optional pipeline for MULTISIGN OUT Wire 
    if(PREG) D_REG #(.N(1)) SIGN_REG (MULTISIGNOUT_IN,RSTP,CLK,MULTISIGNOUT,CEP);
    else assign MULTISIGNOUT=MULTISIGNOUT_IN; 
endgenerate
Dual_B_Register #(.BREG(BREG),.B_INPUT(B_INPUT),.BCASCREG(BCASCREG)) 
          Dual_B_Module(B,BCIN,INMODE_R[4],BCOUT,B_MULT,X_MUX_B,CLK,CEB1,CEB2,RSTB);
Dual_A_D_PRE_Adder #(.AREG(AREG),.ACASCREG(ACASCREG),.DREG(DREG),.ADREG(ADREG),.A_INPUT(A_INPUT),.USE_DPORT(USE_DPORT)) 
          Dual_A_D_PRE_Adder_Module(A,ACIN,D,INMODE[3:0],CEA1,CEA2,RSTA,CED,CEAD,RSTD,A_MULT,ACOUT,X_MUX_A,CLK);

/////////////////// MULT 25*18/////////////////////////
generate 
if(USE_MULT=="MULTIPLY") begin
  Partial_Product #(.A_WIDTH(25),.B_WIDTH(18)) Multiplier_25_18(A_MULT,B_MULT,MULT_OUT);    
end
else if (USE_MULT=="DYNAMIC") begin
  Partial_Product #(.A_WIDTH(25),.B_WIDTH(18)) Multiplier_25_18(A_MULT,B_MULT,raw_mult);
  assign MULT_OUT=(OPMODE_R[3:0]==4'b0101)? raw_mult : 0;     
end
else if (USE_MULT=="NONE") begin
  assign MULT_OUT=0;
end
endgenerate
//////////////// X MUX /////////////////////////////////////////
MUX4_1 #(.N(48)) X_MUX({48{1'b0}},(OPMODE_R[3:2]==2'b01)?{{5{MULT_OUT_R[42]}},MULT_OUT_R}:0,(PREG)?P:0,{X_MUX_A,X_MUX_B},OPMODE_R[1:0],X_OUT);
/////////////// Y MUX //////////////////////////////////////////
MUX4_1 #(.N(48)) Y_MUX({48{1'b0}},(OPMODE_R[1:0]==2'b01)?{{5{MULT_OUT_R[42]}},MULT_OUT_R}:0,{48{1'b1}},C_R,OPMODE_R[3:2],Y_OUT);
//////////////// Z MUX ////////////////////////////////////////
MUX8_1 #(.N(48)) Z_MUX({48{1'b0}},PCIN,(PREG)?P:0,C_R,(PREG & OPMODE_R[3:0]==4'b1000)?P:0,(PCIN >>> 17),(P >>> 17),{48{1'b0}},OPMODE_R[6:4],Z_OUT);
//////////////// CIN MUX ////////////////////////////////////
MUX8_1 #(.N(1)) CIN_MUX(CARRYIN_R,~PCIN[47],CARRYCASCIN,PCIN[47],CARRYCASCOUT,~P[47],AB_ROUND_R,P[47],CARRYINSEL_R,CIN);
////////////// ALU ///////////////////////////////////////
generate
if(USE_SIMD=="ONE48") begin
ALU #(.N(48)) ALU_MODULE(X_OUT,Y_OUT,Z_OUT,CIN,ALUMODE_R,OPMODE_R,P_IN,CARRYOUT_IN[3]);
assign CARRYOUT_IN[2:0]=0;
end
else if (USE_SIMD=="TWO24") begin
ALU #(.N(24)) ALU1_MODULE(X_OUT[23:0],Y_OUT[23:0],Z_OUT[23:0],CIN,ALUMODE_R,OPMODE_R,P_IN[23:0],CARRYOUT_IN[1]);
ALU #(.N(24)) ALU2_MODULE(X_OUT[47:24],Y_OUT[47:24],Z_OUT[47:24],0,ALUMODE_R,OPMODE_R,P_IN[47:24],CARRYOUT_IN[3]);
assign CARRYOUT_IN[0]=0;
assign CARRYOUT_IN[2]=0;   
end
else if(USE_SIMD=="FOUR12") begin
ALU #(.N(12)) ALU1_MODULE(X_OUT[11:0],Y_OUT[11:0],Z_OUT[11:0],CIN,ALUMODE_R,OPMODE_R,P_IN[11:0],CARRYOUT_IN[0]);
ALU #(.N(12)) ALU2_MODULE(X_OUT[23:12],Y_OUT[23:12],Z_OUT[23:12],0,ALUMODE_R,OPMODE_R,P_IN[23:12],CARRYOUT_IN[1]); 
ALU #(.N(12)) ALU3_MODULE(X_OUT[35:24],Y_OUT[35:24],Z_OUT[35:24],0,ALUMODE_R,OPMODE_R,P_IN[35:24],CARRYOUT_IN[2]);
ALU #(.N(12)) ALU4_MODULE(X_OUT[47:36],Y_OUT[47:36],Z_OUT[47:36],0,ALUMODE_R,OPMODE_R,P_IN[47:36],CARRYOUT_IN[3]);   
end
endgenerate
/////////// pattern detection part//////////////////
genvar i;
generate
if(USE_PATTERN_DETECT=="PATDET")begin 
assign Final_MASK=(SEL_MASK=="MASK")? MASK 
                 :(SEL_MASK=="C")?C_R
                 :(SEL_MASK=="ROUNDING_MODE1")?(~C_R)<<1
                 :(SEL_MASK=="ROUNDING_MODE2")?(~C_R)<<2
                 :0;
assign FINAL_PATTERN=(SEL_PATTERN=="PATTERN")?PATTERN
                    :(SEL_PATTERN=="C")?C_R:0;
///////////////// Mask Comparing Module ///////////
Mask_Compare COMPARE_MODULE(P,FINAL_PATTERN,Final_MASK,PD,PBD);
///////////////// Pipeline to detection Flags /////////////////
if(PREG) begin
D_REG #(.N(1)) PD_REG(PD,RSTP,CLK,PATTERNDETECT,CEP);
D_REG #(.N(1)) PBD_REG(PBD,RSTP,CLK,PATTERNBDETECT,CEP);
end
else begin
  assign PATTERNDETECT=PD;
  assign PATTERNBDETECT=PBD;
end
/// PAST VERSIONS PIPELINED WITHOUT CONDTIONS
D_REG #(.N(1)) PD_PAST_REG(PATTERNDETECT,RSTP,CLK,PATTERNDETECTPAST,CEP); 
D_REG #(.N(1)) PBD_PAST_REG(PATTERNBDETECT,RSTP,CLK,PATTERNBDETECTPAST,CEP);
/// Under Flow and Over Flow Flags 
assign OVERFLOW=(~PATTERNDETECT)&(~PATTERNBDETECT)&(PATTERNDETECTPAST);
assign UNDERFLOW=(~PATTERNDETECT)&(~PATTERNBDETECT)&(PATTERNBDETECTPAST);
end
endgenerate
////////////// AUTO RESET LOGIC /////////////////
 generate
if(USE_PATTERN_DETECT=="PATDET") begin
  if(AUTORESET_PATDET=="RESET_MATCH") begin
    always@(*)begin
     if(PATTERNDETECT) P_OUT=0;
     else P_OUT=P_IN;
  end
  end
  else if (AUTORESET_PATDET=="RESET_NOT_MATCH")begin
    always@(*) begin
    if(PATTERNBDETECT) P_OUT=0;
    else P_OUT=P_IN;
  end
end
else begin
  always @(*) begin
   P_OUT=P_IN; 
  end
end
end
  endgenerate

endmodule //DSP48E1