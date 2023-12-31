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

int main(int argc, char** argv, char** env) {
    Vh2bp *dut = new Vh2bp;

    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    dut->clk ^= 1;
    dut->rst = 1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

    dut->clk ^= 1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;

    dut->clk ^= 1;
    dut->rst = 0;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;
    
    while(sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1;
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
