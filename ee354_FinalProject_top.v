//////////////////////////////////////////////////////////////////////////////////
// Author:			Robert Hung
// Create Date:		02/25/08
// File Name:		ee354_FinalProject.v 
// Description: 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ee354_FinalProject_top 
		(MemOE, MemWR, RamCS, QuadSpiFlashCS, // Disable the three memory chips

        ClkPort,                           // the 100 MHz incoming clock signal
		
		BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons BtnL, BtnR,
		BtnC,                              // the center button (this is our reset in most of our designs)
		Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw3, Sw2, Sw1, Sw0, // 8 switches
		Ld8, Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0, // 8 LEDs
		An3, An2, An1, An0,			       // 4 anodes
		An7, An6, An5, An4,                // another 4 anodes which are not used
		Ca, Cb, Cc, Cd, Ce, Cf, Cg,        // 7 cathodes
		Dp                                 // Dot Point Cathode on SSDs
	  );

	/*  INPUTS */
	// Clock & Reset I/O
	input		ClkPort;	
	// Project Specific Inputs
	input		BtnL, BtnU, BtnD, BtnR, BtnC;	
	input		Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw3, Sw2, Sw1, Sw0; //removed uselss switches
	
	
	/*  OUTPUTS */
	// Control signals on Memory chips 	(to disable them)
	output 	MemOE, MemWR, RamCS, QuadSpiFlashCS;
	// Project Specific Outputs
	// LEDs
	output 	Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7, Ld8;
	// SSD Outputs
	output 	Cg, Cf, Ce, Cd, Cc, Cb, Ca, Dp;
	output 	An0, An1, An2, An3;	
	output 	An4, An5, An6, An7;	
	
	/*  LOCAL SIGNALS */
	wire		Reset, ClkPort;
	wire		board_clk, sys_clk;
	wire [2:0] 	ssdscan_clk; //modified clk to include more SSDs (FINAL)
	reg [26:0]	DIV_CLK;
	
	wire BtnL_Pulse; //was Start_Ack_Pulse (final)
	wire in_AB_Pulse, CEN_Pulse, BtnR_Pulse, BtnU_Pulse; 
	wire q_I, q_Enter, q_Load, q_Comp, q_Done; 
	reg [255:0] PackedInput_array ;
	wire signed [31:0] det; // added this reg to hold det
	reg [3:0]	SSD; //widened (final)
	wire [3:0]	SSD7, SSD6, SSD5, SSD4,SSD3, SSD2, SSD1, SSD0; //added all SSDs (FINAL)
	reg [7:0]  SSD_CATHODES;
	reg [5:0] arrIndex; //added this
	//added these new ones (FINAL)
	wire [3:0] matrixInput;
	wire [2:0] currRow;
	wire [2:0] currColumn;
	
    integer i;
//------------	






// Disable the three memories so that they do not interfere with the rest of the design.
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;
	
	
//------------
// CLOCK DIVISION

	// The clock division circuitary works like this:
	//
	// ClkPort ---> [BUFGP2] ---> board_clk
	// board_clk ---> [clock dividing counter] ---> DIV_CLK
	// DIV_CLK ---> [constant assignment] ---> sys_clk;
	
	BUFGP BUFGP1 (board_clk, ClkPort); 	

// As the ClkPort signal travels throughout our design,
// it is necessary to provide global routing to this signal. 
// The BUFGPs buffer these input ports and connect them to the global 
// routing resources in the FPGA.

	assign Reset = BtnC;
	
//------------
	// Our clock is too fast (100MHz) for SSD scanning
	// create a series of slower "divided" clocks
	// each successive bit is 1/2 frequency
  always @(posedge board_clk, posedge Reset) 	// trying to resolve multi assign operation
    begin							
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end
//-------------------	
	// In this design, we run the core design at full 100MHz clock!
	//assign	sys_clk = board_clk;
	assign	sys_clk = DIV_CLK[10]; 

//------------
// INPUT: SWITCHES & BUTTONS
ee354_debouncer #(.N_dc(28)) ee354_debouncer_2 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB( ),
		.SCEN(BtnL_Pulse), .MCEN( ), .CCEN( )); // changed from Start_Ack_Pulse to BtnL_Pulse (final)
		 		 

ee354_debouncer #(.N_dc(28)) ee354_debouncer_1 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB( ), 
		.SCEN(BtnR_Pulse), .MCEN( ), .CCEN( ));

ee354_debouncer #(.N_dc(28)) ee354_debouncer_0 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), // complete this instantiation
		.SCEN(BtnU_Pulse), .MCEN( ), .CCEN( )); // to produce BtnU_Pulse from BtnU
		
