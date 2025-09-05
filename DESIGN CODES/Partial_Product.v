module Partial_Product #(
    parameter A_WIDTH = 8,
    parameter B_WIDTH = 8
)(
    input  [A_WIDTH-1:0] A,
    input  [B_WIDTH-1:0] B,
    output [A_WIDTH+B_WIDTH-1:0] P
);
    reg [A_WIDTH+B_WIDTH-1:0] P_ARR;
    integer i;
    always @(*) begin
        P_ARR = 0;
        for (i = 0; i < B_WIDTH; i = i+1) begin
            P_ARR = P_ARR + ( (A & {A_WIDTH{B[i]}}) << i );
        end
    end
    assign P = P_ARR;
endmodule
