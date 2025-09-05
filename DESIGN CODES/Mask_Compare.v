module Mask_Compare (P,FINAL_PATTERN,Final_MASK,PD,PBD);
input signed [47:0]P,FINAL_PATTERN;
input [47:0]Final_MASK;
output reg PD,PBD;
reg [5:0] valid_bits,true_bits,valid_bits1,true_bits1; //// the maximum count for both 48 so minimum is 6 bits 2^6=64
integer i;
always @(*) begin
    valid_bits = 0;
    true_bits  = 0;
    valid_bits1 = 0;
    true_bits1  = 0;
    for (i=0; i<48; i=i+1) begin
        if(Final_MASK[i]==0) begin
            valid_bits = valid_bits + 1;
            if(P[i] == FINAL_PATTERN[i])
                true_bits = true_bits + 1;

            valid_bits1 = valid_bits1 + 1;
            if(P[i] == ~FINAL_PATTERN[i])
                true_bits1 = true_bits1 + 1;
        end
    end

    PD  = (true_bits  == valid_bits)  ? 1'b1 : 1'b0;
    PBD = (true_bits1 == valid_bits1) ? 1'b1 : 1'b0;
end
endmodule //Mask_Compare