module Dual_B_Register_tb();
parameter  BREG      = 2; // (0,1,2) Num of B input pipeline regs
parameter  B_INPUT   = "CASCADE";  // "DIRECT" or "CASCADE"
parameter  BCASCREG  = 1; // (0,1,2) Num of B cascade pipeline regs; must be <= BREG
reg  signed [17:0]B,BCIN;
wire signed [17:0]BCOUT,B_MULT,X_MUX_B;
reg INMODE_4,CLK,CEB1,CEB2,RSTB;
integer i,error_count,correct_count;
Dual_B_Register #(.BREG(BREG),.B_INPUT(B_INPUT),.BCASCREG(BCASCREG)) 
                DUT(B,BCIN,INMODE_4,BCOUT,B_MULT,X_MUX_B,CLK,CEB1,CEB2,RSTB); 
initial begin
    CLK=0;
    forever begin
        #1 CLK=~CLK;
    end
end 
task check_result1(input signed [17:0]BCOUT_EX);
    repeat(BCASCREG) @(negedge CLK);
        if(BCOUT!=BCOUT_EX) begin
        $display("ERROR IN BCOUT");
        error_count=error_count+1;
  end
        else correct_count=correct_count+1;
endtask
task check_result2(input signed [17:0]B_MULT_EX);
        if(INMODE_4)  @(negedge CLK);
        else  begin
             repeat(2) @(negedge CLK);
  end
        if(B_MULT!=B_MULT_EX) begin
        $display("ERROR IN B_MULT");
        error_count=error_count+1;
  end
        else correct_count=correct_count+1;
endtask
task check_result3(input signed [17:0]X_MUX_B_EX);
    repeat(BREG) @(negedge CLK);
        if(X_MUX_B!=X_MUX_B_EX) begin
        $display("ERROR IN X_MUX_B");
        error_count=error_count+1;
  end
        else correct_count=correct_count+1;
endtask
task RST_ASSERT();
      RSTB=1;
      @(negedge CLK);
      if(BCOUT!=0 ||B_MULT!=0 || X_MUX_B!=0 )begin
        $display("ERROR IN RST FUNCTION");
        error_count=error_count+1;
      end
      else correct_count=correct_count+1;
      RSTB=0;
    endtask 
initial begin
    RSTB=0; B=0; BCIN=0; CEB1=0; CEB2=0; i=0; INMODE_4=0; correct_count=0; error_count=0;
    if (BREG>0) RST_ASSERT(); /// USED IN ALL CASES EXCEPT BREG=0
    for(i=0;i<1000;i=i+1) begin
        B=$random; BCIN=$random; CEB1=1; CEB2=1; INMODE_4=$random;
        if(B_INPUT=="DIRECT") begin
        check_result1(B); check_result2(B); check_result3(B);
        end
        else begin
         check_result1(BCIN); check_result2(BCIN); check_result3(BCIN); 
        end
    end
    if (BREG>0) RST_ASSERT(); /// USED IN ALL CASES EXCEPT BREG=0
    $display("ERROR_COUNT = %0d  ::::::::  CORRECT_COUNT = %0d ",error_count,correct_count);
    $stop;
end
endmodule