module Dual_B_Register (B,BCIN,INMODE_4,BCOUT,B_MULT,X_MUX_B,CLK,CEB1,CEB2,RSTB);
parameter  BREG      = 2; // (0,1,2) Num of B input pipeline regs
parameter  B_INPUT   = "DIRECT";  // "DIRECT" or "CASCADE"
parameter  BCASCREG  = 2; // (0,1,2) Num of B cascade pipeline regs; must be <= BREG
input  signed[17:0] B,BCIN;
input INMODE_4,CLK,CEB1,CEB2,RSTB;
output signed [17:0] BCOUT,B_MULT,X_MUX_B;
wire   signed [17:0] B1_IN ;
wire   signed [17:0] B1_R,B2_R;
assign B1_IN  = (B_INPUT=="DIRECT")?B:BCIN;
assign X_MUX_B  = B2_R;
assign B_MULT = (INMODE_4)? B1_R : X_MUX_B;
assign BCOUT  = (BCASCREG==2)?B2_R:(BCASCREG==1)?B1_R:B1_IN;
generate
if(BREG==2) begin
D_REG #(.N(18)) B1(B1_IN,RSTB,CLK,B1_R,CEB1);
D_REG #(.N(18)) B2(B1_R,RSTB,CLK,B2_R,CEB2);
end
else if (BREG==1) begin
D_REG #(.N(18)) B1(B1_IN,RSTB,CLK,B1_R,CEB1);
assign B2_R=B1_R ;   
end
else begin
assign  B1_R=B1_IN; 
assign  B2_R=B1_R; 
end    
endgenerate
endmodule //Dual_B_Register