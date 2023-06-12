// IEEE754
//   31 | 30           23 | 22                                          0
//    0 | 0 1 1 1 1 1 1 1 | 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
// sign |     exponent    |         fraction

// TODO: Check overflow/underflow

module fpu import h2bp::*;(
    input   logic[2:0]  operation,

    input   float operand_a,
    input   float operand_b,
    
    output  float result
);

    float       sum_result;

    float       operand_b_2;

    logic[23:0] fraction_one_a;
    logic[23:0] fraction_one_b;

    logic[23:0] fraction_shifted_a;
    logic[23:0] fraction_shifted_b;

    logic[24:0] fraction_signed_a;
    logic[24:0] fraction_signed_b;

    // CARRY | SIGN | 2'S COMPLEMENT (W. LEADING ONE)
    //   25  |  24  | 23                            0
    logic[24:0] sum_intermediate;
    logic[24:0] sum_unsigned;
    /* verilator lint_off UNUSEDSIGNAL */
    logic[24:0] fraction_final;
    /* verilator lint_on UNUSEDSIGNAL */

    logic[7:0]  exponent;

    logic       overflow;

    always_comb begin
        operand_b_2 = operand_b;
        case(operation)
            opADD:    result = sum_result;
            opSUB:    begin
                        operand_b_2 = {~operand_b.sign, operand_b.exponent, operand_b.fraction};
                        result = sum_result;
                    end
            //MULT: TODO
            //DIV:  TODO
            default: result = 32'b0;
        endcase
    end

    // Add the 1.
    assign fraction_one_a = (operand_a.exponent == 0) ? {1'b0, operand_a.fraction} : {1'b1, operand_a.fraction}; 
    assign fraction_one_b = (operand_b_2.exponent == 0) ? {1'b0, operand_b_2.fraction} : {1'b1, operand_b_2.fraction}; 

    // Same exponent
    always_comb begin : add_float
        fraction_shifted_a = fraction_one_a;
        fraction_shifted_b = fraction_one_b;
        exponent = 0;
        if(operand_a.exponent == operand_b_2.exponent) begin
            exponent = operand_a.exponent;
        end else if(operand_a.exponent > operand_b_2.exponent) begin
            exponent = operand_a.exponent;
            fraction_shifted_b =fraction_one_b >> (operand_a.exponent - operand_b_2.exponent);
        end else if(operand_a.exponent < operand_b_2.exponent) begin
            exponent = operand_b_2.exponent;
            fraction_shifted_a = fraction_one_a >> (operand_b_2.exponent - operand_a.exponent);
        end
    end

    // Add
    assign fraction_signed_a = (operand_a.sign) ? ~{1'b0, fraction_shifted_a}+1 : {1'b0, fraction_shifted_a};
    assign fraction_signed_b = (operand_b_2.sign) ? ~{1'b0, fraction_shifted_b}+1 : {1'b0, fraction_shifted_b};

    assign sum_intermediate = fraction_signed_a + fraction_signed_b;
    // TODO: CHECK OVERFLOW FORMULA
    assign overflow = (fraction_signed_a[24]^fraction_signed_b[24]) ? 0: (sum_intermediate[24]^fraction_signed_a[24]);
    assign sum_result.fraction = fraction_final[22:0];
    assign sum_unsigned = (sum_intermediate[24]) ? -sum_intermediate : sum_intermediate;

    always_comb begin : sign
        sum_result.sign = sum_intermediate[24];
        if (operand_a.sign == operand_b_2.sign)
            sum_result.sign = operand_a.sign;
    end

    always_comb begin : shift_result
        if(overflow) begin
            fraction_final = (sum_unsigned >> 1);
            sum_result.exponent = exponent + 1;
        end else if(pointer <= 23) begin
            fraction_final = (sum_unsigned << (23 - pointer));
            sum_result.exponent = exponent - (23 - pointer);
        end else begin
            fraction_final = sum_unsigned;
            sum_result.exponent = exponent;
        end
    end

    logic found;
    logic[7:0] i;
    logic[7:0] pointer;

    always_comb begin : shift_amount
        found = 0;
        pointer = 0;
        for(i=0; i<=23; i++) begin
            if(sum_intermediate[23 - i[4:0]] == 1 && !found) begin
                pointer = 23 - i;
                found = 1;
            end
        end
    end

endmodule
