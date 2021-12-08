/**
 * @author: RayleighZ
 * @date: 2021/12/8 9:25
 * @describe: 对于riscv汇编的进一步封装
 */

// mstatus相关(机器状态寄存器，获取当前机器所处的mode)

//几种具体形态
#define MSTATUS_MPP_MASK (3L << 11) // previous mode.
#define MSTATUS_MPP_M (3L << 11)
#define MSTATUS_MPP_S (1L << 11)
#define MSTATUS_MPP_U (0L << 11)
#define MSTATUS_MIE (1L << 3)    // machine-mode interrupt enable.

//获取mstatus
static inline uint64 r_mstatus(){
    uint64 x;
    asm volatile("csrr %0, mstatus" : "=r" (x) );
    return x;
}

//写入mstatus
static inline void w_mstatus(uint64 x){
    asm volatile("csrw mstatus, %0" : : "r" (x));
}

//sepc相关 (当kernel在machine mode下出现exception时，将会回调到sepc指向的函数)
//当然，这种触发不一定完全来自被动触发的exception，比如手动调用mret
static inline void w_sepc(uint64 x)
{
    asm volatile("csrw sepc, %0" : : "r" (x));
}

//tp相关 (thread pointer，持有当前进程所处的cpu的core的index)