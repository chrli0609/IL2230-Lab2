create_clock -period 5 [get_ports clk]

set_false_path -from [get_ports rst_n]

set_clock_uncertainty 0.3 [get_clock clk]

#set_clock_uncertainty -setup 0.65 [get_clocks clk]
#set_clock_uncertainty -hold 0.45 [get_clocks clk]
set_input_delay .2 -clock clk [get_ports in]
set_input_delay .2 -clock clk [get_ports weights]
set_input_delay .2 -clock clk [get_ports bias]
