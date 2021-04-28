`timescale 1ns / 1ps

module ee354_FinalProject_tb_v;

	// Inputs
	reg Clk;
	reg Reset;
	reg Start;
	reg Ack;
	integer input_arr [63:0];
	

	// Outputs
	wire [31:0] det;
	wire q_I;
	wire q_Load;
	wire q_Comp;
	wire q_Done;
	wire q_Enter;
	reg [6*8:0] state_string;
	integer clk_cnt, start_clock_cnt,clocks_taken;
	// Instantiate the Unit Under Test (UUT)
	ee354_FinalProject(.Clk(Clk), .Reset(Reset), .Start(Start), .Ack(Ack), .input_arr(input_arr), .det(det), .q_I(q_I), .q_Enter(q_Enter). .q_Load(q_Load), .q_Comp(q_Comp), .q_Done(q_Done));
	
		
		
		always  begin #5; Clk = ~ Clk; end
		always@(posedge Clk) clk_cnt=clk_cnt+1; //don't want to use reset to clear the clk_cnt or initialize
		initial begin
		// Initialize Inputs
		clk_cnt=0;
		Clk = 0;
		Reset = 0;
		Start = 0;
		Ack = 0;
		
		
		//reset control
		@(posedge Clk); //wait until we get a posedge in the Clk signal
		@(posedge Clk);
		#1;
		Reset=1;
		@(posedge Clk);
		#1;
		Reset=0;
		
		
		//First stimulus (36,24)
		input_arr = {6, 1, 1, 0, 0, 0, 0, 0, 4, -2, 5, 0, 0, 0, 0, 0, 2, 8, 7, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0,
             0, 0, 0, 0, 1, 0, 0, 0,
             0, 0, 0, 0, 0, 1, 0, 0,
             0, 0, 0, 0, 0, 0, 1, 0,
             0, 0, 0, 0, 0, 0, 0, 1};
		//make start signal active for one clock
		@(posedge Clk);
		#1;
		Start=1;
		@(posedge Clk);
		#1;
		Start=0;
		//leaving the q_I state, so start keeping track of the clocks taken
		start_clock_cnt=clk_cnt;
		wait(q_Done); //wait until q_Done signal is a 1
		clocks_taken = clk_cnt - start_clock_cnt;
		#1;
		$display("Determinant Value: %d", det);
		$display("It took %d clock(s) to compute the GCD", clocks_taken);
		//keep Ack signal high for one clock
		Ack=1;
		@(posedge Clk);
		#1;
		Ack=0;
		
		
		
	end
	
	always @(*)
		begin
			case ({q_I, q_Enter, q_Load, q_Comp, q_Done})    
				5'b10000: state_string = "q_I   ";  
				5'b01000: state_string = "q_Enter   ";  
				5'b00100: state_string = "q_Load ";  
				5'b00010: state_string = "q_Comp";
				5'b00001: state_string = "q_Done";			
			endcase
		end
 
      
endmodule

