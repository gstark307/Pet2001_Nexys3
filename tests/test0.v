`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:44:22 09/23/2011
// Design Name:   pet2001
// Module Name:   test0.v
// Project Name:  Pet2001
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pet2001
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////

module test0;

    // Inputs
    reg 	btns;
    reg 	btnu;
    reg 	btnl;
    reg 	btnd;
    reg 	btnr;
    reg		Rs232RxD;
    reg 	PS2KeyboardClk;
    reg 	PS2KeyboardData;
    reg 	cass_read;
    reg [7:0] 	sw;
    reg 	clk_100M;

    // Outputs
    wire [2:0] 	vgaRed;
    wire [2:0] 	vgaGreen;
    wire [2:1] 	vgaBlue;
    wire 	Hsync;
    wire 	Vsync;
    wire [7:0] 	Led;
    wire [7:0] 	seg;
    wire [3:0] 	an;
    wire 	cass_motor;
    wire 	cass_write;
    wire 	audio;
    wire	Rs232TxD;
    wire        Rs232Ctsn;
    
    // inouts
    wire [7:0] 	JA;
    wire [7:0] 	JB;

    // Instantiate the Unit Under Test (UUT)
    pet2001 uut (.btns(btns),
		 .btnu(btnu),
		 .btnl(btnl),
		 .btnd(btnd),
		 .btnr(btnr),
		  
		 .sw(sw),
		 
		 .Led(Led),
		 
		 .vgaRed(vgaRed), 
		 .vgaGreen(vgaGreen), 
		 .vgaBlue(vgaBlue), 
		 .Hsync(Hsync), 
		 .Vsync(Vsync),

		 .Rs232RxD(Rs232RxD),
		 .Rs232TxD(Rs232TxD),
		 
		 .seg(seg), 
		 .an(an),
		 
		 .JA(JA),
		 .JB(JB),

		 .clk_100M(clk_100M)
	 );
    
    assign JA[4] = PS2KeyboardClk;
    assign JA[6] = PS2KeyboardData;
    assign JB[2] = cass_read;
    assign cass_motor = JB[3];
    assign cass_write = JB[1];
    assign audio = JB[0];
    assign Rs232Ctsn = JA[3];

    initial begin
	// Initialize Inputs
	btns = 0;
	btnu = 0;
	btnl = 0;
	btnd = 0;
	btnr = 0;
	sw = 8'b0000_0001; // set sw[0] for high speed.
	Rs232RxD = 1;
	PS2KeyboardClk = 1;
	PS2KeyboardData = 1;
	cass_read = 0;
	clk_100M = 0;

	// Wait 100 ns for global reset to finish
	#100;
        
	// Add stimulus here

    end
    
    always #5.0 clk_100M = ~clk_100M;
    
endmodule
