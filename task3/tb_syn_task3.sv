`timescale 1 ps/ 1 ps
module tb_syn_task3();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
logic CLOCK_50, VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT;
logic [2:0] VGA_COLOUR;
logic [3:0] KEYS;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_Y;
logic [7:0] VGA_R, VGA_B, VGA_G, VGA_X;
logic [9:0] SW, LEDR;

task3 do_task3(.CLOCK_50(CLOCK_50), .KEY(KEYS), .SW(SW), .LEDR(LEDR), 
		.HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), 
		.VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_CLK(VGA_CLK),
		.VGA_X(VGA_X), .VGA_Y(VGA_Y), .VGA_COLOUR(VGA_COLOUR), .VGA_PLOT(VGA_PLOT));

vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEYS[3]), .clock(CLOCK_50), 
		.colour(VGA_COLOUR), .x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
		.VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),.VGA_HS(VGA_HS), .VGA_VS(VGA_VS), 
		.VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC),  .VGA_CLK(VGA_CLK) ); 

initial begin
	CLOCK_50 = 0;
	forever
	#1 CLOCK_50 =~CLOCK_50; 
end

initial begin
#1;
KEYS[3] = 0;
#1;
KEYS[3] = 1;

#50000

$stop(0);
end

endmodule: tb_syn_task3
