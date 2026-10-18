
module axis_lfsr #(
    parameter C_TDATA_BYTES= 4,
    parameter C_BEAT_COOLDOWN = 3,
    parameter C_PACKET_LENGTH = 16,
    parameter [63:0] C_INITIAL_STATE = 1
) (
    input lfsr_axis_aclk,
    input lfsr_axis_aresetn,
    output [(C_TDATA_BYTES * 8) - 1:0] lfsr_axis_tdata,
    output lfsr_axis_tlast,
    output lfsr_axis_tvalid,
    input lfsr_axis_tready
);
    wire tready;
    wire clk;
    wire resetn;
    reg tvalid;
    reg tlast;
    reg [(C_TDATA_BYTES * 8) - 1:0] tdata;

    assign clk = lfsr_axis_aclk;
    assign resetn = lfsr_axis_aresetn;
    assign lfsr_axis_tdata = tdata;
    assign lfsr_axis_tlast = tlast;
    assign lfsr_axis_tvalid = tvalid;
    assign tready = lfsr_axis_tready;

    reg [15:0] cooldown_counter;
    reg [15:0] packet_counter;

    reg [63:0] internal_state;

    always @(posedge clk) begin
        if(resetn == 0) begin
            cooldown_counter <= 0;
            tvalid <= 0;
            tlast <= 0;
            internal_state <= C_INITIAL_STATE;
        end
    end

endmodule
			
			