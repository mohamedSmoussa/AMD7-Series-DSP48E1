module ALU (X_OUT,Y_OUT,Z_OUT,CIN,ALUMODE_R,OPMODE_R,P_IN,COUT);
parameter N=48;
input signed [N-1:0] X_OUT,Y_OUT,Z_OUT;
input CIN;
input  [3:0]ALUMODE_R;
input  [6:0]OPMODE_R;
output reg signed [N-1:0] P_IN;
output  reg  COUT;
wire signed [N-1:0] CIN1;
assign CIN1=CIN;
always @(*) begin
case(ALUMODE_R)
4'b0000: {COUT,P_IN}=Z_OUT+X_OUT+Y_OUT+CIN1;
4'b0001: {COUT,P_IN}=~Z_OUT+X_OUT+Y_OUT+CIN1;
4'b0010: {COUT,P_IN}=~(Z_OUT+X_OUT+Y_OUT+CIN1);
4'b0011: {COUT,P_IN}=Z_OUT-(X_OUT+Y_OUT+CIN1);
4'b0100: begin 
         if(OPMODE_R[3:2]==2'b00)begin
            {COUT,P_IN}=X_OUT^Z_OUT;

         end
         else if (OPMODE_R[3:2]==2'b10) begin
            {COUT,P_IN}=~(X_OUT^Z_OUT);
         end
         else begin
            {COUT,P_IN}=0;
         end
         end   
4'b0101:begin 
        if(OPMODE_R[3:2]==2'b00)begin
           {COUT,P_IN}=~(X_OUT^Z_OUT);
        end
        else if (OPMODE_R[3:2]==2'b10) begin
           {COUT,P_IN}=X_OUT^Z_OUT; 
        end
        else begin
           {COUT,P_IN}=0;
        end
        end      
4'b0110:begin 
        if(OPMODE_R[3:2]==2'b00)begin
           {COUT,P_IN}=~(X_OUT^Z_OUT);
        end
        else if (OPMODE_R[3:2]==2'b10) begin
           {COUT,P_IN}=X_OUT^Z_OUT; 
        end
        else begin
           {COUT,P_IN}=0;
        end
        end      
4'b0111:begin 
        if(OPMODE_R[3:2]==2'b00)begin
           {COUT,P_IN}=X_OUT^Z_OUT;
        end
        else if (OPMODE_R[3:2]==2'b10) begin
           {COUT,P_IN}=~(X_OUT^Z_OUT); 
        end
        else begin
           {COUT,P_IN}=0;
        end
        end      
4'b1100:begin 
        if(OPMODE_R[3:2]==2'b00)begin
           {COUT,P_IN}=X_OUT & Z_OUT;
        end
        else if (OPMODE_R[3:2]==2'b10) begin
           {COUT,P_IN}=X_OUT|Z_OUT; 
        end
        else begin
          {COUT,P_IN}=0;
        end
        end      
4'b1101:begin 
        if(OPMODE_R[3:2]==2'b00)begin
           {COUT,P_IN}=X_OUT&(~Z_OUT);
        end
        else if (OPMODE_R[3:2]==2'b10) begin
           {COUT,P_IN}=X_OUT|(~Z_OUT); 
        end
        else begin
           {COUT,P_IN}=0;
        end
        end      
4'b1110:begin
        if(OPMODE_R[3:2]==2'b00)begin
           {COUT,P_IN}=~(X_OUT&Z_OUT);
        end
        else if (OPMODE_R[3:2]==2'b10) begin
          {COUT,P_IN}=~(X_OUT|Z_OUT); 
        end
        else begin
           {COUT,P_IN}=0;
        end
        end      
4'b1111:begin 
        if(OPMODE_R[3:2]==2'b00)begin
           {COUT,P_IN}=(~X_OUT)|Z_OUT;
        end
        else if (OPMODE_R[3:2]==2'b10) begin
           {COUT,P_IN}=(~X_OUT)&Z_OUT; 
        end
        else begin
           {COUT,P_IN}=0;
        end
        end
        default : {COUT,P_IN}=0;            
endcase   
end
endmodule //ALU