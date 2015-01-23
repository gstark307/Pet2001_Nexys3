`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:54:23 10/14/2011
// Design Name:   pet2001ps2_key
// Module Name:   test_ps2
// Project Name:  Pet2001
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pet2001ps2_key
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////

module test_ps2;

    // Inputs
    reg [3:0] keyrow;
    reg       ps2_clk;
    reg       ps2_data;
    reg       clk;
    reg       reset;

    // Outputs
    wire [7:0] keyin;

    // Instantiate the Unit Under Test (UUT)
    pet2001ps2_key uut (
			.keyin(keyin), 
			.keyrow(keyrow), 
			.ps2_clk(ps2_clk), 
			.ps2_data(ps2_data), 
			.clk(clk), 
			.reset(reset)
			);

    // Way fast PS/2 rate.
    parameter PS2_CLK_RATE = 20;

    task putbit;
	input bit;
	begin
            ps2_data <= #1 bit;
            repeat (PS2_CLK_RATE) @(posedge clk);
            ps2_clk <= #1 0;
            repeat (PS2_CLK_RATE * 2) @(posedge clk);
            ps2_clk <= #1 1;
            repeat (PS2_CLK_RATE) @(posedge clk);
	end
    endtask
    
    task putbyte;
	input [7:0] b;
	begin:foo
            reg parity;
            
            parity = ~^{b};
            putbit(0);
            putbit(b[0]);
            putbit(b[1]);
            putbit(b[2]);
            putbit(b[3]);
            putbit(b[4]);
            putbit(b[5]);
            putbit(b[6]);
            putbit(b[7]);
            putbit(parity);
            putbit(1);
            
            repeat (PS2_CLK_RATE * 2) @(posedge clk);
	end
    endtask // putbyte

    task dumprows;
	begin:foo
	    integer i;
	    for (i=0; i<16; i=i+1) begin
		keyrow <= 4'd0 + i;
		repeat (3) @(posedge clk);
		$display("[%t] row: %b keyin: %b", $time, keyrow, keyin);
		@(posedge clk);
	    end
	    $display("------------------");
	end
    endtask // dumprows
    
    
    initial begin
	// Initialize Inputs
	keyrow = 0;
	ps2_clk = 1;
	ps2_data = 0;
	clk = 0;
	reset = 1;

	// Wait 100 ns for global reset to finish
	#100;
        
	// Add stimulus here
	repeat (10) @(posedge clk);
	reset <= 0;

	repeat (10) @(posedge clk);
	
	putbyte(8'h1A); // press Z
	repeat (100) @(posedge clk);
	$display("Press Z");
	dumprows();
	putbyte(8'hF0);
	putbyte(8'h1A);	// release Z
	$display("Release Z");
	dumprows();
	
	@(posedge clk); // get out of step with oddclock.
	
	putbyte(8'h1A);	// press Z
	putbyte(8'h2C); // press T
	$display("Press Z and T");
	dumprows();
	
	putbyte(8'h2C);	// press T again
	putbyte(8'hF0); // release T
	putbyte(8'h2C);
	$display("Release T (still Z?)");
	dumprows();
	
	putbyte(8'hF0);
	putbyte(8'h1A);	// release Z
	$display("Release Z");
	dumprows();
	
    end // initial begin

    always #5.0 clk = ~clk;
      
endmodule

