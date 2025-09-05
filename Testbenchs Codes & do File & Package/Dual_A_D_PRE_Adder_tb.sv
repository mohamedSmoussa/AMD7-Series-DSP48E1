module Dual_A_D_PRE_Adder_tb();
parameter  A_INPUT    = "CASCADE";  // "DIRECT" or "CASCADE"
parameter  AREG       = 2; // (0,1,2) Num of A input pipeline regs
parameter  ACASCREG   = 1; // (0,1,2) Num of A cascade pipeline regs; must be <=
parameter  ADREG      = 1; // (0,1) Num of AD pipeline regs
parameter  DREG       = 1; // (0,1) Num of D input pipeline regs
parameter  USE_DPORT  = "FALSE";   // "TRUE" or "FALSE" (enable pre-adder D port)
reg signed [29:0] A,ACIN;
reg signed [24:0] D;
reg [3:0]  INMODE_0TO3;
reg  CEA1,CEA2,RSTA,CED,CEAD,RSTD,CLK;
wire signed [29:0] ACOUT,X_MUX_A ;
wire signed [24:0] A_MULT;
wire signed [24:0] ACC;
assign ACC= (A_INPUT=="DIRECT")?A[24:0]:ACIN[24:0]; //// to Compare in Wave
integer i,error_count,correct_count;
Dual_A_D_PRE_Adder #(.A_INPUT(A_INPUT),.AREG(AREG),.ADREG(ADREG),.DREG(DREG),.USE_DPORT(USE_DPORT),.ACASCREG(ACASCREG)) 
                   DUT(A,ACIN,D,INMODE_0TO3,CEA1,CEA2,RSTA,CED,CEAD,RSTD,A_MULT,ACOUT,X_MUX_A,CLK);

initial begin
    CLK=0;
    forever begin
        #1 CLK=~CLK;
    end
end 
task RSTA_ASSERT();
  RSTA=1;
  @(negedge CLK);
  if(ACOUT!=0 || X_MUX_A !=0)  begin
    $display("ERROR IN RSTA function");
    error_count=error_count+1;
  end
  else correct_count=correct_count+1;
  RSTA=0;
endtask
task RSTD_ASSERT();
  RSTD=1;
  @(negedge CLK);
  if( A_MULT !=0)  begin
    $display("ERROR IN RSTD function");
    error_count=error_count+1;
  end
  else correct_count=correct_count+1;
  RSTD=0;
endtask
task check_result1(input signed [29:0] ACOUT_EX); 
    repeat(ACASCREG)@(negedge CLK);
   if(ACOUT!=ACOUT_EX) begin
    $display("ERROR IN ACOUT fucntion");
    error_count=error_count+1;
   end
   else correct_count=correct_count+1;
endtask
task check_result2(input signed [29:0] X_MUX_A_EX);
   repeat(AREG) @(negedge CLK);
   if(X_MUX_A!=X_MUX_A_EX) begin
    $display("ERROR IN X_MUX_A fucntion");
    error_count=error_count+1;
   end
   else correct_count=correct_count+1;
