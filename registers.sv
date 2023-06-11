module registers import h2bp::*;(
    input   logic       clk,

    input   logic       operand_a_enable,
    input   logic       operand_b_enable,
    input   logic       result_enable,

    input   logic[4:0]  operand_a_addr,
    input   logic[4:0]  operand_b_addr,
    input   logic[4:0]  result_addr,

    output  logic[31:0] operand_a,
    output  logic[31:0] operand_b,
    input   logic[31:0] result
);

    logic[31:0]    registers_array[31:0];

    always_ff @(posedge clk) begin
        if(operand_a_enable) begin
            operand_a <= registers_array[operand_a_addr];
            if(operand_a_addr == 5'b0)
                operand_a <= 32'b0;
        end
        if(operand_b_enable) begin
            operand_b <= registers_array[operand_b_addr];
            if(operand_b_addr == 5'b0)
                operand_b <= 32'b0;
        end

        if(result_enable)
            registers_array[result_addr] <= result;
    end

endmodule
