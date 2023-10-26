module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     // draw the circle
logic y_increment, x_increment, crit1_increment, crit2_increment, loop_start, plot;
logic [9:0] offset_x, next_vgax, offset_y, next_vgay, crit;
logic [3:0] state, next_state, which_octant; 

assign vga_colour = colour; 

localparam x_dimension = 159; 
localparam y_dimension = 119;  

localparam RESET = 4'b0000;
localparam START_DRAWING = 4'b0001;
localparam BIG_LOOP = 4'b0010;
localparam OCTANT_1 = 4'b0011;
localparam OCTANT_2 = 4'b0100;
localparam OCTANT_3 = 4'b0101;
localparam OCTANT_4 = 4'b0110;
localparam OCTANT_5 = 4'b0111;
localparam OCTANT_6 = 4'b1000;
localparam OCTANT_7 = 4'b1001;
localparam OCTANT_8 = 4'b1010;
localparam INCREMENT_Y = 4'b1011;
localparam INCREMENT_CRIT1 = 4'b1100;
localparam INCREMENT_CRIT2 = 4'b1101;
localparam DONE_ALL = 4'b1110;

//Update State
always_ff @(posedge clk or negedge rst_n) begin 
	if(!rst_n) state = RESET; 
	else state = next_state; 
end //End Update State Block

//updating vga_plot
always_comb begin 
	if (plot ==1 && $signed(next_vgax) >= 0 && $signed(next_vgax) <= x_dimension && $signed(next_vgay) >= 0 && $signed(next_vgay) <= y_dimension)
		vga_plot = 1;
	else vga_plot = 0;
end


//increment block
always_ff @(posedge clk) begin
	if(loop_start == 1) offset_y <= 10'd0; 
	else if (y_increment) offset_y <= offset_y + 10'd1;
	else offset_y <= offset_y;
end

always_ff @ (posedge clk) begin
	if(loop_start == 1) offset_x <= radius;
	else if (x_increment) offset_x <= offset_x - 10'd1;
	else offset_x <= offset_x;
end

always_ff @ (posedge clk) begin
	if(loop_start == 1) crit <= 10'd1 - radius;
	else if (crit1_increment) crit <= crit + (10'd2 * offset_y) + 10'd1; 
	else if (crit2_increment) crit <= crit + (10'd2 * (offset_y - offset_x)) + 10'd1;
	else crit <= crit;
end //end increment block 

always_ff @(posedge clk) begin 
	case(which_octant) 
	4'd1: begin
		next_vgax = centre_x + offset_x;
		next_vgay = centre_y + offset_y; end
	4'd2: begin
		next_vgax = centre_x + offset_y;
		next_vgay = centre_y + offset_x; end
	4'd3: begin
		next_vgax = centre_x - offset_x;
		next_vgay = centre_y + offset_y; end
	4'd4: begin
		next_vgax = centre_x - offset_y;
		next_vgay = centre_y + offset_x; end
	4'd5: begin
		next_vgax = centre_x - offset_x;
		next_vgay = centre_y - offset_y; end
	4'd6: begin
		next_vgax = centre_x - offset_y;
		next_vgay = centre_y - offset_x; end
	4'd7: begin
		next_vgax = centre_x + offset_x;
		next_vgay = centre_y - offset_y; end
	4'd8: begin
		next_vgax = centre_x + offset_y;
		next_vgay = centre_y - offset_x; end
	default:  begin
		next_vgax = next_vgax;
		next_vgay = next_vgay; end
	endcase
end // end octant block

assign vga_x = next_vgax[7:0];
assign vga_y = next_vgay[6:0];

//state machine
always_comb begin
	case(state)
	RESET: begin
		if (start) begin
			next_state = START_DRAWING; 
			end
		else next_state = RESET;
		end
	START_DRAWING: begin 
			next_state = BIG_LOOP; end //reset all else except internal loop?
	BIG_LOOP: begin
			if ($signed(offset_y) <= $signed(offset_x)) next_state = OCTANT_1; //and reset all else
			else next_state = DONE_ALL; 
		end
	OCTANT_1: next_state = OCTANT_2; // and plot flag raised 
	OCTANT_2: next_state = OCTANT_3; // and plot flag raised 
	OCTANT_3: next_state = OCTANT_4; // and plot flag raised 
	OCTANT_4: next_state = OCTANT_5; // and plot flag raised 
	OCTANT_5: next_state = OCTANT_6; // and plot flag raised 
	OCTANT_6: next_state = OCTANT_7; // and plot flag raised 
	OCTANT_7: next_state = OCTANT_8; // and plot flag raised 
	OCTANT_8: next_state = INCREMENT_Y; // and plot flag raised 
	
	INCREMENT_Y: next_state = INCREMENT_CRIT1; // and increment y

	INCREMENT_CRIT1: begin 
		if($signed(crit) <= 0) next_state = BIG_LOOP; // and increment crit 1
		else next_state = INCREMENT_CRIT2; //and increment x
		end

	INCREMENT_CRIT2: next_state = BIG_LOOP; // and increment crit 2

	DONE_ALL: next_state = DONE_ALL; // and raise done flag
	default: next_state = RESET; // zero all 

	endcase
end // end state machine

always_comb begin
	case(state) 
	RESET: begin
		loop_start = 0;
		which_octant = 0;
		plot = 0;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	START_DRAWING: begin
		loop_start = 1;
		which_octant = 0;
		plot = 0;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	BIG_LOOP: begin
		loop_start = 0;
		which_octant = 0;
		plot = 0;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	OCTANT_1: begin
		loop_start = 0;
		which_octant = 4'd1;
		plot = 1;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	OCTANT_2: begin
		loop_start = 0;
		which_octant = 4'd2;
		plot = 1;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	OCTANT_3: begin
		loop_start = 0;
		which_octant = 4'd3;
		plot = 1;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	OCTANT_4: begin
		loop_start = 0;
		which_octant = 4'd4;
		plot = 1;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	OCTANT_5: begin
		loop_start = 0;
		which_octant = 4'd5;
		plot = 1;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	OCTANT_6: begin
		loop_start = 0;
		which_octant = 4'd6;
		plot = 1;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	OCTANT_7: begin
		loop_start = 0;
		which_octant = 4'd7;
		plot = 1;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	OCTANT_8: begin
		loop_start = 0;
		which_octant = 4'd8;
		plot = 1;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	INCREMENT_Y: begin
		loop_start = 0;
		which_octant = 4'd8;
		plot = 1;
		x_increment = 0;
		y_increment = 1;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	INCREMENT_CRIT1: begin

		if($signed(crit) <= 0) begin crit1_increment = 1; x_increment = 0; end// and increment crit 1
		else begin x_increment = 1; crit1_increment = 0; end //and increment x
		
		loop_start = 0;
		which_octant = 0;
		plot = 0;
		y_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	INCREMENT_CRIT2: begin
		loop_start = 0;
		which_octant = 0;
		plot = 0;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 1;
		done = 0;
		end
	DONE_ALL: begin
		loop_start = 0;
		which_octant = 0;
		plot = 0;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 1;
		end
	default:  begin
		loop_start = 0;
		which_octant = 0;
		plot = 0;
		x_increment = 0;
		y_increment = 0;
		crit1_increment = 0;
		crit2_increment  = 0;
		done = 0;
		end
	endcase
end //end output 
endmodule

