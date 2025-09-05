vlib work
vlog ALU.v DSP48E1_tb.sv DSP_PKG.sv Dual_A_D_PRE_Adder.v Dual_B_Register.v Mask_Compare.v MUX4_1.v MUX8_1.v Partial_Product.v REG.v DSP48E1.v   +cover -covercells
vsim -voptargs=+acc work.DSP48E1_tb -cover
add wave *
coverage save DSP48E1_tb.ucdb -onexit -du work.DSP48E1 -du work.ALU 
run -all
coverage exclude -du DSP48E1 -togglenode {CARRYOUT[0]}
coverage exclude -du DSP48E1 -togglenode {CARRYOUT[1]}
coverage exclude -du DSP48E1 -togglenode {CARRYOUT[2]}
coverage exclude -du DSP48E1 -togglenode {CARRYOUT_IN[0]}
coverage exclude -du DSP48E1 -togglenode {CARRYOUT_IN[1]}
coverage exclude -du DSP48E1 -togglenode {CARRYOUT_IN[2]}
coverage exclude -du DSP48E1 -togglenode CEA1
coverage exclude -du DSP48E1 -togglenode CEA2
coverage exclude -du DSP48E1 -togglenode CEAD
coverage exclude -du DSP48E1 -togglenode CEALUMODE
coverage exclude -du DSP48E1 -togglenode CEB1
coverage exclude -du DSP48E1 -togglenode CEB2
coverage exclude -du DSP48E1 -togglenode CEC
coverage exclude -du DSP48E1 -togglenode CECARRYIN
coverage exclude -du DSP48E1 -togglenode CECTRL
coverage exclude -du DSP48E1 -togglenode CED
coverage exclude -du DSP48E1 -togglenode CEINMODE
coverage exclude -du DSP48E1 -togglenode CEM
coverage exclude -du DSP48E1 -togglenode CEP
coverage exclude -du DSP48E1 -togglenode Final_MASK
coverage exclude -du DSP48E1 -togglenode FINAL_PATTERN
coverage exclude -du DSP48E1 -togglenode Final_MASK
coverage exclude -du DSP48E1 -togglenode raw_mult
coverage exclude -src MUX8_1.v -line 14 -code s
coverage exclude -src MUX8_1.v -line 15 -code s
coverage exclude -src MUX8_1.v -line 14 -code b
coverage exclude -src MUX8_1.v -line 15 -code b
coverage exclude -du MUX4_1 -togglenode in0
coverage exclude -du MUX4_1 -togglenode in2
coverage exclude -du ALU -togglenode CIN1
coverage exclude -du ALU -togglenode COUT
coverage exclude -clear -du ALU -togglenode {CIN1[0]}
coverage exclude -du Mask_Compare -togglenode i
coverage exclude -du Mask_Compare -togglenode true_bits
coverage exclude -du Mask_Compare -togglenode true_bits1
coverage exclude -du Mask_Compare -togglenode valid_bits
coverage exclude -du Mask_Compare -togglenode valid_bits1


quit -sim
vcover report DSP48E1_tb.ucdb -details -annotate -all -output DSP48E1_co.txt 