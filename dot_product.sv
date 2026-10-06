module dot_product (
    input logic clk,
    input logic rst_n,
    input logic valid_in,

    input logic signed [7:0] a1,
    input logic signed [7:0] a2,
    input logic signed [7:0] a3,
    input logic signed [7:0] a4,

    input logic signed [7:0] b1,
    input logic signed [7:0] b2,
    input logic signed [7:0] b3,
    input logic signed [7:0] b4,

    input logic signed [15:0] c,
    
    output logic valid_out,
    output logic overflow,
    output logic signed [15:0] d
);
    logic valid_s1, valid_s2;
    logic signed [15:0] c_s1, c_s2;


    logic signed [15:0] p1, p2, p3, p4;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p1 <= 0;
            p2 <= 0;
            p3 <= 0;
            p4 <= 0;
            c_s1 <= 0;
            valid_s1 <= 0;
        end else if (valid_in) begin
            p1 <= a1 * b1;
            p2 <= a2 * b2;
            p3 <= a3 * b3;
            p4 <= a4 * b4;
            c_s1 <= c;
            valid_s1 <= 1;
        end else begin
            valid_s1 <= 0;
        end
    end

    logic signed [17:0] sum;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum <= 0;
            c_s2 <= 0;
            valid_s2 <= 0;
        end else if (valid_s1) begin
            sum <= p1 + p2 + p3 + p4;
            c_s2 <= c_s1;
            valid_s2 <= 1;
        end else begin
            valid_s2 <= 0;
        end
    end

    logic signed [18:0] full_sum;
    assign full_sum = sum + c_s2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d <= 0;
            overflow <= 0;
            valid_out <= 0;
        end else if (valid_s2) begin
            if (full_sum > 19'sd32767) begin
                d <= 16'h7FFF;
                overflow <= 1;
                valid_out <= 1;
            end else if (full_sum < -19'sd32768) begin
                d <= 16'h8000;
                overflow <= 1;
                valid_out <= 1;
            end else begin
                d <= full_sum[15:0];
                overflow <= 0;
                valid_out <= 1;
            end
        end else begin
            overflow <= 0;
            valid_out <= 0;
        end
    end
endmodule