#include <cstdio>
#include <stdlib.h>
#include <assert.h>
#include <iostream>
#include <cstring>

#include "verilated.h"
#include "Vadd64.h"

using namespace std;

int main (int argc, char **argv) {
    VerilatedContext *contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vadd64 *add = new Vadd64 (contextp);
    srand(time(0));
    add->operand1 = ((unsigned long long)rand() << 33) + rand();
    unsigned long long b = ((unsigned long long)rand() << 33) + rand();
    add->operand2 = ~b;
    add->c0 = 1;
    add->eval();
    printf("%20lld - \n%20lld = \n%20lld, carry = %d\n", add->operand1, b, add->result, add->carry);
    assert(add->operand1-b == add->result);
    printf("right\n");
    delete add;
    delete contextp;
    return 0;
}