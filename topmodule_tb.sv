`timescale 1 ps / 1 ps

module mandelbrot_top_tb();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
    reg CLOCK_50;
    reg [3:0] KEY;
    reg [9:0] SW;
    wire [7:0] VGA_R, VGA_G, VGA_B, VGA_X;
    wire VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT;
    wire [6:0] VGA_Y;
    wire [2:0] VGA_COLOUR;
    wire [9:0] LEDR;
    wire [6:0] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;

    mandelbrot_top dut(.CLOCK_50(CLOCK_50), .KEY(KEY), .SW(SW),
                    .LEDR(LEDR),
                    .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
                    .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
                    .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
                    .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_CLK(VGA_CLK),
                    .VGA_X(VGA_X), .VGA_Y(VGA_Y),
                    .VGA_COLOUR(VGA_COLOUR), .VGA_PLOT(VGA_PLOT));

    initial begin
        forever begin        
            CLOCK_50 = !CLOCK_50;
            #2;
        end
    end

    initial begin
        forever begin
            CLOCK_50 = 0;
            KEY[3] = 0;
            @(posedge CLOCK_50);
            #1
            KEY[3] = 1;
            #10


            @(posedge LEDR[3]);
            $stop;

            #50
            KEY[3] = 0;
            #10;
            $stop;

        end
    end

endmodule