endtask
task check_result3(input signed [24:0] A_MULT_EX);
   if(USE_DPORT=="TRUE") begin
     if(AREG==2 && INMODE_0TO3[0]) begin
     repeat(AREG+ADREG-1) @(negedge CLK);
     end
     else begin
     if(!ADREG && !AREG) begin 
      repeat(DREG) @(negedge CLK);
     end
     else begin
     repeat(AREG+ADREG) @(negedge CLK); 
     end  
     end
   end 
   else begin
    if(AREG==2 && INMODE_0TO3[0]) begin
     repeat(AREG-1) @(negedge CLK);
    end
    else  begin 
        repeat(AREG) @(negedge CLK);
    end
   end
    if(A_MULT!=A_MULT_EX) begin
    $display("ERROR IN A_MULT fucntion");
    error_count=error_count+1;
   end
   else correct_count=correct_count+1;
    endtask
  task prevent_time_error();
   if(!ADREG && !AREG) @(negedge CLK);
  endtask
  initial begin
  {A,ACIN,D,INMODE_0TO3,CEA1,CEA2,RSTA,CED,CEAD,RSTD,error_count,correct_count,i}=0;
    if(AREG>0)  RSTA_ASSERT();  /// USED IN ALL CASES EXCEPT AREG=0
    if(USE_DPORT=="TRUE" && ADREG) begin 
         RSTD_ASSERT(); /// USED IF I PIPELINED THE RESULT FROM PRE ADDER/SUBTRACTOR
    end
    for (i=0;i<2000;i=i+1) begin
     A=$random;  ACIN=$random; D=$random; CEA1=1; CEA2=1; CED=1; CEAD=1;
     if (A_INPUT=="DIRECT") begin
      if(USE_DPORT=="TRUE") begin
     INMODE_0TO3=4'b0000; check_result3(A[24:0]);  check_result2(A); check_result1(A);
     INMODE_0TO3=4'b0001; check_result3(A[24:0]);     prevent_time_error();
     INMODE_0TO3=4'b0010; check_result3(0);           prevent_time_error(); 
     INMODE_0TO3=4'b0011; check_result3(0);           prevent_time_error();
     INMODE_0TO3=4'b0100; check_result3(D+A[24:0]);   prevent_time_error(); 
     INMODE_0TO3=4'b0101; check_result3(D+A[24:0]);   prevent_time_error();
     INMODE_0TO3=4'b0110; check_result3(D);           prevent_time_error();
     INMODE_0TO3=4'b0111; check_result3(D);           prevent_time_error();
     INMODE_0TO3=4'b1000; check_result3(-A[24:0]);    prevent_time_error();
     INMODE_0TO3=4'b1001; check_result3(-A[24:0]);    prevent_time_error();
     INMODE_0TO3=4'b1010; check_result3(0);           prevent_time_error();
     INMODE_0TO3=4'b1011; check_result3(0);           prevent_time_error();
     INMODE_0TO3=4'b1100; check_result3(D-A[24:0]);   prevent_time_error();
     INMODE_0TO3=4'b1101; check_result3(D-A[24:0]);   prevent_time_error();
     INMODE_0TO3=4'b1110; check_result3(D);           prevent_time_error();
     INMODE_0TO3=4'b1111; check_result3(D);           prevent_time_error();
      end
      else begin
      INMODE_0TO3=4'b0000; check_result3(A[24:0]);  check_result2(A); check_result1(A);
      INMODE_0TO3=4'b0001; check_result3(A[24:0]);     prevent_time_error();
      INMODE_0TO3=4'b0010; check_result3(0);           prevent_time_error();
      INMODE_0TO3=4'b0011; check_result3(0);           prevent_time_error();  
      end
     end
     else begin
      if(USE_DPORT=="TRUE") begin
     INMODE_0TO3=4'b0000; check_result3(ACIN[24:0]);  check_result2(ACIN); check_result1(ACIN);
     INMODE_0TO3=4'b0001; check_result3(ACIN[24:0]);  prevent_time_error();
     INMODE_0TO3=4'b0010; check_result3(0);           prevent_time_error();
     INMODE_0TO3=4'b0011; check_result3(0);           prevent_time_error();
     INMODE_0TO3=4'b0100; check_result3(D+ACIN[24:0]);prevent_time_error();
     INMODE_0TO3=4'b0101; check_result3(D+ACIN[24:0]);prevent_time_error();
     INMODE_0TO3=4'b0110; check_result3(D);           prevent_time_error();
     INMODE_0TO3=4'b0111; check_result3(D);           prevent_time_error();
     INMODE_0TO3=4'b1000; check_result3(-ACIN[24:0]); prevent_time_error();
     INMODE_0TO3=4'b1001; check_result3(-ACIN[24:0]); prevent_time_error();
     INMODE_0TO3=4'b1010; check_result3(0);           prevent_time_error();
     INMODE_0TO3=4'b1011; check_result3(0);           prevent_time_error();
     INMODE_0TO3=4'b1100; check_result3(D-ACIN[24:0]);prevent_time_error();
     INMODE_0TO3=4'b1101; check_result3(D-ACIN[24:0]);prevent_time_error();
     INMODE_0TO3=4'b1110; check_result3(D);           prevent_time_error();
     INMODE_0TO3=4'b1111; check_result3(D);           prevent_time_error();
      end
      else begin
      INMODE_0TO3=4'b0000; check_result3(ACIN[24:0]);  check_result2(ACIN); check_result1(ACIN); 
      INMODE_0TO3=4'b0001; check_result3(ACIN[24:0]);     prevent_time_error();
      INMODE_0TO3=4'b0010; check_result3(0);              prevent_time_error();
      INMODE_0TO3=4'b0011; check_result3(0);              prevent_time_error();    
      end
     end
    end
    if(AREG>0)  RSTA_ASSERT();  /// USED IN ALL CASES EXCEPT AREG=0
    if(USE_DPORT=="TRUE") begin 
        if(ADREG) RSTD_ASSERT(); /// USED IF I PIPELINED THE RESULT FROM PRE ADDER/SUBTRACTOR
    end 
    $display("ERROR_COUNT = %0d  ::::::::  CORRECT_COUNT = %0d ",error_count,correct_count);
    $stop;    
end
endmodule