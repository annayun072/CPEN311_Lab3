module task3(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module

logic fillscreen_start, fillscreen_done, circle_start, circle_done, fillscreen_plot, circle_plot;
logic [2:0] fillscreen_colour_out, circle_colour_out;
assign fillscreen_start = KEY[3] ? 1 : 0; 
assign circle_start = fillscreen_done ? 1 : 0;

logic [2:0] fillscreen_colour;
assign fillscreen_colour = 0;

logic [7:0] fillscreen_x, circle_x;
logic [6:0] fillscreen_y, circle_y;

assign VGA_X = fillscreen_done == 1 ? circle_x : fillscreen_x;
assign VGA_Y = fillscreen_done == 1 ? circle_y : fillscreen_y;
assign VGA_COLOUR = fillscreen_done == 1 ? circle_colour_out : fillscreen_colour_out;
assign VGA_PLOT = fillscreen_done == 1 ? circle_plot : fillscreen_plot;

/*// FOR CIRCLE SIMULATION ONLY----------------------------------
assign VGA_X = circle_x;
assign VGA_Y = circle_y;
assign VGA_COLOUR = circle_colour_out;
assign VGA_PLOT = circle_plot;
assign circle_start = KEY[3] ? 1: 0;
//--------------------------------------------------------------*/



logic [7:0] centre_x, radius;
logic [6:0] centre_y;
logic [2:0] circle_colour;
assign centre_x = 8'd80;
assign centre_y = 7'd60;
assign radius = 8'd40;
assign circle_colour = 3'b010; 

fillscreen do_fillscreen(.clk(CLOCK_50), .rst_n(KEY[3]), .colour(fillscreen_colour), .start(fillscreen_start), .done(fillscreen_done), 
			.vga_x(fillscreen_x), .vga_y(fillscreen_y), .vga_colour(fillscreen_colour_out), .vga_plot(fillscreen_plot)); 



circle do_circle(.clk(CLOCK_50), .rst_n(KEY[3]),  .colour(circle_colour),
	.centre_x(centre_x), .centre_y(centre_y), .radius(radius),
	 .start(circle_start), .done(circle_done), .vga_x(circle_x), .vga_y(circle_y), 
	.vga_colour(circle_colour_out), .vga_plot(circle_plot) );

vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), 
		.colour(VGA_COLOUR), .x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
		.VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), 
		.VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC), .VGA_CLK(VGA_CLK));

endmodule: task3
