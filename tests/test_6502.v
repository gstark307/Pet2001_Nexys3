`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:44:27 11/28/2011
// Design Name:   cpu6502
// Module Name:   /home/skibo/FPGA/Nexys3/Pet2001/tests/test_6502.v
// Project Name:  Pet2001
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu6502
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_6502;

    // Inputs
    wire [7:0] data_in;
    reg       rdy;
    reg       irq;
    reg       nmi;
    reg       reset;
    reg       clk;

    // Outputs
    wire [15:0] addr;
    wire [7:0] 	data_out;
    wire 	we;

    // Instantiate the Unit Under Test (UUT)
    cpu6502 uut (
		 .addr(addr), 
		 .data_out(data_out), 
		 .we(we), 
		 .data_in(data_in), 
		 .rdy(rdy), 
		 .irq(irq), 
		 .nmi(nmi), 
		 .reset(reset), 
		 .clk(clk)
	 );

    initial begin
	// Initialize Inputs
	rdy = 0;
	irq = 0;
	nmi = 0;
	reset = 1;
	clk = 0;

	// Wait 100 ns for global reset to finish
	#100;
        
	// Add stimulus here
	repeat (10) @(posedge clk);
	reset <= 0;
	repeat (10) @(posedge clk);
	rdy <= 1;

    end

    // A clock
    always #5.0 clk = ~clk;

    // Simulate memory.
    reg [7:0] mem[65535 : 0];
    
    initial begin
	$readmemh("asm/AllSuiteA.mem", mem);
    end
    
    assign data_in = rdy ? mem[ addr ] : 8'hXX;
    
    always @(posedge clk)
	if (rdy) begin
	    if (we) begin
		$display("[%t] ADDR %h WRITE %h", $time, addr, data_out);
		mem[ addr ] = data_out;
		if (data_out === 8'hXX)
		    $stop;
	    end
	    else
		$display("[%t] ADDR %h READ %h", $time, addr, data_in);
	end

    // IRQ after 20us
    initial begin
	#20000.0;
	@(posedge clk);
	$display("[%t] Starting IRQ.", $time);
	irq <= 1;
	repeat (20) @(posedge clk);
	irq <= 0;
    end

    // NMI after 30us
    initial begin
	#30000.0;
	@(posedge clk);
	$display("[%t] Starting NMI.", $time);
	nmi <= 1;
	@(posedge clk);
	nmi <= 0;
    end

`ifdef rdystuff
    // RDY stuff
    always @(posedge clk) begin
	rdy <= 0;
	repeat (3) @(posedge clk);
	rdy <= 1;
    end
`endif

`ifdef xxx
    reg [15:0] last_addr;
    reg [7:0]  last_data;
    reg        last_we;
    reg        last_rdy;

    always @(posedge clk) begin
	last_addr <= addr;
	last_data <= data_out;
	last_rdy <= rdy;
	last_we <= we;

	if (!last_rdy && addr !== last_addr) begin
	    $display("[%t] address changed without RDY!", $time);
	    $stop;
	end
	else if (!last_rdy && data_out !== last_data) begin
	    $display("[%t] data changed without RDY!", $time);
	    $stop;
	end
	else if (!last_rdy && we !== last_we) begin
	    $display("[%t] we changed without RDY!", $time);
	    $stop;
	end
    end    
`endif

endmodule

