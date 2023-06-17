package h2bp;

    // Instruction format
    // TYPE T
        //  OPCODE |  RD  |  RS1  |  RS2  |  IMM
    // TYPE D
        //  OPCODE |  RD  |  RS1  |  IMM  | USE_IMM
    // TYPE I
        //  OPCODE |  RD  |  IMM
    typedef enum logic [1:0] {
        T, D, I
    } formats;

    // Instructions
    typedef enum logic [4:0] {
        ADD, ADD2, SUB, SUB2, MUL, MUL2, DIV, DIV2, AND, AND2, OR, OR2, LS, LS2, RS, RS2,
        BEQ, BNE, BLT, BGT, BLE, BGE, LW, LB, SW, SB, J, JR, CALL, RET, PUSH, POP
    } instructions;

    typedef enum logic [2:0] {
        EQ, NE, LT, GT, LE, GE
    } conditions;

    typedef enum logic [2:0] {
        opADD, opSUB, opMULT, opDIV, opAND, opOR, opLSHIFT, opRSHIFT
    } operations;

    typedef struct packed {
        logic       zero;
        logic       negative;
        logic       carry;
        logic       overflow;
    } flags;

    typedef struct packed {
        logic       sign;
        logic[7:0]  exponent;
        logic[22:0] fraction;
    } float;

endpackage
