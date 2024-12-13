// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

`define STARTRENDER 1
`define HALT 0

module mandelbrot_top(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    logic [2:0] vga_colour_render;
    logic [7:0] vga_x_render;
    logic [6:0] vga_y_render;
    logic plot_render;
    logic done_render;

    logic start_render;
    logic [1:0] ps, ns;
    logic [1:0] nsr;

    // Reset and state logic
    assign nsr = (~KEY[3]) ? `STARTRENDER : ns;

    // Instantiate the VGA adapter
    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), .colour(vga_colour_render),
                                            .x(vga_x_render), .y(vga_y_render), .plot(plot_render),
                                            .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
                                            .VGA_CLK(VGA_CLK), .VGA_HS(VGA_HS), .VGA_VS(VGA_VS), .VGA_BLANK(), .VGA_SYNC(), .*);

    render render_inst(
        .clk(CLOCK_50),
        .rst_n(~KEY[3]),
        .colour(3'b010),
        .start(start_render),
        .done(done_render),
        .vga_x(vga_x_render),
        .vga_y(vga_y_render),
        .vga_colour(vga_colour_render),
        .vga_plot(plot_render)
    );

    always @(posedge CLOCK_50) begin
        ps <= nsr;
    end

    always @(*) begin
        VGA_X = vga_x_render;
        VGA_Y = vga_y_render;
        VGA_COLOUR = vga_colour_render;
        VGA_PLOT = plot_render;

        case (ps)
            `STARTRENDER: begin
                if (done_render) begin
                    start_render = 1;
                    ns = `STARTRENDER;
                end else begin
                    start_render = 0;
                    ns = `HALT;
                end
            end

            `HALT: begin
                start_render = 0;
                ns = `HALT;
            end

            default: begin
                start_render = 0;
                ns = `STARTRENDER;
            end
        endcase
    end

endmodule