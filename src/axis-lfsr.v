
module axis_lfsr #(
    parameter C_TDATA_BYTES= 4,
    parameter C_BEAT_COOLDOWN = 3,
    parameter C_PACKET_LENGTH = 16,
    parameter [126:0] C_INITIAL_STATE = 126'h34f05a3a531350aa17b4c6c002f05277
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
    wire [(C_TDATA_BYTES * 8) - 1:0] tdata;

    assign clk = lfsr_axis_aclk;
    assign resetn = lfsr_axis_aresetn;
    assign lfsr_axis_tdata = tdata;
    assign lfsr_axis_tlast = tlast;
    assign lfsr_axis_tvalid = tvalid;
    assign tready = lfsr_axis_tready;

    reg [15:0] cooldown_counter;
    reg [15:0] packet_counter;
    reg [63:0] staged_data;
    assign tdata = staged_data[(C_TDATA_BYTES * 8) - 1:0];

    reg [126:0] i_s;
    reg [126:0] next_state;
    integer i;

    always @(i_s) begin
        next_state = {i_s[0],i_s[0]^i_s[126],i_s[125:1]};
        for(i = 0; i < 16; i = i+1) begin
            staged_data[4*(i+1)-1 -: 4] <= i_s[7*(16-i)-1 -: 4];
        end
    end

    always @(posedge clk) begin
        if(resetn == 0) begin
            cooldown_counter <= C_BEAT_COOLDOWN;
            packet_counter <= C_PACKET_LENGTH;
            tvalid <= 0;
            tlast <= 0;
            i_s <= C_INITIAL_STATE;
        end
        else begin
            if(cooldown_counter == 0) begin
                tvalid <= 1;
                tlast <= (packet_counter == 0) ? 1 : 0;
            end
            else if(tvalid && tready) begin
                tvalid <= 0;
                tlast <= 0;
            end

            if(tvalid && tready) begin
                i_s <= next_state;
                cooldown_counter <= C_BEAT_COOLDOWN;
                packet_counter <= (packet_counter == 0) ? C_PACKET_LENGTH : packet_counter - 1;
            end
            else begin
                cooldown_counter <= (cooldown_counter == 0) ? 0 : cooldown_counter - 1;
            end
        end
    end

endmodule
			
			