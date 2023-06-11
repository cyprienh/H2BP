module alu import h2bp::*;(
    input   logic[2:0]  operation,

    input   logic[31:0] operand_a,
    input   logic[31:0] operand_b,
    
    output  logic[31:0] result//,
    //output  flags       alu_flags
);

    //assign alu_flags.zero = result == 32'b0;
    //assign alu_flags.negative = result[31] == 1'b1;

    always_comb begin
        case (operation)
            opADD:    /*{alu_flags.carry,*/ result/*}*/ = operand_a + operand_b;
            opSUB:    result = operand_a - operand_b;
            opMULT:   result = operand_a * operand_b;
            //DIV:  TODO
            opAND:    result = operand_a & operand_b;
            opOR:     result = operand_a | operand_b;
            opLSHIFT: result = operand_a << operand_b;
            opRSHIFT: result = operand_a >> operand_b;
            default: result = 32'b0;
        endcase
    end

endmodule
