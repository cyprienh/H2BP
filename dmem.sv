module dmem import h2bp::*;(
    input   logic       clk,
    
    /* verilator lint_off UNUSEDSIGNAL */
    input   logic[31:0] addr,
    /* verilator lint_on UNUSEDSIGNAL */

    input   logic       write,
    
    input   logic[31:0] data_i,
    output  logic[31:0] data_o
);

    logic[31:0] memory[31:0];

    always_ff @(posedge clk) begin
        if(write) begin
            memory[addr[4:0]] <= data_i;
        end

        data_o <= memory[addr[4:0]];
    end

endmodule
