module tb_axis_lfsr(

);

    reg clk = 1;
    reg resetn = 0;
    always #5 clk = ~clk;
    initial #99 @(posedge clk) resetn = 1;

    axis_lfsr #(
        .C_BEAT_COOLDOWN(0)
    ) uut(
        .lfsr_axis_aclk(clk),
        .lfsr_axis_aresetn(resetn),
        .lfsr_axis_tready(1)
    );
endmodule