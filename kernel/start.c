/**
 * @author: RayleighZ
 * @date: 2021/12/6 10:18
 * @describe: RayKernel的起始文件
 */
#include "riscv.h"
#include "types.h"

//cpu中c语言的栈的大小
__attribute__ ((aligned (16))) char stack0[4096 * NCPU];
void main();
void start(){
    //当前kernel处于machine mode
    //接下来将进行一些简单的初始化，之后尽快跳转到supervisor mode
    unsigned long x = r_mstatus();
    //将x切换到s mode
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_S;

    //将main函数位置写入mepc
    w_sepc((uint64)main);
}