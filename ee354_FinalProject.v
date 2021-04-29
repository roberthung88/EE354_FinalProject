//////////////////////////////////////////////////////////////////////////////////
// Author:			Robert (Jui Po) Hung, Robert Sutherland
// Create Date:   04/16/21
// File Name:		ee354_FinalProject.v 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////


module ee354_FinalProject(Clk, Reset, Start, Ack, input_arr_flat, det, q_I, q_Enter, q_Load, q_Comp, q_Done);


	/*  INPUTS */
	input	Clk, Reset, Start, Ack;
	input [255:0] input_arr_flat;
	
	
	
	/*  OUTPUTS */
	output reg [31:0] det;
	// store current state
	output q_I, q_Enter, q_Load, q_Comp, q_Done;
	reg [4:0] state;	
	assign {q_Done, q_Comp, q_Load, q_Enter, q_I} = state;
	
	
	/* TEMP VARS */
	integer seven [6:0][6:0];
	integer six [5:0][5:0];
	integer five [4:0][4:0];
	integer four [3:0][3:0];
	integer three [2:0][2:0];
	integer temp_val [5:0]; // temp_val[0] stores det
	reg [2:0] size_curr; //current size of matrix being worked on
	reg [2:0] sub_index [4:0]; //column to "ignore" while calculating determinant
	integer i, j, indexi, indexj, a, b, c, d, e, f, g, h, k;
	reg [3:0] input_arr[63:0];
	reg [255:0] temp_input;


	localparam 	
	I = 5'b00001, ENTER = 5'b00010, LOAD = 5'b00100, COMP = 5'b01000, DONE = 5'b10000, UNK = 5'bXXXXX;
	
	assign input_arr_flat = temp_input;
	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin
		if(Reset) begin
			state <= I;		  	
			size_curr <= 3'bx;
			for(i = 0; i < 5; i=i+1) begin
				sub_index[i] <= 3'bx;
			end
			for(i = 0; i < 6; i=i+1) begin
				temp_val[i] <= 6'bx;
			end
			input_arr_flat <= 256'b0;
		end
		else				
			case(state)	
				I:
				begin
					// state transfers on start condtion
					state <= ENTER;
					// data transfers
					size_curr <= 3'd7;
					for(i = 0; i < 5; i=i+1) begin
						sub_index[i] <= 3'b0;
					end
					for(i = 0; i < 6; i=i+1) begin
						temp_val[i] <= 0;
					end
				end	
				ENTER:
				begin
					if (Start) begin
						state <= LOAD;
						for(i = 0; i < 64; i=i+1) begin
							input_arr[i] <=  input_arr_flat[i*4+:4];
						end
					end
						
				end	
				LOAD:
					begin
						// state transfers
						state <= COMP;
						// data transfers
						case(size_curr)
							3'b000: ;//impossible case
							3'b001: ;//impossible case
							3'b010: ;//impossible case must be at least a 3X3
							3'b011: begin
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 4; i=i+1) begin
									for(j = 0; j < 4; j=j+1) begin
										if(!(j == sub_index[4])) begin										
											three[indexi][indexj] <= four[i][j];
											indexj=indexj+1;
										end
									end
									indexj = 0;
									indexi=indexi+1;
								end
							end
							3'b100: begin
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 5; i=i+1) begin
									for(j = 0; j < 5; j=j+1) begin
										if(!(j == sub_index[3])) begin										
											four[indexi][indexj] <= five[i][j];
											indexj=indexj+1;
										end
									end
									indexj = 0;
									indexi=indexi+1;
								end
							end
							3'b101: begin
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 6; i=i+1) begin
									for(j = 0; j < 6; j=j+1) begin
										if(!(j == sub_index[2])) begin										
											five[indexi][indexj] <= six[i][j];
											indexj=indexj+1;
										end
									end
									indexj = 0;
									indexi=indexi+1;
								end
							end
							3'b110: begin
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 7; i=i+1) begin
									for(j = 0; j < 7; j=j+1) begin
										if(!(j == sub_index[1])) begin										
											six[indexi][indexj] <= seven[i][j];
											indexj=indexj+1;
										end
									end
									indexj = 0;
									indexi=indexi+1;
								end
							end
							3'b111: begin
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 8; i=i+1) begin
									for(j = 0; j < 8; j=j+1) begin
										if(!(j == sub_index[0])) begin										
											seven[indexi][indexj] <= input_arr[i*8+j];
											indexj=indexj+1;
										end
									end
									indexj = 0;
									indexi=indexi+1;
								end	
							end
							default: ;//hopefully we don't arrive here!
						endcase

					end
				
				COMP:
					begin
						// state transfers
						if(sub_index[0] == 7 && sub_index[1] == 6 && sub_index[2] == 5 && sub_index[3] == 4 && sub_index[4] == 3)
							//calculating the very last matrix
							state <= DONE;
						else
							state <= LOAD;
						
						
						// data transfers
						if(size_curr != 3)
							size_curr=size_curr-1;
						else begin
							a = three[0][0];
							b = three[0][1];
							c = three[0][2];
							d = three[1][0];
							e = three[1][1];
							f = three[1][2];
							g = three[2][0];
							h = three[2][1];
							k = three[2][2];

							// temp storage for 3x3 matrix det
							temp_val[5] = a*(e*k-f*h) - b*(d*k-f*g) + c*(d*h-e*g);

							// add det to 4x4
							if(sub_index[4] % 2 == 0)
								temp_val[4] = temp_val[4]+(temp_val[5]*four[0][sub_index[4]]);
							else
								temp_val[4] = temp_val[4]-(temp_val[5]*four[0][sub_index[4]]);
							

							//calculated very last 3x3 matrix
							if(sub_index[4] == 3) begin
								sub_index[4] = 0;
								size_curr=size_curr+1;
								// update values
								if(sub_index[3] % 2 == 0)
									temp_val[3] = temp_val[3]+(temp_val[4]*five[0][sub_index[3]]);
								else
									temp_val[3] = temp_val[3]-(temp_val[4]*five[0][sub_index[3]]);
								temp_val[4] = 0;

								// calculated very last 4x4 matrix
								if(sub_index[3] == 4) begin
									sub_index[3] = 0;
									size_curr=size_curr+1;
									// update values
									if(sub_index[2] % 2 == 0)
										temp_val[2] = temp_val[2]+(temp_val[3]*six[0][sub_index[2]]);
									else
										temp_val[2] = temp_val[2]-(temp_val[3]*six[0][sub_index[2]]);
									temp_val[3] = 0;

									// calculated very last 5x5 matrix
									if(sub_index[2] == 5) begin
										sub_index[2] = 0;
										size_curr=size_curr+1;
										// update values
										if(sub_index[1] % 2 == 0)
											temp_val[1] = temp_val[1]+(temp_val[2]*seven[0][sub_index[1]]);
										else
											temp_val[1] = temp_val[1]-(temp_val[2]*seven[0][sub_index[1]]);
										temp_val[2] = 0;

										// calculated very last 6x6 matrix
										if(sub_index[1] == 6) begin
											sub_index[1] = 0;
											size_curr=size_curr+1;
											// update values
											if(sub_index[0] % 2 == 0)
												temp_val[0] = temp_val[0]+(temp_val[1]*input_arr[sub_index[0]]);
											else
												temp_val[0] = temp_val[0]-(temp_val[1]*input_arr[sub_index[0]]);
											
											// calculated very last 7x7 matrix
											if(sub_index[0] == 7) begin
												//calculated everything
												temp_val[0] = temp_val[0]-(temp_val[1]*input_arr[sub_index[0]]);
												det = temp_val[0];
											end
											else begin
												temp_val[1] = 0;
												sub_index[0]=sub_index[0]+1;
											end
											
										end
										else
											sub_index[1]=sub_index[1]+1;
										
									end
									else
										sub_index[2]=sub_index[2]+1;
									
								end
								else
									// calculate next 4x4
									sub_index[3]=sub_index[3]+1;
								
							end
							else
								// haven't calculated very last 3x3 matrix, so calculate next 3x3 det
								sub_index[4]=sub_index[4]+1;
						end
					end
				DONE:
					begin
						// state transfers
						if(Ack)
							state <= I;
						// data transfers
						det = temp_val[0];
					end
				default:		
					state <= UNK;
			endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
