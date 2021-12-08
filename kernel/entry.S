# Kernel的启动位置
# 因为是要在qemu中启动，系统应当被加载进0x80000000中
# 具体的配置位于kernel.ld中

_entry:
	# 设置C语言的栈，使得C可以运行
	    la sp, stack0
        li a0, 1024*4
	csrr a1, mhartid
        addi a1, a1, 1
        mul a0, a0, a1
        add sp, sp, a0
	# 调用start.c中的start函数
        call start
spin:
        j spin
