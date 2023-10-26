module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     // draw the Reuleaux triangle

//declaring states
localparam RESET = 4'b0000;
localparam CIRCLE_1 = 4'b0001;
localparam CIRCLE_2 = 4'b0010;
localparam CIRCLE_3 = 4'b0011;
localparam DONE = 4'b0100;

//variables
logic [7:0] corner_x1, corner_y1, corner_x2, corner_y2, corner_x3, corner_y3;
logic circle_1_start, circle_2_start, circle_3_start, circle_1_done, circle_2_done, circle_3_done, circle_1_plot, circle_2_plot, circle_3_plot; 
logic [7:0] circle_1_x, circle_2_x, circle_3_x;
logic [6:0] circle_1_y, circle_2_y, circle_3_y;
logic [3:0] state, next_state;

assign vga_colour = colour; 

//These corners will be the centre coordinates for the 3 circle modules
assign corner_x1 = centre_x + (diameter / 2); 
assign corner_y1 = centre_y + (((diameter * 978122)/564719)/6);

assign corner_x2 = centre_x - (diameter / 2);
assign corner_y2 = centre_y + (((diameter * 978122)/564719)/6);

assign corner_x3 = centre_x;
assign corner_y3 = centre_y - (((diameter * 978122)/564719)/3);

circle circle_1(.clk(clk), .rst_n(rst_n),  .colour(colour),
	.centre_x(corner_x1), .centre_y(corner_y1), .radius(diameter),
	 .start(circle_1_start), .done(circle_1_done), .vga_x(circle_1_x), .vga_y(circle_1_y), 
	.vga_colour(circle_1_colour_out), .vga_plot(circle_1_plot) );

circle circle_2(.clk(clk), .rst_n(rst_n),  .colour(colour),
	.centre_x(corner_x2), .centre_y(corner_y2), .radius(diameter),
	 .start(circle_2_start), .done(circle_2_done), .vga_x(circle_2_x), .vga_y(circle_2_y), 
	.vga_colour(circle_2_colour_out), .vga_plot(circle_2_plot) );

circle circle_3(.clk(clk), .rst_n(rst_n),  .colour(colour),
	.centre_x(corner_x3), .centre_y(corner_y3), .radius(diameter),
	 .start(circle_3_start), .done(circle_3_done), .vga_x(circle_3_x), .vga_y(circle_3_y), 
	.vga_colour(circle_3_colour_out), .vga_plot(circle_3_plot) );


//To draw the segments of the reuleaux triangle -only- and not the entire circles
always_comb begin 
	if (circle_1_plot ==1 
			&& $signed(circle_1_x) >= $signed(0) 
			&& $signed(circle_1_x) <= $signed(corner_x3) 
			&& (circle_1_y) >= (corner_y3) 
			&& (circle_1_y) <= (corner_y2) 
		) begin
		vga_x = circle_1_x;
		vga_y = circle_1_y;
		vga_plot = circle_1_plot;
		end
	

	else if (circle_2_plot == 1 
			&& $signed(circle_2_x) >= $signed(corner_x3)
			&& $signed(circle_2_x) <= $signed(corner_x1) 
			&& (circle_2_y) >= (corner_y3) 
			&& (circle_2_y) <= (corner_y1) 
		) begin
		vga_x = circle_2_x;
		vga_y = circle_2_y;
		vga_plot = circle_2_plot;
		end

	else if (circle_3_plot == 1
			&& $signed(circle_3_x) >= $signed(corner_x2)
			&& $signed(circle_3_x) <= $signed(corner_x1)
			&& (circle_3_y) >= (corner_y3) 
			&& (circle_3_y) <= (corner_y1 + diameter) 
			) begin
		vga_x = circle_3_x;
		vga_y = circle_3_y;
		vga_plot = circle_3_plot;
		end
	else begin 
		vga_x = 0;
		vga_y = 0;
		vga_plot = 0;
		end
end


//Update State and check for reset
always_ff @(posedge clk or negedge rst_n) begin 
	if(!rst_n) state = RESET; 
	else state = next_state; 
end //End Update State Block

//State machine block to enable circle modules and check when the circle modules are done
always_comb begin
	case(state)
	RESET: begin
		if (start) next_state = CIRCLE_1;
		else next_state = RESET;
		end

	CIRCLE_1: begin
		if (circle_1_done) next_state = CIRCLE_2;
		else next_state = CIRCLE_1;
		end

	CIRCLE_2: begin
		if (circle_2_done) next_state = CIRCLE_3;
		else next_state = CIRCLE_2;
		end

	CIRCLE_3: begin
		if (circle_3_done) next_state = DONE;
		else next_state = CIRCLE_3;
		end

	DONE: next_state = DONE;
	default: next_state = RESET;
	endcase
end

always_comb begin //begin output block. controls the circle module start enable and done flag
	case(state)
	RESET: begin
		circle_1_start = 0;
		circle_2_start = 0;
		circle_3_start = 0;
		done = 0; end

	CIRCLE_1:  begin
		circle_1_start = 1;
		circle_2_start = 0;
		circle_3_start = 0;
		done = 0; end

	CIRCLE_2: begin
		circle_1_start = 0;
		circle_2_start = 1;
		circle_3_start = 0;
		done = 0; end

	CIRCLE_3: begin
		circle_1_start = 0;
		circle_2_start = 0;
		circle_3_start = 1;
		done = 0; end

	DONE: begin
		circle_1_start = 0;
		circle_2_start = 0;
		circle_3_start = 0;
		done = 1; end

	default:  begin
		circle_1_start = 0;
		circle_2_start = 0;
		circle_3_start = 0;
		done = 0; end
	endcase
end //end output block
endmodule

