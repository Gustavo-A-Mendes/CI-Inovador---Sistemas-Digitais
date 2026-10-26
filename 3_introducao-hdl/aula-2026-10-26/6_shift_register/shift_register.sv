module shift_register8 (
    input wire          clk,
    input wire          rst_n,
    input wire          en,
    input wire          dir,
    input wire          serial_in,
    input wire          parallel_en,
    input wire [7:0]    d,
    output reg [7:0]    q
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 8'b0000_0000;
        end
        else if (en) begin
            if (dir == 1'b0)
                q <= {serial_in, q[7:1]};
            else
                q <= {q[6:0], serial_in};
        end

        else if (parallel_en)
            q <= d;
    end

endmodule