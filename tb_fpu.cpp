#include <stdlib.h>
#include <iostream>
#include <bitset>
#include <climits>
#include <stdio.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vh2bp.h"
#include "Vh2bp___024root.h"

#define MAX_SIM_TIME 600
vluint64_t sim_time = 0;

float bintofloat(unsigned int x) {
    union {
        unsigned int  x;
        float  f;
    } temp;
    temp.x = x;
    return temp.f;
}

int main(int argc, char** argv, char** env) {
    Vh2bp *dut = new Vh2bp;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    dut->operation = 0;
    dut->operand_a = 0x00102080;
    dut->operand_b = 0x42102080;

    float a = bintofloat(0x00102080); //3
    float b = bintofloat(0x42102080); //-7

    union
    {
        float input; // assumes sizeof(float) == sizeof(int)
        int   output;
    } data;

    data.input = a+b;

    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

    std::bitset<sizeof(float) * CHAR_BIT> bits(data.output);
    std::cout << bits << std::endl;

    std::bitset<sizeof(float) * CHAR_BIT> out(dut->result);
    std::cout << out << std::endl;

    if(out == bits)
        std::cout << "same" << std::endl;

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
