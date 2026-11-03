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
        // casex ({rst_n, en, dir})
        //     3'b0xx:     q <= 8'b0000_0000; 
        //     3'b10x:     q <= d;
        //     3'b110:     q <= {serial_in, q[7:1]};
        //     3'b111:     q <= {q[6:0], serial_in};
        // endcase

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