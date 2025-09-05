module DSP48E1_tb();
import DSP48E1_P::*;
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
parameter  [47:0] MASK             = 48'hFFFF00FFFFFF; // 48-bit mask (1=ignore bit, 0=compare bit)
parameter  [47:0] PATTERN          = 48'h000054000000; // 48-bit pattern for detect
parameter  SEL_MASK         = "MASK";          // "MASK", "C", "ROUNDING_MODE1", "ROUNDING_MODE2"
parameter  SEL_PATTERN      = "PATTERN";       // "PATTERN" or "C"
parameter  USE_PATTERN_DETECT = "PATDET";   // "NO_PATDET" or "PATDET"
// Testbench signals
logic signed [29:0] A, ACIN;        // Inputs
logic signed [17:0] B, BCIN;
logic signed [47:0] C, PCIN;
logic signed [24:0] D;
logic [6:0] OPMODE;
logic [3:0] ALUMODE;
logic CARRYIN;
logic [2:0] CARRYINSEL;
logic [4:0] INMODE;
// Clock enables
logic CEA1, CEA2, CEB1, CEB2, CEC, CED, CEM, CEP;
logic CEAD, CEALUMODE, CECTRL, CECARRYIN, CEINMODE;
// Resets
logic RSTA, RSTB, RSTC, RSTD, RSTM, RSTP;
logic RSTCTRL, RSTALLCARRYIN, RSTALUMODE, RSTINMODE;
// Clock
logic CLK;
// Cascade inputs
logic CARRYCASCIN;
logic MULTISIGNIN;
// DUT outputs
logic signed [29:0] ACOUT,ACOUT_EXP;
logic signed [17:0] BCOUT,BCOUT_EXP;
logic signed [47:0] PCOUT,PCOUT_EXP;
logic signed [47:0] P,P_EXP;
logic [3:0] CARRYOUT,CARRYOUT_EXP;
logic CARRYCASCOUT,CARRYCASCOUT_EXP;
logic MULTISIGNOUT,MULTISIGNOUT_EXP;
// Status outputs
logic PATTERNDETECT;
logic PATTERNBDETECT;
logic OVERFLOW;
logic UNDERFLOW;
logic rst_flag;
integer correct_count,error_count;
assign CARRYOUT_EXP[2:0]=0;
assign CARRYCASCOUT_EXP=CARRYOUT_EXP[3];
assign MULTISIGNOUT_EXP=MULTISIGNIN;
assign ACOUT_EXP=A;
assign BCOUT_EXP=B;
assign PCOUT_EXP=P_EXP;
DSP48E1 #(.AREG(AREG),.BREG(BREG), .USE_MULT(USE_MULT),  .PREG(PREG),
  .DREG(DREG),.CARRYINREG(CARRYINREG),.CARRYINSELREG(CARRYINSELREG),
  .ADREG(ADREG),.INMODEREG(INMODEREG),.MREG(MREG),.OPMODEREG(OPMODEREG),
  .ACASCREG(ACASCREG),.BCASCREG(BCASCREG),.A_INPUT(A_INPUT),.B_INPUT(B_INPUT),
  .USE_DPORT(USE_DPORT),.USE_SIMD(USE_SIMD),.AUTORESET_PATDET(AUTORESET_PATDET),
  .MASK(MASK),.PATTERN(PATTERN),.SEL_MASK(SEL_MASK),.SEL_PATTERN(SEL_PATTERN),
  .USE_PATTERN_DETECT(USE_PATTERN_DETECT)) DUT(.*);
initial begin
    CLK=0;
    forever begin
        #1 CLK=~CLK;
    end
