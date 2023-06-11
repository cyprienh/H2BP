module imem import h2bp::*;(
    input   logic       clk,

    input   logic[31:0] pc,

    output  logic[31:0] instruction
);

    //logic[255:0][31:0]    memory;

    always_ff @(posedge clk) begin
        case(pc)
            0:  instruction <= 32'b00001000010000110101010101010101;
            1:  instruction <= 32'b0;
            2:  instruction <= 32'b0;
            3:  instruction <= 32'b0;
            4:  instruction <= 32'b0;
            5:  instruction <= 32'b0;
            6:  instruction <= 32'b0;
            7:  instruction <= 32'b0;
        endcase
    end

endmodule
