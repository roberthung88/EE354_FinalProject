//////////////////////////////////////////////////////////////////////////////////
// Author:			Robert (Jui Po) Hung
// Create Date:   04/16/21
// File Name:		ee354_FinalProject.v 
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////


module ee354_FinalProject(Clk, CEN, Reset, Start, Ack, input_arr, det, q_I, q_Input, q_Load, q_Comp, q_Done);


	/*  INPUTS */
	input	Clk, CEN, Reset, Start, Ack;
	input integer input_arr [7:0][7:0];
	
	
	/*  OUTPUTS */
	output reg [31:0] det;
	// store current state
	output q_I, q_Input, q_Load, q_Comp, q_Done;
	reg [4:0] state;	
	assign {q_Done, q_Comp, q_Load, q_Input, q_I} = state;
	
	
	/* TEMP VARS */
	reg integer seven [6:0][6:0];
	reg integer six [5:0][5:0];
	reg integer five [4:0][4:0];
	reg integer four [3:0][3:0];
	reg integer three [2:0][2:0];
	reg integer temp_val [8*7*6*5*4 - 1:0];
	reg status [8*7*6*5*4 - 1:0];
	
	localparam 	
	I = 5'b00001, INP = 5'b00010, LOAD = 5'b00100, COMP = 5'b01000, DONE = 5'b10000, UNK = 5'bXXXXX;
	
	// NSL AND SM
	always @ (posedge Clk, posedge Reset)
	begin
		if(Reset) 
		  begin
			state <= I;
			A <= 8'bx;		  	
			B <= 8'bx;
			AB_GCD <= 8'bx;			
		  end
		else				
				case(state)	
					I:
					begin
						// state transfers
						if (Start) state <= SUB;
						// data transfers
						i_count <= 0;
						A <= Ain;
						B <= Bin;
						AB_GCD <= 0;
					end		
					SUB: 
		               if (CEN) //  This causes single-stepping the SUB state
						begin		
							// state transfers
							if (A == B) state <= (i_count == 0) ? DONE   : MULT  ;
							// data transfers
							if (A == B) AB_GCD <= A  ;		
							else if (A < B)
							  begin
								// swap A and B
								A <= B;
								B <= A;
 
							  end
							else						// if (A > B)
							  begin	
								// A and B are even
								if(~A[0] && ~B[0])
								begin
									i_count <= i_count + 1'b1;
									A <= A >> 1;
									B <= B >> 1;
								end
								
								//A odd B even
								if(A[0] && ~B[0])
								begin
									B <= B >> 1;
								end
								//A even B odd
								if(~A[0] && B[0])
								begin
									A <= A >> 1;
								end
								//both odd
								if(A[0] && B[0])
								begin
									A <= A - B;
								end
							

							  end
						end
					MULT:
					  if (CEN) // This causes single-stepping the MULT state
						begin
							// state transfers
							if(i_count==8'b1)
							begin
								state <= DONE;
								AB_GCD <= AB_GCD << 1;
								i_count <= i_count - 1'b1;
							end
							else
							begin
								AB_GCD <= AB_GCD << 1;
								i_count <= i_count - 1'b1;
								state <= MULT;
							end
							// data transfers
							

						end
					
					DONE:
						if (Ack)	state <= I;
						
					default:		
						state <= UNK;
				endcase
	end
		
	// OFL
	// no combinational output signals
	
endmodule
