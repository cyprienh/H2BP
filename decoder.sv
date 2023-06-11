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
    output  logic       is_store
);

    // TODO: if using float registers AND logic operations -> use ALU anyway
    always_comb begin
        use_alu = 1'b0;
        use_fpu = 1'b0;
        use_imm = 1'b0;
        operation = 3'b0;
        rd_addr = instruction[26:22];
        rs1_addr = 5'b0;
        rs2_addr = 5'b0;
        immediate = 32'b0;
        operand_a_enable = 1'b0;
        operand_b_enable = 1'b0;
        result_enable = 1'b0;
        rd_is_operand_a = 1'b0;
        is_load = 1'b0;
        is_store = 1'b0;

        if(instruction[31] == 1'b0) begin
            // ALU/FPU
            result_enable = 1'b1;
            operand_a_enable = 1'b1;
            rs1_addr = instruction[21:17];
            operation = instruction[30:28];
            if(instruction[27] == 1'b0) begin
                // 3 registers
                operand_b_enable = 1'b1;
                rs2_addr = instruction[16:12];
                immediate = {{20{instruction[11]}}, instruction[11:0]};    // Sign extend
            end else begin
                // 2 registers
                immediate = {{16{instruction[16]}}, instruction[16:1]};    // Sign extend
                if(instruction[0] == 1'b0) begin
                    // TODO: Immediate as offset 
                    use_imm = 1'b0;
                    operand_b_enable = 1'b1;
                    rd_is_operand_a = 1'b1;
                end else begin
                    // Immediate as register
                    use_imm = 1'b1;
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
            rd_is_operand_a = 1'b1;
            result_enable = 1'b1;
            if(instruction[31:27] == LW) begin
                is_load = 1'b1;
            end else if(instruction[31:27] == SW) begin
                is_store = 1'b1;
            end
        end
    end

endmodule
