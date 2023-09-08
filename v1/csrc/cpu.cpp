#include <cstdio>
#include <cstdlib>
#include <assert.h>
#include <iostream>

#include "Vcpu.h"
#include "verilated.h"

using namespace std;

int main(int argc, char **argv)
{
    VerilatedContext *contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vcpu *cpu = new Vcpu(contextp);

    // pc and memory_middleware test
    cpu->clk = 0;
    cpu->eval();
    int test_times = 6;
    while (test_times--)
    {
        printf("------------------------\n");
        cpu->clk = 1;
        cpu->eval();
        // printf("posedge: Instruction: %x\n", cpu->Instruction);
        cpu->clk = 0;
        cpu->eval();
        // printf("negedge: Instruction: %x\n", cpu->Instruction);
    }

    delete cpu;
    delete contextp;
    return 0;
}