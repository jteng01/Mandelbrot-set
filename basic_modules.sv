module load_ff(clk,D,Q,reset,load);
    parameter n=1;
    input logic clk;
    input logic [n-1:0] D;
    input logic reset;
    input logic load;
    output logic [n-1:0] Q;
    always @(posedge clk) begin
        if (reset == 1) begin
            Q <= {n{1'b0}};
        end
        else if (load == 0) begin
            Q <= Q;
        end
        else
            Q <= D;
    end
endmodule

module MUX3(option0, option1, option2, sel, out);
    parameter n=1;
    input logic [1:0] sel;
    input logic [n-1:0] option0, option1, option2;
    output logic [n-1:0] out;

    always @* begin
        if(sel == 0)
            out = option0;
        else if(sel == 1)
            out = option1;
        else if(sel == 2)
            out = option2;
        else
            out = {n{1'bx}};
    end
endmodule
