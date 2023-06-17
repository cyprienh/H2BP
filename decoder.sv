module decoder import h2bp::*;(
    input   logic[31:0] instruction,

    output  logic[4:0]  rd_addr,
    output  logic[4:0]  rs1_addr,
    output  logic[4:0]  rs2_addr,

    output  logic[2:0]  operation,

    output  logic[31:0] immediate,

    output  logic       use_alu,
    output  logic       use_fpu,
    output  logic       use_imm,    // as register

    output  logic       operand_a_enable,
    output  logic       operand_b_enable,
    output  logic       result_enable,
    output  logic       rd_is_operand_a,

    output  logic       is_load,
    output  logic       is_store,
    output  logic       is_jump,
    output  logic       is_jump_register,

    output  logic[2:0]  condition
);

    // TODO: if using float registers AND logic operations -> use ALU anyway
    always_comb begin
        use_alu = 1'b0;
        use_fpu = 1'b0;
        use_imm = 1'b0;
        operation = 3'b0;
        rd_addr = instruction[26:22];
        rs1_addr = instruction[21:17];
        rs2_addr = instruction[16:12];
        immediate = 32'b0;
        operand_a_enable = 1'b1;
        operand_b_enable = 1'b1;
        result_enable = 1'b0;
        rd_is_operand_a = 1'b0;
        is_load = 1'b0;
        is_store = 1'b0;
        is_jump = 1'b0;
        is_jump_register = 1'b0;
        condition = 3'b111;

        if(instruction[31] == 1'b0) begin
            // ALU/FPU
            result_enable = 1'b1;
            operation = instruction[30:28];
            if(instruction[27] == 1'b0) begin
                // 3 registers
                immediate = {{20{instruction[11]}}, instruction[11:0]};    // Sign extend
            end else begin
                // 2 registers
                immediate = {{16{instruction[16]}}, instruction[16:1]};    // Sign extend
                if(instruction[0] == 1'b0) begin
                    // TODO: Immediate as offset
                    rd_is_operand_a = 1'b1;
                end else begin
                    // Immediate as register
                    use_imm = 1'b1;
                    operand_b_enable = 1'b0;
                end
            end
            // ALU/FPU is decided based on the destination register
            if(instruction[26] == 1'b0) begin
                use_alu = 1'b1;
            end else begin
                use_fpu = 1'b1;
            end
        end else begin
            // OTHERS
            if(instruction[31:27] inside {[LW:SB]}) begin
                rd_is_operand_a = 1'b1;
                if(instruction[31:27] == LW) begin
                    is_load = 1'b1;
                end else if(instruction[31:27] == SW) begin
                    is_store = 1'b1;
                end
                use_alu = 1'b1;
                operation = opADD;
                immediate = {{16{instruction[16]}}, instruction[16:1]};    // Sign extend
            end else if(instruction[31:27] == J) begin
                immediate = {{5{instruction[26]}}, instruction[26:0]};
                is_jump = 1'b1;
            end else if(instruction[31:27] == JR) begin
                immediate = {{10{instruction[21]}}, instruction[21:0]};
                rs1_addr = instruction[26:22];
                is_jump_register = 1'b1;
                use_alu = 1'b1;
                operation = opADD;
                use_imm = 1'b1;
                operand_b_enable = 1'b0;
            end else begin
                // BRANCHES -> if condition != 3'b111 then its a branch
                condition = instruction[29:27];
                rd_is_operand_a = 1'b1;
                use_alu = 1'b1;
                operation = opSUB;
                immediate = {{16{instruction[16]}}, instruction[16:1]};    // Sign extend
            end
        end
    end

endmodule
