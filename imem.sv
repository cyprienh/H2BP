module imem import h2bp::*;(
    input   logic       clk,
    input   logic       rst,

    input   logic[31:0] pc,

    output  logic[31:0] instruction,

    input   logic       branch
);

    //logic[255:0][31:0]    memory;

    always_ff @(posedge clk) begin
        if(!(rst || branch)) begin
            case(pc)
                0:  instruction <= 32'b00001000010000010101010101010101;    // add x1,x0,#-21846
                //1:  instruction <= 32'b0;
                //2:  instruction <= 32'b0;
                //3:  instruction <= 32'b0;
                1:  instruction <= 32'b00001000110000010101010101010101;    // add x3,x0,#-21846
                //5:  instruction <= 32'b0;
                //6:  instruction <= 32'b0;
                //7:  instruction <= 32'b0;
                2:  instruction <= 32'b10000000010001100000000000001110;    // beq x1,x3,#7
                3:  instruction <= 32'b00001000010000001010101010101011;    // add x1,x0,####
                4:  instruction <= 32'b00001000110000001010101010101011;    // add x3,x0,####
                5:  instruction <= 32'b0;
                6:  instruction <= 32'b0;
                7:  instruction <= 32'b0;
                8:  instruction <= 32'b0;
                9:  instruction <= 32'b00001000010000000000000000000011;    // add x1,x0,#1
                10: instruction <= 32'b11000000010000000000000000001111;    // str x1,x0,#7
                default: instruction <= 32'b0;
            endcase
        end else begin
            instruction <= 32'b0;
        end
    end

endmodule
