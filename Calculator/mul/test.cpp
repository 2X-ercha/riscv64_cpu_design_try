#include <cstdio>
#include <stdlib.h>
#include <assert.h>
#include <iostream>
#include <cstring>

#include "verilated.h"
#include "Vmul128.h"

using namespace std;

int main(int argc, char **argv)
{
    VerilatedContext *contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vmul128 *mul = new Vmul128(contextp);
    srand(time(0));
    mul->operand1 = ((unsigned long long)rand() << 33) + rand();
    mul->operand2 = ((unsigned long long)rand() << 33) + rand();
    mul->sign_x = 0;
    mul->sign_y = 0;
    mul->eval();
    printf("%016llx *\n%016llx = \n%016llx\n%016llx\n", mul->operand1, mul->operand2, mul->result_h, mul->result_l);
    delete mul;
    delete contextp;
    return 0;
}