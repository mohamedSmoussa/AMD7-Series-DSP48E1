module Dual_A_D_PRE_Adder (A,ACIN,D,INMODE_0TO3,CEA1,CEA2,RSTA,CED,CEAD,RSTD,A_MULT,ACOUT,X_MUX_A,CLK);
parameter  A_INPUT    = "DIRECT";  // "DIRECT" or "CASCADE"
parameter  AREG       = 2; // (0,1,2) Num of A input pipeline regs
parameter  ACASCREG   = 1; // (0,1,2) Num of A cascade pipeline regs; must be <= AREG
parameter  ADREG      = 1; // (0,1) Num of AD pipeline regs
parameter  DREG       = 1; // (0,1) Num of D input pipeline regs
parameter  USE_DPORT  = "TRUE";   // "TRUE" or "FALSE" (enable pre-adder D port)
input signed [29:0] A,ACIN ;
input signed [24:0] D;
input [3:0] INMODE_0TO3;
input CEA1,CEA2,RSTA,CED,CEAD,RSTD,CLK;
output signed [29:0] ACOUT,X_MUX_A;
output signed [24:0] A_MULT;
wire   signed [29:0] A1_IN ;
wire   signed [29:0] A1_R,A2_R;
wire   signed [24:0] A_MUX_OUT1,A_MUX_OUT2,D_R,PRE_Adder_OUT,AD_R,D_OUT;

////////////////////////// Fixed Part ///////////////////////////////////
assign A1_IN   = (A_INPUT=="DIRECT")?A:ACIN;  
assign X_MUX_A = A2_R; 
assign ACOUT   = (ACASCREG==2)?A2_R:(ACASCREG==1)?A1_R:A1_IN; 
assign A_MUX_OUT1  = (INMODE_0TO3[0])? A1_R[24:0] : X_MUX_A[24:0]; 
assign A_MUX_OUT2  = A_MUX_OUT1 & {25{~INMODE_0TO3[1]}};
assign A_MULT = (USE_DPORT=="FALSE")? A_MUX_OUT2 : AD_R;
//////////////////////////////////////////////////////////////////////////
generate
if(AREG==2) begin
D_REG #(.N(30)) A1(A1_IN,RSTA,CLK,A1_R,CEA1);
D_REG #(.N(30)) A2(A1_R,RSTA,CLK,A2_R,CEA2); 
end
else if (AREG==1) begin
D_REG #(.N(30)) A1(A1_IN,RSTA,CLK,A1_R,CEA1);
assign A2_R=A1_R;    
end 
else begin
assign A1_R=A1_IN;
assign A2_R=A1_R;    
end  
endgenerate 
generate
if(USE_DPORT=="TRUE") begin  
/////////////////////////////
 if(DREG) D_REG #(.N(25)) D1(D,RSTD,CLK,D_R,CED);
 else    assign D_R=D;
/////////////////////////////
 if (ADREG) D_REG #(.N(25)) AD(PRE_Adder_OUT,RSTD,CLK,AD_R,CEAD); 
 else assign AD_R=PRE_Adder_OUT;
/////////////////////////////
assign D_OUT = D_R & {25{INMODE_0TO3[2]}};
assign PRE_Adder_OUT = (INMODE_0TO3[3])? D_OUT-A_MUX_OUT2 : D_OUT+A_MUX_OUT2;
end
endgenerate
endmodule //Dual_A&D&PRE_Adder