`define IDLE 3'd0
`define MAP_COORDINATES 3'd1
`define WAIT_FOR_CALCULATE 3'd2
`define PLOT_PIXEL 3'd3
`define UPDATE_PIXELCOORD 3'd4

module render(
    input logic clk, 
    input logic rst_n, 
    input logic [2:0] colour,
    input logic start, 
    output logic done,
    output logic [7:0] vga_x, 
    output logic [6:0] vga_y,
    output logic [2:0] vga_colour, 
    output logic vga_plot
);

    logic [7:0] x;
    logic [6:0] y;
    logic plot, loadx, loady, en;

    logic [2:0] ps, ns, nsr;
    assign nsr = (rst_n) ? `IDLE: ns;

    logic ready;
    logic [15:0] iterations;
    logic signed [31:0] initial_a, initial_b;

    mandelbrot_calc mandelbrot (
        .initial_a(initial_a),
        .initial_b(initial_b),
        .clk(clk),
        .en(en),
        .rst(rst_n),
        .ready(ready),
        .iterations(iterations)
    );

    wire signed [31:0] x_shifted = (x - 8'd120) <<< 16;
    wire signed [31:0] y_shifted = (y - 7'd60) <<< 16;

    q15_16_signed_multiplier amap(
        .a(x_shifted), 
        .b(32'h00000333), 
        .out(initial_a)
    );

    q15_16_signed_multiplier bmap(
        .a(y_shifted), 
        .b(32'h00000444), 
        .out(initial_b)
    );

    load_ff #(8) xreg(
        .clk(clk), 
        .D(x + 8'd1), 
        .Q(x), 
        .reset(rst_n), 
        .load(loadx)
    );

    load_ff #(7) yreg(
        .clk(clk), 
        .D((y + 1 == 120) ? 7'b0 : y + 7'd1), 
        .Q(y), 
        .reset(rst_n), 
        .load(loady)
    );

    always @(posedge clk) begin
        ps <= nsr;
    end

    always_comb begin
        done = 1'b0;
        plot = 1'b0;
        loadx = 1'b0;
        loady = 1'b0;
        en = 1'b0;
        vga_colour = 3'b000;
        ns = `IDLE;

        case (ps)
            `IDLE: begin
                done = 1'b1;
                if (start) begin
                    ns = `MAP_COORDINATES;
                end else begin
                    ns = `IDLE;
                end
            end

            `MAP_COORDINATES: begin
                en = 1'b1;
                ns = `WAIT_FOR_CALCULATE;
            end

            `WAIT_FOR_CALCULATE: begin
                if (ready) begin
                    ns = `PLOT_PIXEL;
                end else begin
                    ns = `WAIT_FOR_CALCULATE;
                end
            end

            `PLOT_PIXEL: begin
                plot = 1'b1;
                vga_colour = (iterations < 16'd100) ? 3'b111 : 3'b000;
                ns = `UPDATE_PIXELCOORD;
            end

            `UPDATE_PIXELCOORD: begin
                if (y + 1 == 120) begin
                    loady = 1'b1;
                    loadx = 1'b1;
                    if (x + 1 == 160) begin
                        ns = `IDLE;
                    end else begin
                        ns = `MAP_COORDINATES;
                    end
                end else begin
                    loady = 1'b1;
                    loadx = 1'b0;
                    ns = `MAP_COORDINATES;
                end
            end

            default: begin
                ns = `IDLE;
            end
        endcase
    end

    assign vga_x = x;
    assign vga_y = y;
    assign vga_plot = plot;

endmodule