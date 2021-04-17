//////////////////////////////////////////////////////////////////////////////////
// Author:			Robert (Jui Po) Hung
// Create Date:   04/16/21
// File Name:		ee354_FinalProject.v 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////


module ee354_FinalProject(Clk, CEN, Reset, Start, Ack, input_arr, det, q_I, q_Load, q_Comp, q_Done);


	/*  INPUTS */
	input	Clk, CEN, Reset, Start, Ack;
	input integer input_arr [7:0][7:0];
	
	
	/*  OUTPUTS */
	output reg [31:0] det;
	// store current state
	output q_I, q_Load, q_Comp, q_Done;
	reg [3:0] state;	
	assign {q_Done, q_Comp, q_Load, q_I} = state;
	
	
	/* TEMP VARS */
	reg integer seven [6:0][6:0];
	reg integer six [5:0][5:0];
	reg integer five [4:0][4:0];
	reg integer four [3:0][3:0];
	reg integer three [2:0][2:0];
	reg integer temp_val [8*7*6*5*4 - 1:0];
	reg [8*7*6*5*4 - 1:0] status;
	reg [2:0] size_curr; //current size of matrix being worked on
	reg [2:0] sub_index; //column to "ignore" while calculating determinant
	
	localparam 	
	I = 4'b0001, LOAD = 4'b0010, COMP = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX;
	
	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin
		if(Reset) begin
			state <= I;		  	
			size_curr = 3'bx;
			sub_index = 3'bx;
			temp_val = 6720'bx;
			status = 6720'bx;
		end
		else				
			case(state)	
				I:
				begin
					// state transfers
					if (Start) state <= LOAD;
					// data transfers
					size_curr = 3'd7;
					sub_index = 3'd0;
					status = 6720'd0;
					temp_val = '{default:0}; 
				end		
				LOAD:
					begin
						// state transfers
						state <= COMP;
						// data transfers
						case(size_curr)
							3'b000: //impossible case
							3'b001: //impossible case
							3'b010://impossible case
							3'b011: //impossible case
							3'b100: begin
								integer i, j, indexi, indexj;
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 5; i++) begin
									for(j = 0; j < 5; j++) begin
										if(j == sub_index)
											j++;
										four[indexi][indexj] = five[i][j];
										indexi++;
										indexj++;
									end
								end	
							end
							3'b101: begin
								integer i, j, indexi, indexj;
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 6; i++) begin
									for(j = 0; j < 6; j++) begin
										if(j == sub_index)
											j++;
										five[indexi][indexj] = six[i][j];
										indexi++;
										indexj++;
									end
								end	
							end
							3'b110: begin
								integer i, j, indexi, indexj;
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 7; i++) begin
									for(j = 0; j < 7; j++) begin
										if(j == sub_index)
											j++;
										six[indexi][indexj] = seven[i][j];
										indexi++;
										indexj++;
									end
								end	
							end
							3'b111: begin
								integer i, j, indexi, indexj;
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 8; i++) begin
									for(j = 0; j < 8; j++) begin
										if(j == sub_index)
											j++;
										seven[indexi][indexj] = input_arr[i][j];
										indexi++;
										indexj++;
									end
								end	
							end
							default: //hopefully we don't arrive here!
						endcase

					end
				
				COMP:
					if (Ack)	state <= I;
				DONE:
					begin
						// state transfers
						
						// data transfers
				default:		
					state <= UNK;
			endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
