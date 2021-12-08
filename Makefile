K = kernel
U = user
OBJS = \
	$K/entry.o\

# 下面同样是来自xv6的shell判断代码
ifndef TOOLPREFIX
TOOLPREFIX := $(shell if riscv64-unknown-elf-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-elf-'; \
	elif riscv64-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-linux-gnu-'; \
	elif riscv64-unknown-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-linux-gnu-'; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find a riscv64 version of GCC/binutils." 1>&2; \
	echo "*** To turn off this error, run 'gmake TOOLPREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

# 来自shell的基本指令封装
CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gas
LD = $(TOOLPREFIX)ld
OBJCOPY = $(TOOLPREFIX)objcopy
OBJDUMP = $(TOOLPREFIX)objdump

QEMU = qemu-system-riscv64
# cv的xv6里面的qemu配置
QEMUOPTS = -machine virt -bios none -kernel $K/kernel -m 128M -smp $(CPUS) -nographic
QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0
QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

# 只有当可分配到的ram大于4KByte的时候，才链接
# 与PageTable的设计有关
LDFLAGS = -z max-page-size=4096

# 下面将完成内核的编译和链接部分
$K/kernel: $(OBJS) $K/kernel.ld
	$(LD) $(LDFLAGS) -T $K/kernel.ld -o $K/kernel $(OBJS) # 将编译后的.o通过kernel.ld链接形成可执行的kernel
	$(OBJDUMP) -S $K/kernel > $K/kernel.asm # 机器码反编译形成汇编, 方便调试

# 一切的起始，当在命令行输入make rayKernel之后，就会执行下面这段makeFile
# kernel的编译就从这里开始
rayKernel: $K/kernel
	$(QEMU) $(QEMUOPTS)