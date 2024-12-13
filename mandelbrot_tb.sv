module tb_mandelbrotcalc;

    reg signed [31:0] initial_a;
    reg signed [31:0] initial_b;
    reg clk;
    reg en;
    reg rst;
    
    wire ready;
    wire [15:0] iterations;

    MandelbrotCalc uut (
        .initial_a(initial_a),
        .initial_b(initial_b),
        .clk(clk),
        .en(en),
        .rst(rst),
        .ready(ready),
        .iterations(iterations)
    );

    always begin
        #5 clk = ~clk; // Clock with period 10 units
    end

    initial begin
        // Initialize inputs
        clk = 0;
        en = 0;
        rst = 0;
        
        // Apply reset
        rst = 1;
        #10;
        rst = 0;

        // Test Case 1: c = 0 + 0i (inside the Mandelbrot set)
        initial_a = 32'h00000000;   // Real part: 0.0 (Q15.16)
        initial_b = 32'h00000000;   // Imaginary part: 0.0 (Q15.16)
        en = 1;                  // Enable calculation
        #10;
        en = 0;                  // Disable enable signal
        wait (ready == 1);
        $display("Test 1: c = 0 + 0i | Iterations: %d", iterations);
        #10;

        // Test Case 2: Divergence in one cycle, c = 2 + 2i
        initial_a = 32'h00020000;   // Real part: 2.0 (Q15.16)
        initial_b = 32'h00020000;   // Imaginary part: 2.0 (Q15.16)
        en = 1;                  // Enable calculation
        #10;
        en = 0;                  // Disable enable signal
        wait (ready == 1);
        $display("Test 2: c = 2 + 2i | Iterations: %d", iterations);
        #10;

        // Test Case 3: c = 0.25 + 0.25i (inside the Mandelbrot set)
        initial_a = 32'h00004000;   // Real part: 0.25 (Q15.16)
        initial_b = 32'h00004000;   // Imaginary part: 0.25 (Q15.16)
        en = 1;                  // Enable calculation
        #10;
        en = 0;                  // Disable enable signal
        wait (ready == 1);
        $display("Test 3: c = 0.25 + 0.25i | Iterations: %d", iterations);
        #10;

        // Test Case 4: c = -0.25 + 0.5i
        initial_a = 32'hFFFFC000;  // Real part: -0.25 (Q15.16)
        initial_b = 32'h00008000;  // Imaginary part: 0.5 (Q15.16)
        en = 1;                  // Enable calculation
        #10;
        en = 0;                  // Disable enable signal
        wait (ready == 1);
        $display("Test 4: c = -0.25 + 0.5i | Iterations: %d", iterations);
        #10;

        // Test Case 5: Divergence in 50 cycles, c = -0.8 + 0.156i
        initial_a = 32'hFFFFCD33;   // Real part: -0.8 (Q15.16)
        initial_b = 32'h0000271C;   // Imaginary part: 0.156 (Q15.16)
        en = 1;                  // Enable calculation
        #10;
        en = 0;                  // Disable enable signal
        wait (ready == 1);
        $display("Test 5: c = -0.8 + 0.156i | Iterations: %d", iterations);
        #10;

        // Test Case 6: Divergence in 75 cycles, c = -0.74 + 0.18i
        initial_a = 32'hFFFFD187;   // Real part: -0.74 (Q15.16)
        initial_b = 32'h00002E14;   // Imaginary part: 0.18 (Q15.16)
        en = 1;                  // Enable calculation
        #10;
        en = 0;                  // Disable enable signal
        wait (ready == 1);
        $display("Test 6: c = -0.74 + 0.18i | Iterations: %d", iterations);
        #10;

        $stop; // Stop simulation after all tests
    end

endmodule