`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:30:59 10/03/2011
// Design Name:   pet2001cass232
// Module Name:   test_cass232.v
// Project Name:  Pet2001
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pet2001cass232
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_cass232;

	// Inputs
    reg		rx232;
    reg 	cass_motor_n;
    reg 	cass_write;
    reg 	clk;
    reg 	reset;

    // Outputs
    wire 	tx232;
    wire 	cass_read;
    wire 	cts232n;

    // Instantiate the Unit Under Test (UUT)
    pet2001cass232 uut (
			.tx232(tx232), 
			.rx232(rx232),
			.cts232n(cts232n),
			.cass_motor_n(cass_motor_n), 
			.cass_write(cass_write), 
			.cass_read(cass_read), 
			.clk(clk), 
			.reset(reset)
		);

    parameter RS232_BIT_TIME = 26042.0; // 8680=115,200 baud, 26042=38,400
    
    task write_char(input [7:0] c);
	begin
            while (cts232n)
		@(posedge clk);
            
            rx232 <= 1'b0;					// start bit
            repeat (8) begin
		#RS232_BIT_TIME rx232 <= c[0];
		c = {1'bx, c[7:1]};
            end
            #RS232_BIT_TIME rx232 <= 1'b1;	// stop
            #RS232_BIT_TIME ;
	end
    endtask // write_char

    // Read all characters.
    always @(negedge tx232) begin:foo2
	reg [7:0] c;
	
	#(RS232_BIT_TIME / 2.0); // move to halfway into bit time for sampling
	
	repeat (8) begin
            #(RS232_BIT_TIME) c = { tx232, c[7:1] };
	end
	
	#(RS232_BIT_TIME) ;	// stop bit
	
	$display("%t: received '%h'", $time, c);
    end

    initial begin
	// Initialize Inputs
	rx232 = 1;
	cass_motor_n = 1;
	cass_write = 0;
	clk = 0;
	reset = 1;

	// Wait 100 ns for global reset to finish
	#100;
        
	// Add stimulus here
	
	repeat (20) @(posedge clk);
	reset <= 0;
	
	#1000000.0 cass_motor_n <= 0; // 1ms, turn on

	#100000.0;
	
	repeat (20) begin
            write_char(8'h07);
            write_char(8'hff);
            write_char(8'he0);
            write_char(8'h00);
	end
	
	#1000000.0;
	
	#3000000.0 cass_motor_n <= 1; // 3ms, turn off
	#1000000.0 ;

	cass_motor_n <= 0;
	forever begin
            @(negedge tx232);
            rx232 <= 1'b0;
            @(posedge tx232);
            rx232 <= 1'b1;
	end
	
    end
    
    always @(posedge cts232n) begin
	$display("[%t] cts232n=1", $time);
	@(negedge cts232n);
	$display("[%t] cts232n=0", $time);
    end
    
    always #5.0 clk = ~clk;
    always #400000.0 cass_write = ~cass_write;
    
endmodule

