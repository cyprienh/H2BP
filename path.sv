// TODO: BRANCH, MOV, CALL/RET, PUSH/POP + Forwarding/stalling

module path import h2bp::*;(
    input   logic       clk,
    input   logic       rst
);

    // Instruction stage
    logic[31:0] pc;
    logic[31:0] instruction;

    logic[4:0]  rd_addr_inst;
    logic[4:0]  rs1_addr_inst;
    logic[4:0]  rs2_addr_inst;

    logic[2:0]  op_inst;

    logic[31:0] imm_inst;

    logic       use_alu_inst;
    logic       use_fpu_inst;
    logic       use_imm_inst;

    logic       operand_a_enable_inst;
    logic       operand_b_enable_inst;
    logic       result_enable_inst;
    logic       rd_is_operand_a_inst;

    logic       is_load_inst;
    logic       is_store_inst;

    // Register stage
    logic[4:0]  rd_addr_reg;
    logic[4:0]  rs1_addr_reg;
    logic[4:0]  rs2_addr_reg;

    logic[2:0]  op_reg;

    logic[31:0] imm_reg;

    logic       use_alu_reg;
    logic       use_fpu_reg;
    logic       use_imm_reg;

    logic       operand_a_enable_reg;
    logic       operand_b_enable_reg;
    logic       result_enable_reg;
    logic       rd_is_operand_a_reg;

    logic[4:0] operand_a_addr;
    logic[4:0] operand_b_addr;

    logic[31:0] operand_a_reg;
    logic[31:0] operand_b_reg;

    logic       is_load_reg;
    logic       is_store_reg;

    logic[4:0]  result_addr_reg;

    // Function stage
    logic[2:0]  op_func;

    logic       use_alu_func;
    logic       use_fpu_func;

    logic[4:0]  result_addr_func;
    logic       result_enable_func;

    logic[31:0] operand_a_func;
    logic[31:0] operand_b_func;

    logic[31:0] result_alu;
    logic[31:0] result_fpu;
    logic[31:0] result_func;

    logic       is_load_func;
    logic       is_store_func;

    // Data stage

    logic[4:0]  result_addr_data;
    logic       result_enable_data;
    logic[31:0] result_data;

    logic[31:0] operand_a_data;
    logic[31:0] result_load_data;

    logic       is_load_data;
    logic       is_store_data;


    always_ff @(posedge clk) begin : pc_generation
        if(rst) begin
            pc <= 32'b0;
        end else begin
            pc <= pc + 1;
        end
    end 

    imem instruction_memory(
        .clk,
        .pc,
        .instruction
    );

    decoder decoder(
        .instruction,
        .rd_addr            (rd_addr_inst),
        .rs1_addr           (rs1_addr_inst),
        .rs2_addr           (rs2_addr_inst),
        .operation          (op_inst),
        .immediate          (imm_inst),
        .use_alu            (use_alu_inst),
        .use_fpu            (use_fpu_inst),
        .use_imm            (use_imm_inst),
        .operand_a_enable   (operand_a_enable_inst),
        .operand_b_enable   (operand_b_enable_inst),
        .result_enable      (result_enable_inst),
        .rd_is_operand_a    (rd_is_operand_a_inst),
        .is_load            (is_load_inst),
        .is_store           (is_store_inst)
    );

    always_ff @(posedge clk) begin : inst_reg
        if(rst) begin
            rd_addr_reg             <= 5'b0;
            rs1_addr_reg            <= 5'b0;
            rs2_addr_reg            <= 5'b0;
            op_reg                  <= 3'b0;
            imm_reg                 <= 32'b0;
            use_alu_reg             <= 1'b0;
            use_fpu_reg             <= 1'b0;
            use_imm_reg             <= 1'b0;
            operand_a_enable_reg    <= 1'b0;
            operand_b_enable_reg    <= 1'b0;
            result_enable_reg       <= 1'b0;
            rd_is_operand_a_reg     <= 1'b0;
            is_load_reg             <= 1'b0;
            is_store_reg            <= 1'b0;
        end else begin
            rd_addr_reg             <= rd_addr_inst;
            rs1_addr_reg            <= rs1_addr_inst;
            rs2_addr_reg            <= rs2_addr_inst;
            op_reg                  <= op_inst;
            imm_reg                 <= imm_inst;
            use_alu_reg             <= use_alu_inst;
            use_fpu_reg             <= use_fpu_inst;
            use_imm_reg             <= use_imm_inst;
            operand_a_enable_reg    <= operand_a_enable_inst;
            operand_b_enable_reg    <= operand_b_enable_inst;
            result_enable_reg       <= result_enable_inst;
            rd_is_operand_a_reg     <= rd_is_operand_a_inst;
            is_load_reg             <= is_load_inst;
            is_store_reg            <= is_store_inst;
        end
    end 

    assign operand_a_addr  = (rd_is_operand_a_reg) ? rd_addr_reg : rs1_addr_reg;
    assign operand_b_addr  = (rd_is_operand_a_reg) ? rs1_addr_reg : rs2_addr_reg;
    assign result_addr_reg = rd_addr_reg;

    registers registers(
        .clk,
        .operand_a_enable (operand_a_enable_reg),
        .operand_b_enable (operand_b_enable_reg),
        .result_enable    (result_enable_data),
        .operand_a_addr   (operand_a_addr),
        .operand_b_addr   (operand_b_addr),
        .result_addr      (result_addr_data),
        .operand_a        (operand_a_reg),
        .operand_b        (operand_b_reg),
        .result           ((is_load_data) ? result_load_data : result_data)
    );

    always_ff @(posedge clk) begin : reg_func
        if(rst) begin
            op_func             <= 3'b0;
            use_alu_func        <= 1'b0;
            use_fpu_func        <= 1'b0;
            result_addr_func    <= 5'b0;
            result_enable_func  <= 1'b0;
            operand_a_func      <= 32'b0;
            operand_b_func      <= 32'b0;
            is_load_func        <= 1'b0;
            is_store_func       <= 1'b0;
        end else begin
            op_func             <= op_reg;
            use_alu_func        <= use_alu_reg;
            use_fpu_func        <= use_fpu_reg;
            result_addr_func    <= result_addr_reg;
            result_enable_func  <= result_enable_reg;
            operand_a_func      <= operand_a_reg;
            operand_b_func      <= (use_imm_reg) ? imm_reg : operand_b_reg;
            is_load_func        <= is_load_reg;
            is_store_func       <= is_store_reg;
        end
    end 

    alu alu(
        .operation(op_func),
        .operand_a(operand_a_func),
        .operand_b(operand_b_func),
        .result   (result_alu)
    );

    fpu fpu(
        .operation(op_func),
        .operand_a(operand_a_func),
        .operand_b(operand_b_func),
        .result   (result_fpu)
    );

    always_comb begin : result_select
        result_func = 32'b0;
        if(use_alu_func)
            result_func = result_alu;
        else if(use_fpu_func)
            result_func = result_fpu;
        else if(is_load_func | is_store_func)
            result_func = operand_b_func;
    end

    always_ff @(posedge clk) begin : func_data
        if(rst) begin
            result_addr_data    <= 5'b0;
            result_enable_data  <= 1'b0;
            result_data         <= 32'b0;
            operand_a_data      <= 32'b0;
            is_load_data        <= 1'b0;
            is_store_data       <= 1'b0;
        end else begin
            result_addr_data    <= result_addr_func;
            result_enable_data  <= result_enable_func;
            result_data         <= result_func;
            operand_a_data      <= operand_a_func;
            is_load_data        <= is_load_func;
            is_store_data       <= is_store_func;
        end
    end 

    dmem dmem(
        .clk,
        .addr(result_data),
        .write(is_store_data),
        .data_i(operand_a_data),
        .data_o(result_load_data)
    );

endmodule
