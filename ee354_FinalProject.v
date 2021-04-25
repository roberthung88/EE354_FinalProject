//////////////////////////////////////////////////////////////////////////////////
// Author:			Robert (Jui Po) Hung, Robert Sutherland
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
	reg integer temp_val[5:0]; // temp_val[0] stores det
	reg [2:0] size_curr; //current size of matrix being worked on
	reg [2:0] sub_index [4:0]; //column to "ignore" while calculating determinant

	localparam 	
	I = 4'b0001, LOAD = 4'b0010, COMP = 4'b0100, DONE = 4'b1000, UNK = 4'bXXXX;
	
	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin
		if(Reset) begin
			state <= I;		  	
			size_curr = 3'bx;
			sub_index = '{default:x}; 
			temp_val = 'bx;
		end
		else				
			case(state)	
				I:
				begin
					// state transfers on start condtion
					if (Start) state <= LOAD;
					// data transfers
					size_curr = 3'd7;
					sub_index = '{default:0}; 
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
							3'b010://impossible case must be at least a 3X3
							3'b011: begin
								integer i, j, indexi, indexj;
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 4; i++) begin
									for(j = 0; j < 4; j++) begin
										if(j == sub_index[4])
											j++;
										three[indexi][indexj] = four[i][j];
										indexi++;
										indexj++;
									end
								end
							end
							3'b100: begin
								integer i, j, indexi, indexj;
								indexi = 0;
								indexj = 0;
								for(i = 1; i < 5; i++) begin
									for(j = 0; j < 5; j++) begin
										if(j == sub_index[3])
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
										if(j == sub_index[2])
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
										if(j == sub_index[1])
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
										if(j == sub_index[0])
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
					begin
						// state transfers
						if(sub_index[0] == 7 && sub_index[1] == 6 && sub_index[2] == 5 && sub_index[3] == 4 && sub_index[4] == 3){
							//calculating the very last matrix
							state <= DONE;
						}else{
							state <= LOAD;
						}
						
						// data transfers
						if(size_curr != 3){
							size_curr--;
						}else{
							integer a = three[0][0];
							integer b = three[0][1];
							integer c = three[0][2];
							integer d = three[1][0];
							integer e = three[1][1];
							integer f = three[1][2];
							integer g = three[2][0];
							integer h = three[2][1];
							integer i = three[2][2];

							// temp storage for 3x3 matrix det
							temp_val[5] = a*(e*i-f*h) - b*(d*i-f*g) + c*(d*h-e*g);

							// add det to 4x4
							if(sub_index[4] % 2 == 0){
								temp_val[4] += (temp_val[5]*four[0][sub_index[4]]);
							}else{
								temp_val[4] -= (temp_val[5]*four[0][sub_index[4]]);
							}

							//calculated very last 3x3 matrix
							if(sub_index[4] == 3){
								sub_index[4] = 0;
								size_curr++;
								// update values
								if(sub_index[3] % 2 == 0){
									temp_val[3] += (temp_val[4]*five[0][sub_index[3]]);
								}else{
									temp_val[3] -= (temp_val[4]*five[0][sub_index[3]]);
								}

								// calculated very last 4x4 matrix
								if(sub_index[3] == 4){
									sub_index[3] = 0;
									size_curr++;
									// update values
									if(sub_index[2] % 2 == 0){
										temp_val[2] += (temp_val[3]*six[0][sub_index[2]]);
									}else{
										temp_val[2] -= (temp_val[3]*six[0][sub_index[2]]);
									}
									// calculated very last 5x5 matrix
									if(sub_index[2] == 5){
										sub_index[2] = 0;
										size_curr++;
										// update values
										if(sub_index[1] % 2 == 0){
											temp_val[1] += (temp_val[2]*seven[0][sub_index[1]]);
										}else{
											temp_val[1] -= (temp_val[2]*seven[0][sub_index[1]]);
										}
										// calculated very last 6x6 matrix
										if(sub_index[1] == 6){
											sub_index[1] = 0;
											size_curr++;
											// update values
											if(sub_index[0] % 2 == 0){
												temp_val[0] += (temp_val[1]*input_arr[0][sub_index[0]]);
											}else{
												temp_val[0] -= (temp_val[1]*input_arr[0][sub_index[0]]);
											}
											// calculated very last 7x7 matrix
											if(sub_index[0] == 7){
												//calculated everything
												temp_val[0] -= (temp_val[1]*input_arr[0][sub_index[0]]);
												det <= temp_val[0];
											}else{
												sub_index[0]++;
											}
										}else{
											sub_index[1]++;
										}
									}else{
										sub_index[2]++;
									}
								}else{
									// calculate next 4x4
									sub_index[3]++;
								}
							}else{
								// haven't calculated very last 3x3 matrix, so calculate next 3x3 det
								sub_index[4]++;
							}
						}

					end
				DONE:
					begin
						// state transfers
						if(Ack)
							state <= I;
						// data transfers
						
					end
				default:		
					state <= UNK;
			endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