//------------ 
//Seting inputs for diffrent Purposes here (FINAL)
assign currRow = {Sw15, Sw14, Sw13};
assign currColumn = {Sw12, Sw11, Sw10};
assign matrixInput = {Sw3, Sw2, Sw1, Sw0};
assign enterPulse =  BtnR;

	always @ (posedge sys_clk, posedge Reset)
	begin 
		if (Reset) begin
           PackedInput_array <=  256'b0;
           PackedInput_array[0] <= 1'b1;
           PackedInput_array[36] <= 1'b1;
           PackedInput_array[72] <= 1'b1;
           PackedInput_array[108] <= 1'b1;
           PackedInput_array[144] <= 1'b1;
           PackedInput_array[180] <= 1'b1;
           PackedInput_array[216] <= 1'b1;
           PackedInput_array[252] <= 1'b1;
		end
		//do something
		else if (q_Enter == 1)
		  begin : ArrayInputBlock
            arrIndex = 32*currRow + currColumn*4;
            if (enterPulse)
                PackedInput_array[arrIndex+:4] <= matrixInput;
		  end
	end
		  
	ee354_FinalProject ee354_FinalProject1(.Clk(sys_clk), .Reset(Reset), .Start(BtnL), .Ack(BtnU),  //Modified tp included correct states (final) TODO many things (chaged Start_Ack_Pulse to BtnL_Pulse
						  .input_arr_flat(PackedInput_array), .det(det), //.Bin(Bin), .A(A), .B(B), .AB_GCD(AB_GCD), .i_count(i_count), <-dont think I need any of this
						  .q_I(q_I), .q_Enter(q_Enter), .q_Load(q_Load),.q_Comp(q_Comp), .q_Done(q_Done)); 

//------------
// OUTPUT: LEDS
	assign {Ld8, Ld7, Ld6, Ld5, Ld4} = {q_I, q_Enter, q_Load ,q_Comp, q_Done}; //Modified tp included correct states (final) TODO
	assign {Ld3, Ld2 ,Ld1, Ld0} = {BtnU, BtnC, BtnL, BtnR}; 
	// Here
	// BtnL = Start
	// BtnU = Ack
	// BtnR = Enter
	// BtnC = Reset
	
//------------
// SSD (Seven Segment Display)
	assign SSD7 = (q_Done) ? det[31:28]  : 4'b0000;
	assign SSD6 = (q_Done) ? det[27:24]  : 4'b0000;
	assign SSD5 = (q_Done) ? det[23:20]  : 4'b0000;
	assign SSD4 = (q_Done) ? det[19:16]  : 4'b0000;
	assign SSD3 = (q_Done) ? det[15:12]  : {1'b0,currRow};
	assign SSD2 = (q_Done) ? det[11:08]  : {1'b0,currColumn};
	assign SSD1 = (q_Done) ? det[07:04]  : arrIndex[3:0];
	assign SSD0 = (q_Done) ? det[03:00]  : PackedInput_array[arrIndex+:4];


	// need a scan clk for the seven segment display 
	// 191Hz (100 MHz / 2^19) works well CHANGED (FINAL)
	assign ssdscan_clk = DIV_CLK[19:17];
	assign An0	= !( ~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 000
	assign An1	= !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 001
	assign An2	=  !(~(ssdscan_clk[2]) && (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 010
	assign An3	=  !(~(ssdscan_clk[2]) && (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 011
	assign An4	= !((ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 100
	assign An5	= !((ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 101
	assign An6	=  !((ssdscan_clk[2]) && (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 110
	assign An7	=  !((ssdscan_clk[2]) && (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 111
	
	

	
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3, SSD4, SSD5, SSD6, SSD7) //removed old case structure
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
				  3'b000: SSD = SSD0;
				  3'b001: SSD = SSD1;
				  3'b010: SSD = SSD2;
				  3'b011: SSD = SSD3;
				  3'b100: SSD = SSD4;
				  3'b101: SSD = SSD5;
				  3'b110: SSD = SSD6;
				  3'b111: SSD = SSD7;
		endcase 
	end
	
	// and finally convert SSD_num to ssd
	// We convert the output of our 4-bit 4x1 mux

	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};

	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD) // in this solution file the dot points are made to glow by making Dp = 0
		    //                                                                abcdefg,Dp
			4'b0000: SSD_CATHODES = 8'b00000010; // 0
			4'b0001: SSD_CATHODES = 8'b10011110; // 1
			4'b0010: SSD_CATHODES = 8'b00100100; // 2
			4'b0011: SSD_CATHODES = 8'b00001100; // 3
			4'b0100: SSD_CATHODES = 8'b10011000; // 4
			4'b0101: SSD_CATHODES = 8'b01001000; // 5
			4'b0110: SSD_CATHODES = 8'b01000000; // 6
			4'b0111: SSD_CATHODES = 8'b00011110; // 7
			4'b1000: SSD_CATHODES = 8'b00000000; // 8
			4'b1001: SSD_CATHODES = 8'b00001000; // 9
			4'b1010: SSD_CATHODES = 8'b00010000; // A
			4'b1011: SSD_CATHODES = 8'b11000000; // B
			4'b1100: SSD_CATHODES = 8'b01100010; // C
			4'b1101: SSD_CATHODES = 8'b10000100; // D
			4'b1110: SSD_CATHODES = 8'b01100000; // E
			4'b1111: SSD_CATHODES = 8'b01110000; // F    
			default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
		endcase
	end	
	assign Dp = 1;
endmodule

