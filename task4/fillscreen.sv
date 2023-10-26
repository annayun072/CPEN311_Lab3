module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);

/* for x = 0 to 159:
    for y = 0 to 119:
        turn on pixel (x, y) with colour (x mod 8) */


localparam x_dimension = 159; //shld be 159
localparam y_dimension = 119;  //shld be 119

//State Declarations
localparam RESET = 0;
localparam FILLING = 1;
localparam DONE_FILL = 2;

logic [7:0] x_increment, y_increment; 
logic should_y_increment, should_x_increment, reset_y_increment, reset_x_increment;
logic [1:0] state, next_state; 

//Update State
always_ff @(posedge clk or negedge rst_n) begin 
	if(!rst_n) state = RESET; 
	else state = next_state; 
end //End Update State Block


//Increment x and y 
always@(posedge clk) begin
	if (reset_y_increment) y_increment = 0;
	else if (should_y_increment) y_increment = y_increment + 1;
	else y_increment = y_increment;

	if (reset_x_increment) x_increment = 0;
	else if (should_x_increment) x_increment = x_increment + 1;
	else x_increment = x_increment;
end
/* Or alternatively (?) have a separate module for an adder, and y/x_increment = reset_y/x_increment ? 0 : y/x_added
and adder module is adder(y/x_increment, y/x_added)*/

//Start State Machine
always_comb begin 
	case(state)
	RESET: begin
		if(start) next_state = FILLING;
		else next_state = RESET; end 

	FILLING: if (!start) next_state = RESET; 
		
		else if (done != 1) next_state = FILLING;
		else if (done == 1) next_state = DONE_FILL; 
		else next_state = RESET; //if for some reason start and done are not appropriate values

	DONE_FILL: next_state = DONE_FILL; //loop DONE_FILL state until reset is pushed 
	default: next_state = RESET; 
	endcase
end //End State Machine

always_latch begin //Begin State Outputs
	case(state)
	RESET: begin
		should_y_increment = 0;
		reset_y_increment = 1;
		should_x_increment = 0;
		reset_x_increment = 1;

		vga_x = 0;
		vga_y = 0;
		vga_colour = 0;
		vga_plot = 0;

		done = 0;
		end
	FILLING: begin
		

		if (y_increment < y_dimension) begin
			should_x_increment = 0;
			reset_x_increment = 0;
			should_y_increment = 1; 
			reset_y_increment = 0; 
			
			vga_x = vga_x; 
			vga_y = vga_y;
			vga_plot = vga_plot;
			vga_colour = vga_colour;

			done = 0; end

		else begin
			should_x_increment = 1; 
			should_y_increment = 0;
			reset_y_increment = 1; 
			reset_x_increment = reset_x_increment;

			vga_x = vga_x; 
			vga_y = vga_y;
			vga_plot = vga_plot;
			vga_colour = vga_colour;

			done = 0; end

		if (x_increment > x_dimension) begin
			should_y_increment = 0;
			reset_y_increment = 0;
			should_x_increment = 0;
			reset_x_increment = 0;
            		done = 1; 
			{vga_x, vga_y, vga_colour, vga_plot} = 0; end
                         
                else begin 
			should_y_increment = should_y_increment;
			reset_y_increment = reset_y_increment;
			should_x_increment = should_x_increment;
			reset_x_increment = reset_x_increment;

			vga_x = x_increment; 
			vga_y = y_increment;
			vga_plot = 1;
			vga_colour = colour;
			done = 0; end
		end 

	DONE_FILL: begin
		should_y_increment = 0;
		reset_y_increment = 1;
		should_x_increment = 0;
		reset_x_increment = 1;

		vga_x = 0;
		vga_y = 0;
		vga_colour = 0;
		vga_plot = 0;

		done = 1;
		end

	default: begin
		should_y_increment = 0;
		reset_y_increment = 1;
		should_x_increment = 0;
		reset_x_increment = 1;

		vga_x = 0;
		vga_y = 0;
		vga_colour = 0;
		vga_plot = 0;

		done = 0;
		end
	endcase
end //End State Outputs

endmodule