end 
task Golden_Model(input logic signed [47:0]Z_OUT,Y_OUT,X_OUT , input logic cin);
if(rst_flag) {CARRYOUT_EXP[3],P_EXP}=0;
else begin
case (ALUMODE)
  4'b0000: {CARRYOUT_EXP[3],P_EXP} = Z_OUT + X_OUT + Y_OUT +$signed({47'd0,cin}) ;
  4'b0001: {CARRYOUT_EXP[3],P_EXP} = ~Z_OUT + X_OUT + Y_OUT +$signed({47'd0,cin}) ;
  4'b0010: {CARRYOUT_EXP[3],P_EXP} = ~(Z_OUT + X_OUT + Y_OUT +$signed({47'd0,cin}));
  4'b0011: {CARRYOUT_EXP[3],P_EXP} = Z_OUT - (X_OUT + Y_OUT +$signed({47'd0,cin}));
  4'b0100: {CARRYOUT_EXP[3],P_EXP} =(OPMODE[3:2]==2'b00) ?  (X_OUT ^ Z_OUT) :
                         (OPMODE[3:2]==2'b10) ? ~(X_OUT ^ Z_OUT) : 0;
  4'b0101: {CARRYOUT_EXP[3],P_EXP} =(OPMODE[3:2]==2'b00) ? ~(X_OUT ^ Z_OUT) :
                         (OPMODE[3:2]==2'b10) ?  (X_OUT ^ Z_OUT) : 0;
  4'b0110: {CARRYOUT_EXP[3],P_EXP} =(OPMODE[3:2]==2'b00) ? ~(X_OUT ^ Z_OUT) :
                         (OPMODE[3:2]==2'b10) ?  (X_OUT ^ Z_OUT) : 0;
  4'b0111: {CARRYOUT_EXP[3],P_EXP} =(OPMODE[3:2]==2'b00) ?  (X_OUT ^ Z_OUT) :
                         (OPMODE[3:2]==2'b10) ? ~(X_OUT ^ Z_OUT) : 0;
  4'b1100: {CARRYOUT_EXP[3],P_EXP} =(OPMODE[3:2]==2'b00) ?  (X_OUT & Z_OUT) :
                         (OPMODE[3:2]==2'b10) ?  (X_OUT | Z_OUT) : 0;
  4'b1101: {CARRYOUT_EXP[3],P_EXP} =(OPMODE[3:2]==2'b00) ?  (X_OUT & ~Z_OUT) :
                         (OPMODE[3:2]==2'b10) ?  (X_OUT | ~Z_OUT) : 0;
  4'b1110: {CARRYOUT_EXP[3],P_EXP} =(OPMODE[3:2]==2'b00) ? ~(X_OUT & Z_OUT) :
                         (OPMODE[3:2]==2'b10) ? ~(X_OUT | Z_OUT) : 0;
  4'b1111: {CARRYOUT_EXP[3],P_EXP} =(OPMODE[3:2]==2'b00) ?  ((~X_OUT) | Z_OUT) :
                         (OPMODE[3:2]==2'b10) ?  ((~X_OUT) & Z_OUT) : 0;
  default: {CARRYOUT_EXP[3],P_EXP} =0;
endcase
end
endtask
task assert_reset();
RSTA=1;RSTB=1;RSTC=1;RSTD=1;RSTM=1;RSTP=1;RSTCTRL=1;
RSTALLCARRYIN=1;RSTALUMODE=1;RSTINMODE=1;
rst_flag=1;
check_result(0,0,0,0);
RSTA=0;RSTB=0;RSTC=0;RSTD=0;RSTM=0;RSTP=0;RSTCTRL=0;
RSTALLCARRYIN=0;RSTALUMODE=0;RSTINMODE=0;
rst_flag=0;
endtask
task check_result(input logic signed [47:0]Z_OUT,Y_OUT,X_OUT , input logic cin);
Golden_Model(Z_OUT,Y_OUT,X_OUT,cin);
if(ACOUT_EXP!=ACOUT || BCOUT_EXP!=BCOUT || MULTISIGNOUT_EXP!=MULTISIGNOUT) begin
    $display("ERROR IN DUALS CASC OUT A AND B");
    error_count=error_count+1;
end
else correct_count=correct_count+1;
if (PATTERNDETECT==1) begin
    P_EXP=0;
end
@(negedge CLK);  /// to cover  Pattern cases
if(P_EXP!=P || PCOUT_EXP!=PCOUT || CARRYOUT_EXP!=CARRYOUT || CARRYCASCOUT_EXP!= CARRYCASCOUT) begin
     $display("ERROR IN DSP48E1 FUNCTION ");
     error_count=error_count+1;
end
else correct_count=correct_count+1;
endtask
initial begin
    logic signed [24:0] dual_a_out;
    logic signed [42:0] mult;
    logic signed [47:0] X,Y,Z,P_FED_CIN,P_FED_XZ;
    logic carryin,carryout_fed;
    DSP48E1_Stimulus TEST;
    TEST=new();
    correct_count=0; error_count=0;
    assert_reset();
    {CEA1, CEA2, CEB1, CEB2, CEC, CED, CEM, CEP}=8'hFF;
    {CEAD, CEALUMODE, CECTRL, CECARRYIN, CEINMODE}=5'b11111;
    repeat(20000) begin
     assert(TEST.randomize());
     A = TEST.A;
     B = TEST.B;
     C = TEST.C;
     D = TEST.D;
     ACIN = TEST.ACIN;
     BCIN = TEST.BCIN;
     PCIN = TEST.PCIN;
     CARRYIN= TEST.CARRYIN;
     OPMODE = TEST.OPMODE;
     ALUMODE= TEST.ALUMODE;
     INMODE = TEST.INMODE;
     CARRYINSEL = TEST.CARRYINSEL;
     MULTISIGNIN = TEST.MULTISIGNIN;
     CARRYCASCIN = TEST.CARRYCASCIN;
      repeat(2) @(negedge CLK);
      P_FED_XZ=P;
      @(negedge CLK); 
      P_FED_CIN=P;
      P_FED_XZ=P;
      carryout_fed=CARRYCASCOUT; // to prevent feedback proplem
    case (INMODE[3:0])
     0:dual_a_out=A[24:0];   
     1:dual_a_out=A[24:0];
     2:dual_a_out=0;
     3:dual_a_out=0;
     4:dual_a_out=D+A[24:0];
     5:dual_a_out=D+A[24:0];
     6:dual_a_out=D;
     7:dual_a_out=D;
     8:dual_a_out=-A[24:0];
     9:dual_a_out=-A[24:0];
    10:dual_a_out=0;
    11:dual_a_out=0;
    12:dual_a_out=D-A[24:0];
    13:dual_a_out=D-A[24:0];
    14:dual_a_out=D;
    15:dual_a_out=D;
   endcase
     case(OPMODE[1:0]) 
     0:X=0;
     1:X=(OPMODE[3:2]==2'b01)?{{5{mult[42]}},mult}:0;
     2:X=P_FED_XZ;
     3:X={A,B};
     endcase
     case(OPMODE[3:2])
     0:Y=0;
     1:Y=(OPMODE[1:0]==2'b01)?{{5{mult[42]}},mult}:0;
     2:Y={48{1'b1}};
     3:Y=C;
     endcase
     case(OPMODE[6:4])
     0:Z=0;
     1:Z=PCIN;
     2:Z=P_FED_XZ;
     3:Z=C;
     4:Z=(OPMODE[3:0]==8)?P_FED_XZ:0;
     5:Z=PCIN>>>17;
     6:Z=P_FED_XZ>>>17;
     endcase
     case(CARRYINSEL) 
     0:carryin=CARRYIN;
     1:carryin=~PCIN[47];
     2:carryin=CARRYCASCIN;
     3:carryin=PCIN[47];
     4:carryin=carryout_fed;
     5:carryin=~P_FED_CIN[47];
     6:carryin=~(dual_a_out[24]^B[17]);
     7:carryin=P_FED_XZ[47];
     endcase
     check_result(Z,Y,X,carryin);
    end
    assert_reset();
    $display("TIME : %0t :::::: ERROR_COUNT = %0d :::::: CORRECT_COUNT = %0d ",$time,error_count,correct_count);
    $stop;
end
endmodule