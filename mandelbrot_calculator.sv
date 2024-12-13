`define READY_WAIT 0
`define LOAD_INITIALVALUES 1
`define CALCULATE_NEXT_Z 2

//All calculations done in Signed Q15.16 Format
module mandelbrot_calc(
    input signed [31:0] initial_a,
    input signed [31:0] initial_b,
    input logic clk,
    input logic en,
    input logic rst,
    output logic ready,
    output logic [15:0] iterations
);

    logic [31:0] next_a, curr_a;
    logic [31:0] next_b, curr_b;
    logic [31:0] magsquare;
    logic [15:0] curr_iter;
    logic calc_stopped;
    logic [3:0] ps, ns, nsr;

    logic rst_iter, load_iter, set_initial_ab, load_next_ab;

    load_ff #(16) iter_reg(
        .clk(clk), 
        .D(rst_iter ? 16'b1: curr_iter + 16'b1),
        .Q(curr_iter),
        .reset(rst),
        .load(load_iter)
    );

    load_ff #(32) a_reg(
        .clk(clk), 
        .D(set_initial_ab ? initial_a: next_a),
        .Q(curr_a),
        .reset(rst),
        .load(load_next_ab)
    );

    load_ff #(32) b_reg(
        .clk(clk), 
        .D(set_initial_ab ? initial_b: next_b),
        .Q(curr_b),
        .reset(rst),
        .load(load_next_ab)
    );

    mandelbrot_recusion zsquared(
        .a(curr_a),
        .b(curr_b),
        .initial_a(initial_a),
        .initial_b(initial_b),
        .realpart(next_a),
        .imagpart(next_b),
        .magsquare(magsquare)
    );

    assign calc_stopped = (magsquare >= 32'd4 << 16) || (curr_iter >= 32'd100);
    assign iterations = curr_iter;
    assign nsr = (rst) ? `READY_WAIT : ns;

    always_ff @(posedge clk) begin
        ps <= nsr;
    end

    always_comb begin
        ready = 0;
        rst_iter = 0;
        load_iter = 0;
        set_initial_ab = 0;
        load_next_ab = 0;
        ns = `READY_WAIT;

        casex(ps)
            `READY_WAIT: begin
                ready = 1;
                if (en) begin
                    rst_iter = 1;
                    load_iter = 1;
                    set_initial_ab = 1;
                    load_next_ab = 1;
                    ns = `LOAD_INITIALVALUES;
                end
            end

            `LOAD_INITIALVALUES: begin
                ns = `CALCULATE_NEXT_Z;
            end

            `CALCULATE_NEXT_Z: begin
                if (calc_stopped) begin
                    ns = `READY_WAIT;
                end else begin
                    load_iter = 1;
                    load_next_ab = 1;
                    ns = `CALCULATE_NEXT_Z;
                end
            end

            default: begin
                ns = `READY_WAIT;
            end
        endcase
    end

endmodule

module mandelbrot_recusion(
    input signed [31:0] a,
    input signed [31:0] b,
    input signed [31:0] initial_a,
    input signed [31:0] initial_b,
    output signed [31:0] realpart,
    output signed [31:0] imagpart,
    output signed [31:0] magsquare
);

    wire signed [63:0] a_squared;
    wire signed [63:0] b_squared;
    wire signed [63:0] ab_product;

    
    assign a_squared = a * a;
    assign b_squared = b * b;
    assign ab_product = a * b;


    assign realpart = ((a_squared - b_squared) >>> 16) + initial_a;
    assign imagpart = ((ab_product << 1) >>> 16) + initial_b;

    assign magsquare = (a_squared + b_squared) >>> 16;

endmodule

module q15_16_signed_multiplier (
    input signed [31:0] a,
    input signed [31:0] b,
    output signed [31:0] out
);

    wire signed [63:0] temp;
    
    assign temp = a * b;
    assign out = temp >>> 16;

endmodule