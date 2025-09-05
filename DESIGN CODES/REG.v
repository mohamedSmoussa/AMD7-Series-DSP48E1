module D_REG(d,rst,clk,q,enable);
parameter N=1; 
input [N-1:0] d;
input rst,clk,enable;
output reg [N-1:0] q;
always @(posedge clk) begin
    if(rst) q<=0;
    else if(enable) q<= d;
end
endmodule