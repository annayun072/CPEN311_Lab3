`timescale 1 ps/ 1 ps
module tb_rtl_circle();
logic CLOCK_50, VGA_HS, VGA_VS, VGA_CLK, vga_plot, rst_n, start, done;
logic [2:0] vga_colour, colour;
logic [6:0] vga_y, centre_y;
logic [7:0] vga_x, centre_x, radius;
// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
/* module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);*/

circle do_circle(.clk(CLOCK_50), .rst_n(rst_n),  .colour(colour),
	.centre_x(centre_x), .centre_y(centre_y), .radius(radius),
	 .start(start), .done(done), .vga_x(vga_x), .vga_y(vga_y), 
	.vga_colour(vga_colour), .vga_plot(vga_plot) );

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
	centre_x = 8'd80;
	centre_y = 7'd60;
	radius = 8'd40;
	colour = 3'b010; 

	#4000;

	start = 0;
	rst_n = 0;
	#100;
	start = 1;
	rst_n = 1;
	#100;

// change colour
	centre_x = 8'd80;
	centre_y = 7'd60;
	radius = 8'd40;
	colour = 3'b011; 

	#4000;

	start = 0;
	rst_n = 0;
	#1;
	rst_n = 1;
	#10;

//change center (within bounds)
	start = 1;
	centre_x = 8'd40;
	centre_y = 7'd40;
	radius = 8'd40;
	colour = 3'b010; 

	#4000;

	#1;
	rst_n = 0;
	#1;
	rst_n = 1;
	#10; 



//centre_x is just within bounds 
	radius = 8'd40;
	start = 1;
	centre_x = 8'd159;
	centre_y = 7'd60;
	colour = 3'b010; 

	#4000;

	#1;
	rst_n = 0;
	#1;
	rst_n = 1;
	#10;

//centre_y is just within bounds
	start = 1;
	centre_x = 8'd80;
	centre_y = 7'd119;
	radius = 8'd40;
	colour = 3'b010; 

	#4000;

	#1;
	rst_n = 0;
	#1;
	radius = 8'd100;
	rst_n = 1;
	#10;

//large radius 
	start = 1;
	centre_x = 8'd80;
	centre_y = 7'd60;
	colour = 3'b010; 

	#4000;
	
	#1;
	rst_n = 0;
	#1;
	radius = 8'd10;
	rst_n = 1;
	#10;

//very small radius
	start = 1;
	centre_x = 8'd80;
	centre_y = 7'd60;
	colour = 3'b010; 

	#4000;


end
endmodule: tb_rtl_circle
