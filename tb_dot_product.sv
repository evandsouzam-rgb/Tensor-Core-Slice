`timescale 1ns/1ps

module tb_dot_product (
);

logic clk, rst_n;
logic signed [7:0] a1, a2, a3, a4, b1, b2, b3, b4;
logic signed [15:0] c, d;
logic valid_in, valid_out, overflow;

dot_product dut (.clk(clk), .rst_n(rst_n), .valid_in(valid_in), 
                .a1(a1), .a2(a2), .a3(a3), .a4(a4), .b1(b1), .b2(b2), .b3(b3), .b4(b4), .c(c),
                .d(d), .valid_out(valid_out), .overflow(overflow));

initial clk = 0;
always #5 clk = ~clk;

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_dot_product);
end

integer in_file, exp_file;
integer scan_in, scan_exp;
integer tests_passed = 0; 
integer tests_failed = 0;
logic signed [15:0] exp_d;
logic exp_overflow;

initial begin
    rst_n = 0;
    valid_in = 0;
    a1 = 0; a2 = 0; a3 = 0; a4 = 0; b1 = 0; b2 = 0; b3 = 0; b4 = 0; c = 0;

    in_file = $fopen("inputs.hex", "r");
    if (in_file == 0) begin
            $display("ERROR: Could not open inputs.hex! Check that the file exists.");
            $finish; 
    end
    #20;
    @(posedge clk);
    rst_n <= 1;

    while (!$feof(in_file)) begin
        @(negedge clk);
        scan_in = $fscanf(in_file, "%h %h %h %h %h %h %h %h %h\n", 
                            a1, a2, a3, a4, b1, b2, b3, b4, c);
        if (scan_in == 9) begin
            valid_in <= 1'b1;
        end else begin
            valid_in <= 1'b0;
        end
    end

    @(posedge clk);
        valid_in <= 1'b0;

        $fclose(in_file);
        repeat (10) @(posedge clk);
        $display("\n========================================");
        $display("          REGRESSION REPORT             ");
        $display("========================================");
        $display("Passed: %0d", tests_passed);
        $display("Failed: %0d", tests_failed);
        if (tests_failed == 0 && tests_passed > 0) begin
            $display(">> SUCCESS: ALL TEST VECTORS MATCHED <<");
        end else begin
            $display(">> FAILURE: ERRORS DETECTED <<");
        end
        $display("========================================\n");
        
        $finish;
end

initial begin
        exp_file = $fopen("expected.hex", "r");
        if (exp_file == 0) begin
            $display("ERROR: Could not open expected.hex! Check that the file exists.");
            $finish;
        end
    end

    always @(posedge clk) begin
        if (rst_n && valid_out) begin
            scan_exp = $fscanf(exp_file, "%h %b\n", exp_d, exp_overflow);

            if (scan_exp == 2) begin
                if ((d === exp_d) && (overflow === exp_overflow)) begin
                    tests_passed++;
                end else begin
                    tests_failed++;
                    $display("MISMATCH at time %0t ps:", $time);
                    $display("  DUT:      d = %h (%0d), overflow = %b", d, d, overflow);
                    $display("  EXPECTED: d = %h (%0d), overflow = %b", exp_d, exp_d, exp_overflow);
                end
            end
        end
    end

endmodule