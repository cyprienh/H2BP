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
    input   logic[31:0] result,

    input   logic[4:0]  result_addr_func,
    input   logic[4:0]  result_addr_data,

    input   logic[31:0] result_func,
    input   logic[31:0] result_data
);

    logic[31:0] registers_array[31:0];

    //initial registers_array[1] = 32'hF0F0F0F0;
    //initial registers_array[3] = 32'hF0F0F0F0;

    always_ff @(posedge clk) begin
        if(operand_a_enable) begin
            if(operand_a_addr == result_addr_func) begin
                operand_a <= result_func;
            end else if(operand_a_addr == result_addr_data) begin
                operand_a <= result_data;
            end else begin
                operand_a <= registers_array[operand_a_addr];
                if(operand_a_addr == 5'b0)
                    operand_a <= 32'b0;
            end
        end
        if(operand_b_enable) begin
            if(operand_b_addr == result_addr_func) begin
                operand_b <= result_func;
            end else if(operand_b_addr == result_addr_data) begin
                operand_b <= result_data;
            end else begin
                operand_b <= registers_array[operand_b_addr];
                if(operand_b_addr == 5'b0)
                    operand_b <= 32'b0;
            end
        end

        if(result_enable)
            registers_array[result_addr] <= result;
    end

endmodule
