`timescale 1 ps/ 1 ps
module tb_syn_fillscreen();
logic CLOCK_50, VGA_HS, VGA_VS, VGA_CLK, vga_plot, rst_n, start, done;
logic [2:0] vga_colour, colour;
logic [7:0] vga_x;
logic [6:0] vga_y;

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

fillscreen do_fillscreen(.clk(CLOCK_50), .rst_n(rst_n), .colour(colour), .start(start), .done(done), 
			.vga_x(vga_x), .vga_y(vga_y), .vga_colour(vga_colour), .vga_plot(vga_plot)); 

vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(rst_n), .clock(CLOCK_50), 
		.colour(vga_colour), .x(vga_x), .y(vga_y), .plot(vga_plot),
		.VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),.VGA_HS(VGA_HS), .VGA_VS(VGA_VS), 
		.VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC),  .VGA_CLK(VGA_CLK) );

initial begin
	CLOCK_50 = 0;
	forever
	#1 CLOCK_50 =~CLOCK_50; 
end

initial begin
	#1;
	rst_n = 0;
	#1;
	rst_n = 1;
	#10;

	start = 1;

	#40000;
end

endmodule: tb_syn_fillscreen
