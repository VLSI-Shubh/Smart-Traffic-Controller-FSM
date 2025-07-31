`timescale 1ns / 1ps
`include "traffic_controller.v"
module traffic_controller_tb;

    // Inputs
    reg [3:0]T;
    reg clk, rst;

    // Outputs
    wire [3:0] r, g, y;


    // Instantiate the Unit Under Test (UUT)
    traffic_controller uut (.Traffic(T), 
    .clk(clk), .rst(rst), .Red(r), .Green(g), .Yellow(y));

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("traffic_controller_tb.vcd");
        $dumpvars(0, traffic_controller_tb);

        // Initialize inputs
        T = 4'b000;
        rst = 1;

        // Hold reset for a few clock cycles
        #20;
        rst = 0;

        // --- Test case 1: Traffic on lane 1 ---
        T = 4'b1000;
        // Wait enough time for full traffic to complete
        #600;
                // --- Test case 1: Traffic on lane 3  ---
        T = 4'b0100;
        // Wait enough time for full traffic a
        #600;

        // --- Test case 2: Traffic on lane 2 & 4 and pedestrian on ped_24 ---
        T = 4'b1010;
        // Wait enough time for full traffic a
        #600;

        // --- Test case 3: No traffic or pedestrians (idle state) ---
        T = 4'b0000;

        #100;

        // Finish simulation
        $finish;
    end

    // Simple monitoring to print relevant signals at every clock positive edge
    always @(posedge clk) begin
        $display("Time: %0t ns | rst=%b | T=%b%b%b%b | R=%b%b%b%b G=%b%b%b%b Y=%b%b%b%b | State=%d Timer=%d Done=%b",
            $time, rst,
            T[3], T[2], T[1], T[0],     // Traffic bits
            r[3], r[2], r[1], r[0],     // Red lights
            g[3], g[2], g[1], g[0],     // Green lights  
            y[3], y[2], y[1], y[0],     // Yellow lights
            uut.ps,                     // Current state
            uut.max_timer,              // Timer value
            uut.done                    // Done signal
        );
    end

endmodule
