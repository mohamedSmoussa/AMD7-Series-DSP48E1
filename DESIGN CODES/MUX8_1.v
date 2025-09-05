module MUX8_1 (in0,in1,in2,in3,in4,in5,in6,in7,sel,out);
parameter N=1;
input [N-1:0] in0,in1,in2,in3,in4,in5,in6,in7;
input [2:0] sel;
output reg [N-1:0] out;
always @(*) begin
case (sel)  
0:out=in0;
1:out=in1;
2:out=in2;
3:out=in3;
4:out=in4;
5:out=in5;
6:out=in6;
7:out=in7;
endcase
end
endmodule //MUX8_1
