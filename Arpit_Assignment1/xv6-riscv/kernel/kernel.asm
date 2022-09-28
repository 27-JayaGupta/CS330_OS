
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	95013103          	ld	sp,-1712(sp) # 80008950 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	20c78793          	addi	a5,a5,524 # 80006270 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de078793          	addi	a5,a5,-544 # 80000e8e <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00003097          	auipc	ra,0x3
    80000130:	914080e7          	jalr	-1772(ra) # 80002a40 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	78e080e7          	jalr	1934(ra) # 800008ca <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ff450513          	addi	a0,a0,-12 # 80011180 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a50080e7          	jalr	-1456(ra) # 80000be4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	fe448493          	addi	s1,s1,-28 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	07290913          	addi	s2,s2,114 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001ae:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b2:	4da9                	li	s11,10
  while(n > 0){
    800001b4:	07405863          	blez	s4,80000224 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71463          	bne	a4,a5,800001e8 <consoleread+0x84>
      if(myproc()->killed){
    800001c4:	00001097          	auipc	ra,0x1
    800001c8:	7ec080e7          	jalr	2028(ra) # 800019b0 <myproc>
    800001cc:	551c                	lw	a5,40(a0)
    800001ce:	e7b5                	bnez	a5,8000023a <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001d0:	85ce                	mv	a1,s3
    800001d2:	854a                	mv	a0,s2
    800001d4:	00002097          	auipc	ra,0x2
    800001d8:	314080e7          	jalr	788(ra) # 800024e8 <sleep>
    while(cons.r == cons.w){
    800001dc:	0984a783          	lw	a5,152(s1)
    800001e0:	09c4a703          	lw	a4,156(s1)
    800001e4:	fef700e3          	beq	a4,a5,800001c4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e8:	0017871b          	addiw	a4,a5,1
    800001ec:	08e4ac23          	sw	a4,152(s1)
    800001f0:	07f7f713          	andi	a4,a5,127
    800001f4:	9726                	add	a4,a4,s1
    800001f6:	01874703          	lbu	a4,24(a4)
    800001fa:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001fe:	079c0663          	beq	s8,s9,8000026a <consoleread+0x106>
    cbuf = c;
    80000202:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	f8f40613          	addi	a2,s0,-113
    8000020c:	85d6                	mv	a1,s5
    8000020e:	855a                	mv	a0,s6
    80000210:	00002097          	auipc	ra,0x2
    80000214:	7da080e7          	jalr	2010(ra) # 800029ea <either_copyout>
    80000218:	01a50663          	beq	a0,s10,80000224 <consoleread+0xc0>
    dst++;
    8000021c:	0a85                	addi	s5,s5,1
    --n;
    8000021e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000220:	f9bc1ae3          	bne	s8,s11,800001b4 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000224:	00011517          	auipc	a0,0x11
    80000228:	f5c50513          	addi	a0,a0,-164 # 80011180 <cons>
    8000022c:	00001097          	auipc	ra,0x1
    80000230:	a6c080e7          	jalr	-1428(ra) # 80000c98 <release>

  return target - n;
    80000234:	414b853b          	subw	a0,s7,s4
    80000238:	a811                	j	8000024c <consoleread+0xe8>
        release(&cons.lock);
    8000023a:	00011517          	auipc	a0,0x11
    8000023e:	f4650513          	addi	a0,a0,-186 # 80011180 <cons>
    80000242:	00001097          	auipc	ra,0x1
    80000246:	a56080e7          	jalr	-1450(ra) # 80000c98 <release>
        return -1;
    8000024a:	557d                	li	a0,-1
}
    8000024c:	70e6                	ld	ra,120(sp)
    8000024e:	7446                	ld	s0,112(sp)
    80000250:	74a6                	ld	s1,104(sp)
    80000252:	7906                	ld	s2,96(sp)
    80000254:	69e6                	ld	s3,88(sp)
    80000256:	6a46                	ld	s4,80(sp)
    80000258:	6aa6                	ld	s5,72(sp)
    8000025a:	6b06                	ld	s6,64(sp)
    8000025c:	7be2                	ld	s7,56(sp)
    8000025e:	7c42                	ld	s8,48(sp)
    80000260:	7ca2                	ld	s9,40(sp)
    80000262:	7d02                	ld	s10,32(sp)
    80000264:	6de2                	ld	s11,24(sp)
    80000266:	6109                	addi	sp,sp,128
    80000268:	8082                	ret
      if(n < target){
    8000026a:	000a071b          	sext.w	a4,s4
    8000026e:	fb777be3          	bgeu	a4,s7,80000224 <consoleread+0xc0>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	faf72323          	sw	a5,-90(a4) # 80011218 <cons+0x98>
    8000027a:	b76d                	j	80000224 <consoleread+0xc0>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	564080e7          	jalr	1380(ra) # 800007f0 <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	552080e7          	jalr	1362(ra) # 800007f0 <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	546080e7          	jalr	1350(ra) # 800007f0 <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	53c080e7          	jalr	1340(ra) # 800007f0 <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	eb450513          	addi	a0,a0,-332 # 80011180 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	910080e7          	jalr	-1776(ra) # 80000be4 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	7a4080e7          	jalr	1956(ra) # 80002a96 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	e8650513          	addi	a0,a0,-378 # 80011180 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	996080e7          	jalr	-1642(ra) # 80000c98 <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	e6270713          	addi	a4,a4,-414 # 80011180 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	e3878793          	addi	a5,a5,-456 # 80011180 <cons>
    80000350:	0a07a703          	lw	a4,160(a5)
    80000354:	0017069b          	addiw	a3,a4,1
    80000358:	0006861b          	sext.w	a2,a3
    8000035c:	0ad7a023          	sw	a3,160(a5)
    80000360:	07f77713          	andi	a4,a4,127
    80000364:	97ba                	add	a5,a5,a4
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	ea27a783          	lw	a5,-350(a5) # 80011218 <cons+0x98>
    8000037e:	0807879b          	addiw	a5,a5,128
    80000382:	f6f61ce3          	bne	a2,a5,800002fa <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000386:	863e                	mv	a2,a5
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	df670713          	addi	a4,a4,-522 # 80011180 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	de648493          	addi	s1,s1,-538 # 80011180 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	daa70713          	addi	a4,a4,-598 # 80011180 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	e2f72a23          	sw	a5,-460(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000412:	00011797          	auipc	a5,0x11
    80000416:	d6e78793          	addi	a5,a5,-658 # 80011180 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	dec7a323          	sw	a2,-538(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	dda50513          	addi	a0,a0,-550 # 80011218 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	360080e7          	jalr	864(ra) # 800027a6 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00011517          	auipc	a0,0x11
    80000464:	d2050513          	addi	a0,a0,-736 # 80011180 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6ec080e7          	jalr	1772(ra) # 80000b54 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	330080e7          	jalr	816(ra) # 800007a0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	0a078793          	addi	a5,a5,160 # 80021518 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00011797          	auipc	a5,0x11
    8000054e:	ce07ab23          	sw	zero,-778(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	cf450513          	addi	a0,a0,-780 # 80008260 <digits+0x220>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00009717          	auipc	a4,0x9
    80000582:	a8f72123          	sw	a5,-1406(a4) # 80009000 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00011d97          	auipc	s11,0x11
    800005be:	c86dad83          	lw	s11,-890(s11) # 80011240 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	16050263          	beqz	a0,8000073a <printf+0x1b2>
    800005da:	4481                	li	s1,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b13          	li	s6,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b97          	auipc	s7,0x8
    800005ea:	a5ab8b93          	addi	s7,s7,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00011517          	auipc	a0,0x11
    800005fc:	c3050513          	addi	a0,a0,-976 # 80011228 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5e4080e7          	jalr	1508(ra) # 80000be4 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2485                	addiw	s1,s1,1
    80000624:	009a07b3          	add	a5,s4,s1
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050763          	beqz	a0,8000073a <printf+0x1b2>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2485                	addiw	s1,s1,1
    80000636:	009a07b3          	add	a5,s4,s1
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000642:	cfe5                	beqz	a5,8000073a <printf+0x1b2>
    switch(c){
    80000644:	05678a63          	beq	a5,s6,80000698 <printf+0x110>
    80000648:	02fb7663          	bgeu	s6,a5,80000674 <printf+0xec>
    8000064c:	09978963          	beq	a5,s9,800006de <printf+0x156>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79863          	bne	a5,a4,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	0b578263          	beq	a5,s5,80000718 <printf+0x190>
    80000678:	0b879663          	bne	a5,s8,80000724 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c9d793          	srli	a5,s3,0x3c
    800006c6:	97de                	add	a5,a5,s7
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0992                	slli	s3,s3,0x4
    800006d6:	397d                	addiw	s2,s2,-1
    800006d8:	fe0915e3          	bnez	s2,800006c2 <printf+0x13a>
    800006dc:	b799                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	0007b903          	ld	s2,0(a5)
    800006ee:	00090e63          	beqz	s2,8000070a <printf+0x182>
      for(; *s; s++)
    800006f2:	00094503          	lbu	a0,0(s2)
    800006f6:	d515                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	b84080e7          	jalr	-1148(ra) # 8000027c <consputc>
      for(; *s; s++)
    80000700:	0905                	addi	s2,s2,1
    80000702:	00094503          	lbu	a0,0(s2)
    80000706:	f96d                	bnez	a0,800006f8 <printf+0x170>
    80000708:	bf29                	j	80000622 <printf+0x9a>
        s = "(null)";
    8000070a:	00008917          	auipc	s2,0x8
    8000070e:	91690913          	addi	s2,s2,-1770 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000712:	02800513          	li	a0,40
    80000716:	b7cd                	j	800006f8 <printf+0x170>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b62080e7          	jalr	-1182(ra) # 8000027c <consputc>
      break;
    80000722:	b701                	j	80000622 <printf+0x9a>
      consputc('%');
    80000724:	8556                	mv	a0,s5
    80000726:	00000097          	auipc	ra,0x0
    8000072a:	b56080e7          	jalr	-1194(ra) # 8000027c <consputc>
      consputc(c);
    8000072e:	854a                	mv	a0,s2
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b4c080e7          	jalr	-1204(ra) # 8000027c <consputc>
      break;
    80000738:	b5ed                	j	80000622 <printf+0x9a>
  if(locking)
    8000073a:	020d9163          	bnez	s11,8000075c <printf+0x1d4>
}
    8000073e:	70e6                	ld	ra,120(sp)
    80000740:	7446                	ld	s0,112(sp)
    80000742:	74a6                	ld	s1,104(sp)
    80000744:	7906                	ld	s2,96(sp)
    80000746:	69e6                	ld	s3,88(sp)
    80000748:	6a46                	ld	s4,80(sp)
    8000074a:	6aa6                	ld	s5,72(sp)
    8000074c:	6b06                	ld	s6,64(sp)
    8000074e:	7be2                	ld	s7,56(sp)
    80000750:	7c42                	ld	s8,48(sp)
    80000752:	7ca2                	ld	s9,40(sp)
    80000754:	7d02                	ld	s10,32(sp)
    80000756:	6de2                	ld	s11,24(sp)
    80000758:	6129                	addi	sp,sp,192
    8000075a:	8082                	ret
    release(&pr.lock);
    8000075c:	00011517          	auipc	a0,0x11
    80000760:	acc50513          	addi	a0,a0,-1332 # 80011228 <pr>
    80000764:	00000097          	auipc	ra,0x0
    80000768:	534080e7          	jalr	1332(ra) # 80000c98 <release>
}
    8000076c:	bfc9                	j	8000073e <printf+0x1b6>

000000008000076e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076e:	1101                	addi	sp,sp,-32
    80000770:	ec06                	sd	ra,24(sp)
    80000772:	e822                	sd	s0,16(sp)
    80000774:	e426                	sd	s1,8(sp)
    80000776:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000778:	00011497          	auipc	s1,0x11
    8000077c:	ab048493          	addi	s1,s1,-1360 # 80011228 <pr>
    80000780:	00008597          	auipc	a1,0x8
    80000784:	8b858593          	addi	a1,a1,-1864 # 80008038 <etext+0x38>
    80000788:	8526                	mv	a0,s1
    8000078a:	00000097          	auipc	ra,0x0
    8000078e:	3ca080e7          	jalr	970(ra) # 80000b54 <initlock>
  pr.locking = 1;
    80000792:	4785                	li	a5,1
    80000794:	cc9c                	sw	a5,24(s1)
}
    80000796:	60e2                	ld	ra,24(sp)
    80000798:	6442                	ld	s0,16(sp)
    8000079a:	64a2                	ld	s1,8(sp)
    8000079c:	6105                	addi	sp,sp,32
    8000079e:	8082                	ret

00000000800007a0 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a0:	1141                	addi	sp,sp,-16
    800007a2:	e406                	sd	ra,8(sp)
    800007a4:	e022                	sd	s0,0(sp)
    800007a6:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a8:	100007b7          	lui	a5,0x10000
    800007ac:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b0:	f8000713          	li	a4,-128
    800007b4:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b8:	470d                	li	a4,3
    800007ba:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007be:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c2:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c6:	469d                	li	a3,7
    800007c8:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007cc:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d0:	00008597          	auipc	a1,0x8
    800007d4:	88858593          	addi	a1,a1,-1912 # 80008058 <digits+0x18>
    800007d8:	00011517          	auipc	a0,0x11
    800007dc:	a7050513          	addi	a0,a0,-1424 # 80011248 <uart_tx_lock>
    800007e0:	00000097          	auipc	ra,0x0
    800007e4:	374080e7          	jalr	884(ra) # 80000b54 <initlock>
}
    800007e8:	60a2                	ld	ra,8(sp)
    800007ea:	6402                	ld	s0,0(sp)
    800007ec:	0141                	addi	sp,sp,16
    800007ee:	8082                	ret

00000000800007f0 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	1000                	addi	s0,sp,32
    800007fa:	84aa                	mv	s1,a0
  push_off();
    800007fc:	00000097          	auipc	ra,0x0
    80000800:	39c080e7          	jalr	924(ra) # 80000b98 <push_off>

  if(panicked){
    80000804:	00008797          	auipc	a5,0x8
    80000808:	7fc7a783          	lw	a5,2044(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	10000737          	lui	a4,0x10000
  if(panicked){
    80000810:	c391                	beqz	a5,80000814 <uartputc_sync+0x24>
    for(;;)
    80000812:	a001                	j	80000812 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000814:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000818:	0ff7f793          	andi	a5,a5,255
    8000081c:	0207f793          	andi	a5,a5,32
    80000820:	dbf5                	beqz	a5,80000814 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000822:	0ff4f793          	andi	a5,s1,255
    80000826:	10000737          	lui	a4,0x10000
    8000082a:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082e:	00000097          	auipc	ra,0x0
    80000832:	40a080e7          	jalr	1034(ra) # 80000c38 <pop_off>
}
    80000836:	60e2                	ld	ra,24(sp)
    80000838:	6442                	ld	s0,16(sp)
    8000083a:	64a2                	ld	s1,8(sp)
    8000083c:	6105                	addi	sp,sp,32
    8000083e:	8082                	ret

0000000080000840 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000840:	00008717          	auipc	a4,0x8
    80000844:	7c873703          	ld	a4,1992(a4) # 80009008 <uart_tx_r>
    80000848:	00008797          	auipc	a5,0x8
    8000084c:	7c87b783          	ld	a5,1992(a5) # 80009010 <uart_tx_w>
    80000850:	06e78c63          	beq	a5,a4,800008c8 <uartstart+0x88>
{
    80000854:	7139                	addi	sp,sp,-64
    80000856:	fc06                	sd	ra,56(sp)
    80000858:	f822                	sd	s0,48(sp)
    8000085a:	f426                	sd	s1,40(sp)
    8000085c:	f04a                	sd	s2,32(sp)
    8000085e:	ec4e                	sd	s3,24(sp)
    80000860:	e852                	sd	s4,16(sp)
    80000862:	e456                	sd	s5,8(sp)
    80000864:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000866:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086a:	00011a17          	auipc	s4,0x11
    8000086e:	9dea0a13          	addi	s4,s4,-1570 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000872:	00008497          	auipc	s1,0x8
    80000876:	79648493          	addi	s1,s1,1942 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000087a:	00008997          	auipc	s3,0x8
    8000087e:	79698993          	addi	s3,s3,1942 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000882:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000886:	0ff7f793          	andi	a5,a5,255
    8000088a:	0207f793          	andi	a5,a5,32
    8000088e:	c785                	beqz	a5,800008b6 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000890:	01f77793          	andi	a5,a4,31
    80000894:	97d2                	add	a5,a5,s4
    80000896:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000089a:	0705                	addi	a4,a4,1
    8000089c:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089e:	8526                	mv	a0,s1
    800008a0:	00002097          	auipc	ra,0x2
    800008a4:	f06080e7          	jalr	-250(ra) # 800027a6 <wakeup>
    
    WriteReg(THR, c);
    800008a8:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ac:	6098                	ld	a4,0(s1)
    800008ae:	0009b783          	ld	a5,0(s3)
    800008b2:	fce798e3          	bne	a5,a4,80000882 <uartstart+0x42>
  }
}
    800008b6:	70e2                	ld	ra,56(sp)
    800008b8:	7442                	ld	s0,48(sp)
    800008ba:	74a2                	ld	s1,40(sp)
    800008bc:	7902                	ld	s2,32(sp)
    800008be:	69e2                	ld	s3,24(sp)
    800008c0:	6a42                	ld	s4,16(sp)
    800008c2:	6aa2                	ld	s5,8(sp)
    800008c4:	6121                	addi	sp,sp,64
    800008c6:	8082                	ret
    800008c8:	8082                	ret

00000000800008ca <uartputc>:
{
    800008ca:	7179                	addi	sp,sp,-48
    800008cc:	f406                	sd	ra,40(sp)
    800008ce:	f022                	sd	s0,32(sp)
    800008d0:	ec26                	sd	s1,24(sp)
    800008d2:	e84a                	sd	s2,16(sp)
    800008d4:	e44e                	sd	s3,8(sp)
    800008d6:	e052                	sd	s4,0(sp)
    800008d8:	1800                	addi	s0,sp,48
    800008da:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008dc:	00011517          	auipc	a0,0x11
    800008e0:	96c50513          	addi	a0,a0,-1684 # 80011248 <uart_tx_lock>
    800008e4:	00000097          	auipc	ra,0x0
    800008e8:	300080e7          	jalr	768(ra) # 80000be4 <acquire>
  if(panicked){
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	7147a783          	lw	a5,1812(a5) # 80009000 <panicked>
    800008f4:	c391                	beqz	a5,800008f8 <uartputc+0x2e>
    for(;;)
    800008f6:	a001                	j	800008f6 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f8:	00008797          	auipc	a5,0x8
    800008fc:	7187b783          	ld	a5,1816(a5) # 80009010 <uart_tx_w>
    80000900:	00008717          	auipc	a4,0x8
    80000904:	70873703          	ld	a4,1800(a4) # 80009008 <uart_tx_r>
    80000908:	02070713          	addi	a4,a4,32
    8000090c:	02f71b63          	bne	a4,a5,80000942 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00011a17          	auipc	s4,0x11
    80000914:	938a0a13          	addi	s4,s4,-1736 # 80011248 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	6f048493          	addi	s1,s1,1776 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	6f090913          	addi	s2,s2,1776 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000928:	85d2                	mv	a1,s4
    8000092a:	8526                	mv	a0,s1
    8000092c:	00002097          	auipc	ra,0x2
    80000930:	bbc080e7          	jalr	-1092(ra) # 800024e8 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000934:	00093783          	ld	a5,0(s2)
    80000938:	6098                	ld	a4,0(s1)
    8000093a:	02070713          	addi	a4,a4,32
    8000093e:	fef705e3          	beq	a4,a5,80000928 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000942:	00011497          	auipc	s1,0x11
    80000946:	90648493          	addi	s1,s1,-1786 # 80011248 <uart_tx_lock>
    8000094a:	01f7f713          	andi	a4,a5,31
    8000094e:	9726                	add	a4,a4,s1
    80000950:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000954:	0785                	addi	a5,a5,1
    80000956:	00008717          	auipc	a4,0x8
    8000095a:	6af73d23          	sd	a5,1722(a4) # 80009010 <uart_tx_w>
      uartstart();
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	ee2080e7          	jalr	-286(ra) # 80000840 <uartstart>
      release(&uart_tx_lock);
    80000966:	8526                	mv	a0,s1
    80000968:	00000097          	auipc	ra,0x0
    8000096c:	330080e7          	jalr	816(ra) # 80000c98 <release>
}
    80000970:	70a2                	ld	ra,40(sp)
    80000972:	7402                	ld	s0,32(sp)
    80000974:	64e2                	ld	s1,24(sp)
    80000976:	6942                	ld	s2,16(sp)
    80000978:	69a2                	ld	s3,8(sp)
    8000097a:	6a02                	ld	s4,0(sp)
    8000097c:	6145                	addi	sp,sp,48
    8000097e:	8082                	ret

0000000080000980 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000980:	1141                	addi	sp,sp,-16
    80000982:	e422                	sd	s0,8(sp)
    80000984:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098e:	8b85                	andi	a5,a5,1
    80000990:	cb91                	beqz	a5,800009a4 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000992:	100007b7          	lui	a5,0x10000
    80000996:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000099a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099e:	6422                	ld	s0,8(sp)
    800009a0:	0141                	addi	sp,sp,16
    800009a2:	8082                	ret
    return -1;
    800009a4:	557d                	li	a0,-1
    800009a6:	bfe5                	j	8000099e <uartgetc+0x1e>

00000000800009a8 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009a8:	1101                	addi	sp,sp,-32
    800009aa:	ec06                	sd	ra,24(sp)
    800009ac:	e822                	sd	s0,16(sp)
    800009ae:	e426                	sd	s1,8(sp)
    800009b0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b2:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b4:	00000097          	auipc	ra,0x0
    800009b8:	fcc080e7          	jalr	-52(ra) # 80000980 <uartgetc>
    if(c == -1)
    800009bc:	00950763          	beq	a0,s1,800009ca <uartintr+0x22>
      break;
    consoleintr(c);
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	8fe080e7          	jalr	-1794(ra) # 800002be <consoleintr>
  while(1){
    800009c8:	b7f5                	j	800009b4 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ca:	00011497          	auipc	s1,0x11
    800009ce:	87e48493          	addi	s1,s1,-1922 # 80011248 <uart_tx_lock>
    800009d2:	8526                	mv	a0,s1
    800009d4:	00000097          	auipc	ra,0x0
    800009d8:	210080e7          	jalr	528(ra) # 80000be4 <acquire>
  uartstart();
    800009dc:	00000097          	auipc	ra,0x0
    800009e0:	e64080e7          	jalr	-412(ra) # 80000840 <uartstart>
  release(&uart_tx_lock);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	2b2080e7          	jalr	690(ra) # 80000c98 <release>
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret

00000000800009f8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	e04a                	sd	s2,0(sp)
    80000a02:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a04:	03451793          	slli	a5,a0,0x34
    80000a08:	ebb9                	bnez	a5,80000a5e <kfree+0x66>
    80000a0a:	84aa                	mv	s1,a0
    80000a0c:	00025797          	auipc	a5,0x25
    80000a10:	5f478793          	addi	a5,a5,1524 # 80026000 <end>
    80000a14:	04f56563          	bltu	a0,a5,80000a5e <kfree+0x66>
    80000a18:	47c5                	li	a5,17
    80000a1a:	07ee                	slli	a5,a5,0x1b
    80000a1c:	04f57163          	bgeu	a0,a5,80000a5e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a20:	6605                	lui	a2,0x1
    80000a22:	4585                	li	a1,1
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	2bc080e7          	jalr	700(ra) # 80000ce0 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a2c:	00011917          	auipc	s2,0x11
    80000a30:	85490913          	addi	s2,s2,-1964 # 80011280 <kmem>
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	1ae080e7          	jalr	430(ra) # 80000be4 <acquire>
  r->next = kmem.freelist;
    80000a3e:	01893783          	ld	a5,24(s2)
    80000a42:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a44:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a48:	854a                	mv	a0,s2
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	24e080e7          	jalr	590(ra) # 80000c98 <release>
}
    80000a52:	60e2                	ld	ra,24(sp)
    80000a54:	6442                	ld	s0,16(sp)
    80000a56:	64a2                	ld	s1,8(sp)
    80000a58:	6902                	ld	s2,0(sp)
    80000a5a:	6105                	addi	sp,sp,32
    80000a5c:	8082                	ret
    panic("kfree");
    80000a5e:	00007517          	auipc	a0,0x7
    80000a62:	60250513          	addi	a0,a0,1538 # 80008060 <digits+0x20>
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	ad8080e7          	jalr	-1320(ra) # 8000053e <panic>

0000000080000a6e <freerange>:
{
    80000a6e:	7179                	addi	sp,sp,-48
    80000a70:	f406                	sd	ra,40(sp)
    80000a72:	f022                	sd	s0,32(sp)
    80000a74:	ec26                	sd	s1,24(sp)
    80000a76:	e84a                	sd	s2,16(sp)
    80000a78:	e44e                	sd	s3,8(sp)
    80000a7a:	e052                	sd	s4,0(sp)
    80000a7c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a7e:	6785                	lui	a5,0x1
    80000a80:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a84:	94aa                	add	s1,s1,a0
    80000a86:	757d                	lui	a0,0xfffff
    80000a88:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8a:	94be                	add	s1,s1,a5
    80000a8c:	0095ee63          	bltu	a1,s1,80000aa8 <freerange+0x3a>
    80000a90:	892e                	mv	s2,a1
    kfree(p);
    80000a92:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	6985                	lui	s3,0x1
    kfree(p);
    80000a96:	01448533          	add	a0,s1,s4
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	f5e080e7          	jalr	-162(ra) # 800009f8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa2:	94ce                	add	s1,s1,s3
    80000aa4:	fe9979e3          	bgeu	s2,s1,80000a96 <freerange+0x28>
}
    80000aa8:	70a2                	ld	ra,40(sp)
    80000aaa:	7402                	ld	s0,32(sp)
    80000aac:	64e2                	ld	s1,24(sp)
    80000aae:	6942                	ld	s2,16(sp)
    80000ab0:	69a2                	ld	s3,8(sp)
    80000ab2:	6a02                	ld	s4,0(sp)
    80000ab4:	6145                	addi	sp,sp,48
    80000ab6:	8082                	ret

0000000080000ab8 <kinit>:
{
    80000ab8:	1141                	addi	sp,sp,-16
    80000aba:	e406                	sd	ra,8(sp)
    80000abc:	e022                	sd	s0,0(sp)
    80000abe:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ac0:	00007597          	auipc	a1,0x7
    80000ac4:	5a858593          	addi	a1,a1,1448 # 80008068 <digits+0x28>
    80000ac8:	00010517          	auipc	a0,0x10
    80000acc:	7b850513          	addi	a0,a0,1976 # 80011280 <kmem>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	084080e7          	jalr	132(ra) # 80000b54 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ad8:	45c5                	li	a1,17
    80000ada:	05ee                	slli	a1,a1,0x1b
    80000adc:	00025517          	auipc	a0,0x25
    80000ae0:	52450513          	addi	a0,a0,1316 # 80026000 <end>
    80000ae4:	00000097          	auipc	ra,0x0
    80000ae8:	f8a080e7          	jalr	-118(ra) # 80000a6e <freerange>
}
    80000aec:	60a2                	ld	ra,8(sp)
    80000aee:	6402                	ld	s0,0(sp)
    80000af0:	0141                	addi	sp,sp,16
    80000af2:	8082                	ret

0000000080000af4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000af4:	1101                	addi	sp,sp,-32
    80000af6:	ec06                	sd	ra,24(sp)
    80000af8:	e822                	sd	s0,16(sp)
    80000afa:	e426                	sd	s1,8(sp)
    80000afc:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000afe:	00010497          	auipc	s1,0x10
    80000b02:	78248493          	addi	s1,s1,1922 # 80011280 <kmem>
    80000b06:	8526                	mv	a0,s1
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	0dc080e7          	jalr	220(ra) # 80000be4 <acquire>
  r = kmem.freelist;
    80000b10:	6c84                	ld	s1,24(s1)
  if(r)
    80000b12:	c885                	beqz	s1,80000b42 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b14:	609c                	ld	a5,0(s1)
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	76a50513          	addi	a0,a0,1898 # 80011280 <kmem>
    80000b1e:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	178080e7          	jalr	376(ra) # 80000c98 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b28:	6605                	lui	a2,0x1
    80000b2a:	4595                	li	a1,5
    80000b2c:	8526                	mv	a0,s1
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	1b2080e7          	jalr	434(ra) # 80000ce0 <memset>
  return (void*)r;
}
    80000b36:	8526                	mv	a0,s1
    80000b38:	60e2                	ld	ra,24(sp)
    80000b3a:	6442                	ld	s0,16(sp)
    80000b3c:	64a2                	ld	s1,8(sp)
    80000b3e:	6105                	addi	sp,sp,32
    80000b40:	8082                	ret
  release(&kmem.lock);
    80000b42:	00010517          	auipc	a0,0x10
    80000b46:	73e50513          	addi	a0,a0,1854 # 80011280 <kmem>
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	14e080e7          	jalr	334(ra) # 80000c98 <release>
  if(r)
    80000b52:	b7d5                	j	80000b36 <kalloc+0x42>

0000000080000b54 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b54:	1141                	addi	sp,sp,-16
    80000b56:	e422                	sd	s0,8(sp)
    80000b58:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b5a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b5c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b60:	00053823          	sd	zero,16(a0)
}
    80000b64:	6422                	ld	s0,8(sp)
    80000b66:	0141                	addi	sp,sp,16
    80000b68:	8082                	ret

0000000080000b6a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	411c                	lw	a5,0(a0)
    80000b6c:	e399                	bnez	a5,80000b72 <holding+0x8>
    80000b6e:	4501                	li	a0,0
  return r;
}
    80000b70:	8082                	ret
{
    80000b72:	1101                	addi	sp,sp,-32
    80000b74:	ec06                	sd	ra,24(sp)
    80000b76:	e822                	sd	s0,16(sp)
    80000b78:	e426                	sd	s1,8(sp)
    80000b7a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b7c:	6904                	ld	s1,16(a0)
    80000b7e:	00001097          	auipc	ra,0x1
    80000b82:	e16080e7          	jalr	-490(ra) # 80001994 <mycpu>
    80000b86:	40a48533          	sub	a0,s1,a0
    80000b8a:	00153513          	seqz	a0,a0
}
    80000b8e:	60e2                	ld	ra,24(sp)
    80000b90:	6442                	ld	s0,16(sp)
    80000b92:	64a2                	ld	s1,8(sp)
    80000b94:	6105                	addi	sp,sp,32
    80000b96:	8082                	ret

0000000080000b98 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b98:	1101                	addi	sp,sp,-32
    80000b9a:	ec06                	sd	ra,24(sp)
    80000b9c:	e822                	sd	s0,16(sp)
    80000b9e:	e426                	sd	s1,8(sp)
    80000ba0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ba2:	100024f3          	csrr	s1,sstatus
    80000ba6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000baa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bac:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bb0:	00001097          	auipc	ra,0x1
    80000bb4:	de4080e7          	jalr	-540(ra) # 80001994 <mycpu>
    80000bb8:	5d3c                	lw	a5,120(a0)
    80000bba:	cf89                	beqz	a5,80000bd4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bbc:	00001097          	auipc	ra,0x1
    80000bc0:	dd8080e7          	jalr	-552(ra) # 80001994 <mycpu>
    80000bc4:	5d3c                	lw	a5,120(a0)
    80000bc6:	2785                	addiw	a5,a5,1
    80000bc8:	dd3c                	sw	a5,120(a0)
}
    80000bca:	60e2                	ld	ra,24(sp)
    80000bcc:	6442                	ld	s0,16(sp)
    80000bce:	64a2                	ld	s1,8(sp)
    80000bd0:	6105                	addi	sp,sp,32
    80000bd2:	8082                	ret
    mycpu()->intena = old;
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	dc0080e7          	jalr	-576(ra) # 80001994 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bdc:	8085                	srli	s1,s1,0x1
    80000bde:	8885                	andi	s1,s1,1
    80000be0:	dd64                	sw	s1,124(a0)
    80000be2:	bfe9                	j	80000bbc <push_off+0x24>

0000000080000be4 <acquire>:
{
    80000be4:	1101                	addi	sp,sp,-32
    80000be6:	ec06                	sd	ra,24(sp)
    80000be8:	e822                	sd	s0,16(sp)
    80000bea:	e426                	sd	s1,8(sp)
    80000bec:	1000                	addi	s0,sp,32
    80000bee:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bf0:	00000097          	auipc	ra,0x0
    80000bf4:	fa8080e7          	jalr	-88(ra) # 80000b98 <push_off>
  if(holding(lk))
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	00000097          	auipc	ra,0x0
    80000bfe:	f70080e7          	jalr	-144(ra) # 80000b6a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c02:	4705                	li	a4,1
  if(holding(lk))
    80000c04:	e115                	bnez	a0,80000c28 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c06:	87ba                	mv	a5,a4
    80000c08:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c0c:	2781                	sext.w	a5,a5
    80000c0e:	ffe5                	bnez	a5,80000c06 <acquire+0x22>
  __sync_synchronize();
    80000c10:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c14:	00001097          	auipc	ra,0x1
    80000c18:	d80080e7          	jalr	-640(ra) # 80001994 <mycpu>
    80000c1c:	e888                	sd	a0,16(s1)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    panic("acquire");
    80000c28:	00007517          	auipc	a0,0x7
    80000c2c:	44850513          	addi	a0,a0,1096 # 80008070 <digits+0x30>
    80000c30:	00000097          	auipc	ra,0x0
    80000c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	d54080e7          	jalr	-684(ra) # 80001994 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c48:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c4c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4e:	e78d                	bnez	a5,80000c78 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c50:	5d3c                	lw	a5,120(a0)
    80000c52:	02f05b63          	blez	a5,80000c88 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c56:	37fd                	addiw	a5,a5,-1
    80000c58:	0007871b          	sext.w	a4,a5
    80000c5c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5e:	eb09                	bnez	a4,80000c70 <pop_off+0x38>
    80000c60:	5d7c                	lw	a5,124(a0)
    80000c62:	c799                	beqz	a5,80000c70 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c64:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c68:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c6c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c70:	60a2                	ld	ra,8(sp)
    80000c72:	6402                	ld	s0,0(sp)
    80000c74:	0141                	addi	sp,sp,16
    80000c76:	8082                	ret
    panic("pop_off - interruptible");
    80000c78:	00007517          	auipc	a0,0x7
    80000c7c:	40050513          	addi	a0,a0,1024 # 80008078 <digits+0x38>
    80000c80:	00000097          	auipc	ra,0x0
    80000c84:	8be080e7          	jalr	-1858(ra) # 8000053e <panic>
    panic("pop_off");
    80000c88:	00007517          	auipc	a0,0x7
    80000c8c:	40850513          	addi	a0,a0,1032 # 80008090 <digits+0x50>
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	8ae080e7          	jalr	-1874(ra) # 8000053e <panic>

0000000080000c98 <release>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	ec6080e7          	jalr	-314(ra) # 80000b6a <holding>
    80000cac:	c115                	beqz	a0,80000cd0 <release+0x38>
  lk->cpu = 0;
    80000cae:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb6:	0f50000f          	fence	iorw,ow
    80000cba:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	f7a080e7          	jalr	-134(ra) # 80000c38 <pop_off>
}
    80000cc6:	60e2                	ld	ra,24(sp)
    80000cc8:	6442                	ld	s0,16(sp)
    80000cca:	64a2                	ld	s1,8(sp)
    80000ccc:	6105                	addi	sp,sp,32
    80000cce:	8082                	ret
    panic("release");
    80000cd0:	00007517          	auipc	a0,0x7
    80000cd4:	3c850513          	addi	a0,a0,968 # 80008098 <digits+0x58>
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	866080e7          	jalr	-1946(ra) # 8000053e <panic>

0000000080000ce0 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ce6:	ce09                	beqz	a2,80000d00 <memset+0x20>
    80000ce8:	87aa                	mv	a5,a0
    80000cea:	fff6071b          	addiw	a4,a2,-1
    80000cee:	1702                	slli	a4,a4,0x20
    80000cf0:	9301                	srli	a4,a4,0x20
    80000cf2:	0705                	addi	a4,a4,1
    80000cf4:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x16>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d46:	ca0d                	beqz	a2,80000d78 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d48:	00a5f963          	bgeu	a1,a0,80000d5a <memmove+0x1a>
    80000d4c:	02061693          	slli	a3,a2,0x20
    80000d50:	9281                	srli	a3,a3,0x20
    80000d52:	00d58733          	add	a4,a1,a3
    80000d56:	02e56463          	bltu	a0,a4,80000d7e <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d5a:	fff6079b          	addiw	a5,a2,-1
    80000d5e:	1782                	slli	a5,a5,0x20
    80000d60:	9381                	srli	a5,a5,0x20
    80000d62:	0785                	addi	a5,a5,1
    80000d64:	97ae                	add	a5,a5,a1
    80000d66:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d68:	0585                	addi	a1,a1,1
    80000d6a:	0705                	addi	a4,a4,1
    80000d6c:	fff5c683          	lbu	a3,-1(a1)
    80000d70:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d74:	fef59ae3          	bne	a1,a5,80000d68 <memmove+0x28>

  return dst;
}
    80000d78:	6422                	ld	s0,8(sp)
    80000d7a:	0141                	addi	sp,sp,16
    80000d7c:	8082                	ret
    d += n;
    80000d7e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d80:	fff6079b          	addiw	a5,a2,-1
    80000d84:	1782                	slli	a5,a5,0x20
    80000d86:	9381                	srli	a5,a5,0x20
    80000d88:	fff7c793          	not	a5,a5
    80000d8c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d8e:	177d                	addi	a4,a4,-1
    80000d90:	16fd                	addi	a3,a3,-1
    80000d92:	00074603          	lbu	a2,0(a4)
    80000d96:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d9a:	fef71ae3          	bne	a4,a5,80000d8e <memmove+0x4e>
    80000d9e:	bfe9                	j	80000d78 <memmove+0x38>

0000000080000da0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da0:	1141                	addi	sp,sp,-16
    80000da2:	e406                	sd	ra,8(sp)
    80000da4:	e022                	sd	s0,0(sp)
    80000da6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da8:	00000097          	auipc	ra,0x0
    80000dac:	f98080e7          	jalr	-104(ra) # 80000d40 <memmove>
}
    80000db0:	60a2                	ld	ra,8(sp)
    80000db2:	6402                	ld	s0,0(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dbe:	ce11                	beqz	a2,80000dda <strncmp+0x22>
    80000dc0:	00054783          	lbu	a5,0(a0)
    80000dc4:	cf89                	beqz	a5,80000dde <strncmp+0x26>
    80000dc6:	0005c703          	lbu	a4,0(a1)
    80000dca:	00f71a63          	bne	a4,a5,80000dde <strncmp+0x26>
    n--, p++, q++;
    80000dce:	367d                	addiw	a2,a2,-1
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd4:	f675                	bnez	a2,80000dc0 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	a809                	j	80000dea <strncmp+0x32>
    80000dda:	4501                	li	a0,0
    80000ddc:	a039                	j	80000dea <strncmp+0x32>
  if(n == 0)
    80000dde:	ca09                	beqz	a2,80000df0 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de0:	00054503          	lbu	a0,0(a0)
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	9d1d                	subw	a0,a0,a5
}
    80000dea:	6422                	ld	s0,8(sp)
    80000dec:	0141                	addi	sp,sp,16
    80000dee:	8082                	ret
    return 0;
    80000df0:	4501                	li	a0,0
    80000df2:	bfe5                	j	80000dea <strncmp+0x32>

0000000080000df4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df4:	1141                	addi	sp,sp,-16
    80000df6:	e422                	sd	s0,8(sp)
    80000df8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dfa:	872a                	mv	a4,a0
    80000dfc:	8832                	mv	a6,a2
    80000dfe:	367d                	addiw	a2,a2,-1
    80000e00:	01005963          	blez	a6,80000e12 <strncpy+0x1e>
    80000e04:	0705                	addi	a4,a4,1
    80000e06:	0005c783          	lbu	a5,0(a1)
    80000e0a:	fef70fa3          	sb	a5,-1(a4)
    80000e0e:	0585                	addi	a1,a1,1
    80000e10:	f7f5                	bnez	a5,80000dfc <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e12:	00c05d63          	blez	a2,80000e2c <strncpy+0x38>
    80000e16:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e18:	0685                	addi	a3,a3,1
    80000e1a:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e1e:	fff6c793          	not	a5,a3
    80000e22:	9fb9                	addw	a5,a5,a4
    80000e24:	010787bb          	addw	a5,a5,a6
    80000e28:	fef048e3          	bgtz	a5,80000e18 <strncpy+0x24>
  return os;
}
    80000e2c:	6422                	ld	s0,8(sp)
    80000e2e:	0141                	addi	sp,sp,16
    80000e30:	8082                	ret

0000000080000e32 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e32:	1141                	addi	sp,sp,-16
    80000e34:	e422                	sd	s0,8(sp)
    80000e36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e38:	02c05363          	blez	a2,80000e5e <safestrcpy+0x2c>
    80000e3c:	fff6069b          	addiw	a3,a2,-1
    80000e40:	1682                	slli	a3,a3,0x20
    80000e42:	9281                	srli	a3,a3,0x20
    80000e44:	96ae                	add	a3,a3,a1
    80000e46:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e48:	00d58963          	beq	a1,a3,80000e5a <safestrcpy+0x28>
    80000e4c:	0585                	addi	a1,a1,1
    80000e4e:	0785                	addi	a5,a5,1
    80000e50:	fff5c703          	lbu	a4,-1(a1)
    80000e54:	fee78fa3          	sb	a4,-1(a5)
    80000e58:	fb65                	bnez	a4,80000e48 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e5a:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5e:	6422                	ld	s0,8(sp)
    80000e60:	0141                	addi	sp,sp,16
    80000e62:	8082                	ret

0000000080000e64 <strlen>:

int
strlen(const char *s)
{
    80000e64:	1141                	addi	sp,sp,-16
    80000e66:	e422                	sd	s0,8(sp)
    80000e68:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e6a:	00054783          	lbu	a5,0(a0)
    80000e6e:	cf91                	beqz	a5,80000e8a <strlen+0x26>
    80000e70:	0505                	addi	a0,a0,1
    80000e72:	87aa                	mv	a5,a0
    80000e74:	4685                	li	a3,1
    80000e76:	9e89                	subw	a3,a3,a0
    80000e78:	00f6853b          	addw	a0,a3,a5
    80000e7c:	0785                	addi	a5,a5,1
    80000e7e:	fff7c703          	lbu	a4,-1(a5)
    80000e82:	fb7d                	bnez	a4,80000e78 <strlen+0x14>
    ;
  return n;
}
    80000e84:	6422                	ld	s0,8(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e8a:	4501                	li	a0,0
    80000e8c:	bfe5                	j	80000e84 <strlen+0x20>

0000000080000e8e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	aee080e7          	jalr	-1298(ra) # 80001984 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e9e:	00008717          	auipc	a4,0x8
    80000ea2:	17a70713          	addi	a4,a4,378 # 80009018 <started>
  if(cpuid() == 0){
    80000ea6:	c139                	beqz	a0,80000eec <main+0x5e>
    while(started == 0)
    80000ea8:	431c                	lw	a5,0(a4)
    80000eaa:	2781                	sext.w	a5,a5
    80000eac:	dff5                	beqz	a5,80000ea8 <main+0x1a>
      ;
    __sync_synchronize();
    80000eae:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb2:	00001097          	auipc	ra,0x1
    80000eb6:	ad2080e7          	jalr	-1326(ra) # 80001984 <cpuid>
    80000eba:	85aa                	mv	a1,a0
    80000ebc:	00007517          	auipc	a0,0x7
    80000ec0:	1fc50513          	addi	a0,a0,508 # 800080b8 <digits+0x78>
    80000ec4:	fffff097          	auipc	ra,0xfffff
    80000ec8:	6c4080e7          	jalr	1732(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000ecc:	00000097          	auipc	ra,0x0
    80000ed0:	0d8080e7          	jalr	216(ra) # 80000fa4 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed4:	00002097          	auipc	ra,0x2
    80000ed8:	d02080e7          	jalr	-766(ra) # 80002bd6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000edc:	00005097          	auipc	ra,0x5
    80000ee0:	3d4080e7          	jalr	980(ra) # 800062b0 <plicinithart>
  }

  scheduler();        
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	452080e7          	jalr	1106(ra) # 80002336 <scheduler>
    consoleinit();
    80000eec:	fffff097          	auipc	ra,0xfffff
    80000ef0:	564080e7          	jalr	1380(ra) # 80000450 <consoleinit>
    printfinit();
    80000ef4:	00000097          	auipc	ra,0x0
    80000ef8:	87a080e7          	jalr	-1926(ra) # 8000076e <printfinit>
    printf("\n");
    80000efc:	00007517          	auipc	a0,0x7
    80000f00:	36450513          	addi	a0,a0,868 # 80008260 <digits+0x220>
    80000f04:	fffff097          	auipc	ra,0xfffff
    80000f08:	684080e7          	jalr	1668(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000f0c:	00007517          	auipc	a0,0x7
    80000f10:	19450513          	addi	a0,a0,404 # 800080a0 <digits+0x60>
    80000f14:	fffff097          	auipc	ra,0xfffff
    80000f18:	674080e7          	jalr	1652(ra) # 80000588 <printf>
    printf("\n");
    80000f1c:	00007517          	auipc	a0,0x7
    80000f20:	34450513          	addi	a0,a0,836 # 80008260 <digits+0x220>
    80000f24:	fffff097          	auipc	ra,0xfffff
    80000f28:	664080e7          	jalr	1636(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	b8c080e7          	jalr	-1140(ra) # 80000ab8 <kinit>
    kvminit();       // create kernel page table
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	322080e7          	jalr	802(ra) # 80001256 <kvminit>
    kvminithart();   // turn on paging
    80000f3c:	00000097          	auipc	ra,0x0
    80000f40:	068080e7          	jalr	104(ra) # 80000fa4 <kvminithart>
    procinit();      // process table
    80000f44:	00001097          	auipc	ra,0x1
    80000f48:	990080e7          	jalr	-1648(ra) # 800018d4 <procinit>
    trapinit();      // trap vectors
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	c62080e7          	jalr	-926(ra) # 80002bae <trapinit>
    trapinithart();  // install kernel trap vector
    80000f54:	00002097          	auipc	ra,0x2
    80000f58:	c82080e7          	jalr	-894(ra) # 80002bd6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	33e080e7          	jalr	830(ra) # 8000629a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f64:	00005097          	auipc	ra,0x5
    80000f68:	34c080e7          	jalr	844(ra) # 800062b0 <plicinithart>
    binit();         // buffer cache
    80000f6c:	00002097          	auipc	ra,0x2
    80000f70:	526080e7          	jalr	1318(ra) # 80003492 <binit>
    iinit();         // inode table
    80000f74:	00003097          	auipc	ra,0x3
    80000f78:	bb6080e7          	jalr	-1098(ra) # 80003b2a <iinit>
    fileinit();      // file table
    80000f7c:	00004097          	auipc	ra,0x4
    80000f80:	b60080e7          	jalr	-1184(ra) # 80004adc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f84:	00005097          	auipc	ra,0x5
    80000f88:	44e080e7          	jalr	1102(ra) # 800063d2 <virtio_disk_init>
    userinit();      // first user process
    80000f8c:	00001097          	auipc	ra,0x1
    80000f90:	d4c080e7          	jalr	-692(ra) # 80001cd8 <userinit>
    __sync_synchronize();
    80000f94:	0ff0000f          	fence
    started = 1;
    80000f98:	4785                	li	a5,1
    80000f9a:	00008717          	auipc	a4,0x8
    80000f9e:	06f72f23          	sw	a5,126(a4) # 80009018 <started>
    80000fa2:	b789                	j	80000ee4 <main+0x56>

0000000080000fa4 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa4:	1141                	addi	sp,sp,-16
    80000fa6:	e422                	sd	s0,8(sp)
    80000fa8:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000faa:	00008797          	auipc	a5,0x8
    80000fae:	0767b783          	ld	a5,118(a5) # 80009020 <kernel_pagetable>
    80000fb2:	83b1                	srli	a5,a5,0xc
    80000fb4:	577d                	li	a4,-1
    80000fb6:	177e                	slli	a4,a4,0x3f
    80000fb8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fba:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fbe:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc2:	6422                	ld	s0,8(sp)
    80000fc4:	0141                	addi	sp,sp,16
    80000fc6:	8082                	ret

0000000080000fc8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc8:	7139                	addi	sp,sp,-64
    80000fca:	fc06                	sd	ra,56(sp)
    80000fcc:	f822                	sd	s0,48(sp)
    80000fce:	f426                	sd	s1,40(sp)
    80000fd0:	f04a                	sd	s2,32(sp)
    80000fd2:	ec4e                	sd	s3,24(sp)
    80000fd4:	e852                	sd	s4,16(sp)
    80000fd6:	e456                	sd	s5,8(sp)
    80000fd8:	e05a                	sd	s6,0(sp)
    80000fda:	0080                	addi	s0,sp,64
    80000fdc:	84aa                	mv	s1,a0
    80000fde:	89ae                	mv	s3,a1
    80000fe0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe2:	57fd                	li	a5,-1
    80000fe4:	83e9                	srli	a5,a5,0x1a
    80000fe6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fea:	04b7f263          	bgeu	a5,a1,8000102e <walk+0x66>
    panic("walk");
    80000fee:	00007517          	auipc	a0,0x7
    80000ff2:	0e250513          	addi	a0,a0,226 # 800080d0 <digits+0x90>
    80000ff6:	fffff097          	auipc	ra,0xfffff
    80000ffa:	548080e7          	jalr	1352(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ffe:	060a8663          	beqz	s5,8000106a <walk+0xa2>
    80001002:	00000097          	auipc	ra,0x0
    80001006:	af2080e7          	jalr	-1294(ra) # 80000af4 <kalloc>
    8000100a:	84aa                	mv	s1,a0
    8000100c:	c529                	beqz	a0,80001056 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000100e:	6605                	lui	a2,0x1
    80001010:	4581                	li	a1,0
    80001012:	00000097          	auipc	ra,0x0
    80001016:	cce080e7          	jalr	-818(ra) # 80000ce0 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101a:	00c4d793          	srli	a5,s1,0xc
    8000101e:	07aa                	slli	a5,a5,0xa
    80001020:	0017e793          	ori	a5,a5,1
    80001024:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001028:	3a5d                	addiw	s4,s4,-9
    8000102a:	036a0063          	beq	s4,s6,8000104a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000102e:	0149d933          	srl	s2,s3,s4
    80001032:	1ff97913          	andi	s2,s2,511
    80001036:	090e                	slli	s2,s2,0x3
    80001038:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000103a:	00093483          	ld	s1,0(s2)
    8000103e:	0014f793          	andi	a5,s1,1
    80001042:	dfd5                	beqz	a5,80000ffe <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001044:	80a9                	srli	s1,s1,0xa
    80001046:	04b2                	slli	s1,s1,0xc
    80001048:	b7c5                	j	80001028 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000104a:	00c9d513          	srli	a0,s3,0xc
    8000104e:	1ff57513          	andi	a0,a0,511
    80001052:	050e                	slli	a0,a0,0x3
    80001054:	9526                	add	a0,a0,s1
}
    80001056:	70e2                	ld	ra,56(sp)
    80001058:	7442                	ld	s0,48(sp)
    8000105a:	74a2                	ld	s1,40(sp)
    8000105c:	7902                	ld	s2,32(sp)
    8000105e:	69e2                	ld	s3,24(sp)
    80001060:	6a42                	ld	s4,16(sp)
    80001062:	6aa2                	ld	s5,8(sp)
    80001064:	6b02                	ld	s6,0(sp)
    80001066:	6121                	addi	sp,sp,64
    80001068:	8082                	ret
        return 0;
    8000106a:	4501                	li	a0,0
    8000106c:	b7ed                	j	80001056 <walk+0x8e>

000000008000106e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000106e:	57fd                	li	a5,-1
    80001070:	83e9                	srli	a5,a5,0x1a
    80001072:	00b7f463          	bgeu	a5,a1,8000107a <walkaddr+0xc>
    return 0;
    80001076:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001078:	8082                	ret
{
    8000107a:	1141                	addi	sp,sp,-16
    8000107c:	e406                	sd	ra,8(sp)
    8000107e:	e022                	sd	s0,0(sp)
    80001080:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001082:	4601                	li	a2,0
    80001084:	00000097          	auipc	ra,0x0
    80001088:	f44080e7          	jalr	-188(ra) # 80000fc8 <walk>
  if(pte == 0)
    8000108c:	c105                	beqz	a0,800010ac <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000108e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001090:	0117f693          	andi	a3,a5,17
    80001094:	4745                	li	a4,17
    return 0;
    80001096:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001098:	00e68663          	beq	a3,a4,800010a4 <walkaddr+0x36>
}
    8000109c:	60a2                	ld	ra,8(sp)
    8000109e:	6402                	ld	s0,0(sp)
    800010a0:	0141                	addi	sp,sp,16
    800010a2:	8082                	ret
  pa = PTE2PA(*pte);
    800010a4:	00a7d513          	srli	a0,a5,0xa
    800010a8:	0532                	slli	a0,a0,0xc
  return pa;
    800010aa:	bfcd                	j	8000109c <walkaddr+0x2e>
    return 0;
    800010ac:	4501                	li	a0,0
    800010ae:	b7fd                	j	8000109c <walkaddr+0x2e>

00000000800010b0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b0:	715d                	addi	sp,sp,-80
    800010b2:	e486                	sd	ra,72(sp)
    800010b4:	e0a2                	sd	s0,64(sp)
    800010b6:	fc26                	sd	s1,56(sp)
    800010b8:	f84a                	sd	s2,48(sp)
    800010ba:	f44e                	sd	s3,40(sp)
    800010bc:	f052                	sd	s4,32(sp)
    800010be:	ec56                	sd	s5,24(sp)
    800010c0:	e85a                	sd	s6,16(sp)
    800010c2:	e45e                	sd	s7,8(sp)
    800010c4:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010c6:	c205                	beqz	a2,800010e6 <mappages+0x36>
    800010c8:	8aaa                	mv	s5,a0
    800010ca:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010cc:	77fd                	lui	a5,0xfffff
    800010ce:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010d2:	15fd                	addi	a1,a1,-1
    800010d4:	00c589b3          	add	s3,a1,a2
    800010d8:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010dc:	8952                	mv	s2,s4
    800010de:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e2:	6b85                	lui	s7,0x1
    800010e4:	a015                	j	80001108 <mappages+0x58>
    panic("mappages: size");
    800010e6:	00007517          	auipc	a0,0x7
    800010ea:	ff250513          	addi	a0,a0,-14 # 800080d8 <digits+0x98>
    800010ee:	fffff097          	auipc	ra,0xfffff
    800010f2:	450080e7          	jalr	1104(ra) # 8000053e <panic>
      panic("mappages: remap");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	ff250513          	addi	a0,a0,-14 # 800080e8 <digits+0xa8>
    800010fe:	fffff097          	auipc	ra,0xfffff
    80001102:	440080e7          	jalr	1088(ra) # 8000053e <panic>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
  for(;;){
    80001108:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000110c:	4605                	li	a2,1
    8000110e:	85ca                	mv	a1,s2
    80001110:	8556                	mv	a0,s5
    80001112:	00000097          	auipc	ra,0x0
    80001116:	eb6080e7          	jalr	-330(ra) # 80000fc8 <walk>
    8000111a:	cd19                	beqz	a0,80001138 <mappages+0x88>
    if(*pte & PTE_V)
    8000111c:	611c                	ld	a5,0(a0)
    8000111e:	8b85                	andi	a5,a5,1
    80001120:	fbf9                	bnez	a5,800010f6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001122:	80b1                	srli	s1,s1,0xc
    80001124:	04aa                	slli	s1,s1,0xa
    80001126:	0164e4b3          	or	s1,s1,s6
    8000112a:	0014e493          	ori	s1,s1,1
    8000112e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001130:	fd391be3          	bne	s2,s3,80001106 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	a011                	j	8000113a <mappages+0x8a>
      return -1;
    80001138:	557d                	li	a0,-1
}
    8000113a:	60a6                	ld	ra,72(sp)
    8000113c:	6406                	ld	s0,64(sp)
    8000113e:	74e2                	ld	s1,56(sp)
    80001140:	7942                	ld	s2,48(sp)
    80001142:	79a2                	ld	s3,40(sp)
    80001144:	7a02                	ld	s4,32(sp)
    80001146:	6ae2                	ld	s5,24(sp)
    80001148:	6b42                	ld	s6,16(sp)
    8000114a:	6ba2                	ld	s7,8(sp)
    8000114c:	6161                	addi	sp,sp,80
    8000114e:	8082                	ret

0000000080001150 <kvmmap>:
{
    80001150:	1141                	addi	sp,sp,-16
    80001152:	e406                	sd	ra,8(sp)
    80001154:	e022                	sd	s0,0(sp)
    80001156:	0800                	addi	s0,sp,16
    80001158:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000115a:	86b2                	mv	a3,a2
    8000115c:	863e                	mv	a2,a5
    8000115e:	00000097          	auipc	ra,0x0
    80001162:	f52080e7          	jalr	-174(ra) # 800010b0 <mappages>
    80001166:	e509                	bnez	a0,80001170 <kvmmap+0x20>
}
    80001168:	60a2                	ld	ra,8(sp)
    8000116a:	6402                	ld	s0,0(sp)
    8000116c:	0141                	addi	sp,sp,16
    8000116e:	8082                	ret
    panic("kvmmap");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f8850513          	addi	a0,a0,-120 # 800080f8 <digits+0xb8>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3c6080e7          	jalr	966(ra) # 8000053e <panic>

0000000080001180 <kvmmake>:
{
    80001180:	1101                	addi	sp,sp,-32
    80001182:	ec06                	sd	ra,24(sp)
    80001184:	e822                	sd	s0,16(sp)
    80001186:	e426                	sd	s1,8(sp)
    80001188:	e04a                	sd	s2,0(sp)
    8000118a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	968080e7          	jalr	-1688(ra) # 80000af4 <kalloc>
    80001194:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001196:	6605                	lui	a2,0x1
    80001198:	4581                	li	a1,0
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	b46080e7          	jalr	-1210(ra) # 80000ce0 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011a2:	4719                	li	a4,6
    800011a4:	6685                	lui	a3,0x1
    800011a6:	10000637          	lui	a2,0x10000
    800011aa:	100005b7          	lui	a1,0x10000
    800011ae:	8526                	mv	a0,s1
    800011b0:	00000097          	auipc	ra,0x0
    800011b4:	fa0080e7          	jalr	-96(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011b8:	4719                	li	a4,6
    800011ba:	6685                	lui	a3,0x1
    800011bc:	10001637          	lui	a2,0x10001
    800011c0:	100015b7          	lui	a1,0x10001
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f8a080e7          	jalr	-118(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ce:	4719                	li	a4,6
    800011d0:	004006b7          	lui	a3,0x400
    800011d4:	0c000637          	lui	a2,0xc000
    800011d8:	0c0005b7          	lui	a1,0xc000
    800011dc:	8526                	mv	a0,s1
    800011de:	00000097          	auipc	ra,0x0
    800011e2:	f72080e7          	jalr	-142(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011e6:	00007917          	auipc	s2,0x7
    800011ea:	e1a90913          	addi	s2,s2,-486 # 80008000 <etext>
    800011ee:	4729                	li	a4,10
    800011f0:	80007697          	auipc	a3,0x80007
    800011f4:	e1068693          	addi	a3,a3,-496 # 8000 <_entry-0x7fff8000>
    800011f8:	4605                	li	a2,1
    800011fa:	067e                	slli	a2,a2,0x1f
    800011fc:	85b2                	mv	a1,a2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f50080e7          	jalr	-176(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001208:	4719                	li	a4,6
    8000120a:	46c5                	li	a3,17
    8000120c:	06ee                	slli	a3,a3,0x1b
    8000120e:	412686b3          	sub	a3,a3,s2
    80001212:	864a                	mv	a2,s2
    80001214:	85ca                	mv	a1,s2
    80001216:	8526                	mv	a0,s1
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f38080e7          	jalr	-200(ra) # 80001150 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001220:	4729                	li	a4,10
    80001222:	6685                	lui	a3,0x1
    80001224:	00006617          	auipc	a2,0x6
    80001228:	ddc60613          	addi	a2,a2,-548 # 80007000 <_trampoline>
    8000122c:	040005b7          	lui	a1,0x4000
    80001230:	15fd                	addi	a1,a1,-1
    80001232:	05b2                	slli	a1,a1,0xc
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	f1a080e7          	jalr	-230(ra) # 80001150 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000123e:	8526                	mv	a0,s1
    80001240:	00000097          	auipc	ra,0x0
    80001244:	5fe080e7          	jalr	1534(ra) # 8000183e <proc_mapstacks>
}
    80001248:	8526                	mv	a0,s1
    8000124a:	60e2                	ld	ra,24(sp)
    8000124c:	6442                	ld	s0,16(sp)
    8000124e:	64a2                	ld	s1,8(sp)
    80001250:	6902                	ld	s2,0(sp)
    80001252:	6105                	addi	sp,sp,32
    80001254:	8082                	ret

0000000080001256 <kvminit>:
{
    80001256:	1141                	addi	sp,sp,-16
    80001258:	e406                	sd	ra,8(sp)
    8000125a:	e022                	sd	s0,0(sp)
    8000125c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	f22080e7          	jalr	-222(ra) # 80001180 <kvmmake>
    80001266:	00008797          	auipc	a5,0x8
    8000126a:	daa7bd23          	sd	a0,-582(a5) # 80009020 <kernel_pagetable>
}
    8000126e:	60a2                	ld	ra,8(sp)
    80001270:	6402                	ld	s0,0(sp)
    80001272:	0141                	addi	sp,sp,16
    80001274:	8082                	ret

0000000080001276 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001276:	715d                	addi	sp,sp,-80
    80001278:	e486                	sd	ra,72(sp)
    8000127a:	e0a2                	sd	s0,64(sp)
    8000127c:	fc26                	sd	s1,56(sp)
    8000127e:	f84a                	sd	s2,48(sp)
    80001280:	f44e                	sd	s3,40(sp)
    80001282:	f052                	sd	s4,32(sp)
    80001284:	ec56                	sd	s5,24(sp)
    80001286:	e85a                	sd	s6,16(sp)
    80001288:	e45e                	sd	s7,8(sp)
    8000128a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000128c:	03459793          	slli	a5,a1,0x34
    80001290:	e795                	bnez	a5,800012bc <uvmunmap+0x46>
    80001292:	8a2a                	mv	s4,a0
    80001294:	892e                	mv	s2,a1
    80001296:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001298:	0632                	slli	a2,a2,0xc
    8000129a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000129e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a0:	6b05                	lui	s6,0x1
    800012a2:	0735e863          	bltu	a1,s3,80001312 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012a6:	60a6                	ld	ra,72(sp)
    800012a8:	6406                	ld	s0,64(sp)
    800012aa:	74e2                	ld	s1,56(sp)
    800012ac:	7942                	ld	s2,48(sp)
    800012ae:	79a2                	ld	s3,40(sp)
    800012b0:	7a02                	ld	s4,32(sp)
    800012b2:	6ae2                	ld	s5,24(sp)
    800012b4:	6b42                	ld	s6,16(sp)
    800012b6:	6ba2                	ld	s7,8(sp)
    800012b8:	6161                	addi	sp,sp,80
    800012ba:	8082                	ret
    panic("uvmunmap: not aligned");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e4450513          	addi	a0,a0,-444 # 80008100 <digits+0xc0>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	27a080e7          	jalr	634(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e4c50513          	addi	a0,a0,-436 # 80008118 <digits+0xd8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	26a080e7          	jalr	618(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012dc:	00007517          	auipc	a0,0x7
    800012e0:	e4c50513          	addi	a0,a0,-436 # 80008128 <digits+0xe8>
    800012e4:	fffff097          	auipc	ra,0xfffff
    800012e8:	25a080e7          	jalr	602(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012ec:	00007517          	auipc	a0,0x7
    800012f0:	e5450513          	addi	a0,a0,-428 # 80008140 <digits+0x100>
    800012f4:	fffff097          	auipc	ra,0xfffff
    800012f8:	24a080e7          	jalr	586(ra) # 8000053e <panic>
      uint64 pa = PTE2PA(*pte);
    800012fc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fe:	0532                	slli	a0,a0,0xc
    80001300:	fffff097          	auipc	ra,0xfffff
    80001304:	6f8080e7          	jalr	1784(ra) # 800009f8 <kfree>
    *pte = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	995a                	add	s2,s2,s6
    8000130e:	f9397ce3          	bgeu	s2,s3,800012a6 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001312:	4601                	li	a2,0
    80001314:	85ca                	mv	a1,s2
    80001316:	8552                	mv	a0,s4
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	cb0080e7          	jalr	-848(ra) # 80000fc8 <walk>
    80001320:	84aa                	mv	s1,a0
    80001322:	d54d                	beqz	a0,800012cc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001324:	6108                	ld	a0,0(a0)
    80001326:	00157793          	andi	a5,a0,1
    8000132a:	dbcd                	beqz	a5,800012dc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000132c:	3ff57793          	andi	a5,a0,1023
    80001330:	fb778ee3          	beq	a5,s7,800012ec <uvmunmap+0x76>
    if(do_free){
    80001334:	fc0a8ae3          	beqz	s5,80001308 <uvmunmap+0x92>
    80001338:	b7d1                	j	800012fc <uvmunmap+0x86>

000000008000133a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000133a:	1101                	addi	sp,sp,-32
    8000133c:	ec06                	sd	ra,24(sp)
    8000133e:	e822                	sd	s0,16(sp)
    80001340:	e426                	sd	s1,8(sp)
    80001342:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	7b0080e7          	jalr	1968(ra) # 80000af4 <kalloc>
    8000134c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000134e:	c519                	beqz	a0,8000135c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001350:	6605                	lui	a2,0x1
    80001352:	4581                	li	a1,0
    80001354:	00000097          	auipc	ra,0x0
    80001358:	98c080e7          	jalr	-1652(ra) # 80000ce0 <memset>
  return pagetable;
}
    8000135c:	8526                	mv	a0,s1
    8000135e:	60e2                	ld	ra,24(sp)
    80001360:	6442                	ld	s0,16(sp)
    80001362:	64a2                	ld	s1,8(sp)
    80001364:	6105                	addi	sp,sp,32
    80001366:	8082                	ret

0000000080001368 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001368:	7179                	addi	sp,sp,-48
    8000136a:	f406                	sd	ra,40(sp)
    8000136c:	f022                	sd	s0,32(sp)
    8000136e:	ec26                	sd	s1,24(sp)
    80001370:	e84a                	sd	s2,16(sp)
    80001372:	e44e                	sd	s3,8(sp)
    80001374:	e052                	sd	s4,0(sp)
    80001376:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001378:	6785                	lui	a5,0x1
    8000137a:	04f67863          	bgeu	a2,a5,800013ca <uvminit+0x62>
    8000137e:	8a2a                	mv	s4,a0
    80001380:	89ae                	mv	s3,a1
    80001382:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001384:	fffff097          	auipc	ra,0xfffff
    80001388:	770080e7          	jalr	1904(ra) # 80000af4 <kalloc>
    8000138c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000138e:	6605                	lui	a2,0x1
    80001390:	4581                	li	a1,0
    80001392:	00000097          	auipc	ra,0x0
    80001396:	94e080e7          	jalr	-1714(ra) # 80000ce0 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000139a:	4779                	li	a4,30
    8000139c:	86ca                	mv	a3,s2
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	8552                	mv	a0,s4
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	d0c080e7          	jalr	-756(ra) # 800010b0 <mappages>
  memmove(mem, src, sz);
    800013ac:	8626                	mv	a2,s1
    800013ae:	85ce                	mv	a1,s3
    800013b0:	854a                	mv	a0,s2
    800013b2:	00000097          	auipc	ra,0x0
    800013b6:	98e080e7          	jalr	-1650(ra) # 80000d40 <memmove>
}
    800013ba:	70a2                	ld	ra,40(sp)
    800013bc:	7402                	ld	s0,32(sp)
    800013be:	64e2                	ld	s1,24(sp)
    800013c0:	6942                	ld	s2,16(sp)
    800013c2:	69a2                	ld	s3,8(sp)
    800013c4:	6a02                	ld	s4,0(sp)
    800013c6:	6145                	addi	sp,sp,48
    800013c8:	8082                	ret
    panic("inituvm: more than a page");
    800013ca:	00007517          	auipc	a0,0x7
    800013ce:	d8e50513          	addi	a0,a0,-626 # 80008158 <digits+0x118>
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	16c080e7          	jalr	364(ra) # 8000053e <panic>

00000000800013da <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013da:	1101                	addi	sp,sp,-32
    800013dc:	ec06                	sd	ra,24(sp)
    800013de:	e822                	sd	s0,16(sp)
    800013e0:	e426                	sd	s1,8(sp)
    800013e2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013e4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013e6:	00b67d63          	bgeu	a2,a1,80001400 <uvmdealloc+0x26>
    800013ea:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ec:	6785                	lui	a5,0x1
    800013ee:	17fd                	addi	a5,a5,-1
    800013f0:	00f60733          	add	a4,a2,a5
    800013f4:	767d                	lui	a2,0xfffff
    800013f6:	8f71                	and	a4,a4,a2
    800013f8:	97ae                	add	a5,a5,a1
    800013fa:	8ff1                	and	a5,a5,a2
    800013fc:	00f76863          	bltu	a4,a5,8000140c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001400:	8526                	mv	a0,s1
    80001402:	60e2                	ld	ra,24(sp)
    80001404:	6442                	ld	s0,16(sp)
    80001406:	64a2                	ld	s1,8(sp)
    80001408:	6105                	addi	sp,sp,32
    8000140a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000140c:	8f99                	sub	a5,a5,a4
    8000140e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001410:	4685                	li	a3,1
    80001412:	0007861b          	sext.w	a2,a5
    80001416:	85ba                	mv	a1,a4
    80001418:	00000097          	auipc	ra,0x0
    8000141c:	e5e080e7          	jalr	-418(ra) # 80001276 <uvmunmap>
    80001420:	b7c5                	j	80001400 <uvmdealloc+0x26>

0000000080001422 <uvmalloc>:
  if(newsz < oldsz)
    80001422:	0ab66163          	bltu	a2,a1,800014c4 <uvmalloc+0xa2>
{
    80001426:	7139                	addi	sp,sp,-64
    80001428:	fc06                	sd	ra,56(sp)
    8000142a:	f822                	sd	s0,48(sp)
    8000142c:	f426                	sd	s1,40(sp)
    8000142e:	f04a                	sd	s2,32(sp)
    80001430:	ec4e                	sd	s3,24(sp)
    80001432:	e852                	sd	s4,16(sp)
    80001434:	e456                	sd	s5,8(sp)
    80001436:	0080                	addi	s0,sp,64
    80001438:	8aaa                	mv	s5,a0
    8000143a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000143c:	6985                	lui	s3,0x1
    8000143e:	19fd                	addi	s3,s3,-1
    80001440:	95ce                	add	a1,a1,s3
    80001442:	79fd                	lui	s3,0xfffff
    80001444:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001448:	08c9f063          	bgeu	s3,a2,800014c8 <uvmalloc+0xa6>
    8000144c:	894e                	mv	s2,s3
    mem = kalloc();
    8000144e:	fffff097          	auipc	ra,0xfffff
    80001452:	6a6080e7          	jalr	1702(ra) # 80000af4 <kalloc>
    80001456:	84aa                	mv	s1,a0
    if(mem == 0){
    80001458:	c51d                	beqz	a0,80001486 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000145a:	6605                	lui	a2,0x1
    8000145c:	4581                	li	a1,0
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	882080e7          	jalr	-1918(ra) # 80000ce0 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001466:	4779                	li	a4,30
    80001468:	86a6                	mv	a3,s1
    8000146a:	6605                	lui	a2,0x1
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	c40080e7          	jalr	-960(ra) # 800010b0 <mappages>
    80001478:	e905                	bnez	a0,800014a8 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000147a:	6785                	lui	a5,0x1
    8000147c:	993e                	add	s2,s2,a5
    8000147e:	fd4968e3          	bltu	s2,s4,8000144e <uvmalloc+0x2c>
  return newsz;
    80001482:	8552                	mv	a0,s4
    80001484:	a809                	j	80001496 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001486:	864e                	mv	a2,s3
    80001488:	85ca                	mv	a1,s2
    8000148a:	8556                	mv	a0,s5
    8000148c:	00000097          	auipc	ra,0x0
    80001490:	f4e080e7          	jalr	-178(ra) # 800013da <uvmdealloc>
      return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	70e2                	ld	ra,56(sp)
    80001498:	7442                	ld	s0,48(sp)
    8000149a:	74a2                	ld	s1,40(sp)
    8000149c:	7902                	ld	s2,32(sp)
    8000149e:	69e2                	ld	s3,24(sp)
    800014a0:	6a42                	ld	s4,16(sp)
    800014a2:	6aa2                	ld	s5,8(sp)
    800014a4:	6121                	addi	sp,sp,64
    800014a6:	8082                	ret
      kfree(mem);
    800014a8:	8526                	mv	a0,s1
    800014aa:	fffff097          	auipc	ra,0xfffff
    800014ae:	54e080e7          	jalr	1358(ra) # 800009f8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b2:	864e                	mv	a2,s3
    800014b4:	85ca                	mv	a1,s2
    800014b6:	8556                	mv	a0,s5
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	f22080e7          	jalr	-222(ra) # 800013da <uvmdealloc>
      return 0;
    800014c0:	4501                	li	a0,0
    800014c2:	bfd1                	j	80001496 <uvmalloc+0x74>
    return oldsz;
    800014c4:	852e                	mv	a0,a1
}
    800014c6:	8082                	ret
  return newsz;
    800014c8:	8532                	mv	a0,a2
    800014ca:	b7f1                	j	80001496 <uvmalloc+0x74>

00000000800014cc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014cc:	7179                	addi	sp,sp,-48
    800014ce:	f406                	sd	ra,40(sp)
    800014d0:	f022                	sd	s0,32(sp)
    800014d2:	ec26                	sd	s1,24(sp)
    800014d4:	e84a                	sd	s2,16(sp)
    800014d6:	e44e                	sd	s3,8(sp)
    800014d8:	e052                	sd	s4,0(sp)
    800014da:	1800                	addi	s0,sp,48
    800014dc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014de:	84aa                	mv	s1,a0
    800014e0:	6905                	lui	s2,0x1
    800014e2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	4985                	li	s3,1
    800014e6:	a821                	j	800014fe <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ea:	0532                	slli	a0,a0,0xc
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	fe0080e7          	jalr	-32(ra) # 800014cc <freewalk>
      pagetable[i] = 0;
    800014f4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f8:	04a1                	addi	s1,s1,8
    800014fa:	03248163          	beq	s1,s2,8000151c <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fe:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001500:	00f57793          	andi	a5,a0,15
    80001504:	ff3782e3          	beq	a5,s3,800014e8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001508:	8905                	andi	a0,a0,1
    8000150a:	d57d                	beqz	a0,800014f8 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c6c50513          	addi	a0,a0,-916 # 80008178 <digits+0x138>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	02a080e7          	jalr	42(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    8000151c:	8552                	mv	a0,s4
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4da080e7          	jalr	1242(ra) # 800009f8 <kfree>
}
    80001526:	70a2                	ld	ra,40(sp)
    80001528:	7402                	ld	s0,32(sp)
    8000152a:	64e2                	ld	s1,24(sp)
    8000152c:	6942                	ld	s2,16(sp)
    8000152e:	69a2                	ld	s3,8(sp)
    80001530:	6a02                	ld	s4,0(sp)
    80001532:	6145                	addi	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001536:	1101                	addi	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	addi	s0,sp,32
    80001540:	84aa                	mv	s1,a0
  if(sz > 0)
    80001542:	e999                	bnez	a1,80001558 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f86080e7          	jalr	-122(ra) # 800014cc <freewalk>
}
    8000154e:	60e2                	ld	ra,24(sp)
    80001550:	6442                	ld	s0,16(sp)
    80001552:	64a2                	ld	s1,8(sp)
    80001554:	6105                	addi	sp,sp,32
    80001556:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001558:	6605                	lui	a2,0x1
    8000155a:	167d                	addi	a2,a2,-1
    8000155c:	962e                	add	a2,a2,a1
    8000155e:	4685                	li	a3,1
    80001560:	8231                	srli	a2,a2,0xc
    80001562:	4581                	li	a1,0
    80001564:	00000097          	auipc	ra,0x0
    80001568:	d12080e7          	jalr	-750(ra) # 80001276 <uvmunmap>
    8000156c:	bfe1                	j	80001544 <uvmfree+0xe>

000000008000156e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156e:	c679                	beqz	a2,8000163c <uvmcopy+0xce>
{
    80001570:	715d                	addi	sp,sp,-80
    80001572:	e486                	sd	ra,72(sp)
    80001574:	e0a2                	sd	s0,64(sp)
    80001576:	fc26                	sd	s1,56(sp)
    80001578:	f84a                	sd	s2,48(sp)
    8000157a:	f44e                	sd	s3,40(sp)
    8000157c:	f052                	sd	s4,32(sp)
    8000157e:	ec56                	sd	s5,24(sp)
    80001580:	e85a                	sd	s6,16(sp)
    80001582:	e45e                	sd	s7,8(sp)
    80001584:	0880                	addi	s0,sp,80
    80001586:	8b2a                	mv	s6,a0
    80001588:	8aae                	mv	s5,a1
    8000158a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158e:	4601                	li	a2,0
    80001590:	85ce                	mv	a1,s3
    80001592:	855a                	mv	a0,s6
    80001594:	00000097          	auipc	ra,0x0
    80001598:	a34080e7          	jalr	-1484(ra) # 80000fc8 <walk>
    8000159c:	c531                	beqz	a0,800015e8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159e:	6118                	ld	a4,0(a0)
    800015a0:	00177793          	andi	a5,a4,1
    800015a4:	cbb1                	beqz	a5,800015f8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a6:	00a75593          	srli	a1,a4,0xa
    800015aa:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ae:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b2:	fffff097          	auipc	ra,0xfffff
    800015b6:	542080e7          	jalr	1346(ra) # 80000af4 <kalloc>
    800015ba:	892a                	mv	s2,a0
    800015bc:	c939                	beqz	a0,80001612 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015be:	6605                	lui	a2,0x1
    800015c0:	85de                	mv	a1,s7
    800015c2:	fffff097          	auipc	ra,0xfffff
    800015c6:	77e080e7          	jalr	1918(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ca:	8726                	mv	a4,s1
    800015cc:	86ca                	mv	a3,s2
    800015ce:	6605                	lui	a2,0x1
    800015d0:	85ce                	mv	a1,s3
    800015d2:	8556                	mv	a0,s5
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	adc080e7          	jalr	-1316(ra) # 800010b0 <mappages>
    800015dc:	e515                	bnez	a0,80001608 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015de:	6785                	lui	a5,0x1
    800015e0:	99be                	add	s3,s3,a5
    800015e2:	fb49e6e3          	bltu	s3,s4,8000158e <uvmcopy+0x20>
    800015e6:	a081                	j	80001626 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e8:	00007517          	auipc	a0,0x7
    800015ec:	ba050513          	addi	a0,a0,-1120 # 80008188 <digits+0x148>
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	f4e080e7          	jalr	-178(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015f8:	00007517          	auipc	a0,0x7
    800015fc:	bb050513          	addi	a0,a0,-1104 # 800081a8 <digits+0x168>
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	f3e080e7          	jalr	-194(ra) # 8000053e <panic>
      kfree(mem);
    80001608:	854a                	mv	a0,s2
    8000160a:	fffff097          	auipc	ra,0xfffff
    8000160e:	3ee080e7          	jalr	1006(ra) # 800009f8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001612:	4685                	li	a3,1
    80001614:	00c9d613          	srli	a2,s3,0xc
    80001618:	4581                	li	a1,0
    8000161a:	8556                	mv	a0,s5
    8000161c:	00000097          	auipc	ra,0x0
    80001620:	c5a080e7          	jalr	-934(ra) # 80001276 <uvmunmap>
  return -1;
    80001624:	557d                	li	a0,-1
}
    80001626:	60a6                	ld	ra,72(sp)
    80001628:	6406                	ld	s0,64(sp)
    8000162a:	74e2                	ld	s1,56(sp)
    8000162c:	7942                	ld	s2,48(sp)
    8000162e:	79a2                	ld	s3,40(sp)
    80001630:	7a02                	ld	s4,32(sp)
    80001632:	6ae2                	ld	s5,24(sp)
    80001634:	6b42                	ld	s6,16(sp)
    80001636:	6ba2                	ld	s7,8(sp)
    80001638:	6161                	addi	sp,sp,80
    8000163a:	8082                	ret
  return 0;
    8000163c:	4501                	li	a0,0
}
    8000163e:	8082                	ret

0000000080001640 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001640:	1141                	addi	sp,sp,-16
    80001642:	e406                	sd	ra,8(sp)
    80001644:	e022                	sd	s0,0(sp)
    80001646:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001648:	4601                	li	a2,0
    8000164a:	00000097          	auipc	ra,0x0
    8000164e:	97e080e7          	jalr	-1666(ra) # 80000fc8 <walk>
  if(pte == 0)
    80001652:	c901                	beqz	a0,80001662 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001654:	611c                	ld	a5,0(a0)
    80001656:	9bbd                	andi	a5,a5,-17
    80001658:	e11c                	sd	a5,0(a0)
}
    8000165a:	60a2                	ld	ra,8(sp)
    8000165c:	6402                	ld	s0,0(sp)
    8000165e:	0141                	addi	sp,sp,16
    80001660:	8082                	ret
    panic("uvmclear");
    80001662:	00007517          	auipc	a0,0x7
    80001666:	b6650513          	addi	a0,a0,-1178 # 800081c8 <digits+0x188>
    8000166a:	fffff097          	auipc	ra,0xfffff
    8000166e:	ed4080e7          	jalr	-300(ra) # 8000053e <panic>

0000000080001672 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001672:	c6bd                	beqz	a3,800016e0 <copyout+0x6e>
{
    80001674:	715d                	addi	sp,sp,-80
    80001676:	e486                	sd	ra,72(sp)
    80001678:	e0a2                	sd	s0,64(sp)
    8000167a:	fc26                	sd	s1,56(sp)
    8000167c:	f84a                	sd	s2,48(sp)
    8000167e:	f44e                	sd	s3,40(sp)
    80001680:	f052                	sd	s4,32(sp)
    80001682:	ec56                	sd	s5,24(sp)
    80001684:	e85a                	sd	s6,16(sp)
    80001686:	e45e                	sd	s7,8(sp)
    80001688:	e062                	sd	s8,0(sp)
    8000168a:	0880                	addi	s0,sp,80
    8000168c:	8b2a                	mv	s6,a0
    8000168e:	8c2e                	mv	s8,a1
    80001690:	8a32                	mv	s4,a2
    80001692:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001694:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001696:	6a85                	lui	s5,0x1
    80001698:	a015                	j	800016bc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000169a:	9562                	add	a0,a0,s8
    8000169c:	0004861b          	sext.w	a2,s1
    800016a0:	85d2                	mv	a1,s4
    800016a2:	41250533          	sub	a0,a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	69a080e7          	jalr	1690(ra) # 80000d40 <memmove>

    len -= n;
    800016ae:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b8:	02098263          	beqz	s3,800016dc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016c0:	85ca                	mv	a1,s2
    800016c2:	855a                	mv	a0,s6
    800016c4:	00000097          	auipc	ra,0x0
    800016c8:	9aa080e7          	jalr	-1622(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800016cc:	cd01                	beqz	a0,800016e4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ce:	418904b3          	sub	s1,s2,s8
    800016d2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d4:	fc99f3e3          	bgeu	s3,s1,8000169a <copyout+0x28>
    800016d8:	84ce                	mv	s1,s3
    800016da:	b7c1                	j	8000169a <copyout+0x28>
  }
  return 0;
    800016dc:	4501                	li	a0,0
    800016de:	a021                	j	800016e6 <copyout+0x74>
    800016e0:	4501                	li	a0,0
}
    800016e2:	8082                	ret
      return -1;
    800016e4:	557d                	li	a0,-1
}
    800016e6:	60a6                	ld	ra,72(sp)
    800016e8:	6406                	ld	s0,64(sp)
    800016ea:	74e2                	ld	s1,56(sp)
    800016ec:	7942                	ld	s2,48(sp)
    800016ee:	79a2                	ld	s3,40(sp)
    800016f0:	7a02                	ld	s4,32(sp)
    800016f2:	6ae2                	ld	s5,24(sp)
    800016f4:	6b42                	ld	s6,16(sp)
    800016f6:	6ba2                	ld	s7,8(sp)
    800016f8:	6c02                	ld	s8,0(sp)
    800016fa:	6161                	addi	sp,sp,80
    800016fc:	8082                	ret

00000000800016fe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fe:	c6bd                	beqz	a3,8000176c <copyin+0x6e>
{
    80001700:	715d                	addi	sp,sp,-80
    80001702:	e486                	sd	ra,72(sp)
    80001704:	e0a2                	sd	s0,64(sp)
    80001706:	fc26                	sd	s1,56(sp)
    80001708:	f84a                	sd	s2,48(sp)
    8000170a:	f44e                	sd	s3,40(sp)
    8000170c:	f052                	sd	s4,32(sp)
    8000170e:	ec56                	sd	s5,24(sp)
    80001710:	e85a                	sd	s6,16(sp)
    80001712:	e45e                	sd	s7,8(sp)
    80001714:	e062                	sd	s8,0(sp)
    80001716:	0880                	addi	s0,sp,80
    80001718:	8b2a                	mv	s6,a0
    8000171a:	8a2e                	mv	s4,a1
    8000171c:	8c32                	mv	s8,a2
    8000171e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001720:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001722:	6a85                	lui	s5,0x1
    80001724:	a015                	j	80001748 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001726:	9562                	add	a0,a0,s8
    80001728:	0004861b          	sext.w	a2,s1
    8000172c:	412505b3          	sub	a1,a0,s2
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	60e080e7          	jalr	1550(ra) # 80000d40 <memmove>

    len -= n;
    8000173a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001740:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001744:	02098263          	beqz	s3,80001768 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001748:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85ca                	mv	a1,s2
    8000174e:	855a                	mv	a0,s6
    80001750:	00000097          	auipc	ra,0x0
    80001754:	91e080e7          	jalr	-1762(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    80001758:	cd01                	beqz	a0,80001770 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000175a:	418904b3          	sub	s1,s2,s8
    8000175e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001760:	fc99f3e3          	bgeu	s3,s1,80001726 <copyin+0x28>
    80001764:	84ce                	mv	s1,s3
    80001766:	b7c1                	j	80001726 <copyin+0x28>
  }
  return 0;
    80001768:	4501                	li	a0,0
    8000176a:	a021                	j	80001772 <copyin+0x74>
    8000176c:	4501                	li	a0,0
}
    8000176e:	8082                	ret
      return -1;
    80001770:	557d                	li	a0,-1
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	c6c5                	beqz	a3,80001832 <copyinstr+0xa8>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8a2a                	mv	s4,a0
    800017a4:	8b2e                	mv	s6,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6985                	lui	s3,0x1
    800017ae:	a035                	j	800017da <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017b793          	seqz	a5,a5
    800017ba:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d8:	c8a9                	beqz	s1,8000182a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017da:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017de:	85ca                	mv	a1,s2
    800017e0:	8552                	mv	a0,s4
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	88c080e7          	jalr	-1908(ra) # 8000106e <walkaddr>
    if(pa0 == 0)
    800017ea:	c131                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ec:	41790833          	sub	a6,s2,s7
    800017f0:	984e                	add	a6,a6,s3
    if(n > max)
    800017f2:	0104f363          	bgeu	s1,a6,800017f8 <copyinstr+0x6e>
    800017f6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f8:	955e                	add	a0,a0,s7
    800017fa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fe:	fc080be3          	beqz	a6,800017d4 <copyinstr+0x4a>
    80001802:	985a                	add	a6,a6,s6
    80001804:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001806:	41650633          	sub	a2,a0,s6
    8000180a:	14fd                	addi	s1,s1,-1
    8000180c:	9b26                	add	s6,s6,s1
    8000180e:	00f60733          	add	a4,a2,a5
    80001812:	00074703          	lbu	a4,0(a4)
    80001816:	df49                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    80001818:	00e78023          	sb	a4,0(a5)
      --max;
    8000181c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001820:	0785                	addi	a5,a5,1
    while(n > 0){
    80001822:	ff0796e3          	bne	a5,a6,8000180e <copyinstr+0x84>
      dst++;
    80001826:	8b42                	mv	s6,a6
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
  int got_null = 0;
    80001832:	4781                	li	a5,0
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
    80001852:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	00010497          	auipc	s1,0x10
    80001858:	e7c48493          	addi	s1,s1,-388 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185c:	8b26                	mv	s6,s1
    8000185e:	00006a97          	auipc	s5,0x6
    80001862:	7a2a8a93          	addi	s5,s5,1954 # 80008000 <etext>
    80001866:	04000937          	lui	s2,0x4000
    8000186a:	197d                	addi	s2,s2,-1
    8000186c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00016a17          	auipc	s4,0x16
    80001872:	a62a0a13          	addi	s4,s4,-1438 # 800172d0 <tickslock>
    char *pa = kalloc();
    80001876:	fffff097          	auipc	ra,0xfffff
    8000187a:	27e080e7          	jalr	638(ra) # 80000af4 <kalloc>
    8000187e:	862a                	mv	a2,a0
    if(pa == 0)
    80001880:	c131                	beqz	a0,800018c4 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001882:	416485b3          	sub	a1,s1,s6
    80001886:	8591                	srai	a1,a1,0x4
    80001888:	000ab783          	ld	a5,0(s5)
    8000188c:	02f585b3          	mul	a1,a1,a5
    80001890:	2585                	addiw	a1,a1,1
    80001892:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001896:	4719                	li	a4,6
    80001898:	6685                	lui	a3,0x1
    8000189a:	40b905b3          	sub	a1,s2,a1
    8000189e:	854e                	mv	a0,s3
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	8b0080e7          	jalr	-1872(ra) # 80001150 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a8:	17048493          	addi	s1,s1,368
    800018ac:	fd4495e3          	bne	s1,s4,80001876 <proc_mapstacks+0x38>
  }
}
    800018b0:	70e2                	ld	ra,56(sp)
    800018b2:	7442                	ld	s0,48(sp)
    800018b4:	74a2                	ld	s1,40(sp)
    800018b6:	7902                	ld	s2,32(sp)
    800018b8:	69e2                	ld	s3,24(sp)
    800018ba:	6a42                	ld	s4,16(sp)
    800018bc:	6aa2                	ld	s5,8(sp)
    800018be:	6b02                	ld	s6,0(sp)
    800018c0:	6121                	addi	sp,sp,64
    800018c2:	8082                	ret
      panic("kalloc");
    800018c4:	00007517          	auipc	a0,0x7
    800018c8:	91450513          	addi	a0,a0,-1772 # 800081d8 <digits+0x198>
    800018cc:	fffff097          	auipc	ra,0xfffff
    800018d0:	c72080e7          	jalr	-910(ra) # 8000053e <panic>

00000000800018d4 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018d4:	7139                	addi	sp,sp,-64
    800018d6:	fc06                	sd	ra,56(sp)
    800018d8:	f822                	sd	s0,48(sp)
    800018da:	f426                	sd	s1,40(sp)
    800018dc:	f04a                	sd	s2,32(sp)
    800018de:	ec4e                	sd	s3,24(sp)
    800018e0:	e852                	sd	s4,16(sp)
    800018e2:	e456                	sd	s5,8(sp)
    800018e4:	e05a                	sd	s6,0(sp)
    800018e6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e8:	00007597          	auipc	a1,0x7
    800018ec:	8f858593          	addi	a1,a1,-1800 # 800081e0 <digits+0x1a0>
    800018f0:	00010517          	auipc	a0,0x10
    800018f4:	9b050513          	addi	a0,a0,-1616 # 800112a0 <pid_lock>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	25c080e7          	jalr	604(ra) # 80000b54 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001900:	00007597          	auipc	a1,0x7
    80001904:	8e858593          	addi	a1,a1,-1816 # 800081e8 <digits+0x1a8>
    80001908:	00010517          	auipc	a0,0x10
    8000190c:	9b050513          	addi	a0,a0,-1616 # 800112b8 <wait_lock>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	244080e7          	jalr	580(ra) # 80000b54 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001918:	00010497          	auipc	s1,0x10
    8000191c:	db848493          	addi	s1,s1,-584 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001920:	00007b17          	auipc	s6,0x7
    80001924:	8d8b0b13          	addi	s6,s6,-1832 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001928:	8aa6                	mv	s5,s1
    8000192a:	00006a17          	auipc	s4,0x6
    8000192e:	6d6a0a13          	addi	s4,s4,1750 # 80008000 <etext>
    80001932:	04000937          	lui	s2,0x4000
    80001936:	197d                	addi	s2,s2,-1
    80001938:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193a:	00016997          	auipc	s3,0x16
    8000193e:	99698993          	addi	s3,s3,-1642 # 800172d0 <tickslock>
      initlock(&p->lock, "proc");
    80001942:	85da                	mv	a1,s6
    80001944:	8526                	mv	a0,s1
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	20e080e7          	jalr	526(ra) # 80000b54 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000194e:	415487b3          	sub	a5,s1,s5
    80001952:	8791                	srai	a5,a5,0x4
    80001954:	000a3703          	ld	a4,0(s4)
    80001958:	02e787b3          	mul	a5,a5,a4
    8000195c:	2785                	addiw	a5,a5,1
    8000195e:	00d7979b          	slliw	a5,a5,0xd
    80001962:	40f907b3          	sub	a5,s2,a5
    80001966:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001968:	17048493          	addi	s1,s1,368
    8000196c:	fd349be3          	bne	s1,s3,80001942 <procinit+0x6e>
  }
}
    80001970:	70e2                	ld	ra,56(sp)
    80001972:	7442                	ld	s0,48(sp)
    80001974:	74a2                	ld	s1,40(sp)
    80001976:	7902                	ld	s2,32(sp)
    80001978:	69e2                	ld	s3,24(sp)
    8000197a:	6a42                	ld	s4,16(sp)
    8000197c:	6aa2                	ld	s5,8(sp)
    8000197e:	6b02                	ld	s6,0(sp)
    80001980:	6121                	addi	sp,sp,64
    80001982:	8082                	ret

0000000080001984 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001984:	1141                	addi	sp,sp,-16
    80001986:	e422                	sd	s0,8(sp)
    80001988:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000198c:	2501                	sext.w	a0,a0
    8000198e:	6422                	ld	s0,8(sp)
    80001990:	0141                	addi	sp,sp,16
    80001992:	8082                	ret

0000000080001994 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001994:	1141                	addi	sp,sp,-16
    80001996:	e422                	sd	s0,8(sp)
    80001998:	0800                	addi	s0,sp,16
    8000199a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000199c:	2781                	sext.w	a5,a5
    8000199e:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a0:	00010517          	auipc	a0,0x10
    800019a4:	93050513          	addi	a0,a0,-1744 # 800112d0 <cpus>
    800019a8:	953e                	add	a0,a0,a5
    800019aa:	6422                	ld	s0,8(sp)
    800019ac:	0141                	addi	sp,sp,16
    800019ae:	8082                	ret

00000000800019b0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    800019b0:	1101                	addi	sp,sp,-32
    800019b2:	ec06                	sd	ra,24(sp)
    800019b4:	e822                	sd	s0,16(sp)
    800019b6:	e426                	sd	s1,8(sp)
    800019b8:	1000                	addi	s0,sp,32
  push_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	1de080e7          	jalr	478(ra) # 80000b98 <push_off>
    800019c2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c4:	2781                	sext.w	a5,a5
    800019c6:	079e                	slli	a5,a5,0x7
    800019c8:	00010717          	auipc	a4,0x10
    800019cc:	8d870713          	addi	a4,a4,-1832 # 800112a0 <pid_lock>
    800019d0:	97ba                	add	a5,a5,a4
    800019d2:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	264080e7          	jalr	612(ra) # 80000c38 <pop_off>
  return p;
}
    800019dc:	8526                	mv	a0,s1
    800019de:	60e2                	ld	ra,24(sp)
    800019e0:	6442                	ld	s0,16(sp)
    800019e2:	64a2                	ld	s1,8(sp)
    800019e4:	6105                	addi	sp,sp,32
    800019e6:	8082                	ret

00000000800019e8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e8:	1101                	addi	sp,sp,-32
    800019ea:	ec06                	sd	ra,24(sp)
    800019ec:	e822                	sd	s0,16(sp)
    800019ee:	e426                	sd	s1,8(sp)
    800019f0:	e04a                	sd	s2,0(sp)
    800019f2:	1000                	addi	s0,sp,32
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f4:	00000097          	auipc	ra,0x0
    800019f8:	fbc080e7          	jalr	-68(ra) # 800019b0 <myproc>
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	29c080e7          	jalr	668(ra) # 80000c98 <release>

  uint xticks;

  acquire(&tickslock);
    80001a04:	00016517          	auipc	a0,0x16
    80001a08:	8cc50513          	addi	a0,a0,-1844 # 800172d0 <tickslock>
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	1d8080e7          	jalr	472(ra) # 80000be4 <acquire>
  xticks = ticks;
    80001a14:	00007917          	auipc	s2,0x7
    80001a18:	61c92903          	lw	s2,1564(s2) # 80009030 <ticks>
  release(&tickslock);  
    80001a1c:	00016517          	auipc	a0,0x16
    80001a20:	8b450513          	addi	a0,a0,-1868 # 800172d0 <tickslock>
    80001a24:	fffff097          	auipc	ra,0xfffff
    80001a28:	274080e7          	jalr	628(ra) # 80000c98 <release>

  struct proc * p = myproc();
    80001a2c:	00000097          	auipc	ra,0x0
    80001a30:	f84080e7          	jalr	-124(ra) # 800019b0 <myproc>
    80001a34:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001a36:	fffff097          	auipc	ra,0xfffff
    80001a3a:	1ae080e7          	jalr	430(ra) # 80000be4 <acquire>
  p->stime = xticks;
    80001a3e:	0324ac23          	sw	s2,56(s1)
  release(&p->lock);
    80001a42:	8526                	mv	a0,s1
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	254080e7          	jalr	596(ra) # 80000c98 <release>

  if (first) {
    80001a4c:	00007797          	auipc	a5,0x7
    80001a50:	eb47a783          	lw	a5,-332(a5) # 80008900 <first.1751>
    80001a54:	eb99                	bnez	a5,80001a6a <forkret+0x82>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a56:	00001097          	auipc	ra,0x1
    80001a5a:	198080e7          	jalr	408(ra) # 80002bee <usertrapret>
}
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6902                	ld	s2,0(sp)
    80001a66:	6105                	addi	sp,sp,32
    80001a68:	8082                	ret
    first = 0;
    80001a6a:	00007797          	auipc	a5,0x7
    80001a6e:	e807ab23          	sw	zero,-362(a5) # 80008900 <first.1751>
    fsinit(ROOTDEV);
    80001a72:	4505                	li	a0,1
    80001a74:	00002097          	auipc	ra,0x2
    80001a78:	036080e7          	jalr	54(ra) # 80003aaa <fsinit>
    80001a7c:	bfe9                	j	80001a56 <forkret+0x6e>

0000000080001a7e <allocpid>:
allocpid() {
    80001a7e:	1101                	addi	sp,sp,-32
    80001a80:	ec06                	sd	ra,24(sp)
    80001a82:	e822                	sd	s0,16(sp)
    80001a84:	e426                	sd	s1,8(sp)
    80001a86:	e04a                	sd	s2,0(sp)
    80001a88:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a8a:	00010917          	auipc	s2,0x10
    80001a8e:	81690913          	addi	s2,s2,-2026 # 800112a0 <pid_lock>
    80001a92:	854a                	mv	a0,s2
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	150080e7          	jalr	336(ra) # 80000be4 <acquire>
  pid = nextpid;
    80001a9c:	00007797          	auipc	a5,0x7
    80001aa0:	e6878793          	addi	a5,a5,-408 # 80008904 <nextpid>
    80001aa4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001aa6:	0014871b          	addiw	a4,s1,1
    80001aaa:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aac:	854a                	mv	a0,s2
    80001aae:	fffff097          	auipc	ra,0xfffff
    80001ab2:	1ea080e7          	jalr	490(ra) # 80000c98 <release>
}
    80001ab6:	8526                	mv	a0,s1
    80001ab8:	60e2                	ld	ra,24(sp)
    80001aba:	6442                	ld	s0,16(sp)
    80001abc:	64a2                	ld	s1,8(sp)
    80001abe:	6902                	ld	s2,0(sp)
    80001ac0:	6105                	addi	sp,sp,32
    80001ac2:	8082                	ret

0000000080001ac4 <proc_pagetable>:
{
    80001ac4:	1101                	addi	sp,sp,-32
    80001ac6:	ec06                	sd	ra,24(sp)
    80001ac8:	e822                	sd	s0,16(sp)
    80001aca:	e426                	sd	s1,8(sp)
    80001acc:	e04a                	sd	s2,0(sp)
    80001ace:	1000                	addi	s0,sp,32
    80001ad0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ad2:	00000097          	auipc	ra,0x0
    80001ad6:	868080e7          	jalr	-1944(ra) # 8000133a <uvmcreate>
    80001ada:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001adc:	c121                	beqz	a0,80001b1c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ade:	4729                	li	a4,10
    80001ae0:	00005697          	auipc	a3,0x5
    80001ae4:	52068693          	addi	a3,a3,1312 # 80007000 <_trampoline>
    80001ae8:	6605                	lui	a2,0x1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	5be080e7          	jalr	1470(ra) # 800010b0 <mappages>
    80001afa:	02054863          	bltz	a0,80001b2a <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001afe:	4719                	li	a4,6
    80001b00:	06093683          	ld	a3,96(s2)
    80001b04:	6605                	lui	a2,0x1
    80001b06:	020005b7          	lui	a1,0x2000
    80001b0a:	15fd                	addi	a1,a1,-1
    80001b0c:	05b6                	slli	a1,a1,0xd
    80001b0e:	8526                	mv	a0,s1
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	5a0080e7          	jalr	1440(ra) # 800010b0 <mappages>
    80001b18:	02054163          	bltz	a0,80001b3a <proc_pagetable+0x76>
}
    80001b1c:	8526                	mv	a0,s1
    80001b1e:	60e2                	ld	ra,24(sp)
    80001b20:	6442                	ld	s0,16(sp)
    80001b22:	64a2                	ld	s1,8(sp)
    80001b24:	6902                	ld	s2,0(sp)
    80001b26:	6105                	addi	sp,sp,32
    80001b28:	8082                	ret
    uvmfree(pagetable, 0);
    80001b2a:	4581                	li	a1,0
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	00000097          	auipc	ra,0x0
    80001b32:	a08080e7          	jalr	-1528(ra) # 80001536 <uvmfree>
    return 0;
    80001b36:	4481                	li	s1,0
    80001b38:	b7d5                	j	80001b1c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b3a:	4681                	li	a3,0
    80001b3c:	4605                	li	a2,1
    80001b3e:	040005b7          	lui	a1,0x4000
    80001b42:	15fd                	addi	a1,a1,-1
    80001b44:	05b2                	slli	a1,a1,0xc
    80001b46:	8526                	mv	a0,s1
    80001b48:	fffff097          	auipc	ra,0xfffff
    80001b4c:	72e080e7          	jalr	1838(ra) # 80001276 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b50:	4581                	li	a1,0
    80001b52:	8526                	mv	a0,s1
    80001b54:	00000097          	auipc	ra,0x0
    80001b58:	9e2080e7          	jalr	-1566(ra) # 80001536 <uvmfree>
    return 0;
    80001b5c:	4481                	li	s1,0
    80001b5e:	bf7d                	j	80001b1c <proc_pagetable+0x58>

0000000080001b60 <proc_freepagetable>:
{
    80001b60:	1101                	addi	sp,sp,-32
    80001b62:	ec06                	sd	ra,24(sp)
    80001b64:	e822                	sd	s0,16(sp)
    80001b66:	e426                	sd	s1,8(sp)
    80001b68:	e04a                	sd	s2,0(sp)
    80001b6a:	1000                	addi	s0,sp,32
    80001b6c:	84aa                	mv	s1,a0
    80001b6e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b70:	4681                	li	a3,0
    80001b72:	4605                	li	a2,1
    80001b74:	040005b7          	lui	a1,0x4000
    80001b78:	15fd                	addi	a1,a1,-1
    80001b7a:	05b2                	slli	a1,a1,0xc
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	6fa080e7          	jalr	1786(ra) # 80001276 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	020005b7          	lui	a1,0x2000
    80001b8c:	15fd                	addi	a1,a1,-1
    80001b8e:	05b6                	slli	a1,a1,0xd
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	6e4080e7          	jalr	1764(ra) # 80001276 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b9a:	85ca                	mv	a1,s2
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	998080e7          	jalr	-1640(ra) # 80001536 <uvmfree>
}
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6902                	ld	s2,0(sp)
    80001bae:	6105                	addi	sp,sp,32
    80001bb0:	8082                	ret

0000000080001bb2 <freeproc>:
{
    80001bb2:	1101                	addi	sp,sp,-32
    80001bb4:	ec06                	sd	ra,24(sp)
    80001bb6:	e822                	sd	s0,16(sp)
    80001bb8:	e426                	sd	s1,8(sp)
    80001bba:	1000                	addi	s0,sp,32
    80001bbc:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bbe:	7128                	ld	a0,96(a0)
    80001bc0:	c509                	beqz	a0,80001bca <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	e36080e7          	jalr	-458(ra) # 800009f8 <kfree>
  p->trapframe = 0;
    80001bca:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001bce:	6ca8                	ld	a0,88(s1)
    80001bd0:	c511                	beqz	a0,80001bdc <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bd2:	68ac                	ld	a1,80(s1)
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	f8c080e7          	jalr	-116(ra) # 80001b60 <proc_freepagetable>
  p->pagetable = 0;
    80001bdc:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001be0:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001be4:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001be8:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001bec:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001bf0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bf4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bf8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bfc:	0004ac23          	sw	zero,24(s1)
}
    80001c00:	60e2                	ld	ra,24(sp)
    80001c02:	6442                	ld	s0,16(sp)
    80001c04:	64a2                	ld	s1,8(sp)
    80001c06:	6105                	addi	sp,sp,32
    80001c08:	8082                	ret

0000000080001c0a <allocproc>:
{
    80001c0a:	1101                	addi	sp,sp,-32
    80001c0c:	ec06                	sd	ra,24(sp)
    80001c0e:	e822                	sd	s0,16(sp)
    80001c10:	e426                	sd	s1,8(sp)
    80001c12:	e04a                	sd	s2,0(sp)
    80001c14:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c16:	00010497          	auipc	s1,0x10
    80001c1a:	aba48493          	addi	s1,s1,-1350 # 800116d0 <proc>
    80001c1e:	00015917          	auipc	s2,0x15
    80001c22:	6b290913          	addi	s2,s2,1714 # 800172d0 <tickslock>
    acquire(&p->lock);
    80001c26:	8526                	mv	a0,s1
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	fbc080e7          	jalr	-68(ra) # 80000be4 <acquire>
    if(p->state == UNUSED) {
    80001c30:	4c9c                	lw	a5,24(s1)
    80001c32:	cf81                	beqz	a5,80001c4a <allocproc+0x40>
      release(&p->lock);
    80001c34:	8526                	mv	a0,s1
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	062080e7          	jalr	98(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c3e:	17048493          	addi	s1,s1,368
    80001c42:	ff2492e3          	bne	s1,s2,80001c26 <allocproc+0x1c>
  return 0;
    80001c46:	4481                	li	s1,0
    80001c48:	a889                	j	80001c9a <allocproc+0x90>
  p->pid = allocpid();
    80001c4a:	00000097          	auipc	ra,0x0
    80001c4e:	e34080e7          	jalr	-460(ra) # 80001a7e <allocpid>
    80001c52:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c54:	4785                	li	a5,1
    80001c56:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	e9c080e7          	jalr	-356(ra) # 80000af4 <kalloc>
    80001c60:	892a                	mv	s2,a0
    80001c62:	f0a8                	sd	a0,96(s1)
    80001c64:	c131                	beqz	a0,80001ca8 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c66:	8526                	mv	a0,s1
    80001c68:	00000097          	auipc	ra,0x0
    80001c6c:	e5c080e7          	jalr	-420(ra) # 80001ac4 <proc_pagetable>
    80001c70:	892a                	mv	s2,a0
    80001c72:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001c74:	c531                	beqz	a0,80001cc0 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c76:	07000613          	li	a2,112
    80001c7a:	4581                	li	a1,0
    80001c7c:	06848513          	addi	a0,s1,104
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	060080e7          	jalr	96(ra) # 80000ce0 <memset>
  p->context.ra = (uint64)forkret;
    80001c88:	00000797          	auipc	a5,0x0
    80001c8c:	d6078793          	addi	a5,a5,-672 # 800019e8 <forkret>
    80001c90:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c92:	64bc                	ld	a5,72(s1)
    80001c94:	6705                	lui	a4,0x1
    80001c96:	97ba                	add	a5,a5,a4
    80001c98:	f8bc                	sd	a5,112(s1)
}
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	60e2                	ld	ra,24(sp)
    80001c9e:	6442                	ld	s0,16(sp)
    80001ca0:	64a2                	ld	s1,8(sp)
    80001ca2:	6902                	ld	s2,0(sp)
    80001ca4:	6105                	addi	sp,sp,32
    80001ca6:	8082                	ret
    freeproc(p);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	f08080e7          	jalr	-248(ra) # 80001bb2 <freeproc>
    release(&p->lock);
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	fffff097          	auipc	ra,0xfffff
    80001cb8:	fe4080e7          	jalr	-28(ra) # 80000c98 <release>
    return 0;
    80001cbc:	84ca                	mv	s1,s2
    80001cbe:	bff1                	j	80001c9a <allocproc+0x90>
    freeproc(p);
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	00000097          	auipc	ra,0x0
    80001cc6:	ef0080e7          	jalr	-272(ra) # 80001bb2 <freeproc>
    release(&p->lock);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	fcc080e7          	jalr	-52(ra) # 80000c98 <release>
    return 0;
    80001cd4:	84ca                	mv	s1,s2
    80001cd6:	b7d1                	j	80001c9a <allocproc+0x90>

0000000080001cd8 <userinit>:
{
    80001cd8:	1101                	addi	sp,sp,-32
    80001cda:	ec06                	sd	ra,24(sp)
    80001cdc:	e822                	sd	s0,16(sp)
    80001cde:	e426                	sd	s1,8(sp)
    80001ce0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ce2:	00000097          	auipc	ra,0x0
    80001ce6:	f28080e7          	jalr	-216(ra) # 80001c0a <allocproc>
    80001cea:	84aa                	mv	s1,a0
  initproc = p;
    80001cec:	00007797          	auipc	a5,0x7
    80001cf0:	32a7be23          	sd	a0,828(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cf4:	03400613          	li	a2,52
    80001cf8:	00007597          	auipc	a1,0x7
    80001cfc:	c1858593          	addi	a1,a1,-1000 # 80008910 <initcode>
    80001d00:	6d28                	ld	a0,88(a0)
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	666080e7          	jalr	1638(ra) # 80001368 <uvminit>
  p->sz = PGSIZE;
    80001d0a:	6785                	lui	a5,0x1
    80001d0c:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d0e:	70b8                	ld	a4,96(s1)
    80001d10:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d14:	70b8                	ld	a4,96(s1)
    80001d16:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d18:	4641                	li	a2,16
    80001d1a:	00006597          	auipc	a1,0x6
    80001d1e:	4e658593          	addi	a1,a1,1254 # 80008200 <digits+0x1c0>
    80001d22:	16048513          	addi	a0,s1,352
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	10c080e7          	jalr	268(ra) # 80000e32 <safestrcpy>
  p->cwd = namei("/");
    80001d2e:	00006517          	auipc	a0,0x6
    80001d32:	4e250513          	addi	a0,a0,1250 # 80008210 <digits+0x1d0>
    80001d36:	00002097          	auipc	ra,0x2
    80001d3a:	7a2080e7          	jalr	1954(ra) # 800044d8 <namei>
    80001d3e:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001d42:	478d                	li	a5,3
    80001d44:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d46:	8526                	mv	a0,s1
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	f50080e7          	jalr	-176(ra) # 80000c98 <release>
}
    80001d50:	60e2                	ld	ra,24(sp)
    80001d52:	6442                	ld	s0,16(sp)
    80001d54:	64a2                	ld	s1,8(sp)
    80001d56:	6105                	addi	sp,sp,32
    80001d58:	8082                	ret

0000000080001d5a <growproc>:
{
    80001d5a:	1101                	addi	sp,sp,-32
    80001d5c:	ec06                	sd	ra,24(sp)
    80001d5e:	e822                	sd	s0,16(sp)
    80001d60:	e426                	sd	s1,8(sp)
    80001d62:	e04a                	sd	s2,0(sp)
    80001d64:	1000                	addi	s0,sp,32
    80001d66:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d68:	00000097          	auipc	ra,0x0
    80001d6c:	c48080e7          	jalr	-952(ra) # 800019b0 <myproc>
    80001d70:	892a                	mv	s2,a0
  sz = p->sz;
    80001d72:	692c                	ld	a1,80(a0)
    80001d74:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d78:	00904f63          	bgtz	s1,80001d96 <growproc+0x3c>
  } else if(n < 0){
    80001d7c:	0204cc63          	bltz	s1,80001db4 <growproc+0x5a>
  p->sz = sz;
    80001d80:	1602                	slli	a2,a2,0x20
    80001d82:	9201                	srli	a2,a2,0x20
    80001d84:	04c93823          	sd	a2,80(s2)
  return 0;
    80001d88:	4501                	li	a0,0
}
    80001d8a:	60e2                	ld	ra,24(sp)
    80001d8c:	6442                	ld	s0,16(sp)
    80001d8e:	64a2                	ld	s1,8(sp)
    80001d90:	6902                	ld	s2,0(sp)
    80001d92:	6105                	addi	sp,sp,32
    80001d94:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d96:	9e25                	addw	a2,a2,s1
    80001d98:	1602                	slli	a2,a2,0x20
    80001d9a:	9201                	srli	a2,a2,0x20
    80001d9c:	1582                	slli	a1,a1,0x20
    80001d9e:	9181                	srli	a1,a1,0x20
    80001da0:	6d28                	ld	a0,88(a0)
    80001da2:	fffff097          	auipc	ra,0xfffff
    80001da6:	680080e7          	jalr	1664(ra) # 80001422 <uvmalloc>
    80001daa:	0005061b          	sext.w	a2,a0
    80001dae:	fa69                	bnez	a2,80001d80 <growproc+0x26>
      return -1;
    80001db0:	557d                	li	a0,-1
    80001db2:	bfe1                	j	80001d8a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001db4:	9e25                	addw	a2,a2,s1
    80001db6:	1602                	slli	a2,a2,0x20
    80001db8:	9201                	srli	a2,a2,0x20
    80001dba:	1582                	slli	a1,a1,0x20
    80001dbc:	9181                	srli	a1,a1,0x20
    80001dbe:	6d28                	ld	a0,88(a0)
    80001dc0:	fffff097          	auipc	ra,0xfffff
    80001dc4:	61a080e7          	jalr	1562(ra) # 800013da <uvmdealloc>
    80001dc8:	0005061b          	sext.w	a2,a0
    80001dcc:	bf55                	j	80001d80 <growproc+0x26>

0000000080001dce <ps>:
ps(void){
    80001dce:	7119                	addi	sp,sp,-128
    80001dd0:	fc86                	sd	ra,120(sp)
    80001dd2:	f8a2                	sd	s0,112(sp)
    80001dd4:	f4a6                	sd	s1,104(sp)
    80001dd6:	f0ca                	sd	s2,96(sp)
    80001dd8:	ecce                	sd	s3,88(sp)
    80001dda:	e8d2                	sd	s4,80(sp)
    80001ddc:	e4d6                	sd	s5,72(sp)
    80001dde:	e0da                	sd	s6,64(sp)
    80001de0:	fc5e                	sd	s7,56(sp)
    80001de2:	f862                	sd	s8,48(sp)
    80001de4:	f466                	sd	s9,40(sp)
    80001de6:	f06a                	sd	s10,32(sp)
    80001de8:	ec6e                	sd	s11,24(sp)
    80001dea:	0100                	addi	s0,sp,128
  for(p = proc; p < &proc[NPROC]; p++){
    80001dec:	00010497          	auipc	s1,0x10
    80001df0:	8e448493          	addi	s1,s1,-1820 # 800116d0 <proc>
    acquire(&wait_lock);
    80001df4:	0000fa97          	auipc	s5,0xf
    80001df8:	4c4a8a93          	addi	s5,s5,1220 # 800112b8 <wait_lock>
  for(p = proc; p < &proc[NPROC]; p++){
    80001dfc:	00015d97          	auipc	s11,0x15
    80001e00:	4d4d8d93          	addi	s11,s11,1236 # 800172d0 <tickslock>
    80001e04:	a859                	j	80001e9a <ps+0xcc>
      release(&p->lock);
    80001e06:	8526                	mv	a0,s1
    80001e08:	fffff097          	auipc	ra,0xfffff
    80001e0c:	e90080e7          	jalr	-368(ra) # 80000c98 <release>
      continue;
    80001e10:	a049                	j	80001e92 <ps+0xc4>
      acquire(&tickslock);
    80001e12:	00015517          	auipc	a0,0x15
    80001e16:	4be50513          	addi	a0,a0,1214 # 800172d0 <tickslock>
    80001e1a:	fffff097          	auipc	ra,0xfffff
    80001e1e:	dca080e7          	jalr	-566(ra) # 80000be4 <acquire>
      xticks = ticks;
    80001e22:	00007797          	auipc	a5,0x7
    80001e26:	20e78793          	addi	a5,a5,526 # 80009030 <ticks>
    80001e2a:	0007a903          	lw	s2,0(a5)
      release(&tickslock);
    80001e2e:	00015517          	auipc	a0,0x15
    80001e32:	4a250513          	addi	a0,a0,1186 # 800172d0 <tickslock>
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	e62080e7          	jalr	-414(ra) # 80000c98 <release>
      etime = xticks - p->stime;
    80001e3e:	5c9c                	lw	a5,56(s1)
    80001e40:	40f9093b          	subw	s2,s2,a5
    80001e44:	1902                	slli	s2,s2,0x20
    80001e46:	02095913          	srli	s2,s2,0x20
    release(&p->lock);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	fffff097          	auipc	ra,0xfffff
    80001e50:	e4c080e7          	jalr	-436(ra) # 80000c98 <release>
    acquire(&wait_lock);
    80001e54:	8556                	mv	a0,s5
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	d8e080e7          	jalr	-626(ra) # 80000be4 <acquire>
    struct proc * parent = p->parent;
    80001e5e:	60bc                	ld	a5,64(s1)
    ppid = -1;
    80001e60:	59fd                	li	s3,-1
    if(parent){
    80001e62:	c399                	beqz	a5,80001e68 <ps+0x9a>
      ppid = parent->pid;
    80001e64:	0307a983          	lw	s3,48(a5)
    release(&wait_lock);
    80001e68:	8556                	mv	a0,s5
    80001e6a:	fffff097          	auipc	ra,0xfffff
    80001e6e:	e2e080e7          	jalr	-466(ra) # 80000c98 <release>
    printf("pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%d\n",pid,ppid,state,cmd,ctime,stime,etime,sz);
    80001e72:	e06a                	sd	s10,0(sp)
    80001e74:	88ca                	mv	a7,s2
    80001e76:	8852                	mv	a6,s4
    80001e78:	87e6                	mv	a5,s9
    80001e7a:	8762                	mv	a4,s8
    80001e7c:	86de                	mv	a3,s7
    80001e7e:	864e                	mv	a2,s3
    80001e80:	85da                	mv	a1,s6
    80001e82:	00006517          	auipc	a0,0x6
    80001e86:	39650513          	addi	a0,a0,918 # 80008218 <digits+0x1d8>
    80001e8a:	ffffe097          	auipc	ra,0xffffe
    80001e8e:	6fe080e7          	jalr	1790(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001e92:	17048493          	addi	s1,s1,368
    80001e96:	05b48663          	beq	s1,s11,80001ee2 <ps+0x114>
    acquire(&p->lock);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	fffff097          	auipc	ra,0xfffff
    80001ea0:	d48080e7          	jalr	-696(ra) # 80000be4 <acquire>
    if(p->state==UNUSED){
    80001ea4:	4c98                	lw	a4,24(s1)
    80001ea6:	d325                	beqz	a4,80001e06 <ps+0x38>
    pid = p->pid;
    80001ea8:	0304ab03          	lw	s6,48(s1)
    cmd = p->name;
    80001eac:	16048c13          	addi	s8,s1,352
    state =states[p->state];
    80001eb0:	02071793          	slli	a5,a4,0x20
    80001eb4:	9381                	srli	a5,a5,0x20
    80001eb6:	078e                	slli	a5,a5,0x3
    80001eb8:	00006697          	auipc	a3,0x6
    80001ebc:	45868693          	addi	a3,a3,1112 # 80008310 <states.1640>
    80001ec0:	97b6                	add	a5,a5,a3
    80001ec2:	0007bb83          	ld	s7,0(a5)
    sz = p->sz;
    80001ec6:	0504bd03          	ld	s10,80(s1)
    ctime = p->ctime;
    80001eca:	0344ac83          	lw	s9,52(s1)
    stime = p->stime;
    80001ece:	0384aa03          	lw	s4,56(s1)
    if(p->state==ZOMBIE)
    80001ed2:	4795                	li	a5,5
    80001ed4:	f2f71fe3          	bne	a4,a5,80001e12 <ps+0x44>
    etime = p->etime - p->stime;
    80001ed8:	03c4a903          	lw	s2,60(s1)
    80001edc:	4149093b          	subw	s2,s2,s4
    80001ee0:	b7ad                	j	80001e4a <ps+0x7c>
}
    80001ee2:	4501                	li	a0,0
    80001ee4:	70e6                	ld	ra,120(sp)
    80001ee6:	7446                	ld	s0,112(sp)
    80001ee8:	74a6                	ld	s1,104(sp)
    80001eea:	7906                	ld	s2,96(sp)
    80001eec:	69e6                	ld	s3,88(sp)
    80001eee:	6a46                	ld	s4,80(sp)
    80001ef0:	6aa6                	ld	s5,72(sp)
    80001ef2:	6b06                	ld	s6,64(sp)
    80001ef4:	7be2                	ld	s7,56(sp)
    80001ef6:	7c42                	ld	s8,48(sp)
    80001ef8:	7ca2                	ld	s9,40(sp)
    80001efa:	7d02                	ld	s10,32(sp)
    80001efc:	6de2                	ld	s11,24(sp)
    80001efe:	6109                	addi	sp,sp,128
    80001f00:	8082                	ret

0000000080001f02 <pinfo>:
pinfo(int reqpid, uint64 addr){
    80001f02:	7119                	addi	sp,sp,-128
    80001f04:	fc86                	sd	ra,120(sp)
    80001f06:	f8a2                	sd	s0,112(sp)
    80001f08:	f4a6                	sd	s1,104(sp)
    80001f0a:	f0ca                	sd	s2,96(sp)
    80001f0c:	ecce                	sd	s3,88(sp)
    80001f0e:	e8d2                	sd	s4,80(sp)
    80001f10:	e4d6                	sd	s5,72(sp)
    80001f12:	0100                	addi	s0,sp,128
    80001f14:	89aa                	mv	s3,a0
    80001f16:	8a2e                	mv	s4,a1
  struct proc * currproc = myproc();
    80001f18:	00000097          	auipc	ra,0x0
    80001f1c:	a98080e7          	jalr	-1384(ra) # 800019b0 <myproc>
    80001f20:	8aaa                	mv	s5,a0
  if(reqpid==-1){
    80001f22:	57fd                	li	a5,-1
    for(p = proc; p < &proc[NPROC]; p++){
    80001f24:	0000f497          	auipc	s1,0xf
    80001f28:	7ac48493          	addi	s1,s1,1964 # 800116d0 <proc>
    80001f2c:	00015917          	auipc	s2,0x15
    80001f30:	3a490913          	addi	s2,s2,932 # 800172d0 <tickslock>
  if(reqpid==-1){
    80001f34:	02f99163          	bne	s3,a5,80001f56 <pinfo+0x54>
    p = myproc();
    80001f38:	00000097          	auipc	ra,0x0
    80001f3c:	a78080e7          	jalr	-1416(ra) # 800019b0 <myproc>
    80001f40:	84aa                	mv	s1,a0
  if(!flag)
    80001f42:	a80d                	j	80001f74 <pinfo+0x72>
      release(&p->lock);
    80001f44:	8526                	mv	a0,s1
    80001f46:	fffff097          	auipc	ra,0xfffff
    80001f4a:	d52080e7          	jalr	-686(ra) # 80000c98 <release>
    for(p = proc; p < &proc[NPROC]; p++){
    80001f4e:	17048493          	addi	s1,s1,368
    80001f52:	0d248c63          	beq	s1,s2,8000202a <pinfo+0x128>
      acquire(&p->lock);
    80001f56:	8526                	mv	a0,s1
    80001f58:	fffff097          	auipc	ra,0xfffff
    80001f5c:	c8c080e7          	jalr	-884(ra) # 80000be4 <acquire>
      if(p->state!=UNUSED&&p->pid==reqpid){
    80001f60:	4c9c                	lw	a5,24(s1)
    80001f62:	d3ed                	beqz	a5,80001f44 <pinfo+0x42>
    80001f64:	589c                	lw	a5,48(s1)
    80001f66:	fd379fe3          	bne	a5,s3,80001f44 <pinfo+0x42>
        release(&p->lock);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	d2c080e7          	jalr	-724(ra) # 80000c98 <release>
  acquire(&p->lock);
    80001f74:	8926                	mv	s2,s1
    80001f76:	8526                	mv	a0,s1
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	c6c080e7          	jalr	-916(ra) # 80000be4 <acquire>
  procstat.pid = p->pid;
    80001f80:	589c                	lw	a5,48(s1)
    80001f82:	f8f42423          	sw	a5,-120(s0)
  safestrcpy(procstat.command, p->name, sizeof(p->name));
    80001f86:	4641                	li	a2,16
    80001f88:	16048593          	addi	a1,s1,352
    80001f8c:	f9840513          	addi	a0,s0,-104
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	ea2080e7          	jalr	-350(ra) # 80000e32 <safestrcpy>
  safestrcpy(procstat.state, states[p->state], sizeof(states[p->state]));
    80001f98:	0184e783          	lwu	a5,24(s1)
    80001f9c:	00379713          	slli	a4,a5,0x3
    80001fa0:	00006797          	auipc	a5,0x6
    80001fa4:	37078793          	addi	a5,a5,880 # 80008310 <states.1640>
    80001fa8:	97ba                	add	a5,a5,a4
    80001faa:	4621                	li	a2,8
    80001fac:	7b8c                	ld	a1,48(a5)
    80001fae:	f9040513          	addi	a0,s0,-112
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	e80080e7          	jalr	-384(ra) # 80000e32 <safestrcpy>
  procstat.size = p->sz;
    80001fba:	68bc                	ld	a5,80(s1)
    80001fbc:	faf43c23          	sd	a5,-72(s0)
  procstat.ctime = p->ctime;
    80001fc0:	58dc                	lw	a5,52(s1)
    80001fc2:	faf42423          	sw	a5,-88(s0)
  procstat.stime = p->stime;
    80001fc6:	5c9c                	lw	a5,56(s1)
    80001fc8:	faf42623          	sw	a5,-84(s0)
  if(p->state==ZOMBIE)
    80001fcc:	4c94                	lw	a3,24(s1)
    80001fce:	4715                	li	a4,5
    80001fd0:	04e69f63          	bne	a3,a4,8000202e <pinfo+0x12c>
  procstat.etime = p->etime - p->stime;
    80001fd4:	5cd8                	lw	a4,60(s1)
    80001fd6:	40f707bb          	subw	a5,a4,a5
    80001fda:	faf42823          	sw	a5,-80(s0)
  release(&p->lock);
    80001fde:	854a                	mv	a0,s2
    80001fe0:	fffff097          	auipc	ra,0xfffff
    80001fe4:	cb8080e7          	jalr	-840(ra) # 80000c98 <release>
  acquire(&wait_lock);
    80001fe8:	0000f517          	auipc	a0,0xf
    80001fec:	2d050513          	addi	a0,a0,720 # 800112b8 <wait_lock>
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	bf4080e7          	jalr	-1036(ra) # 80000be4 <acquire>
  struct proc * parent = p->parent;
    80001ff8:	60bc                	ld	a5,64(s1)
  if(parent){
    80001ffa:	c7a5                	beqz	a5,80002062 <pinfo+0x160>
    procstat.ppid = parent->pid;
    80001ffc:	5b9c                	lw	a5,48(a5)
    80001ffe:	f8f42623          	sw	a5,-116(s0)
  release(&wait_lock);
    80002002:	0000f517          	auipc	a0,0xf
    80002006:	2b650513          	addi	a0,a0,694 # 800112b8 <wait_lock>
    8000200a:	fffff097          	auipc	ra,0xfffff
    8000200e:	c8e080e7          	jalr	-882(ra) # 80000c98 <release>
  return 0;
    80002012:	4501                	li	a0,0
  if(addr != 0 && copyout(currproc->pagetable, addr, (char *)&procstat, sizeof(procstat)) < 0){
    80002014:	040a1b63          	bnez	s4,8000206a <pinfo+0x168>
}
    80002018:	70e6                	ld	ra,120(sp)
    8000201a:	7446                	ld	s0,112(sp)
    8000201c:	74a6                	ld	s1,104(sp)
    8000201e:	7906                	ld	s2,96(sp)
    80002020:	69e6                	ld	s3,88(sp)
    80002022:	6a46                	ld	s4,80(sp)
    80002024:	6aa6                	ld	s5,72(sp)
    80002026:	6109                	addi	sp,sp,128
    80002028:	8082                	ret
  return -1;
    8000202a:	557d                	li	a0,-1
    8000202c:	b7f5                	j	80002018 <pinfo+0x116>
    acquire(&tickslock);
    8000202e:	00015517          	auipc	a0,0x15
    80002032:	2a250513          	addi	a0,a0,674 # 800172d0 <tickslock>
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	bae080e7          	jalr	-1106(ra) # 80000be4 <acquire>
    xticks = ticks;
    8000203e:	00007997          	auipc	s3,0x7
    80002042:	ff29a983          	lw	s3,-14(s3) # 80009030 <ticks>
    release(&tickslock);
    80002046:	00015517          	auipc	a0,0x15
    8000204a:	28a50513          	addi	a0,a0,650 # 800172d0 <tickslock>
    8000204e:	fffff097          	auipc	ra,0xfffff
    80002052:	c4a080e7          	jalr	-950(ra) # 80000c98 <release>
    procstat.etime = xticks - p->stime;
    80002056:	5c9c                	lw	a5,56(s1)
    80002058:	40f989bb          	subw	s3,s3,a5
    8000205c:	fb342823          	sw	s3,-80(s0)
    80002060:	bfbd                	j	80001fde <pinfo+0xdc>
  procstat.ppid = -1;
    80002062:	57fd                	li	a5,-1
    80002064:	f8f42623          	sw	a5,-116(s0)
    80002068:	bf69                	j	80002002 <pinfo+0x100>
  if(addr != 0 && copyout(currproc->pagetable, addr, (char *)&procstat, sizeof(procstat)) < 0){
    8000206a:	03800693          	li	a3,56
    8000206e:	f8840613          	addi	a2,s0,-120
    80002072:	85d2                	mv	a1,s4
    80002074:	058ab503          	ld	a0,88(s5)
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	5fa080e7          	jalr	1530(ra) # 80001672 <copyout>
    80002080:	41f5551b          	sraiw	a0,a0,0x1f
    80002084:	bf51                	j	80002018 <pinfo+0x116>

0000000080002086 <fork>:
{
    80002086:	7179                	addi	sp,sp,-48
    80002088:	f406                	sd	ra,40(sp)
    8000208a:	f022                	sd	s0,32(sp)
    8000208c:	ec26                	sd	s1,24(sp)
    8000208e:	e84a                	sd	s2,16(sp)
    80002090:	e44e                	sd	s3,8(sp)
    80002092:	e052                	sd	s4,0(sp)
    80002094:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	91a080e7          	jalr	-1766(ra) # 800019b0 <myproc>
    8000209e:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	b6a080e7          	jalr	-1174(ra) # 80001c0a <allocproc>
    800020a8:	14050163          	beqz	a0,800021ea <fork+0x164>
    800020ac:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800020ae:	05093603          	ld	a2,80(s2)
    800020b2:	6d2c                	ld	a1,88(a0)
    800020b4:	05893503          	ld	a0,88(s2)
    800020b8:	fffff097          	auipc	ra,0xfffff
    800020bc:	4b6080e7          	jalr	1206(ra) # 8000156e <uvmcopy>
    800020c0:	04054663          	bltz	a0,8000210c <fork+0x86>
  np->sz = p->sz;
    800020c4:	05093783          	ld	a5,80(s2)
    800020c8:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    800020cc:	06093683          	ld	a3,96(s2)
    800020d0:	87b6                	mv	a5,a3
    800020d2:	0609b703          	ld	a4,96(s3)
    800020d6:	12068693          	addi	a3,a3,288
    800020da:	0007b803          	ld	a6,0(a5)
    800020de:	6788                	ld	a0,8(a5)
    800020e0:	6b8c                	ld	a1,16(a5)
    800020e2:	6f90                	ld	a2,24(a5)
    800020e4:	01073023          	sd	a6,0(a4)
    800020e8:	e708                	sd	a0,8(a4)
    800020ea:	eb0c                	sd	a1,16(a4)
    800020ec:	ef10                	sd	a2,24(a4)
    800020ee:	02078793          	addi	a5,a5,32
    800020f2:	02070713          	addi	a4,a4,32
    800020f6:	fed792e3          	bne	a5,a3,800020da <fork+0x54>
  np->trapframe->a0 = 0;
    800020fa:	0609b783          	ld	a5,96(s3)
    800020fe:	0607b823          	sd	zero,112(a5)
    80002102:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80002106:	15800a13          	li	s4,344
    8000210a:	a03d                	j	80002138 <fork+0xb2>
    freeproc(np);
    8000210c:	854e                	mv	a0,s3
    8000210e:	00000097          	auipc	ra,0x0
    80002112:	aa4080e7          	jalr	-1372(ra) # 80001bb2 <freeproc>
    release(&np->lock);
    80002116:	854e                	mv	a0,s3
    80002118:	fffff097          	auipc	ra,0xfffff
    8000211c:	b80080e7          	jalr	-1152(ra) # 80000c98 <release>
    return -1;
    80002120:	5a7d                	li	s4,-1
    80002122:	a85d                	j	800021d8 <fork+0x152>
      np->ofile[i] = filedup(p->ofile[i]);
    80002124:	00003097          	auipc	ra,0x3
    80002128:	a4a080e7          	jalr	-1462(ra) # 80004b6e <filedup>
    8000212c:	009987b3          	add	a5,s3,s1
    80002130:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002132:	04a1                	addi	s1,s1,8
    80002134:	01448763          	beq	s1,s4,80002142 <fork+0xbc>
    if(p->ofile[i])
    80002138:	009907b3          	add	a5,s2,s1
    8000213c:	6388                	ld	a0,0(a5)
    8000213e:	f17d                	bnez	a0,80002124 <fork+0x9e>
    80002140:	bfcd                	j	80002132 <fork+0xac>
  np->cwd = idup(p->cwd);
    80002142:	15893503          	ld	a0,344(s2)
    80002146:	00002097          	auipc	ra,0x2
    8000214a:	b9e080e7          	jalr	-1122(ra) # 80003ce4 <idup>
    8000214e:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002152:	4641                	li	a2,16
    80002154:	16090593          	addi	a1,s2,352
    80002158:	16098513          	addi	a0,s3,352
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	cd6080e7          	jalr	-810(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    80002164:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80002168:	854e                	mv	a0,s3
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	b2e080e7          	jalr	-1234(ra) # 80000c98 <release>
  acquire(&wait_lock);
    80002172:	0000f497          	auipc	s1,0xf
    80002176:	14648493          	addi	s1,s1,326 # 800112b8 <wait_lock>
    8000217a:	8526                	mv	a0,s1
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	a68080e7          	jalr	-1432(ra) # 80000be4 <acquire>
  np->parent = p;
    80002184:	0529b023          	sd	s2,64(s3)
  release(&wait_lock);
    80002188:	8526                	mv	a0,s1
    8000218a:	fffff097          	auipc	ra,0xfffff
    8000218e:	b0e080e7          	jalr	-1266(ra) # 80000c98 <release>
  acquire(&tickslock);
    80002192:	00015517          	auipc	a0,0x15
    80002196:	13e50513          	addi	a0,a0,318 # 800172d0 <tickslock>
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	a4a080e7          	jalr	-1462(ra) # 80000be4 <acquire>
  xticks = ticks;
    800021a2:	00007497          	auipc	s1,0x7
    800021a6:	e8e4a483          	lw	s1,-370(s1) # 80009030 <ticks>
  release(&tickslock);
    800021aa:	00015517          	auipc	a0,0x15
    800021ae:	12650513          	addi	a0,a0,294 # 800172d0 <tickslock>
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	ae6080e7          	jalr	-1306(ra) # 80000c98 <release>
  acquire(&np->lock);
    800021ba:	854e                	mv	a0,s3
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	a28080e7          	jalr	-1496(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    800021c4:	478d                	li	a5,3
    800021c6:	00f9ac23          	sw	a5,24(s3)
  np->ctime = xticks;
    800021ca:	0299aa23          	sw	s1,52(s3)
  release(&np->lock);
    800021ce:	854e                	mv	a0,s3
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	ac8080e7          	jalr	-1336(ra) # 80000c98 <release>
}
    800021d8:	8552                	mv	a0,s4
    800021da:	70a2                	ld	ra,40(sp)
    800021dc:	7402                	ld	s0,32(sp)
    800021de:	64e2                	ld	s1,24(sp)
    800021e0:	6942                	ld	s2,16(sp)
    800021e2:	69a2                	ld	s3,8(sp)
    800021e4:	6a02                	ld	s4,0(sp)
    800021e6:	6145                	addi	sp,sp,48
    800021e8:	8082                	ret
    return -1;
    800021ea:	5a7d                	li	s4,-1
    800021ec:	b7f5                	j	800021d8 <fork+0x152>

00000000800021ee <forkf>:
{
    800021ee:	7179                	addi	sp,sp,-48
    800021f0:	f406                	sd	ra,40(sp)
    800021f2:	f022                	sd	s0,32(sp)
    800021f4:	ec26                	sd	s1,24(sp)
    800021f6:	e84a                	sd	s2,16(sp)
    800021f8:	e44e                	sd	s3,8(sp)
    800021fa:	e052                	sd	s4,0(sp)
    800021fc:	1800                	addi	s0,sp,48
    800021fe:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002200:	fffff097          	auipc	ra,0xfffff
    80002204:	7b0080e7          	jalr	1968(ra) # 800019b0 <myproc>
    80002208:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	a00080e7          	jalr	-1536(ra) # 80001c0a <allocproc>
    80002212:	12050063          	beqz	a0,80002332 <forkf+0x144>
    80002216:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002218:	05093603          	ld	a2,80(s2)
    8000221c:	6d2c                	ld	a1,88(a0)
    8000221e:	05893503          	ld	a0,88(s2)
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	34c080e7          	jalr	844(ra) # 8000156e <uvmcopy>
    8000222a:	04054b63          	bltz	a0,80002280 <forkf+0x92>
  np->sz = p->sz;
    8000222e:	05093783          	ld	a5,80(s2)
    80002232:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80002236:	06093683          	ld	a3,96(s2)
    8000223a:	87b6                	mv	a5,a3
    8000223c:	0609b703          	ld	a4,96(s3)
    80002240:	12068693          	addi	a3,a3,288
    80002244:	0007b883          	ld	a7,0(a5)
    80002248:	0087b803          	ld	a6,8(a5)
    8000224c:	6b8c                	ld	a1,16(a5)
    8000224e:	6f90                	ld	a2,24(a5)
    80002250:	01173023          	sd	a7,0(a4)
    80002254:	01073423          	sd	a6,8(a4)
    80002258:	eb0c                	sd	a1,16(a4)
    8000225a:	ef10                	sd	a2,24(a4)
    8000225c:	02078793          	addi	a5,a5,32
    80002260:	02070713          	addi	a4,a4,32
    80002264:	fed790e3          	bne	a5,a3,80002244 <forkf+0x56>
  np->trapframe->a0 = 0;
    80002268:	0609b783          	ld	a5,96(s3)
    8000226c:	0607b823          	sd	zero,112(a5)
  np->trapframe->epc = addr;
    80002270:	0609b783          	ld	a5,96(s3)
    80002274:	ef84                	sd	s1,24(a5)
    80002276:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    8000227a:	15800a13          	li	s4,344
    8000227e:	a03d                	j	800022ac <forkf+0xbe>
    freeproc(np);
    80002280:	854e                	mv	a0,s3
    80002282:	00000097          	auipc	ra,0x0
    80002286:	930080e7          	jalr	-1744(ra) # 80001bb2 <freeproc>
    release(&np->lock);
    8000228a:	854e                	mv	a0,s3
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	a0c080e7          	jalr	-1524(ra) # 80000c98 <release>
    return -1;
    80002294:	5a7d                	li	s4,-1
    80002296:	a069                	j	80002320 <forkf+0x132>
      np->ofile[i] = filedup(p->ofile[i]);
    80002298:	00003097          	auipc	ra,0x3
    8000229c:	8d6080e7          	jalr	-1834(ra) # 80004b6e <filedup>
    800022a0:	009987b3          	add	a5,s3,s1
    800022a4:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    800022a6:	04a1                	addi	s1,s1,8
    800022a8:	01448763          	beq	s1,s4,800022b6 <forkf+0xc8>
    if(p->ofile[i])
    800022ac:	009907b3          	add	a5,s2,s1
    800022b0:	6388                	ld	a0,0(a5)
    800022b2:	f17d                	bnez	a0,80002298 <forkf+0xaa>
    800022b4:	bfcd                	j	800022a6 <forkf+0xb8>
  np->cwd = idup(p->cwd);
    800022b6:	15893503          	ld	a0,344(s2)
    800022ba:	00002097          	auipc	ra,0x2
    800022be:	a2a080e7          	jalr	-1494(ra) # 80003ce4 <idup>
    800022c2:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800022c6:	4641                	li	a2,16
    800022c8:	16090593          	addi	a1,s2,352
    800022cc:	16098513          	addi	a0,s3,352
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	b62080e7          	jalr	-1182(ra) # 80000e32 <safestrcpy>
  pid = np->pid;
    800022d8:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    800022dc:	854e                	mv	a0,s3
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	9ba080e7          	jalr	-1606(ra) # 80000c98 <release>
  acquire(&wait_lock);
    800022e6:	0000f497          	auipc	s1,0xf
    800022ea:	fd248493          	addi	s1,s1,-46 # 800112b8 <wait_lock>
    800022ee:	8526                	mv	a0,s1
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	8f4080e7          	jalr	-1804(ra) # 80000be4 <acquire>
  np->parent = p;
    800022f8:	0529b023          	sd	s2,64(s3)
  release(&wait_lock);
    800022fc:	8526                	mv	a0,s1
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	99a080e7          	jalr	-1638(ra) # 80000c98 <release>
  acquire(&np->lock);
    80002306:	854e                	mv	a0,s3
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	8dc080e7          	jalr	-1828(ra) # 80000be4 <acquire>
  np->state = RUNNABLE;
    80002310:	478d                	li	a5,3
    80002312:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80002316:	854e                	mv	a0,s3
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	980080e7          	jalr	-1664(ra) # 80000c98 <release>
}
    80002320:	8552                	mv	a0,s4
    80002322:	70a2                	ld	ra,40(sp)
    80002324:	7402                	ld	s0,32(sp)
    80002326:	64e2                	ld	s1,24(sp)
    80002328:	6942                	ld	s2,16(sp)
    8000232a:	69a2                	ld	s3,8(sp)
    8000232c:	6a02                	ld	s4,0(sp)
    8000232e:	6145                	addi	sp,sp,48
    80002330:	8082                	ret
    return -1;
    80002332:	5a7d                	li	s4,-1
    80002334:	b7f5                	j	80002320 <forkf+0x132>

0000000080002336 <scheduler>:
{
    80002336:	7139                	addi	sp,sp,-64
    80002338:	fc06                	sd	ra,56(sp)
    8000233a:	f822                	sd	s0,48(sp)
    8000233c:	f426                	sd	s1,40(sp)
    8000233e:	f04a                	sd	s2,32(sp)
    80002340:	ec4e                	sd	s3,24(sp)
    80002342:	e852                	sd	s4,16(sp)
    80002344:	e456                	sd	s5,8(sp)
    80002346:	e05a                	sd	s6,0(sp)
    80002348:	0080                	addi	s0,sp,64
    8000234a:	8792                	mv	a5,tp
  int id = r_tp();
    8000234c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000234e:	00779a93          	slli	s5,a5,0x7
    80002352:	0000f717          	auipc	a4,0xf
    80002356:	f4e70713          	addi	a4,a4,-178 # 800112a0 <pid_lock>
    8000235a:	9756                	add	a4,a4,s5
    8000235c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002360:	0000f717          	auipc	a4,0xf
    80002364:	f7870713          	addi	a4,a4,-136 # 800112d8 <cpus+0x8>
    80002368:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    8000236a:	498d                	li	s3,3
        p->state = RUNNING;
    8000236c:	4b11                	li	s6,4
        c->proc = p;
    8000236e:	079e                	slli	a5,a5,0x7
    80002370:	0000fa17          	auipc	s4,0xf
    80002374:	f30a0a13          	addi	s4,s4,-208 # 800112a0 <pid_lock>
    80002378:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000237a:	00015917          	auipc	s2,0x15
    8000237e:	f5690913          	addi	s2,s2,-170 # 800172d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002382:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002386:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000238a:	10079073          	csrw	sstatus,a5
    8000238e:	0000f497          	auipc	s1,0xf
    80002392:	34248493          	addi	s1,s1,834 # 800116d0 <proc>
    80002396:	a03d                	j	800023c4 <scheduler+0x8e>
        p->state = RUNNING;
    80002398:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000239c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800023a0:	06848593          	addi	a1,s1,104
    800023a4:	8556                	mv	a0,s5
    800023a6:	00000097          	auipc	ra,0x0
    800023aa:	79e080e7          	jalr	1950(ra) # 80002b44 <swtch>
        c->proc = 0;
    800023ae:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    800023b2:	8526                	mv	a0,s1
    800023b4:	fffff097          	auipc	ra,0xfffff
    800023b8:	8e4080e7          	jalr	-1820(ra) # 80000c98 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800023bc:	17048493          	addi	s1,s1,368
    800023c0:	fd2481e3          	beq	s1,s2,80002382 <scheduler+0x4c>
      acquire(&p->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	81e080e7          	jalr	-2018(ra) # 80000be4 <acquire>
      if(p->state == RUNNABLE) {
    800023ce:	4c9c                	lw	a5,24(s1)
    800023d0:	ff3791e3          	bne	a5,s3,800023b2 <scheduler+0x7c>
    800023d4:	b7d1                	j	80002398 <scheduler+0x62>

00000000800023d6 <sched>:
{
    800023d6:	7179                	addi	sp,sp,-48
    800023d8:	f406                	sd	ra,40(sp)
    800023da:	f022                	sd	s0,32(sp)
    800023dc:	ec26                	sd	s1,24(sp)
    800023de:	e84a                	sd	s2,16(sp)
    800023e0:	e44e                	sd	s3,8(sp)
    800023e2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	5cc080e7          	jalr	1484(ra) # 800019b0 <myproc>
    800023ec:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800023ee:	ffffe097          	auipc	ra,0xffffe
    800023f2:	77c080e7          	jalr	1916(ra) # 80000b6a <holding>
    800023f6:	c93d                	beqz	a0,8000246c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023f8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023fa:	2781                	sext.w	a5,a5
    800023fc:	079e                	slli	a5,a5,0x7
    800023fe:	0000f717          	auipc	a4,0xf
    80002402:	ea270713          	addi	a4,a4,-350 # 800112a0 <pid_lock>
    80002406:	97ba                	add	a5,a5,a4
    80002408:	0a87a703          	lw	a4,168(a5)
    8000240c:	4785                	li	a5,1
    8000240e:	06f71763          	bne	a4,a5,8000247c <sched+0xa6>
  if(p->state == RUNNING)
    80002412:	4c98                	lw	a4,24(s1)
    80002414:	4791                	li	a5,4
    80002416:	06f70b63          	beq	a4,a5,8000248c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000241a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000241e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002420:	efb5                	bnez	a5,8000249c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002422:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002424:	0000f917          	auipc	s2,0xf
    80002428:	e7c90913          	addi	s2,s2,-388 # 800112a0 <pid_lock>
    8000242c:	2781                	sext.w	a5,a5
    8000242e:	079e                	slli	a5,a5,0x7
    80002430:	97ca                	add	a5,a5,s2
    80002432:	0ac7a983          	lw	s3,172(a5)
    80002436:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002438:	2781                	sext.w	a5,a5
    8000243a:	079e                	slli	a5,a5,0x7
    8000243c:	0000f597          	auipc	a1,0xf
    80002440:	e9c58593          	addi	a1,a1,-356 # 800112d8 <cpus+0x8>
    80002444:	95be                	add	a1,a1,a5
    80002446:	06848513          	addi	a0,s1,104
    8000244a:	00000097          	auipc	ra,0x0
    8000244e:	6fa080e7          	jalr	1786(ra) # 80002b44 <swtch>
    80002452:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002454:	2781                	sext.w	a5,a5
    80002456:	079e                	slli	a5,a5,0x7
    80002458:	97ca                	add	a5,a5,s2
    8000245a:	0b37a623          	sw	s3,172(a5)
}
    8000245e:	70a2                	ld	ra,40(sp)
    80002460:	7402                	ld	s0,32(sp)
    80002462:	64e2                	ld	s1,24(sp)
    80002464:	6942                	ld	s2,16(sp)
    80002466:	69a2                	ld	s3,8(sp)
    80002468:	6145                	addi	sp,sp,48
    8000246a:	8082                	ret
    panic("sched p->lock");
    8000246c:	00006517          	auipc	a0,0x6
    80002470:	dfc50513          	addi	a0,a0,-516 # 80008268 <digits+0x228>
    80002474:	ffffe097          	auipc	ra,0xffffe
    80002478:	0ca080e7          	jalr	202(ra) # 8000053e <panic>
    panic("sched locks");
    8000247c:	00006517          	auipc	a0,0x6
    80002480:	dfc50513          	addi	a0,a0,-516 # 80008278 <digits+0x238>
    80002484:	ffffe097          	auipc	ra,0xffffe
    80002488:	0ba080e7          	jalr	186(ra) # 8000053e <panic>
    panic("sched running");
    8000248c:	00006517          	auipc	a0,0x6
    80002490:	dfc50513          	addi	a0,a0,-516 # 80008288 <digits+0x248>
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	0aa080e7          	jalr	170(ra) # 8000053e <panic>
    panic("sched interruptible");
    8000249c:	00006517          	auipc	a0,0x6
    800024a0:	dfc50513          	addi	a0,a0,-516 # 80008298 <digits+0x258>
    800024a4:	ffffe097          	auipc	ra,0xffffe
    800024a8:	09a080e7          	jalr	154(ra) # 8000053e <panic>

00000000800024ac <yield>:
{
    800024ac:	1101                	addi	sp,sp,-32
    800024ae:	ec06                	sd	ra,24(sp)
    800024b0:	e822                	sd	s0,16(sp)
    800024b2:	e426                	sd	s1,8(sp)
    800024b4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	4fa080e7          	jalr	1274(ra) # 800019b0 <myproc>
    800024be:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	724080e7          	jalr	1828(ra) # 80000be4 <acquire>
  p->state = RUNNABLE;
    800024c8:	478d                	li	a5,3
    800024ca:	cc9c                	sw	a5,24(s1)
  sched();
    800024cc:	00000097          	auipc	ra,0x0
    800024d0:	f0a080e7          	jalr	-246(ra) # 800023d6 <sched>
  release(&p->lock);
    800024d4:	8526                	mv	a0,s1
    800024d6:	ffffe097          	auipc	ra,0xffffe
    800024da:	7c2080e7          	jalr	1986(ra) # 80000c98 <release>
}
    800024de:	60e2                	ld	ra,24(sp)
    800024e0:	6442                	ld	s0,16(sp)
    800024e2:	64a2                	ld	s1,8(sp)
    800024e4:	6105                	addi	sp,sp,32
    800024e6:	8082                	ret

00000000800024e8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800024e8:	7179                	addi	sp,sp,-48
    800024ea:	f406                	sd	ra,40(sp)
    800024ec:	f022                	sd	s0,32(sp)
    800024ee:	ec26                	sd	s1,24(sp)
    800024f0:	e84a                	sd	s2,16(sp)
    800024f2:	e44e                	sd	s3,8(sp)
    800024f4:	1800                	addi	s0,sp,48
    800024f6:	89aa                	mv	s3,a0
    800024f8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	4b6080e7          	jalr	1206(ra) # 800019b0 <myproc>
    80002502:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002504:	ffffe097          	auipc	ra,0xffffe
    80002508:	6e0080e7          	jalr	1760(ra) # 80000be4 <acquire>
  release(lk);
    8000250c:	854a                	mv	a0,s2
    8000250e:	ffffe097          	auipc	ra,0xffffe
    80002512:	78a080e7          	jalr	1930(ra) # 80000c98 <release>

  // Go to sleep.
  p->chan = chan;
    80002516:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000251a:	4789                	li	a5,2
    8000251c:	cc9c                	sw	a5,24(s1)

  sched();
    8000251e:	00000097          	auipc	ra,0x0
    80002522:	eb8080e7          	jalr	-328(ra) # 800023d6 <sched>

  // Tidy up.
  p->chan = 0;
    80002526:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000252a:	8526                	mv	a0,s1
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	76c080e7          	jalr	1900(ra) # 80000c98 <release>
  acquire(lk);
    80002534:	854a                	mv	a0,s2
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	6ae080e7          	jalr	1710(ra) # 80000be4 <acquire>
}
    8000253e:	70a2                	ld	ra,40(sp)
    80002540:	7402                	ld	s0,32(sp)
    80002542:	64e2                	ld	s1,24(sp)
    80002544:	6942                	ld	s2,16(sp)
    80002546:	69a2                	ld	s3,8(sp)
    80002548:	6145                	addi	sp,sp,48
    8000254a:	8082                	ret

000000008000254c <wait>:
{
    8000254c:	715d                	addi	sp,sp,-80
    8000254e:	e486                	sd	ra,72(sp)
    80002550:	e0a2                	sd	s0,64(sp)
    80002552:	fc26                	sd	s1,56(sp)
    80002554:	f84a                	sd	s2,48(sp)
    80002556:	f44e                	sd	s3,40(sp)
    80002558:	f052                	sd	s4,32(sp)
    8000255a:	ec56                	sd	s5,24(sp)
    8000255c:	e85a                	sd	s6,16(sp)
    8000255e:	e45e                	sd	s7,8(sp)
    80002560:	e062                	sd	s8,0(sp)
    80002562:	0880                	addi	s0,sp,80
    80002564:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002566:	fffff097          	auipc	ra,0xfffff
    8000256a:	44a080e7          	jalr	1098(ra) # 800019b0 <myproc>
    8000256e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002570:	0000f517          	auipc	a0,0xf
    80002574:	d4850513          	addi	a0,a0,-696 # 800112b8 <wait_lock>
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	66c080e7          	jalr	1644(ra) # 80000be4 <acquire>
    havekids = 0;
    80002580:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002582:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002584:	00015997          	auipc	s3,0x15
    80002588:	d4c98993          	addi	s3,s3,-692 # 800172d0 <tickslock>
        havekids = 1;
    8000258c:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000258e:	0000fc17          	auipc	s8,0xf
    80002592:	d2ac0c13          	addi	s8,s8,-726 # 800112b8 <wait_lock>
    havekids = 0;
    80002596:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002598:	0000f497          	auipc	s1,0xf
    8000259c:	13848493          	addi	s1,s1,312 # 800116d0 <proc>
    800025a0:	a0bd                	j	8000260e <wait+0xc2>
          pid = np->pid;
    800025a2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800025a6:	000b0e63          	beqz	s6,800025c2 <wait+0x76>
    800025aa:	4691                	li	a3,4
    800025ac:	02c48613          	addi	a2,s1,44
    800025b0:	85da                	mv	a1,s6
    800025b2:	05893503          	ld	a0,88(s2)
    800025b6:	fffff097          	auipc	ra,0xfffff
    800025ba:	0bc080e7          	jalr	188(ra) # 80001672 <copyout>
    800025be:	02054563          	bltz	a0,800025e8 <wait+0x9c>
          freeproc(np);
    800025c2:	8526                	mv	a0,s1
    800025c4:	fffff097          	auipc	ra,0xfffff
    800025c8:	5ee080e7          	jalr	1518(ra) # 80001bb2 <freeproc>
          release(&np->lock);
    800025cc:	8526                	mv	a0,s1
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	6ca080e7          	jalr	1738(ra) # 80000c98 <release>
          release(&wait_lock);
    800025d6:	0000f517          	auipc	a0,0xf
    800025da:	ce250513          	addi	a0,a0,-798 # 800112b8 <wait_lock>
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	6ba080e7          	jalr	1722(ra) # 80000c98 <release>
          return pid;
    800025e6:	a09d                	j	8000264c <wait+0x100>
            release(&np->lock);
    800025e8:	8526                	mv	a0,s1
    800025ea:	ffffe097          	auipc	ra,0xffffe
    800025ee:	6ae080e7          	jalr	1710(ra) # 80000c98 <release>
            release(&wait_lock);
    800025f2:	0000f517          	auipc	a0,0xf
    800025f6:	cc650513          	addi	a0,a0,-826 # 800112b8 <wait_lock>
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	69e080e7          	jalr	1694(ra) # 80000c98 <release>
            return -1;
    80002602:	59fd                	li	s3,-1
    80002604:	a0a1                	j	8000264c <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002606:	17048493          	addi	s1,s1,368
    8000260a:	03348463          	beq	s1,s3,80002632 <wait+0xe6>
      if(np->parent == p){
    8000260e:	60bc                	ld	a5,64(s1)
    80002610:	ff279be3          	bne	a5,s2,80002606 <wait+0xba>
        acquire(&np->lock);
    80002614:	8526                	mv	a0,s1
    80002616:	ffffe097          	auipc	ra,0xffffe
    8000261a:	5ce080e7          	jalr	1486(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    8000261e:	4c9c                	lw	a5,24(s1)
    80002620:	f94781e3          	beq	a5,s4,800025a2 <wait+0x56>
        release(&np->lock);
    80002624:	8526                	mv	a0,s1
    80002626:	ffffe097          	auipc	ra,0xffffe
    8000262a:	672080e7          	jalr	1650(ra) # 80000c98 <release>
        havekids = 1;
    8000262e:	8756                	mv	a4,s5
    80002630:	bfd9                	j	80002606 <wait+0xba>
    if(!havekids || p->killed){
    80002632:	c701                	beqz	a4,8000263a <wait+0xee>
    80002634:	02892783          	lw	a5,40(s2)
    80002638:	c79d                	beqz	a5,80002666 <wait+0x11a>
      release(&wait_lock);
    8000263a:	0000f517          	auipc	a0,0xf
    8000263e:	c7e50513          	addi	a0,a0,-898 # 800112b8 <wait_lock>
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	656080e7          	jalr	1622(ra) # 80000c98 <release>
      return -1;
    8000264a:	59fd                	li	s3,-1
}
    8000264c:	854e                	mv	a0,s3
    8000264e:	60a6                	ld	ra,72(sp)
    80002650:	6406                	ld	s0,64(sp)
    80002652:	74e2                	ld	s1,56(sp)
    80002654:	7942                	ld	s2,48(sp)
    80002656:	79a2                	ld	s3,40(sp)
    80002658:	7a02                	ld	s4,32(sp)
    8000265a:	6ae2                	ld	s5,24(sp)
    8000265c:	6b42                	ld	s6,16(sp)
    8000265e:	6ba2                	ld	s7,8(sp)
    80002660:	6c02                	ld	s8,0(sp)
    80002662:	6161                	addi	sp,sp,80
    80002664:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002666:	85e2                	mv	a1,s8
    80002668:	854a                	mv	a0,s2
    8000266a:	00000097          	auipc	ra,0x0
    8000266e:	e7e080e7          	jalr	-386(ra) # 800024e8 <sleep>
    havekids = 0;
    80002672:	b715                	j	80002596 <wait+0x4a>

0000000080002674 <waitpid>:
{
    80002674:	711d                	addi	sp,sp,-96
    80002676:	ec86                	sd	ra,88(sp)
    80002678:	e8a2                	sd	s0,80(sp)
    8000267a:	e4a6                	sd	s1,72(sp)
    8000267c:	e0ca                	sd	s2,64(sp)
    8000267e:	fc4e                	sd	s3,56(sp)
    80002680:	f852                	sd	s4,48(sp)
    80002682:	f456                	sd	s5,40(sp)
    80002684:	f05a                	sd	s6,32(sp)
    80002686:	ec5e                	sd	s7,24(sp)
    80002688:	e862                	sd	s8,16(sp)
    8000268a:	e466                	sd	s9,8(sp)
    8000268c:	1080                	addi	s0,sp,96
    8000268e:	8a2a                	mv	s4,a0
    80002690:	8bae                	mv	s7,a1
  struct proc *p = myproc();
    80002692:	fffff097          	auipc	ra,0xfffff
    80002696:	31e080e7          	jalr	798(ra) # 800019b0 <myproc>
    8000269a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000269c:	0000f517          	auipc	a0,0xf
    800026a0:	c1c50513          	addi	a0,a0,-996 # 800112b8 <wait_lock>
    800026a4:	ffffe097          	auipc	ra,0xffffe
    800026a8:	540080e7          	jalr	1344(ra) # 80000be4 <acquire>
    havekids = 0;
    800026ac:	4c01                	li	s8,0
        if(np->state == ZOMBIE){
    800026ae:	4a95                	li	s5,5
    for(np = proc; np < &proc[NPROC]; np++){
    800026b0:	00015997          	auipc	s3,0x15
    800026b4:	c2098993          	addi	s3,s3,-992 # 800172d0 <tickslock>
        havekids = 1;
    800026b8:	4b05                	li	s6,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026ba:	0000fc97          	auipc	s9,0xf
    800026be:	bfec8c93          	addi	s9,s9,-1026 # 800112b8 <wait_lock>
    havekids = 0;
    800026c2:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    800026c4:	0000f497          	auipc	s1,0xf
    800026c8:	00c48493          	addi	s1,s1,12 # 800116d0 <proc>
    800026cc:	a815                	j	80002700 <waitpid+0x8c>
            release(&np->lock);
    800026ce:	8526                	mv	a0,s1
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	5c8080e7          	jalr	1480(ra) # 80000c98 <release>
            release(&wait_lock);
    800026d8:	0000f517          	auipc	a0,0xf
    800026dc:	be050513          	addi	a0,a0,-1056 # 800112b8 <wait_lock>
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	5b8080e7          	jalr	1464(ra) # 80000c98 <release>
            return -1;
    800026e8:	59fd                	li	s3,-1
    800026ea:	a849                	j	8000277c <waitpid+0x108>
        release(&np->lock);
    800026ec:	8526                	mv	a0,s1
    800026ee:	ffffe097          	auipc	ra,0xffffe
    800026f2:	5aa080e7          	jalr	1450(ra) # 80000c98 <release>
        havekids = 1;
    800026f6:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    800026f8:	17048493          	addi	s1,s1,368
    800026fc:	07348363          	beq	s1,s3,80002762 <waitpid+0xee>
      if(np->parent == p && np->pid == req_pid){
    80002700:	60bc                	ld	a5,64(s1)
    80002702:	ff279be3          	bne	a5,s2,800026f8 <waitpid+0x84>
    80002706:	589c                	lw	a5,48(s1)
    80002708:	ff4798e3          	bne	a5,s4,800026f8 <waitpid+0x84>
        acquire(&np->lock);
    8000270c:	8526                	mv	a0,s1
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	4d6080e7          	jalr	1238(ra) # 80000be4 <acquire>
        if(np->state == ZOMBIE){
    80002716:	4c9c                	lw	a5,24(s1)
    80002718:	fd579ae3          	bne	a5,s5,800026ec <waitpid+0x78>
          pid = np->pid;
    8000271c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002720:	000b8e63          	beqz	s7,8000273c <waitpid+0xc8>
    80002724:	4691                	li	a3,4
    80002726:	02c48613          	addi	a2,s1,44
    8000272a:	85de                	mv	a1,s7
    8000272c:	05893503          	ld	a0,88(s2)
    80002730:	fffff097          	auipc	ra,0xfffff
    80002734:	f42080e7          	jalr	-190(ra) # 80001672 <copyout>
    80002738:	f8054be3          	bltz	a0,800026ce <waitpid+0x5a>
          freeproc(np);
    8000273c:	8526                	mv	a0,s1
    8000273e:	fffff097          	auipc	ra,0xfffff
    80002742:	474080e7          	jalr	1140(ra) # 80001bb2 <freeproc>
          release(&np->lock);
    80002746:	8526                	mv	a0,s1
    80002748:	ffffe097          	auipc	ra,0xffffe
    8000274c:	550080e7          	jalr	1360(ra) # 80000c98 <release>
          release(&wait_lock);
    80002750:	0000f517          	auipc	a0,0xf
    80002754:	b6850513          	addi	a0,a0,-1176 # 800112b8 <wait_lock>
    80002758:	ffffe097          	auipc	ra,0xffffe
    8000275c:	540080e7          	jalr	1344(ra) # 80000c98 <release>
          return pid;
    80002760:	a831                	j	8000277c <waitpid+0x108>
    if(!havekids || p->killed){
    80002762:	c701                	beqz	a4,8000276a <waitpid+0xf6>
    80002764:	02892783          	lw	a5,40(s2)
    80002768:	cb85                	beqz	a5,80002798 <waitpid+0x124>
      release(&wait_lock);
    8000276a:	0000f517          	auipc	a0,0xf
    8000276e:	b4e50513          	addi	a0,a0,-1202 # 800112b8 <wait_lock>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	526080e7          	jalr	1318(ra) # 80000c98 <release>
      return -1;
    8000277a:	59fd                	li	s3,-1
}
    8000277c:	854e                	mv	a0,s3
    8000277e:	60e6                	ld	ra,88(sp)
    80002780:	6446                	ld	s0,80(sp)
    80002782:	64a6                	ld	s1,72(sp)
    80002784:	6906                	ld	s2,64(sp)
    80002786:	79e2                	ld	s3,56(sp)
    80002788:	7a42                	ld	s4,48(sp)
    8000278a:	7aa2                	ld	s5,40(sp)
    8000278c:	7b02                	ld	s6,32(sp)
    8000278e:	6be2                	ld	s7,24(sp)
    80002790:	6c42                	ld	s8,16(sp)
    80002792:	6ca2                	ld	s9,8(sp)
    80002794:	6125                	addi	sp,sp,96
    80002796:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002798:	85e6                	mv	a1,s9
    8000279a:	854a                	mv	a0,s2
    8000279c:	00000097          	auipc	ra,0x0
    800027a0:	d4c080e7          	jalr	-692(ra) # 800024e8 <sleep>
    havekids = 0;
    800027a4:	bf39                	j	800026c2 <waitpid+0x4e>

00000000800027a6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800027a6:	7139                	addi	sp,sp,-64
    800027a8:	fc06                	sd	ra,56(sp)
    800027aa:	f822                	sd	s0,48(sp)
    800027ac:	f426                	sd	s1,40(sp)
    800027ae:	f04a                	sd	s2,32(sp)
    800027b0:	ec4e                	sd	s3,24(sp)
    800027b2:	e852                	sd	s4,16(sp)
    800027b4:	e456                	sd	s5,8(sp)
    800027b6:	0080                	addi	s0,sp,64
    800027b8:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800027ba:	0000f497          	auipc	s1,0xf
    800027be:	f1648493          	addi	s1,s1,-234 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800027c2:	4989                	li	s3,2
        p->state = RUNNABLE;
    800027c4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800027c6:	00015917          	auipc	s2,0x15
    800027ca:	b0a90913          	addi	s2,s2,-1270 # 800172d0 <tickslock>
    800027ce:	a821                	j	800027e6 <wakeup+0x40>
        p->state = RUNNABLE;
    800027d0:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    800027d4:	8526                	mv	a0,s1
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	4c2080e7          	jalr	1218(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800027de:	17048493          	addi	s1,s1,368
    800027e2:	03248463          	beq	s1,s2,8000280a <wakeup+0x64>
    if(p != myproc()){
    800027e6:	fffff097          	auipc	ra,0xfffff
    800027ea:	1ca080e7          	jalr	458(ra) # 800019b0 <myproc>
    800027ee:	fea488e3          	beq	s1,a0,800027de <wakeup+0x38>
      acquire(&p->lock);
    800027f2:	8526                	mv	a0,s1
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	3f0080e7          	jalr	1008(ra) # 80000be4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800027fc:	4c9c                	lw	a5,24(s1)
    800027fe:	fd379be3          	bne	a5,s3,800027d4 <wakeup+0x2e>
    80002802:	709c                	ld	a5,32(s1)
    80002804:	fd4798e3          	bne	a5,s4,800027d4 <wakeup+0x2e>
    80002808:	b7e1                	j	800027d0 <wakeup+0x2a>
    }
  }
}
    8000280a:	70e2                	ld	ra,56(sp)
    8000280c:	7442                	ld	s0,48(sp)
    8000280e:	74a2                	ld	s1,40(sp)
    80002810:	7902                	ld	s2,32(sp)
    80002812:	69e2                	ld	s3,24(sp)
    80002814:	6a42                	ld	s4,16(sp)
    80002816:	6aa2                	ld	s5,8(sp)
    80002818:	6121                	addi	sp,sp,64
    8000281a:	8082                	ret

000000008000281c <reparent>:
{
    8000281c:	7179                	addi	sp,sp,-48
    8000281e:	f406                	sd	ra,40(sp)
    80002820:	f022                	sd	s0,32(sp)
    80002822:	ec26                	sd	s1,24(sp)
    80002824:	e84a                	sd	s2,16(sp)
    80002826:	e44e                	sd	s3,8(sp)
    80002828:	e052                	sd	s4,0(sp)
    8000282a:	1800                	addi	s0,sp,48
    8000282c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000282e:	0000f497          	auipc	s1,0xf
    80002832:	ea248493          	addi	s1,s1,-350 # 800116d0 <proc>
      pp->parent = initproc;
    80002836:	00006a17          	auipc	s4,0x6
    8000283a:	7f2a0a13          	addi	s4,s4,2034 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000283e:	00015997          	auipc	s3,0x15
    80002842:	a9298993          	addi	s3,s3,-1390 # 800172d0 <tickslock>
    80002846:	a029                	j	80002850 <reparent+0x34>
    80002848:	17048493          	addi	s1,s1,368
    8000284c:	01348d63          	beq	s1,s3,80002866 <reparent+0x4a>
    if(pp->parent == p){
    80002850:	60bc                	ld	a5,64(s1)
    80002852:	ff279be3          	bne	a5,s2,80002848 <reparent+0x2c>
      pp->parent = initproc;
    80002856:	000a3503          	ld	a0,0(s4)
    8000285a:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    8000285c:	00000097          	auipc	ra,0x0
    80002860:	f4a080e7          	jalr	-182(ra) # 800027a6 <wakeup>
    80002864:	b7d5                	j	80002848 <reparent+0x2c>
}
    80002866:	70a2                	ld	ra,40(sp)
    80002868:	7402                	ld	s0,32(sp)
    8000286a:	64e2                	ld	s1,24(sp)
    8000286c:	6942                	ld	s2,16(sp)
    8000286e:	69a2                	ld	s3,8(sp)
    80002870:	6a02                	ld	s4,0(sp)
    80002872:	6145                	addi	sp,sp,48
    80002874:	8082                	ret

0000000080002876 <exit>:
{
    80002876:	7179                	addi	sp,sp,-48
    80002878:	f406                	sd	ra,40(sp)
    8000287a:	f022                	sd	s0,32(sp)
    8000287c:	ec26                	sd	s1,24(sp)
    8000287e:	e84a                	sd	s2,16(sp)
    80002880:	e44e                	sd	s3,8(sp)
    80002882:	e052                	sd	s4,0(sp)
    80002884:	1800                	addi	s0,sp,48
    80002886:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002888:	fffff097          	auipc	ra,0xfffff
    8000288c:	128080e7          	jalr	296(ra) # 800019b0 <myproc>
    80002890:	89aa                	mv	s3,a0
  if(p == initproc)
    80002892:	00006797          	auipc	a5,0x6
    80002896:	7967b783          	ld	a5,1942(a5) # 80009028 <initproc>
    8000289a:	0d850493          	addi	s1,a0,216
    8000289e:	15850913          	addi	s2,a0,344
    800028a2:	02a79363          	bne	a5,a0,800028c8 <exit+0x52>
    panic("init exiting");
    800028a6:	00006517          	auipc	a0,0x6
    800028aa:	a0a50513          	addi	a0,a0,-1526 # 800082b0 <digits+0x270>
    800028ae:	ffffe097          	auipc	ra,0xffffe
    800028b2:	c90080e7          	jalr	-880(ra) # 8000053e <panic>
      fileclose(f);
    800028b6:	00002097          	auipc	ra,0x2
    800028ba:	30a080e7          	jalr	778(ra) # 80004bc0 <fileclose>
      p->ofile[fd] = 0;
    800028be:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800028c2:	04a1                	addi	s1,s1,8
    800028c4:	01248563          	beq	s1,s2,800028ce <exit+0x58>
    if(p->ofile[fd]){
    800028c8:	6088                	ld	a0,0(s1)
    800028ca:	f575                	bnez	a0,800028b6 <exit+0x40>
    800028cc:	bfdd                	j	800028c2 <exit+0x4c>
  begin_op();
    800028ce:	00002097          	auipc	ra,0x2
    800028d2:	e26080e7          	jalr	-474(ra) # 800046f4 <begin_op>
  iput(p->cwd);
    800028d6:	1589b503          	ld	a0,344(s3)
    800028da:	00001097          	auipc	ra,0x1
    800028de:	602080e7          	jalr	1538(ra) # 80003edc <iput>
  end_op();
    800028e2:	00002097          	auipc	ra,0x2
    800028e6:	e92080e7          	jalr	-366(ra) # 80004774 <end_op>
  p->cwd = 0;
    800028ea:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    800028ee:	0000f497          	auipc	s1,0xf
    800028f2:	9ca48493          	addi	s1,s1,-1590 # 800112b8 <wait_lock>
    800028f6:	8526                	mv	a0,s1
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	2ec080e7          	jalr	748(ra) # 80000be4 <acquire>
  reparent(p);
    80002900:	854e                	mv	a0,s3
    80002902:	00000097          	auipc	ra,0x0
    80002906:	f1a080e7          	jalr	-230(ra) # 8000281c <reparent>
  wakeup(p->parent);
    8000290a:	0409b503          	ld	a0,64(s3)
    8000290e:	00000097          	auipc	ra,0x0
    80002912:	e98080e7          	jalr	-360(ra) # 800027a6 <wakeup>
  acquire(&p->lock);
    80002916:	854e                	mv	a0,s3
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	2cc080e7          	jalr	716(ra) # 80000be4 <acquire>
  p->xstate = status;
    80002920:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002924:	4795                	li	a5,5
    80002926:	00f9ac23          	sw	a5,24(s3)
  acquire(&tickslock);
    8000292a:	00015517          	auipc	a0,0x15
    8000292e:	9a650513          	addi	a0,a0,-1626 # 800172d0 <tickslock>
    80002932:	ffffe097          	auipc	ra,0xffffe
    80002936:	2b2080e7          	jalr	690(ra) # 80000be4 <acquire>
  xticks = ticks;
    8000293a:	00006917          	auipc	s2,0x6
    8000293e:	6f692903          	lw	s2,1782(s2) # 80009030 <ticks>
  release(&tickslock);
    80002942:	00015517          	auipc	a0,0x15
    80002946:	98e50513          	addi	a0,a0,-1650 # 800172d0 <tickslock>
    8000294a:	ffffe097          	auipc	ra,0xffffe
    8000294e:	34e080e7          	jalr	846(ra) # 80000c98 <release>
  p->etime = xticks;
    80002952:	0329ae23          	sw	s2,60(s3)
  release(&wait_lock);
    80002956:	8526                	mv	a0,s1
    80002958:	ffffe097          	auipc	ra,0xffffe
    8000295c:	340080e7          	jalr	832(ra) # 80000c98 <release>
  sched();
    80002960:	00000097          	auipc	ra,0x0
    80002964:	a76080e7          	jalr	-1418(ra) # 800023d6 <sched>
  panic("zombie exit");
    80002968:	00006517          	auipc	a0,0x6
    8000296c:	95850513          	addi	a0,a0,-1704 # 800082c0 <digits+0x280>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	bce080e7          	jalr	-1074(ra) # 8000053e <panic>

0000000080002978 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002978:	7179                	addi	sp,sp,-48
    8000297a:	f406                	sd	ra,40(sp)
    8000297c:	f022                	sd	s0,32(sp)
    8000297e:	ec26                	sd	s1,24(sp)
    80002980:	e84a                	sd	s2,16(sp)
    80002982:	e44e                	sd	s3,8(sp)
    80002984:	1800                	addi	s0,sp,48
    80002986:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002988:	0000f497          	auipc	s1,0xf
    8000298c:	d4848493          	addi	s1,s1,-696 # 800116d0 <proc>
    80002990:	00015997          	auipc	s3,0x15
    80002994:	94098993          	addi	s3,s3,-1728 # 800172d0 <tickslock>
    acquire(&p->lock);
    80002998:	8526                	mv	a0,s1
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	24a080e7          	jalr	586(ra) # 80000be4 <acquire>
    if(p->pid == pid){
    800029a2:	589c                	lw	a5,48(s1)
    800029a4:	01278d63          	beq	a5,s2,800029be <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800029a8:	8526                	mv	a0,s1
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	2ee080e7          	jalr	750(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800029b2:	17048493          	addi	s1,s1,368
    800029b6:	ff3491e3          	bne	s1,s3,80002998 <kill+0x20>
  }
  return -1;
    800029ba:	557d                	li	a0,-1
    800029bc:	a829                	j	800029d6 <kill+0x5e>
      p->killed = 1;
    800029be:	4785                	li	a5,1
    800029c0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800029c2:	4c98                	lw	a4,24(s1)
    800029c4:	4789                	li	a5,2
    800029c6:	00f70f63          	beq	a4,a5,800029e4 <kill+0x6c>
      release(&p->lock);
    800029ca:	8526                	mv	a0,s1
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	2cc080e7          	jalr	716(ra) # 80000c98 <release>
      return 0;
    800029d4:	4501                	li	a0,0
}
    800029d6:	70a2                	ld	ra,40(sp)
    800029d8:	7402                	ld	s0,32(sp)
    800029da:	64e2                	ld	s1,24(sp)
    800029dc:	6942                	ld	s2,16(sp)
    800029de:	69a2                	ld	s3,8(sp)
    800029e0:	6145                	addi	sp,sp,48
    800029e2:	8082                	ret
        p->state = RUNNABLE;
    800029e4:	478d                	li	a5,3
    800029e6:	cc9c                	sw	a5,24(s1)
    800029e8:	b7cd                	j	800029ca <kill+0x52>

00000000800029ea <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800029ea:	7179                	addi	sp,sp,-48
    800029ec:	f406                	sd	ra,40(sp)
    800029ee:	f022                	sd	s0,32(sp)
    800029f0:	ec26                	sd	s1,24(sp)
    800029f2:	e84a                	sd	s2,16(sp)
    800029f4:	e44e                	sd	s3,8(sp)
    800029f6:	e052                	sd	s4,0(sp)
    800029f8:	1800                	addi	s0,sp,48
    800029fa:	84aa                	mv	s1,a0
    800029fc:	892e                	mv	s2,a1
    800029fe:	89b2                	mv	s3,a2
    80002a00:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a02:	fffff097          	auipc	ra,0xfffff
    80002a06:	fae080e7          	jalr	-82(ra) # 800019b0 <myproc>
  if(user_dst){
    80002a0a:	c08d                	beqz	s1,80002a2c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002a0c:	86d2                	mv	a3,s4
    80002a0e:	864e                	mv	a2,s3
    80002a10:	85ca                	mv	a1,s2
    80002a12:	6d28                	ld	a0,88(a0)
    80002a14:	fffff097          	auipc	ra,0xfffff
    80002a18:	c5e080e7          	jalr	-930(ra) # 80001672 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a1c:	70a2                	ld	ra,40(sp)
    80002a1e:	7402                	ld	s0,32(sp)
    80002a20:	64e2                	ld	s1,24(sp)
    80002a22:	6942                	ld	s2,16(sp)
    80002a24:	69a2                	ld	s3,8(sp)
    80002a26:	6a02                	ld	s4,0(sp)
    80002a28:	6145                	addi	sp,sp,48
    80002a2a:	8082                	ret
    memmove((char *)dst, src, len);
    80002a2c:	000a061b          	sext.w	a2,s4
    80002a30:	85ce                	mv	a1,s3
    80002a32:	854a                	mv	a0,s2
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	30c080e7          	jalr	780(ra) # 80000d40 <memmove>
    return 0;
    80002a3c:	8526                	mv	a0,s1
    80002a3e:	bff9                	j	80002a1c <either_copyout+0x32>

0000000080002a40 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a40:	7179                	addi	sp,sp,-48
    80002a42:	f406                	sd	ra,40(sp)
    80002a44:	f022                	sd	s0,32(sp)
    80002a46:	ec26                	sd	s1,24(sp)
    80002a48:	e84a                	sd	s2,16(sp)
    80002a4a:	e44e                	sd	s3,8(sp)
    80002a4c:	e052                	sd	s4,0(sp)
    80002a4e:	1800                	addi	s0,sp,48
    80002a50:	892a                	mv	s2,a0
    80002a52:	84ae                	mv	s1,a1
    80002a54:	89b2                	mv	s3,a2
    80002a56:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	f58080e7          	jalr	-168(ra) # 800019b0 <myproc>
  if(user_src){
    80002a60:	c08d                	beqz	s1,80002a82 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002a62:	86d2                	mv	a3,s4
    80002a64:	864e                	mv	a2,s3
    80002a66:	85ca                	mv	a1,s2
    80002a68:	6d28                	ld	a0,88(a0)
    80002a6a:	fffff097          	auipc	ra,0xfffff
    80002a6e:	c94080e7          	jalr	-876(ra) # 800016fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002a72:	70a2                	ld	ra,40(sp)
    80002a74:	7402                	ld	s0,32(sp)
    80002a76:	64e2                	ld	s1,24(sp)
    80002a78:	6942                	ld	s2,16(sp)
    80002a7a:	69a2                	ld	s3,8(sp)
    80002a7c:	6a02                	ld	s4,0(sp)
    80002a7e:	6145                	addi	sp,sp,48
    80002a80:	8082                	ret
    memmove(dst, (char*)src, len);
    80002a82:	000a061b          	sext.w	a2,s4
    80002a86:	85ce                	mv	a1,s3
    80002a88:	854a                	mv	a0,s2
    80002a8a:	ffffe097          	auipc	ra,0xffffe
    80002a8e:	2b6080e7          	jalr	694(ra) # 80000d40 <memmove>
    return 0;
    80002a92:	8526                	mv	a0,s1
    80002a94:	bff9                	j	80002a72 <either_copyin+0x32>

0000000080002a96 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002a96:	715d                	addi	sp,sp,-80
    80002a98:	e486                	sd	ra,72(sp)
    80002a9a:	e0a2                	sd	s0,64(sp)
    80002a9c:	fc26                	sd	s1,56(sp)
    80002a9e:	f84a                	sd	s2,48(sp)
    80002aa0:	f44e                	sd	s3,40(sp)
    80002aa2:	f052                	sd	s4,32(sp)
    80002aa4:	ec56                	sd	s5,24(sp)
    80002aa6:	e85a                	sd	s6,16(sp)
    80002aa8:	e45e                	sd	s7,8(sp)
    80002aaa:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002aac:	00005517          	auipc	a0,0x5
    80002ab0:	7b450513          	addi	a0,a0,1972 # 80008260 <digits+0x220>
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	ad4080e7          	jalr	-1324(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002abc:	0000f497          	auipc	s1,0xf
    80002ac0:	d7448493          	addi	s1,s1,-652 # 80011830 <proc+0x160>
    80002ac4:	00015917          	auipc	s2,0x15
    80002ac8:	96c90913          	addi	s2,s2,-1684 # 80017430 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002acc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002ace:	00006997          	auipc	s3,0x6
    80002ad2:	80298993          	addi	s3,s3,-2046 # 800082d0 <digits+0x290>
    printf("%d %s %s", p->pid, state, p->name);
    80002ad6:	00006a97          	auipc	s5,0x6
    80002ada:	802a8a93          	addi	s5,s5,-2046 # 800082d8 <digits+0x298>
    printf("\n");
    80002ade:	00005a17          	auipc	s4,0x5
    80002ae2:	782a0a13          	addi	s4,s4,1922 # 80008260 <digits+0x220>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ae6:	00006b97          	auipc	s7,0x6
    80002aea:	82ab8b93          	addi	s7,s7,-2006 # 80008310 <states.1640>
    80002aee:	a00d                	j	80002b10 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002af0:	ed06a583          	lw	a1,-304(a3)
    80002af4:	8556                	mv	a0,s5
    80002af6:	ffffe097          	auipc	ra,0xffffe
    80002afa:	a92080e7          	jalr	-1390(ra) # 80000588 <printf>
    printf("\n");
    80002afe:	8552                	mv	a0,s4
    80002b00:	ffffe097          	auipc	ra,0xffffe
    80002b04:	a88080e7          	jalr	-1400(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b08:	17048493          	addi	s1,s1,368
    80002b0c:	03248163          	beq	s1,s2,80002b2e <procdump+0x98>
    if(p->state == UNUSED)
    80002b10:	86a6                	mv	a3,s1
    80002b12:	eb84a783          	lw	a5,-328(s1)
    80002b16:	dbed                	beqz	a5,80002b08 <procdump+0x72>
      state = "???";
    80002b18:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b1a:	fcfb6be3          	bltu	s6,a5,80002af0 <procdump+0x5a>
    80002b1e:	1782                	slli	a5,a5,0x20
    80002b20:	9381                	srli	a5,a5,0x20
    80002b22:	078e                	slli	a5,a5,0x3
    80002b24:	97de                	add	a5,a5,s7
    80002b26:	73b0                	ld	a2,96(a5)
    80002b28:	f661                	bnez	a2,80002af0 <procdump+0x5a>
      state = "???";
    80002b2a:	864e                	mv	a2,s3
    80002b2c:	b7d1                	j	80002af0 <procdump+0x5a>
  }
}
    80002b2e:	60a6                	ld	ra,72(sp)
    80002b30:	6406                	ld	s0,64(sp)
    80002b32:	74e2                	ld	s1,56(sp)
    80002b34:	7942                	ld	s2,48(sp)
    80002b36:	79a2                	ld	s3,40(sp)
    80002b38:	7a02                	ld	s4,32(sp)
    80002b3a:	6ae2                	ld	s5,24(sp)
    80002b3c:	6b42                	ld	s6,16(sp)
    80002b3e:	6ba2                	ld	s7,8(sp)
    80002b40:	6161                	addi	sp,sp,80
    80002b42:	8082                	ret

0000000080002b44 <swtch>:
    80002b44:	00153023          	sd	ra,0(a0)
    80002b48:	00253423          	sd	sp,8(a0)
    80002b4c:	e900                	sd	s0,16(a0)
    80002b4e:	ed04                	sd	s1,24(a0)
    80002b50:	03253023          	sd	s2,32(a0)
    80002b54:	03353423          	sd	s3,40(a0)
    80002b58:	03453823          	sd	s4,48(a0)
    80002b5c:	03553c23          	sd	s5,56(a0)
    80002b60:	05653023          	sd	s6,64(a0)
    80002b64:	05753423          	sd	s7,72(a0)
    80002b68:	05853823          	sd	s8,80(a0)
    80002b6c:	05953c23          	sd	s9,88(a0)
    80002b70:	07a53023          	sd	s10,96(a0)
    80002b74:	07b53423          	sd	s11,104(a0)
    80002b78:	0005b083          	ld	ra,0(a1)
    80002b7c:	0085b103          	ld	sp,8(a1)
    80002b80:	6980                	ld	s0,16(a1)
    80002b82:	6d84                	ld	s1,24(a1)
    80002b84:	0205b903          	ld	s2,32(a1)
    80002b88:	0285b983          	ld	s3,40(a1)
    80002b8c:	0305ba03          	ld	s4,48(a1)
    80002b90:	0385ba83          	ld	s5,56(a1)
    80002b94:	0405bb03          	ld	s6,64(a1)
    80002b98:	0485bb83          	ld	s7,72(a1)
    80002b9c:	0505bc03          	ld	s8,80(a1)
    80002ba0:	0585bc83          	ld	s9,88(a1)
    80002ba4:	0605bd03          	ld	s10,96(a1)
    80002ba8:	0685bd83          	ld	s11,104(a1)
    80002bac:	8082                	ret

0000000080002bae <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002bae:	1141                	addi	sp,sp,-16
    80002bb0:	e406                	sd	ra,8(sp)
    80002bb2:	e022                	sd	s0,0(sp)
    80002bb4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002bb6:	00005597          	auipc	a1,0x5
    80002bba:	7ea58593          	addi	a1,a1,2026 # 800083a0 <states.1790+0x30>
    80002bbe:	00014517          	auipc	a0,0x14
    80002bc2:	71250513          	addi	a0,a0,1810 # 800172d0 <tickslock>
    80002bc6:	ffffe097          	auipc	ra,0xffffe
    80002bca:	f8e080e7          	jalr	-114(ra) # 80000b54 <initlock>
}
    80002bce:	60a2                	ld	ra,8(sp)
    80002bd0:	6402                	ld	s0,0(sp)
    80002bd2:	0141                	addi	sp,sp,16
    80002bd4:	8082                	ret

0000000080002bd6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002bd6:	1141                	addi	sp,sp,-16
    80002bd8:	e422                	sd	s0,8(sp)
    80002bda:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002bdc:	00003797          	auipc	a5,0x3
    80002be0:	60478793          	addi	a5,a5,1540 # 800061e0 <kernelvec>
    80002be4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002be8:	6422                	ld	s0,8(sp)
    80002bea:	0141                	addi	sp,sp,16
    80002bec:	8082                	ret

0000000080002bee <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002bee:	1141                	addi	sp,sp,-16
    80002bf0:	e406                	sd	ra,8(sp)
    80002bf2:	e022                	sd	s0,0(sp)
    80002bf4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	dba080e7          	jalr	-582(ra) # 800019b0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bfe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002c02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c04:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002c08:	00004617          	auipc	a2,0x4
    80002c0c:	3f860613          	addi	a2,a2,1016 # 80007000 <_trampoline>
    80002c10:	00004697          	auipc	a3,0x4
    80002c14:	3f068693          	addi	a3,a3,1008 # 80007000 <_trampoline>
    80002c18:	8e91                	sub	a3,a3,a2
    80002c1a:	040007b7          	lui	a5,0x4000
    80002c1e:	17fd                	addi	a5,a5,-1
    80002c20:	07b2                	slli	a5,a5,0xc
    80002c22:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c24:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002c28:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002c2a:	180026f3          	csrr	a3,satp
    80002c2e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002c30:	7138                	ld	a4,96(a0)
    80002c32:	6534                	ld	a3,72(a0)
    80002c34:	6585                	lui	a1,0x1
    80002c36:	96ae                	add	a3,a3,a1
    80002c38:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002c3a:	7138                	ld	a4,96(a0)
    80002c3c:	00000697          	auipc	a3,0x0
    80002c40:	13868693          	addi	a3,a3,312 # 80002d74 <usertrap>
    80002c44:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002c46:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002c48:	8692                	mv	a3,tp
    80002c4a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c4c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002c50:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002c54:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c58:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002c5c:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c5e:	6f18                	ld	a4,24(a4)
    80002c60:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c64:	6d2c                	ld	a1,88(a0)
    80002c66:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002c68:	00004717          	auipc	a4,0x4
    80002c6c:	42870713          	addi	a4,a4,1064 # 80007090 <userret>
    80002c70:	8f11                	sub	a4,a4,a2
    80002c72:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002c74:	577d                	li	a4,-1
    80002c76:	177e                	slli	a4,a4,0x3f
    80002c78:	8dd9                	or	a1,a1,a4
    80002c7a:	02000537          	lui	a0,0x2000
    80002c7e:	157d                	addi	a0,a0,-1
    80002c80:	0536                	slli	a0,a0,0xd
    80002c82:	9782                	jalr	a5
}
    80002c84:	60a2                	ld	ra,8(sp)
    80002c86:	6402                	ld	s0,0(sp)
    80002c88:	0141                	addi	sp,sp,16
    80002c8a:	8082                	ret

0000000080002c8c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002c8c:	1101                	addi	sp,sp,-32
    80002c8e:	ec06                	sd	ra,24(sp)
    80002c90:	e822                	sd	s0,16(sp)
    80002c92:	e426                	sd	s1,8(sp)
    80002c94:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c96:	00014497          	auipc	s1,0x14
    80002c9a:	63a48493          	addi	s1,s1,1594 # 800172d0 <tickslock>
    80002c9e:	8526                	mv	a0,s1
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	f44080e7          	jalr	-188(ra) # 80000be4 <acquire>
  ticks++;
    80002ca8:	00006517          	auipc	a0,0x6
    80002cac:	38850513          	addi	a0,a0,904 # 80009030 <ticks>
    80002cb0:	411c                	lw	a5,0(a0)
    80002cb2:	2785                	addiw	a5,a5,1
    80002cb4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002cb6:	00000097          	auipc	ra,0x0
    80002cba:	af0080e7          	jalr	-1296(ra) # 800027a6 <wakeup>
  release(&tickslock);
    80002cbe:	8526                	mv	a0,s1
    80002cc0:	ffffe097          	auipc	ra,0xffffe
    80002cc4:	fd8080e7          	jalr	-40(ra) # 80000c98 <release>
}
    80002cc8:	60e2                	ld	ra,24(sp)
    80002cca:	6442                	ld	s0,16(sp)
    80002ccc:	64a2                	ld	s1,8(sp)
    80002cce:	6105                	addi	sp,sp,32
    80002cd0:	8082                	ret

0000000080002cd2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002cd2:	1101                	addi	sp,sp,-32
    80002cd4:	ec06                	sd	ra,24(sp)
    80002cd6:	e822                	sd	s0,16(sp)
    80002cd8:	e426                	sd	s1,8(sp)
    80002cda:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cdc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002ce0:	00074d63          	bltz	a4,80002cfa <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002ce4:	57fd                	li	a5,-1
    80002ce6:	17fe                	slli	a5,a5,0x3f
    80002ce8:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002cea:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002cec:	06f70363          	beq	a4,a5,80002d52 <devintr+0x80>
  }
}
    80002cf0:	60e2                	ld	ra,24(sp)
    80002cf2:	6442                	ld	s0,16(sp)
    80002cf4:	64a2                	ld	s1,8(sp)
    80002cf6:	6105                	addi	sp,sp,32
    80002cf8:	8082                	ret
     (scause & 0xff) == 9){
    80002cfa:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002cfe:	46a5                	li	a3,9
    80002d00:	fed792e3          	bne	a5,a3,80002ce4 <devintr+0x12>
    int irq = plic_claim();
    80002d04:	00003097          	auipc	ra,0x3
    80002d08:	5e4080e7          	jalr	1508(ra) # 800062e8 <plic_claim>
    80002d0c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002d0e:	47a9                	li	a5,10
    80002d10:	02f50763          	beq	a0,a5,80002d3e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002d14:	4785                	li	a5,1
    80002d16:	02f50963          	beq	a0,a5,80002d48 <devintr+0x76>
    return 1;
    80002d1a:	4505                	li	a0,1
    } else if(irq){
    80002d1c:	d8f1                	beqz	s1,80002cf0 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002d1e:	85a6                	mv	a1,s1
    80002d20:	00005517          	auipc	a0,0x5
    80002d24:	68850513          	addi	a0,a0,1672 # 800083a8 <states.1790+0x38>
    80002d28:	ffffe097          	auipc	ra,0xffffe
    80002d2c:	860080e7          	jalr	-1952(ra) # 80000588 <printf>
      plic_complete(irq);
    80002d30:	8526                	mv	a0,s1
    80002d32:	00003097          	auipc	ra,0x3
    80002d36:	5da080e7          	jalr	1498(ra) # 8000630c <plic_complete>
    return 1;
    80002d3a:	4505                	li	a0,1
    80002d3c:	bf55                	j	80002cf0 <devintr+0x1e>
      uartintr();
    80002d3e:	ffffe097          	auipc	ra,0xffffe
    80002d42:	c6a080e7          	jalr	-918(ra) # 800009a8 <uartintr>
    80002d46:	b7ed                	j	80002d30 <devintr+0x5e>
      virtio_disk_intr();
    80002d48:	00004097          	auipc	ra,0x4
    80002d4c:	aa4080e7          	jalr	-1372(ra) # 800067ec <virtio_disk_intr>
    80002d50:	b7c5                	j	80002d30 <devintr+0x5e>
    if(cpuid() == 0){
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	c32080e7          	jalr	-974(ra) # 80001984 <cpuid>
    80002d5a:	c901                	beqz	a0,80002d6a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002d5c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002d60:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002d62:	14479073          	csrw	sip,a5
    return 2;
    80002d66:	4509                	li	a0,2
    80002d68:	b761                	j	80002cf0 <devintr+0x1e>
      clockintr();
    80002d6a:	00000097          	auipc	ra,0x0
    80002d6e:	f22080e7          	jalr	-222(ra) # 80002c8c <clockintr>
    80002d72:	b7ed                	j	80002d5c <devintr+0x8a>

0000000080002d74 <usertrap>:
{
    80002d74:	1101                	addi	sp,sp,-32
    80002d76:	ec06                	sd	ra,24(sp)
    80002d78:	e822                	sd	s0,16(sp)
    80002d7a:	e426                	sd	s1,8(sp)
    80002d7c:	e04a                	sd	s2,0(sp)
    80002d7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d80:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d84:	1007f793          	andi	a5,a5,256
    80002d88:	e3ad                	bnez	a5,80002dea <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d8a:	00003797          	auipc	a5,0x3
    80002d8e:	45678793          	addi	a5,a5,1110 # 800061e0 <kernelvec>
    80002d92:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d96:	fffff097          	auipc	ra,0xfffff
    80002d9a:	c1a080e7          	jalr	-998(ra) # 800019b0 <myproc>
    80002d9e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002da0:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002da2:	14102773          	csrr	a4,sepc
    80002da6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002da8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002dac:	47a1                	li	a5,8
    80002dae:	04f71c63          	bne	a4,a5,80002e06 <usertrap+0x92>
    if(p->killed)
    80002db2:	551c                	lw	a5,40(a0)
    80002db4:	e3b9                	bnez	a5,80002dfa <usertrap+0x86>
    p->trapframe->epc += 4;
    80002db6:	70b8                	ld	a4,96(s1)
    80002db8:	6f1c                	ld	a5,24(a4)
    80002dba:	0791                	addi	a5,a5,4
    80002dbc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dbe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002dc2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dc6:	10079073          	csrw	sstatus,a5
    syscall();
    80002dca:	00000097          	auipc	ra,0x0
    80002dce:	2e0080e7          	jalr	736(ra) # 800030aa <syscall>
  if(p->killed)
    80002dd2:	549c                	lw	a5,40(s1)
    80002dd4:	ebc1                	bnez	a5,80002e64 <usertrap+0xf0>
  usertrapret();
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	e18080e7          	jalr	-488(ra) # 80002bee <usertrapret>
}
    80002dde:	60e2                	ld	ra,24(sp)
    80002de0:	6442                	ld	s0,16(sp)
    80002de2:	64a2                	ld	s1,8(sp)
    80002de4:	6902                	ld	s2,0(sp)
    80002de6:	6105                	addi	sp,sp,32
    80002de8:	8082                	ret
    panic("usertrap: not from user mode");
    80002dea:	00005517          	auipc	a0,0x5
    80002dee:	5de50513          	addi	a0,a0,1502 # 800083c8 <states.1790+0x58>
    80002df2:	ffffd097          	auipc	ra,0xffffd
    80002df6:	74c080e7          	jalr	1868(ra) # 8000053e <panic>
      exit(-1);
    80002dfa:	557d                	li	a0,-1
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	a7a080e7          	jalr	-1414(ra) # 80002876 <exit>
    80002e04:	bf4d                	j	80002db6 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002e06:	00000097          	auipc	ra,0x0
    80002e0a:	ecc080e7          	jalr	-308(ra) # 80002cd2 <devintr>
    80002e0e:	892a                	mv	s2,a0
    80002e10:	c501                	beqz	a0,80002e18 <usertrap+0xa4>
  if(p->killed)
    80002e12:	549c                	lw	a5,40(s1)
    80002e14:	c3a1                	beqz	a5,80002e54 <usertrap+0xe0>
    80002e16:	a815                	j	80002e4a <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e18:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002e1c:	5890                	lw	a2,48(s1)
    80002e1e:	00005517          	auipc	a0,0x5
    80002e22:	5ca50513          	addi	a0,a0,1482 # 800083e8 <states.1790+0x78>
    80002e26:	ffffd097          	auipc	ra,0xffffd
    80002e2a:	762080e7          	jalr	1890(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e2e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e32:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e36:	00005517          	auipc	a0,0x5
    80002e3a:	5e250513          	addi	a0,a0,1506 # 80008418 <states.1790+0xa8>
    80002e3e:	ffffd097          	auipc	ra,0xffffd
    80002e42:	74a080e7          	jalr	1866(ra) # 80000588 <printf>
    p->killed = 1;
    80002e46:	4785                	li	a5,1
    80002e48:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002e4a:	557d                	li	a0,-1
    80002e4c:	00000097          	auipc	ra,0x0
    80002e50:	a2a080e7          	jalr	-1494(ra) # 80002876 <exit>
  if(which_dev == 2)
    80002e54:	4789                	li	a5,2
    80002e56:	f8f910e3          	bne	s2,a5,80002dd6 <usertrap+0x62>
    yield();
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	652080e7          	jalr	1618(ra) # 800024ac <yield>
    80002e62:	bf95                	j	80002dd6 <usertrap+0x62>
  int which_dev = 0;
    80002e64:	4901                	li	s2,0
    80002e66:	b7d5                	j	80002e4a <usertrap+0xd6>

0000000080002e68 <kerneltrap>:
{
    80002e68:	7179                	addi	sp,sp,-48
    80002e6a:	f406                	sd	ra,40(sp)
    80002e6c:	f022                	sd	s0,32(sp)
    80002e6e:	ec26                	sd	s1,24(sp)
    80002e70:	e84a                	sd	s2,16(sp)
    80002e72:	e44e                	sd	s3,8(sp)
    80002e74:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e76:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e7a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e7e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e82:	1004f793          	andi	a5,s1,256
    80002e86:	cb85                	beqz	a5,80002eb6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e88:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e8c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002e8e:	ef85                	bnez	a5,80002ec6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002e90:	00000097          	auipc	ra,0x0
    80002e94:	e42080e7          	jalr	-446(ra) # 80002cd2 <devintr>
    80002e98:	cd1d                	beqz	a0,80002ed6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e9a:	4789                	li	a5,2
    80002e9c:	06f50a63          	beq	a0,a5,80002f10 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ea0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ea4:	10049073          	csrw	sstatus,s1
}
    80002ea8:	70a2                	ld	ra,40(sp)
    80002eaa:	7402                	ld	s0,32(sp)
    80002eac:	64e2                	ld	s1,24(sp)
    80002eae:	6942                	ld	s2,16(sp)
    80002eb0:	69a2                	ld	s3,8(sp)
    80002eb2:	6145                	addi	sp,sp,48
    80002eb4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002eb6:	00005517          	auipc	a0,0x5
    80002eba:	58250513          	addi	a0,a0,1410 # 80008438 <states.1790+0xc8>
    80002ebe:	ffffd097          	auipc	ra,0xffffd
    80002ec2:	680080e7          	jalr	1664(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002ec6:	00005517          	auipc	a0,0x5
    80002eca:	59a50513          	addi	a0,a0,1434 # 80008460 <states.1790+0xf0>
    80002ece:	ffffd097          	auipc	ra,0xffffd
    80002ed2:	670080e7          	jalr	1648(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002ed6:	85ce                	mv	a1,s3
    80002ed8:	00005517          	auipc	a0,0x5
    80002edc:	5a850513          	addi	a0,a0,1448 # 80008480 <states.1790+0x110>
    80002ee0:	ffffd097          	auipc	ra,0xffffd
    80002ee4:	6a8080e7          	jalr	1704(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ee8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002eec:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ef0:	00005517          	auipc	a0,0x5
    80002ef4:	5a050513          	addi	a0,a0,1440 # 80008490 <states.1790+0x120>
    80002ef8:	ffffd097          	auipc	ra,0xffffd
    80002efc:	690080e7          	jalr	1680(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002f00:	00005517          	auipc	a0,0x5
    80002f04:	5a850513          	addi	a0,a0,1448 # 800084a8 <states.1790+0x138>
    80002f08:	ffffd097          	auipc	ra,0xffffd
    80002f0c:	636080e7          	jalr	1590(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002f10:	fffff097          	auipc	ra,0xfffff
    80002f14:	aa0080e7          	jalr	-1376(ra) # 800019b0 <myproc>
    80002f18:	d541                	beqz	a0,80002ea0 <kerneltrap+0x38>
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	a96080e7          	jalr	-1386(ra) # 800019b0 <myproc>
    80002f22:	4d18                	lw	a4,24(a0)
    80002f24:	4791                	li	a5,4
    80002f26:	f6f71de3          	bne	a4,a5,80002ea0 <kerneltrap+0x38>
    yield();
    80002f2a:	fffff097          	auipc	ra,0xfffff
    80002f2e:	582080e7          	jalr	1410(ra) # 800024ac <yield>
    80002f32:	b7bd                	j	80002ea0 <kerneltrap+0x38>

0000000080002f34 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002f34:	1101                	addi	sp,sp,-32
    80002f36:	ec06                	sd	ra,24(sp)
    80002f38:	e822                	sd	s0,16(sp)
    80002f3a:	e426                	sd	s1,8(sp)
    80002f3c:	1000                	addi	s0,sp,32
    80002f3e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	a70080e7          	jalr	-1424(ra) # 800019b0 <myproc>
  switch (n) {
    80002f48:	4795                	li	a5,5
    80002f4a:	0497e163          	bltu	a5,s1,80002f8c <argraw+0x58>
    80002f4e:	048a                	slli	s1,s1,0x2
    80002f50:	00005717          	auipc	a4,0x5
    80002f54:	59070713          	addi	a4,a4,1424 # 800084e0 <states.1790+0x170>
    80002f58:	94ba                	add	s1,s1,a4
    80002f5a:	409c                	lw	a5,0(s1)
    80002f5c:	97ba                	add	a5,a5,a4
    80002f5e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002f60:	713c                	ld	a5,96(a0)
    80002f62:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002f64:	60e2                	ld	ra,24(sp)
    80002f66:	6442                	ld	s0,16(sp)
    80002f68:	64a2                	ld	s1,8(sp)
    80002f6a:	6105                	addi	sp,sp,32
    80002f6c:	8082                	ret
    return p->trapframe->a1;
    80002f6e:	713c                	ld	a5,96(a0)
    80002f70:	7fa8                	ld	a0,120(a5)
    80002f72:	bfcd                	j	80002f64 <argraw+0x30>
    return p->trapframe->a2;
    80002f74:	713c                	ld	a5,96(a0)
    80002f76:	63c8                	ld	a0,128(a5)
    80002f78:	b7f5                	j	80002f64 <argraw+0x30>
    return p->trapframe->a3;
    80002f7a:	713c                	ld	a5,96(a0)
    80002f7c:	67c8                	ld	a0,136(a5)
    80002f7e:	b7dd                	j	80002f64 <argraw+0x30>
    return p->trapframe->a4;
    80002f80:	713c                	ld	a5,96(a0)
    80002f82:	6bc8                	ld	a0,144(a5)
    80002f84:	b7c5                	j	80002f64 <argraw+0x30>
    return p->trapframe->a5;
    80002f86:	713c                	ld	a5,96(a0)
    80002f88:	6fc8                	ld	a0,152(a5)
    80002f8a:	bfe9                	j	80002f64 <argraw+0x30>
  panic("argraw");
    80002f8c:	00005517          	auipc	a0,0x5
    80002f90:	52c50513          	addi	a0,a0,1324 # 800084b8 <states.1790+0x148>
    80002f94:	ffffd097          	auipc	ra,0xffffd
    80002f98:	5aa080e7          	jalr	1450(ra) # 8000053e <panic>

0000000080002f9c <fetchaddr>:
{
    80002f9c:	1101                	addi	sp,sp,-32
    80002f9e:	ec06                	sd	ra,24(sp)
    80002fa0:	e822                	sd	s0,16(sp)
    80002fa2:	e426                	sd	s1,8(sp)
    80002fa4:	e04a                	sd	s2,0(sp)
    80002fa6:	1000                	addi	s0,sp,32
    80002fa8:	84aa                	mv	s1,a0
    80002faa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	a04080e7          	jalr	-1532(ra) # 800019b0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002fb4:	693c                	ld	a5,80(a0)
    80002fb6:	02f4f863          	bgeu	s1,a5,80002fe6 <fetchaddr+0x4a>
    80002fba:	00848713          	addi	a4,s1,8
    80002fbe:	02e7e663          	bltu	a5,a4,80002fea <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002fc2:	46a1                	li	a3,8
    80002fc4:	8626                	mv	a2,s1
    80002fc6:	85ca                	mv	a1,s2
    80002fc8:	6d28                	ld	a0,88(a0)
    80002fca:	ffffe097          	auipc	ra,0xffffe
    80002fce:	734080e7          	jalr	1844(ra) # 800016fe <copyin>
    80002fd2:	00a03533          	snez	a0,a0
    80002fd6:	40a00533          	neg	a0,a0
}
    80002fda:	60e2                	ld	ra,24(sp)
    80002fdc:	6442                	ld	s0,16(sp)
    80002fde:	64a2                	ld	s1,8(sp)
    80002fe0:	6902                	ld	s2,0(sp)
    80002fe2:	6105                	addi	sp,sp,32
    80002fe4:	8082                	ret
    return -1;
    80002fe6:	557d                	li	a0,-1
    80002fe8:	bfcd                	j	80002fda <fetchaddr+0x3e>
    80002fea:	557d                	li	a0,-1
    80002fec:	b7fd                	j	80002fda <fetchaddr+0x3e>

0000000080002fee <fetchstr>:
{
    80002fee:	7179                	addi	sp,sp,-48
    80002ff0:	f406                	sd	ra,40(sp)
    80002ff2:	f022                	sd	s0,32(sp)
    80002ff4:	ec26                	sd	s1,24(sp)
    80002ff6:	e84a                	sd	s2,16(sp)
    80002ff8:	e44e                	sd	s3,8(sp)
    80002ffa:	1800                	addi	s0,sp,48
    80002ffc:	892a                	mv	s2,a0
    80002ffe:	84ae                	mv	s1,a1
    80003000:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003002:	fffff097          	auipc	ra,0xfffff
    80003006:	9ae080e7          	jalr	-1618(ra) # 800019b0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    8000300a:	86ce                	mv	a3,s3
    8000300c:	864a                	mv	a2,s2
    8000300e:	85a6                	mv	a1,s1
    80003010:	6d28                	ld	a0,88(a0)
    80003012:	ffffe097          	auipc	ra,0xffffe
    80003016:	778080e7          	jalr	1912(ra) # 8000178a <copyinstr>
  if(err < 0)
    8000301a:	00054763          	bltz	a0,80003028 <fetchstr+0x3a>
  return strlen(buf);
    8000301e:	8526                	mv	a0,s1
    80003020:	ffffe097          	auipc	ra,0xffffe
    80003024:	e44080e7          	jalr	-444(ra) # 80000e64 <strlen>
}
    80003028:	70a2                	ld	ra,40(sp)
    8000302a:	7402                	ld	s0,32(sp)
    8000302c:	64e2                	ld	s1,24(sp)
    8000302e:	6942                	ld	s2,16(sp)
    80003030:	69a2                	ld	s3,8(sp)
    80003032:	6145                	addi	sp,sp,48
    80003034:	8082                	ret

0000000080003036 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003036:	1101                	addi	sp,sp,-32
    80003038:	ec06                	sd	ra,24(sp)
    8000303a:	e822                	sd	s0,16(sp)
    8000303c:	e426                	sd	s1,8(sp)
    8000303e:	1000                	addi	s0,sp,32
    80003040:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003042:	00000097          	auipc	ra,0x0
    80003046:	ef2080e7          	jalr	-270(ra) # 80002f34 <argraw>
    8000304a:	c088                	sw	a0,0(s1)
  return 0;
}
    8000304c:	4501                	li	a0,0
    8000304e:	60e2                	ld	ra,24(sp)
    80003050:	6442                	ld	s0,16(sp)
    80003052:	64a2                	ld	s1,8(sp)
    80003054:	6105                	addi	sp,sp,32
    80003056:	8082                	ret

0000000080003058 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003058:	1101                	addi	sp,sp,-32
    8000305a:	ec06                	sd	ra,24(sp)
    8000305c:	e822                	sd	s0,16(sp)
    8000305e:	e426                	sd	s1,8(sp)
    80003060:	1000                	addi	s0,sp,32
    80003062:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003064:	00000097          	auipc	ra,0x0
    80003068:	ed0080e7          	jalr	-304(ra) # 80002f34 <argraw>
    8000306c:	e088                	sd	a0,0(s1)
  return 0;
}
    8000306e:	4501                	li	a0,0
    80003070:	60e2                	ld	ra,24(sp)
    80003072:	6442                	ld	s0,16(sp)
    80003074:	64a2                	ld	s1,8(sp)
    80003076:	6105                	addi	sp,sp,32
    80003078:	8082                	ret

000000008000307a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000307a:	1101                	addi	sp,sp,-32
    8000307c:	ec06                	sd	ra,24(sp)
    8000307e:	e822                	sd	s0,16(sp)
    80003080:	e426                	sd	s1,8(sp)
    80003082:	e04a                	sd	s2,0(sp)
    80003084:	1000                	addi	s0,sp,32
    80003086:	84ae                	mv	s1,a1
    80003088:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000308a:	00000097          	auipc	ra,0x0
    8000308e:	eaa080e7          	jalr	-342(ra) # 80002f34 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003092:	864a                	mv	a2,s2
    80003094:	85a6                	mv	a1,s1
    80003096:	00000097          	auipc	ra,0x0
    8000309a:	f58080e7          	jalr	-168(ra) # 80002fee <fetchstr>
}
    8000309e:	60e2                	ld	ra,24(sp)
    800030a0:	6442                	ld	s0,16(sp)
    800030a2:	64a2                	ld	s1,8(sp)
    800030a4:	6902                	ld	s2,0(sp)
    800030a6:	6105                	addi	sp,sp,32
    800030a8:	8082                	ret

00000000800030aa <syscall>:
[SYS_pinfo] sys_pinfo,
};

void
syscall(void)
{
    800030aa:	1101                	addi	sp,sp,-32
    800030ac:	ec06                	sd	ra,24(sp)
    800030ae:	e822                	sd	s0,16(sp)
    800030b0:	e426                	sd	s1,8(sp)
    800030b2:	e04a                	sd	s2,0(sp)
    800030b4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800030b6:	fffff097          	auipc	ra,0xfffff
    800030ba:	8fa080e7          	jalr	-1798(ra) # 800019b0 <myproc>
    800030be:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800030c0:	06053903          	ld	s2,96(a0)
    800030c4:	0a893783          	ld	a5,168(s2)
    800030c8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800030cc:	37fd                	addiw	a5,a5,-1
    800030ce:	476d                	li	a4,27
    800030d0:	00f76f63          	bltu	a4,a5,800030ee <syscall+0x44>
    800030d4:	00369713          	slli	a4,a3,0x3
    800030d8:	00005797          	auipc	a5,0x5
    800030dc:	42078793          	addi	a5,a5,1056 # 800084f8 <syscalls>
    800030e0:	97ba                	add	a5,a5,a4
    800030e2:	639c                	ld	a5,0(a5)
    800030e4:	c789                	beqz	a5,800030ee <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800030e6:	9782                	jalr	a5
    800030e8:	06a93823          	sd	a0,112(s2)
    800030ec:	a839                	j	8000310a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800030ee:	16048613          	addi	a2,s1,352
    800030f2:	588c                	lw	a1,48(s1)
    800030f4:	00005517          	auipc	a0,0x5
    800030f8:	3cc50513          	addi	a0,a0,972 # 800084c0 <states.1790+0x150>
    800030fc:	ffffd097          	auipc	ra,0xffffd
    80003100:	48c080e7          	jalr	1164(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003104:	70bc                	ld	a5,96(s1)
    80003106:	577d                	li	a4,-1
    80003108:	fbb8                	sd	a4,112(a5)
  }
}
    8000310a:	60e2                	ld	ra,24(sp)
    8000310c:	6442                	ld	s0,16(sp)
    8000310e:	64a2                	ld	s1,8(sp)
    80003110:	6902                	ld	s2,0(sp)
    80003112:	6105                	addi	sp,sp,32
    80003114:	8082                	ret

0000000080003116 <sys_getppid>:
#include "proc.h"


/* New System calls added here */
uint64
sys_getppid(void){
    80003116:	1141                	addi	sp,sp,-16
    80003118:	e406                	sd	ra,8(sp)
    8000311a:	e022                	sd	s0,0(sp)
    8000311c:	0800                	addi	s0,sp,16
  // struct spinlock wait_lock;
  // acquire(&wait_lock);
  struct proc* parent = myproc()->parent;
    8000311e:	fffff097          	auipc	ra,0xfffff
    80003122:	892080e7          	jalr	-1902(ra) # 800019b0 <myproc>
    80003126:	613c                	ld	a5,64(a0)
  // release(&wait_lock);
  if(parent) 
    80003128:	c791                	beqz	a5,80003134 <sys_getppid+0x1e>
  return parent->pid;
    8000312a:	5b88                	lw	a0,48(a5)
  else return -1;
}
    8000312c:	60a2                	ld	ra,8(sp)
    8000312e:	6402                	ld	s0,0(sp)
    80003130:	0141                	addi	sp,sp,16
    80003132:	8082                	ret
  else return -1;
    80003134:	557d                	li	a0,-1
    80003136:	bfdd                	j	8000312c <sys_getppid+0x16>

0000000080003138 <sys_yield>:

uint64
sys_yield(void){
    80003138:	1141                	addi	sp,sp,-16
    8000313a:	e406                	sd	ra,8(sp)
    8000313c:	e022                	sd	s0,0(sp)
    8000313e:	0800                	addi	s0,sp,16
  yield();
    80003140:	fffff097          	auipc	ra,0xfffff
    80003144:	36c080e7          	jalr	876(ra) # 800024ac <yield>
  return 0;
}
    80003148:	4501                	li	a0,0
    8000314a:	60a2                	ld	ra,8(sp)
    8000314c:	6402                	ld	s0,0(sp)
    8000314e:	0141                	addi	sp,sp,16
    80003150:	8082                	ret

0000000080003152 <sys_getpa>:

uint64
sys_getpa(void){
    80003152:	7179                	addi	sp,sp,-48
    80003154:	f406                	sd	ra,40(sp)
    80003156:	f022                	sd	s0,32(sp)
    80003158:	ec26                	sd	s1,24(sp)
    8000315a:	1800                	addi	s0,sp,48
  int  t;
  if(argint(0, &t) < 0)
    8000315c:	fdc40593          	addi	a1,s0,-36
    80003160:	4501                	li	a0,0
    80003162:	00000097          	auipc	ra,0x0
    80003166:	ed4080e7          	jalr	-300(ra) # 80003036 <argint>
    8000316a:	87aa                	mv	a5,a0
    return -1;
    8000316c:	557d                	li	a0,-1
  if(argint(0, &t) < 0)
    8000316e:	0207c163          	bltz	a5,80003190 <sys_getpa+0x3e>
  uint64 A = (uint64)t;
    80003172:	fdc42483          	lw	s1,-36(s0)
  struct proc *p = myproc();
    80003176:	fffff097          	auipc	ra,0xfffff
    8000317a:	83a080e7          	jalr	-1990(ra) # 800019b0 <myproc>
  return walkaddr(p->pagetable, A) + (A & (PGSIZE - 1));
    8000317e:	85a6                	mv	a1,s1
    80003180:	6d28                	ld	a0,88(a0)
    80003182:	ffffe097          	auipc	ra,0xffffe
    80003186:	eec080e7          	jalr	-276(ra) # 8000106e <walkaddr>
    8000318a:	14d2                	slli	s1,s1,0x34
    8000318c:	90d1                	srli	s1,s1,0x34
    8000318e:	9526                	add	a0,a0,s1
}
    80003190:	70a2                	ld	ra,40(sp)
    80003192:	7402                	ld	s0,32(sp)
    80003194:	64e2                	ld	s1,24(sp)
    80003196:	6145                	addi	sp,sp,48
    80003198:	8082                	ret

000000008000319a <sys_forkf>:

uint64
sys_forkf(void){
    8000319a:	1101                	addi	sp,sp,-32
    8000319c:	ec06                	sd	ra,24(sp)
    8000319e:	e822                	sd	s0,16(sp)
    800031a0:	1000                	addi	s0,sp,32
  uint64  addr;
  if(argaddr(0, &addr) < 0)
    800031a2:	fe840593          	addi	a1,s0,-24
    800031a6:	4501                	li	a0,0
    800031a8:	00000097          	auipc	ra,0x0
    800031ac:	eb0080e7          	jalr	-336(ra) # 80003058 <argaddr>
    800031b0:	87aa                	mv	a5,a0
    return -1;
    800031b2:	557d                	li	a0,-1
  if(argaddr(0, &addr) < 0)
    800031b4:	0007c863          	bltz	a5,800031c4 <sys_forkf+0x2a>
  return forkf(addr);
    800031b8:	fe843503          	ld	a0,-24(s0)
    800031bc:	fffff097          	auipc	ra,0xfffff
    800031c0:	032080e7          	jalr	50(ra) # 800021ee <forkf>
}
    800031c4:	60e2                	ld	ra,24(sp)
    800031c6:	6442                	ld	s0,16(sp)
    800031c8:	6105                	addi	sp,sp,32
    800031ca:	8082                	ret

00000000800031cc <sys_waitpid>:

uint64
sys_waitpid(void){
    800031cc:	1101                	addi	sp,sp,-32
    800031ce:	ec06                	sd	ra,24(sp)
    800031d0:	e822                	sd	s0,16(sp)
    800031d2:	1000                	addi	s0,sp,32
  uint64 p;
  int pid;
  if(argint(0,&pid)<0||argaddr(1,&p)<0)
    800031d4:	fe440593          	addi	a1,s0,-28
    800031d8:	4501                	li	a0,0
    800031da:	00000097          	auipc	ra,0x0
    800031de:	e5c080e7          	jalr	-420(ra) # 80003036 <argint>
    800031e2:	87aa                	mv	a5,a0
    return -1;
    800031e4:	557d                	li	a0,-1
  if(argint(0,&pid)<0||argaddr(1,&p)<0)
    800031e6:	0207c663          	bltz	a5,80003212 <sys_waitpid+0x46>
    800031ea:	fe840593          	addi	a1,s0,-24
    800031ee:	4505                	li	a0,1
    800031f0:	00000097          	auipc	ra,0x0
    800031f4:	e68080e7          	jalr	-408(ra) # 80003058 <argaddr>
    800031f8:	02054863          	bltz	a0,80003228 <sys_waitpid+0x5c>
  if(pid==-1)
    800031fc:	fe442503          	lw	a0,-28(s0)
    80003200:	57fd                	li	a5,-1
    80003202:	00f50c63          	beq	a0,a5,8000321a <sys_waitpid+0x4e>
    return wait(p);
  else
    return waitpid(pid,p);
    80003206:	fe843583          	ld	a1,-24(s0)
    8000320a:	fffff097          	auipc	ra,0xfffff
    8000320e:	46a080e7          	jalr	1130(ra) # 80002674 <waitpid>

}
    80003212:	60e2                	ld	ra,24(sp)
    80003214:	6442                	ld	s0,16(sp)
    80003216:	6105                	addi	sp,sp,32
    80003218:	8082                	ret
    return wait(p);
    8000321a:	fe843503          	ld	a0,-24(s0)
    8000321e:	fffff097          	auipc	ra,0xfffff
    80003222:	32e080e7          	jalr	814(ra) # 8000254c <wait>
    80003226:	b7f5                	j	80003212 <sys_waitpid+0x46>
    return -1;
    80003228:	557d                	li	a0,-1
    8000322a:	b7e5                	j	80003212 <sys_waitpid+0x46>

000000008000322c <sys_ps>:

uint64
sys_ps(void){
    8000322c:	1141                	addi	sp,sp,-16
    8000322e:	e406                	sd	ra,8(sp)
    80003230:	e022                	sd	s0,0(sp)
    80003232:	0800                	addi	s0,sp,16
  return ps();
    80003234:	fffff097          	auipc	ra,0xfffff
    80003238:	b9a080e7          	jalr	-1126(ra) # 80001dce <ps>
}
    8000323c:	60a2                	ld	ra,8(sp)
    8000323e:	6402                	ld	s0,0(sp)
    80003240:	0141                	addi	sp,sp,16
    80003242:	8082                	ret

0000000080003244 <sys_pinfo>:

uint64
sys_pinfo(void){
    80003244:	1101                	addi	sp,sp,-32
    80003246:	ec06                	sd	ra,24(sp)
    80003248:	e822                	sd	s0,16(sp)
    8000324a:	1000                	addi	s0,sp,32
  uint64 p;
  int pid;
  if(argint(0,&pid)<0||argaddr(1,&p)<0)
    8000324c:	fe440593          	addi	a1,s0,-28
    80003250:	4501                	li	a0,0
    80003252:	00000097          	auipc	ra,0x0
    80003256:	de4080e7          	jalr	-540(ra) # 80003036 <argint>
    return -1;
    8000325a:	57fd                	li	a5,-1
  if(argint(0,&pid)<0||argaddr(1,&p)<0)
    8000325c:	02054563          	bltz	a0,80003286 <sys_pinfo+0x42>
    80003260:	fe840593          	addi	a1,s0,-24
    80003264:	4505                	li	a0,1
    80003266:	00000097          	auipc	ra,0x0
    8000326a:	df2080e7          	jalr	-526(ra) # 80003058 <argaddr>
    return -1;
    8000326e:	57fd                	li	a5,-1
  if(argint(0,&pid)<0||argaddr(1,&p)<0)
    80003270:	00054b63          	bltz	a0,80003286 <sys_pinfo+0x42>
  return pinfo(pid,p);
    80003274:	fe843583          	ld	a1,-24(s0)
    80003278:	fe442503          	lw	a0,-28(s0)
    8000327c:	fffff097          	auipc	ra,0xfffff
    80003280:	c86080e7          	jalr	-890(ra) # 80001f02 <pinfo>
    80003284:	87aa                	mv	a5,a0
}
    80003286:	853e                	mv	a0,a5
    80003288:	60e2                	ld	ra,24(sp)
    8000328a:	6442                	ld	s0,16(sp)
    8000328c:	6105                	addi	sp,sp,32
    8000328e:	8082                	ret

0000000080003290 <sys_exit>:

/* Existing system calls start from here */
uint64
sys_exit(void)
{
    80003290:	1101                	addi	sp,sp,-32
    80003292:	ec06                	sd	ra,24(sp)
    80003294:	e822                	sd	s0,16(sp)
    80003296:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003298:	fec40593          	addi	a1,s0,-20
    8000329c:	4501                	li	a0,0
    8000329e:	00000097          	auipc	ra,0x0
    800032a2:	d98080e7          	jalr	-616(ra) # 80003036 <argint>
    return -1;
    800032a6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800032a8:	00054963          	bltz	a0,800032ba <sys_exit+0x2a>
  exit(n);
    800032ac:	fec42503          	lw	a0,-20(s0)
    800032b0:	fffff097          	auipc	ra,0xfffff
    800032b4:	5c6080e7          	jalr	1478(ra) # 80002876 <exit>
  return 0;  // not reached
    800032b8:	4781                	li	a5,0
}
    800032ba:	853e                	mv	a0,a5
    800032bc:	60e2                	ld	ra,24(sp)
    800032be:	6442                	ld	s0,16(sp)
    800032c0:	6105                	addi	sp,sp,32
    800032c2:	8082                	ret

00000000800032c4 <sys_getpid>:

uint64
sys_getpid(void)
{
    800032c4:	1141                	addi	sp,sp,-16
    800032c6:	e406                	sd	ra,8(sp)
    800032c8:	e022                	sd	s0,0(sp)
    800032ca:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800032cc:	ffffe097          	auipc	ra,0xffffe
    800032d0:	6e4080e7          	jalr	1764(ra) # 800019b0 <myproc>
}
    800032d4:	5908                	lw	a0,48(a0)
    800032d6:	60a2                	ld	ra,8(sp)
    800032d8:	6402                	ld	s0,0(sp)
    800032da:	0141                	addi	sp,sp,16
    800032dc:	8082                	ret

00000000800032de <sys_fork>:

uint64
sys_fork(void)
{
    800032de:	1141                	addi	sp,sp,-16
    800032e0:	e406                	sd	ra,8(sp)
    800032e2:	e022                	sd	s0,0(sp)
    800032e4:	0800                	addi	s0,sp,16
  return fork();
    800032e6:	fffff097          	auipc	ra,0xfffff
    800032ea:	da0080e7          	jalr	-608(ra) # 80002086 <fork>
}
    800032ee:	60a2                	ld	ra,8(sp)
    800032f0:	6402                	ld	s0,0(sp)
    800032f2:	0141                	addi	sp,sp,16
    800032f4:	8082                	ret

00000000800032f6 <sys_wait>:

uint64
sys_wait(void)
{
    800032f6:	1101                	addi	sp,sp,-32
    800032f8:	ec06                	sd	ra,24(sp)
    800032fa:	e822                	sd	s0,16(sp)
    800032fc:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    800032fe:	fe840593          	addi	a1,s0,-24
    80003302:	4501                	li	a0,0
    80003304:	00000097          	auipc	ra,0x0
    80003308:	d54080e7          	jalr	-684(ra) # 80003058 <argaddr>
    8000330c:	87aa                	mv	a5,a0
    return -1;
    8000330e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003310:	0007c863          	bltz	a5,80003320 <sys_wait+0x2a>
  return wait(p);
    80003314:	fe843503          	ld	a0,-24(s0)
    80003318:	fffff097          	auipc	ra,0xfffff
    8000331c:	234080e7          	jalr	564(ra) # 8000254c <wait>
}
    80003320:	60e2                	ld	ra,24(sp)
    80003322:	6442                	ld	s0,16(sp)
    80003324:	6105                	addi	sp,sp,32
    80003326:	8082                	ret

0000000080003328 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003328:	7179                	addi	sp,sp,-48
    8000332a:	f406                	sd	ra,40(sp)
    8000332c:	f022                	sd	s0,32(sp)
    8000332e:	ec26                	sd	s1,24(sp)
    80003330:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003332:	fdc40593          	addi	a1,s0,-36
    80003336:	4501                	li	a0,0
    80003338:	00000097          	auipc	ra,0x0
    8000333c:	cfe080e7          	jalr	-770(ra) # 80003036 <argint>
    80003340:	87aa                	mv	a5,a0
    return -1;
    80003342:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80003344:	0207c063          	bltz	a5,80003364 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80003348:	ffffe097          	auipc	ra,0xffffe
    8000334c:	668080e7          	jalr	1640(ra) # 800019b0 <myproc>
    80003350:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80003352:	fdc42503          	lw	a0,-36(s0)
    80003356:	fffff097          	auipc	ra,0xfffff
    8000335a:	a04080e7          	jalr	-1532(ra) # 80001d5a <growproc>
    8000335e:	00054863          	bltz	a0,8000336e <sys_sbrk+0x46>
    return -1;
  return addr;
    80003362:	8526                	mv	a0,s1
}
    80003364:	70a2                	ld	ra,40(sp)
    80003366:	7402                	ld	s0,32(sp)
    80003368:	64e2                	ld	s1,24(sp)
    8000336a:	6145                	addi	sp,sp,48
    8000336c:	8082                	ret
    return -1;
    8000336e:	557d                	li	a0,-1
    80003370:	bfd5                	j	80003364 <sys_sbrk+0x3c>

0000000080003372 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003372:	7139                	addi	sp,sp,-64
    80003374:	fc06                	sd	ra,56(sp)
    80003376:	f822                	sd	s0,48(sp)
    80003378:	f426                	sd	s1,40(sp)
    8000337a:	f04a                	sd	s2,32(sp)
    8000337c:	ec4e                	sd	s3,24(sp)
    8000337e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003380:	fcc40593          	addi	a1,s0,-52
    80003384:	4501                	li	a0,0
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	cb0080e7          	jalr	-848(ra) # 80003036 <argint>
    return -1;
    8000338e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003390:	06054563          	bltz	a0,800033fa <sys_sleep+0x88>
  acquire(&tickslock);
    80003394:	00014517          	auipc	a0,0x14
    80003398:	f3c50513          	addi	a0,a0,-196 # 800172d0 <tickslock>
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	848080e7          	jalr	-1976(ra) # 80000be4 <acquire>
  ticks0 = ticks;
    800033a4:	00006917          	auipc	s2,0x6
    800033a8:	c8c92903          	lw	s2,-884(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    800033ac:	fcc42783          	lw	a5,-52(s0)
    800033b0:	cf85                	beqz	a5,800033e8 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800033b2:	00014997          	auipc	s3,0x14
    800033b6:	f1e98993          	addi	s3,s3,-226 # 800172d0 <tickslock>
    800033ba:	00006497          	auipc	s1,0x6
    800033be:	c7648493          	addi	s1,s1,-906 # 80009030 <ticks>
    if(myproc()->killed){
    800033c2:	ffffe097          	auipc	ra,0xffffe
    800033c6:	5ee080e7          	jalr	1518(ra) # 800019b0 <myproc>
    800033ca:	551c                	lw	a5,40(a0)
    800033cc:	ef9d                	bnez	a5,8000340a <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    800033ce:	85ce                	mv	a1,s3
    800033d0:	8526                	mv	a0,s1
    800033d2:	fffff097          	auipc	ra,0xfffff
    800033d6:	116080e7          	jalr	278(ra) # 800024e8 <sleep>
  while(ticks - ticks0 < n){
    800033da:	409c                	lw	a5,0(s1)
    800033dc:	412787bb          	subw	a5,a5,s2
    800033e0:	fcc42703          	lw	a4,-52(s0)
    800033e4:	fce7efe3          	bltu	a5,a4,800033c2 <sys_sleep+0x50>
  }
  release(&tickslock);
    800033e8:	00014517          	auipc	a0,0x14
    800033ec:	ee850513          	addi	a0,a0,-280 # 800172d0 <tickslock>
    800033f0:	ffffe097          	auipc	ra,0xffffe
    800033f4:	8a8080e7          	jalr	-1880(ra) # 80000c98 <release>
  return 0;
    800033f8:	4781                	li	a5,0
}
    800033fa:	853e                	mv	a0,a5
    800033fc:	70e2                	ld	ra,56(sp)
    800033fe:	7442                	ld	s0,48(sp)
    80003400:	74a2                	ld	s1,40(sp)
    80003402:	7902                	ld	s2,32(sp)
    80003404:	69e2                	ld	s3,24(sp)
    80003406:	6121                	addi	sp,sp,64
    80003408:	8082                	ret
      release(&tickslock);
    8000340a:	00014517          	auipc	a0,0x14
    8000340e:	ec650513          	addi	a0,a0,-314 # 800172d0 <tickslock>
    80003412:	ffffe097          	auipc	ra,0xffffe
    80003416:	886080e7          	jalr	-1914(ra) # 80000c98 <release>
      return -1;
    8000341a:	57fd                	li	a5,-1
    8000341c:	bff9                	j	800033fa <sys_sleep+0x88>

000000008000341e <sys_kill>:

uint64
sys_kill(void)
{
    8000341e:	1101                	addi	sp,sp,-32
    80003420:	ec06                	sd	ra,24(sp)
    80003422:	e822                	sd	s0,16(sp)
    80003424:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003426:	fec40593          	addi	a1,s0,-20
    8000342a:	4501                	li	a0,0
    8000342c:	00000097          	auipc	ra,0x0
    80003430:	c0a080e7          	jalr	-1014(ra) # 80003036 <argint>
    80003434:	87aa                	mv	a5,a0
    return -1;
    80003436:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003438:	0007c863          	bltz	a5,80003448 <sys_kill+0x2a>
  return kill(pid);
    8000343c:	fec42503          	lw	a0,-20(s0)
    80003440:	fffff097          	auipc	ra,0xfffff
    80003444:	538080e7          	jalr	1336(ra) # 80002978 <kill>
}
    80003448:	60e2                	ld	ra,24(sp)
    8000344a:	6442                	ld	s0,16(sp)
    8000344c:	6105                	addi	sp,sp,32
    8000344e:	8082                	ret

0000000080003450 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003450:	1101                	addi	sp,sp,-32
    80003452:	ec06                	sd	ra,24(sp)
    80003454:	e822                	sd	s0,16(sp)
    80003456:	e426                	sd	s1,8(sp)
    80003458:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000345a:	00014517          	auipc	a0,0x14
    8000345e:	e7650513          	addi	a0,a0,-394 # 800172d0 <tickslock>
    80003462:	ffffd097          	auipc	ra,0xffffd
    80003466:	782080e7          	jalr	1922(ra) # 80000be4 <acquire>
  xticks = ticks;
    8000346a:	00006497          	auipc	s1,0x6
    8000346e:	bc64a483          	lw	s1,-1082(s1) # 80009030 <ticks>
  release(&tickslock);
    80003472:	00014517          	auipc	a0,0x14
    80003476:	e5e50513          	addi	a0,a0,-418 # 800172d0 <tickslock>
    8000347a:	ffffe097          	auipc	ra,0xffffe
    8000347e:	81e080e7          	jalr	-2018(ra) # 80000c98 <release>
  return xticks;
}
    80003482:	02049513          	slli	a0,s1,0x20
    80003486:	9101                	srli	a0,a0,0x20
    80003488:	60e2                	ld	ra,24(sp)
    8000348a:	6442                	ld	s0,16(sp)
    8000348c:	64a2                	ld	s1,8(sp)
    8000348e:	6105                	addi	sp,sp,32
    80003490:	8082                	ret

0000000080003492 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003492:	7179                	addi	sp,sp,-48
    80003494:	f406                	sd	ra,40(sp)
    80003496:	f022                	sd	s0,32(sp)
    80003498:	ec26                	sd	s1,24(sp)
    8000349a:	e84a                	sd	s2,16(sp)
    8000349c:	e44e                	sd	s3,8(sp)
    8000349e:	e052                	sd	s4,0(sp)
    800034a0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800034a2:	00005597          	auipc	a1,0x5
    800034a6:	13e58593          	addi	a1,a1,318 # 800085e0 <syscalls+0xe8>
    800034aa:	00014517          	auipc	a0,0x14
    800034ae:	e3e50513          	addi	a0,a0,-450 # 800172e8 <bcache>
    800034b2:	ffffd097          	auipc	ra,0xffffd
    800034b6:	6a2080e7          	jalr	1698(ra) # 80000b54 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800034ba:	0001c797          	auipc	a5,0x1c
    800034be:	e2e78793          	addi	a5,a5,-466 # 8001f2e8 <bcache+0x8000>
    800034c2:	0001c717          	auipc	a4,0x1c
    800034c6:	08e70713          	addi	a4,a4,142 # 8001f550 <bcache+0x8268>
    800034ca:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800034ce:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800034d2:	00014497          	auipc	s1,0x14
    800034d6:	e2e48493          	addi	s1,s1,-466 # 80017300 <bcache+0x18>
    b->next = bcache.head.next;
    800034da:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800034dc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800034de:	00005a17          	auipc	s4,0x5
    800034e2:	10aa0a13          	addi	s4,s4,266 # 800085e8 <syscalls+0xf0>
    b->next = bcache.head.next;
    800034e6:	2b893783          	ld	a5,696(s2)
    800034ea:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800034ec:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800034f0:	85d2                	mv	a1,s4
    800034f2:	01048513          	addi	a0,s1,16
    800034f6:	00001097          	auipc	ra,0x1
    800034fa:	4bc080e7          	jalr	1212(ra) # 800049b2 <initsleeplock>
    bcache.head.next->prev = b;
    800034fe:	2b893783          	ld	a5,696(s2)
    80003502:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003504:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003508:	45848493          	addi	s1,s1,1112
    8000350c:	fd349de3          	bne	s1,s3,800034e6 <binit+0x54>
  }
}
    80003510:	70a2                	ld	ra,40(sp)
    80003512:	7402                	ld	s0,32(sp)
    80003514:	64e2                	ld	s1,24(sp)
    80003516:	6942                	ld	s2,16(sp)
    80003518:	69a2                	ld	s3,8(sp)
    8000351a:	6a02                	ld	s4,0(sp)
    8000351c:	6145                	addi	sp,sp,48
    8000351e:	8082                	ret

0000000080003520 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003520:	7179                	addi	sp,sp,-48
    80003522:	f406                	sd	ra,40(sp)
    80003524:	f022                	sd	s0,32(sp)
    80003526:	ec26                	sd	s1,24(sp)
    80003528:	e84a                	sd	s2,16(sp)
    8000352a:	e44e                	sd	s3,8(sp)
    8000352c:	1800                	addi	s0,sp,48
    8000352e:	89aa                	mv	s3,a0
    80003530:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003532:	00014517          	auipc	a0,0x14
    80003536:	db650513          	addi	a0,a0,-586 # 800172e8 <bcache>
    8000353a:	ffffd097          	auipc	ra,0xffffd
    8000353e:	6aa080e7          	jalr	1706(ra) # 80000be4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003542:	0001c497          	auipc	s1,0x1c
    80003546:	05e4b483          	ld	s1,94(s1) # 8001f5a0 <bcache+0x82b8>
    8000354a:	0001c797          	auipc	a5,0x1c
    8000354e:	00678793          	addi	a5,a5,6 # 8001f550 <bcache+0x8268>
    80003552:	02f48f63          	beq	s1,a5,80003590 <bread+0x70>
    80003556:	873e                	mv	a4,a5
    80003558:	a021                	j	80003560 <bread+0x40>
    8000355a:	68a4                	ld	s1,80(s1)
    8000355c:	02e48a63          	beq	s1,a4,80003590 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003560:	449c                	lw	a5,8(s1)
    80003562:	ff379ce3          	bne	a5,s3,8000355a <bread+0x3a>
    80003566:	44dc                	lw	a5,12(s1)
    80003568:	ff2799e3          	bne	a5,s2,8000355a <bread+0x3a>
      b->refcnt++;
    8000356c:	40bc                	lw	a5,64(s1)
    8000356e:	2785                	addiw	a5,a5,1
    80003570:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003572:	00014517          	auipc	a0,0x14
    80003576:	d7650513          	addi	a0,a0,-650 # 800172e8 <bcache>
    8000357a:	ffffd097          	auipc	ra,0xffffd
    8000357e:	71e080e7          	jalr	1822(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    80003582:	01048513          	addi	a0,s1,16
    80003586:	00001097          	auipc	ra,0x1
    8000358a:	466080e7          	jalr	1126(ra) # 800049ec <acquiresleep>
      return b;
    8000358e:	a8b9                	j	800035ec <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003590:	0001c497          	auipc	s1,0x1c
    80003594:	0084b483          	ld	s1,8(s1) # 8001f598 <bcache+0x82b0>
    80003598:	0001c797          	auipc	a5,0x1c
    8000359c:	fb878793          	addi	a5,a5,-72 # 8001f550 <bcache+0x8268>
    800035a0:	00f48863          	beq	s1,a5,800035b0 <bread+0x90>
    800035a4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800035a6:	40bc                	lw	a5,64(s1)
    800035a8:	cf81                	beqz	a5,800035c0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800035aa:	64a4                	ld	s1,72(s1)
    800035ac:	fee49de3          	bne	s1,a4,800035a6 <bread+0x86>
  panic("bget: no buffers");
    800035b0:	00005517          	auipc	a0,0x5
    800035b4:	04050513          	addi	a0,a0,64 # 800085f0 <syscalls+0xf8>
    800035b8:	ffffd097          	auipc	ra,0xffffd
    800035bc:	f86080e7          	jalr	-122(ra) # 8000053e <panic>
      b->dev = dev;
    800035c0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800035c4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800035c8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800035cc:	4785                	li	a5,1
    800035ce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800035d0:	00014517          	auipc	a0,0x14
    800035d4:	d1850513          	addi	a0,a0,-744 # 800172e8 <bcache>
    800035d8:	ffffd097          	auipc	ra,0xffffd
    800035dc:	6c0080e7          	jalr	1728(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    800035e0:	01048513          	addi	a0,s1,16
    800035e4:	00001097          	auipc	ra,0x1
    800035e8:	408080e7          	jalr	1032(ra) # 800049ec <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800035ec:	409c                	lw	a5,0(s1)
    800035ee:	cb89                	beqz	a5,80003600 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800035f0:	8526                	mv	a0,s1
    800035f2:	70a2                	ld	ra,40(sp)
    800035f4:	7402                	ld	s0,32(sp)
    800035f6:	64e2                	ld	s1,24(sp)
    800035f8:	6942                	ld	s2,16(sp)
    800035fa:	69a2                	ld	s3,8(sp)
    800035fc:	6145                	addi	sp,sp,48
    800035fe:	8082                	ret
    virtio_disk_rw(b, 0);
    80003600:	4581                	li	a1,0
    80003602:	8526                	mv	a0,s1
    80003604:	00003097          	auipc	ra,0x3
    80003608:	f12080e7          	jalr	-238(ra) # 80006516 <virtio_disk_rw>
    b->valid = 1;
    8000360c:	4785                	li	a5,1
    8000360e:	c09c                	sw	a5,0(s1)
  return b;
    80003610:	b7c5                	j	800035f0 <bread+0xd0>

0000000080003612 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003612:	1101                	addi	sp,sp,-32
    80003614:	ec06                	sd	ra,24(sp)
    80003616:	e822                	sd	s0,16(sp)
    80003618:	e426                	sd	s1,8(sp)
    8000361a:	1000                	addi	s0,sp,32
    8000361c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000361e:	0541                	addi	a0,a0,16
    80003620:	00001097          	auipc	ra,0x1
    80003624:	466080e7          	jalr	1126(ra) # 80004a86 <holdingsleep>
    80003628:	cd01                	beqz	a0,80003640 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000362a:	4585                	li	a1,1
    8000362c:	8526                	mv	a0,s1
    8000362e:	00003097          	auipc	ra,0x3
    80003632:	ee8080e7          	jalr	-280(ra) # 80006516 <virtio_disk_rw>
}
    80003636:	60e2                	ld	ra,24(sp)
    80003638:	6442                	ld	s0,16(sp)
    8000363a:	64a2                	ld	s1,8(sp)
    8000363c:	6105                	addi	sp,sp,32
    8000363e:	8082                	ret
    panic("bwrite");
    80003640:	00005517          	auipc	a0,0x5
    80003644:	fc850513          	addi	a0,a0,-56 # 80008608 <syscalls+0x110>
    80003648:	ffffd097          	auipc	ra,0xffffd
    8000364c:	ef6080e7          	jalr	-266(ra) # 8000053e <panic>

0000000080003650 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003650:	1101                	addi	sp,sp,-32
    80003652:	ec06                	sd	ra,24(sp)
    80003654:	e822                	sd	s0,16(sp)
    80003656:	e426                	sd	s1,8(sp)
    80003658:	e04a                	sd	s2,0(sp)
    8000365a:	1000                	addi	s0,sp,32
    8000365c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000365e:	01050913          	addi	s2,a0,16
    80003662:	854a                	mv	a0,s2
    80003664:	00001097          	auipc	ra,0x1
    80003668:	422080e7          	jalr	1058(ra) # 80004a86 <holdingsleep>
    8000366c:	c92d                	beqz	a0,800036de <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000366e:	854a                	mv	a0,s2
    80003670:	00001097          	auipc	ra,0x1
    80003674:	3d2080e7          	jalr	978(ra) # 80004a42 <releasesleep>

  acquire(&bcache.lock);
    80003678:	00014517          	auipc	a0,0x14
    8000367c:	c7050513          	addi	a0,a0,-912 # 800172e8 <bcache>
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	564080e7          	jalr	1380(ra) # 80000be4 <acquire>
  b->refcnt--;
    80003688:	40bc                	lw	a5,64(s1)
    8000368a:	37fd                	addiw	a5,a5,-1
    8000368c:	0007871b          	sext.w	a4,a5
    80003690:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003692:	eb05                	bnez	a4,800036c2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003694:	68bc                	ld	a5,80(s1)
    80003696:	64b8                	ld	a4,72(s1)
    80003698:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000369a:	64bc                	ld	a5,72(s1)
    8000369c:	68b8                	ld	a4,80(s1)
    8000369e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800036a0:	0001c797          	auipc	a5,0x1c
    800036a4:	c4878793          	addi	a5,a5,-952 # 8001f2e8 <bcache+0x8000>
    800036a8:	2b87b703          	ld	a4,696(a5)
    800036ac:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800036ae:	0001c717          	auipc	a4,0x1c
    800036b2:	ea270713          	addi	a4,a4,-350 # 8001f550 <bcache+0x8268>
    800036b6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800036b8:	2b87b703          	ld	a4,696(a5)
    800036bc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800036be:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800036c2:	00014517          	auipc	a0,0x14
    800036c6:	c2650513          	addi	a0,a0,-986 # 800172e8 <bcache>
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	5ce080e7          	jalr	1486(ra) # 80000c98 <release>
}
    800036d2:	60e2                	ld	ra,24(sp)
    800036d4:	6442                	ld	s0,16(sp)
    800036d6:	64a2                	ld	s1,8(sp)
    800036d8:	6902                	ld	s2,0(sp)
    800036da:	6105                	addi	sp,sp,32
    800036dc:	8082                	ret
    panic("brelse");
    800036de:	00005517          	auipc	a0,0x5
    800036e2:	f3250513          	addi	a0,a0,-206 # 80008610 <syscalls+0x118>
    800036e6:	ffffd097          	auipc	ra,0xffffd
    800036ea:	e58080e7          	jalr	-424(ra) # 8000053e <panic>

00000000800036ee <bpin>:

void
bpin(struct buf *b) {
    800036ee:	1101                	addi	sp,sp,-32
    800036f0:	ec06                	sd	ra,24(sp)
    800036f2:	e822                	sd	s0,16(sp)
    800036f4:	e426                	sd	s1,8(sp)
    800036f6:	1000                	addi	s0,sp,32
    800036f8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800036fa:	00014517          	auipc	a0,0x14
    800036fe:	bee50513          	addi	a0,a0,-1042 # 800172e8 <bcache>
    80003702:	ffffd097          	auipc	ra,0xffffd
    80003706:	4e2080e7          	jalr	1250(ra) # 80000be4 <acquire>
  b->refcnt++;
    8000370a:	40bc                	lw	a5,64(s1)
    8000370c:	2785                	addiw	a5,a5,1
    8000370e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003710:	00014517          	auipc	a0,0x14
    80003714:	bd850513          	addi	a0,a0,-1064 # 800172e8 <bcache>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	580080e7          	jalr	1408(ra) # 80000c98 <release>
}
    80003720:	60e2                	ld	ra,24(sp)
    80003722:	6442                	ld	s0,16(sp)
    80003724:	64a2                	ld	s1,8(sp)
    80003726:	6105                	addi	sp,sp,32
    80003728:	8082                	ret

000000008000372a <bunpin>:

void
bunpin(struct buf *b) {
    8000372a:	1101                	addi	sp,sp,-32
    8000372c:	ec06                	sd	ra,24(sp)
    8000372e:	e822                	sd	s0,16(sp)
    80003730:	e426                	sd	s1,8(sp)
    80003732:	1000                	addi	s0,sp,32
    80003734:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003736:	00014517          	auipc	a0,0x14
    8000373a:	bb250513          	addi	a0,a0,-1102 # 800172e8 <bcache>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	4a6080e7          	jalr	1190(ra) # 80000be4 <acquire>
  b->refcnt--;
    80003746:	40bc                	lw	a5,64(s1)
    80003748:	37fd                	addiw	a5,a5,-1
    8000374a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000374c:	00014517          	auipc	a0,0x14
    80003750:	b9c50513          	addi	a0,a0,-1124 # 800172e8 <bcache>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	544080e7          	jalr	1348(ra) # 80000c98 <release>
}
    8000375c:	60e2                	ld	ra,24(sp)
    8000375e:	6442                	ld	s0,16(sp)
    80003760:	64a2                	ld	s1,8(sp)
    80003762:	6105                	addi	sp,sp,32
    80003764:	8082                	ret

0000000080003766 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003766:	1101                	addi	sp,sp,-32
    80003768:	ec06                	sd	ra,24(sp)
    8000376a:	e822                	sd	s0,16(sp)
    8000376c:	e426                	sd	s1,8(sp)
    8000376e:	e04a                	sd	s2,0(sp)
    80003770:	1000                	addi	s0,sp,32
    80003772:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003774:	00d5d59b          	srliw	a1,a1,0xd
    80003778:	0001c797          	auipc	a5,0x1c
    8000377c:	24c7a783          	lw	a5,588(a5) # 8001f9c4 <sb+0x1c>
    80003780:	9dbd                	addw	a1,a1,a5
    80003782:	00000097          	auipc	ra,0x0
    80003786:	d9e080e7          	jalr	-610(ra) # 80003520 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000378a:	0074f713          	andi	a4,s1,7
    8000378e:	4785                	li	a5,1
    80003790:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003794:	14ce                	slli	s1,s1,0x33
    80003796:	90d9                	srli	s1,s1,0x36
    80003798:	00950733          	add	a4,a0,s1
    8000379c:	05874703          	lbu	a4,88(a4)
    800037a0:	00e7f6b3          	and	a3,a5,a4
    800037a4:	c69d                	beqz	a3,800037d2 <bfree+0x6c>
    800037a6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800037a8:	94aa                	add	s1,s1,a0
    800037aa:	fff7c793          	not	a5,a5
    800037ae:	8ff9                	and	a5,a5,a4
    800037b0:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800037b4:	00001097          	auipc	ra,0x1
    800037b8:	118080e7          	jalr	280(ra) # 800048cc <log_write>
  brelse(bp);
    800037bc:	854a                	mv	a0,s2
    800037be:	00000097          	auipc	ra,0x0
    800037c2:	e92080e7          	jalr	-366(ra) # 80003650 <brelse>
}
    800037c6:	60e2                	ld	ra,24(sp)
    800037c8:	6442                	ld	s0,16(sp)
    800037ca:	64a2                	ld	s1,8(sp)
    800037cc:	6902                	ld	s2,0(sp)
    800037ce:	6105                	addi	sp,sp,32
    800037d0:	8082                	ret
    panic("freeing free block");
    800037d2:	00005517          	auipc	a0,0x5
    800037d6:	e4650513          	addi	a0,a0,-442 # 80008618 <syscalls+0x120>
    800037da:	ffffd097          	auipc	ra,0xffffd
    800037de:	d64080e7          	jalr	-668(ra) # 8000053e <panic>

00000000800037e2 <balloc>:
{
    800037e2:	711d                	addi	sp,sp,-96
    800037e4:	ec86                	sd	ra,88(sp)
    800037e6:	e8a2                	sd	s0,80(sp)
    800037e8:	e4a6                	sd	s1,72(sp)
    800037ea:	e0ca                	sd	s2,64(sp)
    800037ec:	fc4e                	sd	s3,56(sp)
    800037ee:	f852                	sd	s4,48(sp)
    800037f0:	f456                	sd	s5,40(sp)
    800037f2:	f05a                	sd	s6,32(sp)
    800037f4:	ec5e                	sd	s7,24(sp)
    800037f6:	e862                	sd	s8,16(sp)
    800037f8:	e466                	sd	s9,8(sp)
    800037fa:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800037fc:	0001c797          	auipc	a5,0x1c
    80003800:	1b07a783          	lw	a5,432(a5) # 8001f9ac <sb+0x4>
    80003804:	cbd1                	beqz	a5,80003898 <balloc+0xb6>
    80003806:	8baa                	mv	s7,a0
    80003808:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000380a:	0001cb17          	auipc	s6,0x1c
    8000380e:	19eb0b13          	addi	s6,s6,414 # 8001f9a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003812:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003814:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003816:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003818:	6c89                	lui	s9,0x2
    8000381a:	a831                	j	80003836 <balloc+0x54>
    brelse(bp);
    8000381c:	854a                	mv	a0,s2
    8000381e:	00000097          	auipc	ra,0x0
    80003822:	e32080e7          	jalr	-462(ra) # 80003650 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003826:	015c87bb          	addw	a5,s9,s5
    8000382a:	00078a9b          	sext.w	s5,a5
    8000382e:	004b2703          	lw	a4,4(s6)
    80003832:	06eaf363          	bgeu	s5,a4,80003898 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003836:	41fad79b          	sraiw	a5,s5,0x1f
    8000383a:	0137d79b          	srliw	a5,a5,0x13
    8000383e:	015787bb          	addw	a5,a5,s5
    80003842:	40d7d79b          	sraiw	a5,a5,0xd
    80003846:	01cb2583          	lw	a1,28(s6)
    8000384a:	9dbd                	addw	a1,a1,a5
    8000384c:	855e                	mv	a0,s7
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	cd2080e7          	jalr	-814(ra) # 80003520 <bread>
    80003856:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003858:	004b2503          	lw	a0,4(s6)
    8000385c:	000a849b          	sext.w	s1,s5
    80003860:	8662                	mv	a2,s8
    80003862:	faa4fde3          	bgeu	s1,a0,8000381c <balloc+0x3a>
      m = 1 << (bi % 8);
    80003866:	41f6579b          	sraiw	a5,a2,0x1f
    8000386a:	01d7d69b          	srliw	a3,a5,0x1d
    8000386e:	00c6873b          	addw	a4,a3,a2
    80003872:	00777793          	andi	a5,a4,7
    80003876:	9f95                	subw	a5,a5,a3
    80003878:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000387c:	4037571b          	sraiw	a4,a4,0x3
    80003880:	00e906b3          	add	a3,s2,a4
    80003884:	0586c683          	lbu	a3,88(a3)
    80003888:	00d7f5b3          	and	a1,a5,a3
    8000388c:	cd91                	beqz	a1,800038a8 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000388e:	2605                	addiw	a2,a2,1
    80003890:	2485                	addiw	s1,s1,1
    80003892:	fd4618e3          	bne	a2,s4,80003862 <balloc+0x80>
    80003896:	b759                	j	8000381c <balloc+0x3a>
  panic("balloc: out of blocks");
    80003898:	00005517          	auipc	a0,0x5
    8000389c:	d9850513          	addi	a0,a0,-616 # 80008630 <syscalls+0x138>
    800038a0:	ffffd097          	auipc	ra,0xffffd
    800038a4:	c9e080e7          	jalr	-866(ra) # 8000053e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800038a8:	974a                	add	a4,a4,s2
    800038aa:	8fd5                	or	a5,a5,a3
    800038ac:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800038b0:	854a                	mv	a0,s2
    800038b2:	00001097          	auipc	ra,0x1
    800038b6:	01a080e7          	jalr	26(ra) # 800048cc <log_write>
        brelse(bp);
    800038ba:	854a                	mv	a0,s2
    800038bc:	00000097          	auipc	ra,0x0
    800038c0:	d94080e7          	jalr	-620(ra) # 80003650 <brelse>
  bp = bread(dev, bno);
    800038c4:	85a6                	mv	a1,s1
    800038c6:	855e                	mv	a0,s7
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	c58080e7          	jalr	-936(ra) # 80003520 <bread>
    800038d0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800038d2:	40000613          	li	a2,1024
    800038d6:	4581                	li	a1,0
    800038d8:	05850513          	addi	a0,a0,88
    800038dc:	ffffd097          	auipc	ra,0xffffd
    800038e0:	404080e7          	jalr	1028(ra) # 80000ce0 <memset>
  log_write(bp);
    800038e4:	854a                	mv	a0,s2
    800038e6:	00001097          	auipc	ra,0x1
    800038ea:	fe6080e7          	jalr	-26(ra) # 800048cc <log_write>
  brelse(bp);
    800038ee:	854a                	mv	a0,s2
    800038f0:	00000097          	auipc	ra,0x0
    800038f4:	d60080e7          	jalr	-672(ra) # 80003650 <brelse>
}
    800038f8:	8526                	mv	a0,s1
    800038fa:	60e6                	ld	ra,88(sp)
    800038fc:	6446                	ld	s0,80(sp)
    800038fe:	64a6                	ld	s1,72(sp)
    80003900:	6906                	ld	s2,64(sp)
    80003902:	79e2                	ld	s3,56(sp)
    80003904:	7a42                	ld	s4,48(sp)
    80003906:	7aa2                	ld	s5,40(sp)
    80003908:	7b02                	ld	s6,32(sp)
    8000390a:	6be2                	ld	s7,24(sp)
    8000390c:	6c42                	ld	s8,16(sp)
    8000390e:	6ca2                	ld	s9,8(sp)
    80003910:	6125                	addi	sp,sp,96
    80003912:	8082                	ret

0000000080003914 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003914:	7179                	addi	sp,sp,-48
    80003916:	f406                	sd	ra,40(sp)
    80003918:	f022                	sd	s0,32(sp)
    8000391a:	ec26                	sd	s1,24(sp)
    8000391c:	e84a                	sd	s2,16(sp)
    8000391e:	e44e                	sd	s3,8(sp)
    80003920:	e052                	sd	s4,0(sp)
    80003922:	1800                	addi	s0,sp,48
    80003924:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003926:	47ad                	li	a5,11
    80003928:	04b7fe63          	bgeu	a5,a1,80003984 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000392c:	ff45849b          	addiw	s1,a1,-12
    80003930:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003934:	0ff00793          	li	a5,255
    80003938:	0ae7e363          	bltu	a5,a4,800039de <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000393c:	08052583          	lw	a1,128(a0)
    80003940:	c5ad                	beqz	a1,800039aa <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003942:	00092503          	lw	a0,0(s2)
    80003946:	00000097          	auipc	ra,0x0
    8000394a:	bda080e7          	jalr	-1062(ra) # 80003520 <bread>
    8000394e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003950:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003954:	02049593          	slli	a1,s1,0x20
    80003958:	9181                	srli	a1,a1,0x20
    8000395a:	058a                	slli	a1,a1,0x2
    8000395c:	00b784b3          	add	s1,a5,a1
    80003960:	0004a983          	lw	s3,0(s1)
    80003964:	04098d63          	beqz	s3,800039be <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003968:	8552                	mv	a0,s4
    8000396a:	00000097          	auipc	ra,0x0
    8000396e:	ce6080e7          	jalr	-794(ra) # 80003650 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003972:	854e                	mv	a0,s3
    80003974:	70a2                	ld	ra,40(sp)
    80003976:	7402                	ld	s0,32(sp)
    80003978:	64e2                	ld	s1,24(sp)
    8000397a:	6942                	ld	s2,16(sp)
    8000397c:	69a2                	ld	s3,8(sp)
    8000397e:	6a02                	ld	s4,0(sp)
    80003980:	6145                	addi	sp,sp,48
    80003982:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003984:	02059493          	slli	s1,a1,0x20
    80003988:	9081                	srli	s1,s1,0x20
    8000398a:	048a                	slli	s1,s1,0x2
    8000398c:	94aa                	add	s1,s1,a0
    8000398e:	0504a983          	lw	s3,80(s1)
    80003992:	fe0990e3          	bnez	s3,80003972 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003996:	4108                	lw	a0,0(a0)
    80003998:	00000097          	auipc	ra,0x0
    8000399c:	e4a080e7          	jalr	-438(ra) # 800037e2 <balloc>
    800039a0:	0005099b          	sext.w	s3,a0
    800039a4:	0534a823          	sw	s3,80(s1)
    800039a8:	b7e9                	j	80003972 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800039aa:	4108                	lw	a0,0(a0)
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	e36080e7          	jalr	-458(ra) # 800037e2 <balloc>
    800039b4:	0005059b          	sext.w	a1,a0
    800039b8:	08b92023          	sw	a1,128(s2)
    800039bc:	b759                	j	80003942 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800039be:	00092503          	lw	a0,0(s2)
    800039c2:	00000097          	auipc	ra,0x0
    800039c6:	e20080e7          	jalr	-480(ra) # 800037e2 <balloc>
    800039ca:	0005099b          	sext.w	s3,a0
    800039ce:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800039d2:	8552                	mv	a0,s4
    800039d4:	00001097          	auipc	ra,0x1
    800039d8:	ef8080e7          	jalr	-264(ra) # 800048cc <log_write>
    800039dc:	b771                	j	80003968 <bmap+0x54>
  panic("bmap: out of range");
    800039de:	00005517          	auipc	a0,0x5
    800039e2:	c6a50513          	addi	a0,a0,-918 # 80008648 <syscalls+0x150>
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	b58080e7          	jalr	-1192(ra) # 8000053e <panic>

00000000800039ee <iget>:
{
    800039ee:	7179                	addi	sp,sp,-48
    800039f0:	f406                	sd	ra,40(sp)
    800039f2:	f022                	sd	s0,32(sp)
    800039f4:	ec26                	sd	s1,24(sp)
    800039f6:	e84a                	sd	s2,16(sp)
    800039f8:	e44e                	sd	s3,8(sp)
    800039fa:	e052                	sd	s4,0(sp)
    800039fc:	1800                	addi	s0,sp,48
    800039fe:	89aa                	mv	s3,a0
    80003a00:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003a02:	0001c517          	auipc	a0,0x1c
    80003a06:	fc650513          	addi	a0,a0,-58 # 8001f9c8 <itable>
    80003a0a:	ffffd097          	auipc	ra,0xffffd
    80003a0e:	1da080e7          	jalr	474(ra) # 80000be4 <acquire>
  empty = 0;
    80003a12:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a14:	0001c497          	auipc	s1,0x1c
    80003a18:	fcc48493          	addi	s1,s1,-52 # 8001f9e0 <itable+0x18>
    80003a1c:	0001e697          	auipc	a3,0x1e
    80003a20:	a5468693          	addi	a3,a3,-1452 # 80021470 <log>
    80003a24:	a039                	j	80003a32 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a26:	02090b63          	beqz	s2,80003a5c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003a2a:	08848493          	addi	s1,s1,136
    80003a2e:	02d48a63          	beq	s1,a3,80003a62 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003a32:	449c                	lw	a5,8(s1)
    80003a34:	fef059e3          	blez	a5,80003a26 <iget+0x38>
    80003a38:	4098                	lw	a4,0(s1)
    80003a3a:	ff3716e3          	bne	a4,s3,80003a26 <iget+0x38>
    80003a3e:	40d8                	lw	a4,4(s1)
    80003a40:	ff4713e3          	bne	a4,s4,80003a26 <iget+0x38>
      ip->ref++;
    80003a44:	2785                	addiw	a5,a5,1
    80003a46:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003a48:	0001c517          	auipc	a0,0x1c
    80003a4c:	f8050513          	addi	a0,a0,-128 # 8001f9c8 <itable>
    80003a50:	ffffd097          	auipc	ra,0xffffd
    80003a54:	248080e7          	jalr	584(ra) # 80000c98 <release>
      return ip;
    80003a58:	8926                	mv	s2,s1
    80003a5a:	a03d                	j	80003a88 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003a5c:	f7f9                	bnez	a5,80003a2a <iget+0x3c>
    80003a5e:	8926                	mv	s2,s1
    80003a60:	b7e9                	j	80003a2a <iget+0x3c>
  if(empty == 0)
    80003a62:	02090c63          	beqz	s2,80003a9a <iget+0xac>
  ip->dev = dev;
    80003a66:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003a6a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003a6e:	4785                	li	a5,1
    80003a70:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003a74:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003a78:	0001c517          	auipc	a0,0x1c
    80003a7c:	f5050513          	addi	a0,a0,-176 # 8001f9c8 <itable>
    80003a80:	ffffd097          	auipc	ra,0xffffd
    80003a84:	218080e7          	jalr	536(ra) # 80000c98 <release>
}
    80003a88:	854a                	mv	a0,s2
    80003a8a:	70a2                	ld	ra,40(sp)
    80003a8c:	7402                	ld	s0,32(sp)
    80003a8e:	64e2                	ld	s1,24(sp)
    80003a90:	6942                	ld	s2,16(sp)
    80003a92:	69a2                	ld	s3,8(sp)
    80003a94:	6a02                	ld	s4,0(sp)
    80003a96:	6145                	addi	sp,sp,48
    80003a98:	8082                	ret
    panic("iget: no inodes");
    80003a9a:	00005517          	auipc	a0,0x5
    80003a9e:	bc650513          	addi	a0,a0,-1082 # 80008660 <syscalls+0x168>
    80003aa2:	ffffd097          	auipc	ra,0xffffd
    80003aa6:	a9c080e7          	jalr	-1380(ra) # 8000053e <panic>

0000000080003aaa <fsinit>:
fsinit(int dev) {
    80003aaa:	7179                	addi	sp,sp,-48
    80003aac:	f406                	sd	ra,40(sp)
    80003aae:	f022                	sd	s0,32(sp)
    80003ab0:	ec26                	sd	s1,24(sp)
    80003ab2:	e84a                	sd	s2,16(sp)
    80003ab4:	e44e                	sd	s3,8(sp)
    80003ab6:	1800                	addi	s0,sp,48
    80003ab8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003aba:	4585                	li	a1,1
    80003abc:	00000097          	auipc	ra,0x0
    80003ac0:	a64080e7          	jalr	-1436(ra) # 80003520 <bread>
    80003ac4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003ac6:	0001c997          	auipc	s3,0x1c
    80003aca:	ee298993          	addi	s3,s3,-286 # 8001f9a8 <sb>
    80003ace:	02000613          	li	a2,32
    80003ad2:	05850593          	addi	a1,a0,88
    80003ad6:	854e                	mv	a0,s3
    80003ad8:	ffffd097          	auipc	ra,0xffffd
    80003adc:	268080e7          	jalr	616(ra) # 80000d40 <memmove>
  brelse(bp);
    80003ae0:	8526                	mv	a0,s1
    80003ae2:	00000097          	auipc	ra,0x0
    80003ae6:	b6e080e7          	jalr	-1170(ra) # 80003650 <brelse>
  if(sb.magic != FSMAGIC)
    80003aea:	0009a703          	lw	a4,0(s3)
    80003aee:	102037b7          	lui	a5,0x10203
    80003af2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003af6:	02f71263          	bne	a4,a5,80003b1a <fsinit+0x70>
  initlog(dev, &sb);
    80003afa:	0001c597          	auipc	a1,0x1c
    80003afe:	eae58593          	addi	a1,a1,-338 # 8001f9a8 <sb>
    80003b02:	854a                	mv	a0,s2
    80003b04:	00001097          	auipc	ra,0x1
    80003b08:	b4c080e7          	jalr	-1204(ra) # 80004650 <initlog>
}
    80003b0c:	70a2                	ld	ra,40(sp)
    80003b0e:	7402                	ld	s0,32(sp)
    80003b10:	64e2                	ld	s1,24(sp)
    80003b12:	6942                	ld	s2,16(sp)
    80003b14:	69a2                	ld	s3,8(sp)
    80003b16:	6145                	addi	sp,sp,48
    80003b18:	8082                	ret
    panic("invalid file system");
    80003b1a:	00005517          	auipc	a0,0x5
    80003b1e:	b5650513          	addi	a0,a0,-1194 # 80008670 <syscalls+0x178>
    80003b22:	ffffd097          	auipc	ra,0xffffd
    80003b26:	a1c080e7          	jalr	-1508(ra) # 8000053e <panic>

0000000080003b2a <iinit>:
{
    80003b2a:	7179                	addi	sp,sp,-48
    80003b2c:	f406                	sd	ra,40(sp)
    80003b2e:	f022                	sd	s0,32(sp)
    80003b30:	ec26                	sd	s1,24(sp)
    80003b32:	e84a                	sd	s2,16(sp)
    80003b34:	e44e                	sd	s3,8(sp)
    80003b36:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003b38:	00005597          	auipc	a1,0x5
    80003b3c:	b5058593          	addi	a1,a1,-1200 # 80008688 <syscalls+0x190>
    80003b40:	0001c517          	auipc	a0,0x1c
    80003b44:	e8850513          	addi	a0,a0,-376 # 8001f9c8 <itable>
    80003b48:	ffffd097          	auipc	ra,0xffffd
    80003b4c:	00c080e7          	jalr	12(ra) # 80000b54 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003b50:	0001c497          	auipc	s1,0x1c
    80003b54:	ea048493          	addi	s1,s1,-352 # 8001f9f0 <itable+0x28>
    80003b58:	0001e997          	auipc	s3,0x1e
    80003b5c:	92898993          	addi	s3,s3,-1752 # 80021480 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003b60:	00005917          	auipc	s2,0x5
    80003b64:	b3090913          	addi	s2,s2,-1232 # 80008690 <syscalls+0x198>
    80003b68:	85ca                	mv	a1,s2
    80003b6a:	8526                	mv	a0,s1
    80003b6c:	00001097          	auipc	ra,0x1
    80003b70:	e46080e7          	jalr	-442(ra) # 800049b2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003b74:	08848493          	addi	s1,s1,136
    80003b78:	ff3498e3          	bne	s1,s3,80003b68 <iinit+0x3e>
}
    80003b7c:	70a2                	ld	ra,40(sp)
    80003b7e:	7402                	ld	s0,32(sp)
    80003b80:	64e2                	ld	s1,24(sp)
    80003b82:	6942                	ld	s2,16(sp)
    80003b84:	69a2                	ld	s3,8(sp)
    80003b86:	6145                	addi	sp,sp,48
    80003b88:	8082                	ret

0000000080003b8a <ialloc>:
{
    80003b8a:	715d                	addi	sp,sp,-80
    80003b8c:	e486                	sd	ra,72(sp)
    80003b8e:	e0a2                	sd	s0,64(sp)
    80003b90:	fc26                	sd	s1,56(sp)
    80003b92:	f84a                	sd	s2,48(sp)
    80003b94:	f44e                	sd	s3,40(sp)
    80003b96:	f052                	sd	s4,32(sp)
    80003b98:	ec56                	sd	s5,24(sp)
    80003b9a:	e85a                	sd	s6,16(sp)
    80003b9c:	e45e                	sd	s7,8(sp)
    80003b9e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ba0:	0001c717          	auipc	a4,0x1c
    80003ba4:	e1472703          	lw	a4,-492(a4) # 8001f9b4 <sb+0xc>
    80003ba8:	4785                	li	a5,1
    80003baa:	04e7fa63          	bgeu	a5,a4,80003bfe <ialloc+0x74>
    80003bae:	8aaa                	mv	s5,a0
    80003bb0:	8bae                	mv	s7,a1
    80003bb2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003bb4:	0001ca17          	auipc	s4,0x1c
    80003bb8:	df4a0a13          	addi	s4,s4,-524 # 8001f9a8 <sb>
    80003bbc:	00048b1b          	sext.w	s6,s1
    80003bc0:	0044d593          	srli	a1,s1,0x4
    80003bc4:	018a2783          	lw	a5,24(s4)
    80003bc8:	9dbd                	addw	a1,a1,a5
    80003bca:	8556                	mv	a0,s5
    80003bcc:	00000097          	auipc	ra,0x0
    80003bd0:	954080e7          	jalr	-1708(ra) # 80003520 <bread>
    80003bd4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003bd6:	05850993          	addi	s3,a0,88
    80003bda:	00f4f793          	andi	a5,s1,15
    80003bde:	079a                	slli	a5,a5,0x6
    80003be0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003be2:	00099783          	lh	a5,0(s3)
    80003be6:	c785                	beqz	a5,80003c0e <ialloc+0x84>
    brelse(bp);
    80003be8:	00000097          	auipc	ra,0x0
    80003bec:	a68080e7          	jalr	-1432(ra) # 80003650 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003bf0:	0485                	addi	s1,s1,1
    80003bf2:	00ca2703          	lw	a4,12(s4)
    80003bf6:	0004879b          	sext.w	a5,s1
    80003bfa:	fce7e1e3          	bltu	a5,a4,80003bbc <ialloc+0x32>
  panic("ialloc: no inodes");
    80003bfe:	00005517          	auipc	a0,0x5
    80003c02:	a9a50513          	addi	a0,a0,-1382 # 80008698 <syscalls+0x1a0>
    80003c06:	ffffd097          	auipc	ra,0xffffd
    80003c0a:	938080e7          	jalr	-1736(ra) # 8000053e <panic>
      memset(dip, 0, sizeof(*dip));
    80003c0e:	04000613          	li	a2,64
    80003c12:	4581                	li	a1,0
    80003c14:	854e                	mv	a0,s3
    80003c16:	ffffd097          	auipc	ra,0xffffd
    80003c1a:	0ca080e7          	jalr	202(ra) # 80000ce0 <memset>
      dip->type = type;
    80003c1e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003c22:	854a                	mv	a0,s2
    80003c24:	00001097          	auipc	ra,0x1
    80003c28:	ca8080e7          	jalr	-856(ra) # 800048cc <log_write>
      brelse(bp);
    80003c2c:	854a                	mv	a0,s2
    80003c2e:	00000097          	auipc	ra,0x0
    80003c32:	a22080e7          	jalr	-1502(ra) # 80003650 <brelse>
      return iget(dev, inum);
    80003c36:	85da                	mv	a1,s6
    80003c38:	8556                	mv	a0,s5
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	db4080e7          	jalr	-588(ra) # 800039ee <iget>
}
    80003c42:	60a6                	ld	ra,72(sp)
    80003c44:	6406                	ld	s0,64(sp)
    80003c46:	74e2                	ld	s1,56(sp)
    80003c48:	7942                	ld	s2,48(sp)
    80003c4a:	79a2                	ld	s3,40(sp)
    80003c4c:	7a02                	ld	s4,32(sp)
    80003c4e:	6ae2                	ld	s5,24(sp)
    80003c50:	6b42                	ld	s6,16(sp)
    80003c52:	6ba2                	ld	s7,8(sp)
    80003c54:	6161                	addi	sp,sp,80
    80003c56:	8082                	ret

0000000080003c58 <iupdate>:
{
    80003c58:	1101                	addi	sp,sp,-32
    80003c5a:	ec06                	sd	ra,24(sp)
    80003c5c:	e822                	sd	s0,16(sp)
    80003c5e:	e426                	sd	s1,8(sp)
    80003c60:	e04a                	sd	s2,0(sp)
    80003c62:	1000                	addi	s0,sp,32
    80003c64:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c66:	415c                	lw	a5,4(a0)
    80003c68:	0047d79b          	srliw	a5,a5,0x4
    80003c6c:	0001c597          	auipc	a1,0x1c
    80003c70:	d545a583          	lw	a1,-684(a1) # 8001f9c0 <sb+0x18>
    80003c74:	9dbd                	addw	a1,a1,a5
    80003c76:	4108                	lw	a0,0(a0)
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	8a8080e7          	jalr	-1880(ra) # 80003520 <bread>
    80003c80:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c82:	05850793          	addi	a5,a0,88
    80003c86:	40c8                	lw	a0,4(s1)
    80003c88:	893d                	andi	a0,a0,15
    80003c8a:	051a                	slli	a0,a0,0x6
    80003c8c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003c8e:	04449703          	lh	a4,68(s1)
    80003c92:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003c96:	04649703          	lh	a4,70(s1)
    80003c9a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003c9e:	04849703          	lh	a4,72(s1)
    80003ca2:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003ca6:	04a49703          	lh	a4,74(s1)
    80003caa:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003cae:	44f8                	lw	a4,76(s1)
    80003cb0:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003cb2:	03400613          	li	a2,52
    80003cb6:	05048593          	addi	a1,s1,80
    80003cba:	0531                	addi	a0,a0,12
    80003cbc:	ffffd097          	auipc	ra,0xffffd
    80003cc0:	084080e7          	jalr	132(ra) # 80000d40 <memmove>
  log_write(bp);
    80003cc4:	854a                	mv	a0,s2
    80003cc6:	00001097          	auipc	ra,0x1
    80003cca:	c06080e7          	jalr	-1018(ra) # 800048cc <log_write>
  brelse(bp);
    80003cce:	854a                	mv	a0,s2
    80003cd0:	00000097          	auipc	ra,0x0
    80003cd4:	980080e7          	jalr	-1664(ra) # 80003650 <brelse>
}
    80003cd8:	60e2                	ld	ra,24(sp)
    80003cda:	6442                	ld	s0,16(sp)
    80003cdc:	64a2                	ld	s1,8(sp)
    80003cde:	6902                	ld	s2,0(sp)
    80003ce0:	6105                	addi	sp,sp,32
    80003ce2:	8082                	ret

0000000080003ce4 <idup>:
{
    80003ce4:	1101                	addi	sp,sp,-32
    80003ce6:	ec06                	sd	ra,24(sp)
    80003ce8:	e822                	sd	s0,16(sp)
    80003cea:	e426                	sd	s1,8(sp)
    80003cec:	1000                	addi	s0,sp,32
    80003cee:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cf0:	0001c517          	auipc	a0,0x1c
    80003cf4:	cd850513          	addi	a0,a0,-808 # 8001f9c8 <itable>
    80003cf8:	ffffd097          	auipc	ra,0xffffd
    80003cfc:	eec080e7          	jalr	-276(ra) # 80000be4 <acquire>
  ip->ref++;
    80003d00:	449c                	lw	a5,8(s1)
    80003d02:	2785                	addiw	a5,a5,1
    80003d04:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d06:	0001c517          	auipc	a0,0x1c
    80003d0a:	cc250513          	addi	a0,a0,-830 # 8001f9c8 <itable>
    80003d0e:	ffffd097          	auipc	ra,0xffffd
    80003d12:	f8a080e7          	jalr	-118(ra) # 80000c98 <release>
}
    80003d16:	8526                	mv	a0,s1
    80003d18:	60e2                	ld	ra,24(sp)
    80003d1a:	6442                	ld	s0,16(sp)
    80003d1c:	64a2                	ld	s1,8(sp)
    80003d1e:	6105                	addi	sp,sp,32
    80003d20:	8082                	ret

0000000080003d22 <ilock>:
{
    80003d22:	1101                	addi	sp,sp,-32
    80003d24:	ec06                	sd	ra,24(sp)
    80003d26:	e822                	sd	s0,16(sp)
    80003d28:	e426                	sd	s1,8(sp)
    80003d2a:	e04a                	sd	s2,0(sp)
    80003d2c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003d2e:	c115                	beqz	a0,80003d52 <ilock+0x30>
    80003d30:	84aa                	mv	s1,a0
    80003d32:	451c                	lw	a5,8(a0)
    80003d34:	00f05f63          	blez	a5,80003d52 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003d38:	0541                	addi	a0,a0,16
    80003d3a:	00001097          	auipc	ra,0x1
    80003d3e:	cb2080e7          	jalr	-846(ra) # 800049ec <acquiresleep>
  if(ip->valid == 0){
    80003d42:	40bc                	lw	a5,64(s1)
    80003d44:	cf99                	beqz	a5,80003d62 <ilock+0x40>
}
    80003d46:	60e2                	ld	ra,24(sp)
    80003d48:	6442                	ld	s0,16(sp)
    80003d4a:	64a2                	ld	s1,8(sp)
    80003d4c:	6902                	ld	s2,0(sp)
    80003d4e:	6105                	addi	sp,sp,32
    80003d50:	8082                	ret
    panic("ilock");
    80003d52:	00005517          	auipc	a0,0x5
    80003d56:	95e50513          	addi	a0,a0,-1698 # 800086b0 <syscalls+0x1b8>
    80003d5a:	ffffc097          	auipc	ra,0xffffc
    80003d5e:	7e4080e7          	jalr	2020(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d62:	40dc                	lw	a5,4(s1)
    80003d64:	0047d79b          	srliw	a5,a5,0x4
    80003d68:	0001c597          	auipc	a1,0x1c
    80003d6c:	c585a583          	lw	a1,-936(a1) # 8001f9c0 <sb+0x18>
    80003d70:	9dbd                	addw	a1,a1,a5
    80003d72:	4088                	lw	a0,0(s1)
    80003d74:	fffff097          	auipc	ra,0xfffff
    80003d78:	7ac080e7          	jalr	1964(ra) # 80003520 <bread>
    80003d7c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d7e:	05850593          	addi	a1,a0,88
    80003d82:	40dc                	lw	a5,4(s1)
    80003d84:	8bbd                	andi	a5,a5,15
    80003d86:	079a                	slli	a5,a5,0x6
    80003d88:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003d8a:	00059783          	lh	a5,0(a1)
    80003d8e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003d92:	00259783          	lh	a5,2(a1)
    80003d96:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003d9a:	00459783          	lh	a5,4(a1)
    80003d9e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003da2:	00659783          	lh	a5,6(a1)
    80003da6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003daa:	459c                	lw	a5,8(a1)
    80003dac:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003dae:	03400613          	li	a2,52
    80003db2:	05b1                	addi	a1,a1,12
    80003db4:	05048513          	addi	a0,s1,80
    80003db8:	ffffd097          	auipc	ra,0xffffd
    80003dbc:	f88080e7          	jalr	-120(ra) # 80000d40 <memmove>
    brelse(bp);
    80003dc0:	854a                	mv	a0,s2
    80003dc2:	00000097          	auipc	ra,0x0
    80003dc6:	88e080e7          	jalr	-1906(ra) # 80003650 <brelse>
    ip->valid = 1;
    80003dca:	4785                	li	a5,1
    80003dcc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003dce:	04449783          	lh	a5,68(s1)
    80003dd2:	fbb5                	bnez	a5,80003d46 <ilock+0x24>
      panic("ilock: no type");
    80003dd4:	00005517          	auipc	a0,0x5
    80003dd8:	8e450513          	addi	a0,a0,-1820 # 800086b8 <syscalls+0x1c0>
    80003ddc:	ffffc097          	auipc	ra,0xffffc
    80003de0:	762080e7          	jalr	1890(ra) # 8000053e <panic>

0000000080003de4 <iunlock>:
{
    80003de4:	1101                	addi	sp,sp,-32
    80003de6:	ec06                	sd	ra,24(sp)
    80003de8:	e822                	sd	s0,16(sp)
    80003dea:	e426                	sd	s1,8(sp)
    80003dec:	e04a                	sd	s2,0(sp)
    80003dee:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003df0:	c905                	beqz	a0,80003e20 <iunlock+0x3c>
    80003df2:	84aa                	mv	s1,a0
    80003df4:	01050913          	addi	s2,a0,16
    80003df8:	854a                	mv	a0,s2
    80003dfa:	00001097          	auipc	ra,0x1
    80003dfe:	c8c080e7          	jalr	-884(ra) # 80004a86 <holdingsleep>
    80003e02:	cd19                	beqz	a0,80003e20 <iunlock+0x3c>
    80003e04:	449c                	lw	a5,8(s1)
    80003e06:	00f05d63          	blez	a5,80003e20 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003e0a:	854a                	mv	a0,s2
    80003e0c:	00001097          	auipc	ra,0x1
    80003e10:	c36080e7          	jalr	-970(ra) # 80004a42 <releasesleep>
}
    80003e14:	60e2                	ld	ra,24(sp)
    80003e16:	6442                	ld	s0,16(sp)
    80003e18:	64a2                	ld	s1,8(sp)
    80003e1a:	6902                	ld	s2,0(sp)
    80003e1c:	6105                	addi	sp,sp,32
    80003e1e:	8082                	ret
    panic("iunlock");
    80003e20:	00005517          	auipc	a0,0x5
    80003e24:	8a850513          	addi	a0,a0,-1880 # 800086c8 <syscalls+0x1d0>
    80003e28:	ffffc097          	auipc	ra,0xffffc
    80003e2c:	716080e7          	jalr	1814(ra) # 8000053e <panic>

0000000080003e30 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003e30:	7179                	addi	sp,sp,-48
    80003e32:	f406                	sd	ra,40(sp)
    80003e34:	f022                	sd	s0,32(sp)
    80003e36:	ec26                	sd	s1,24(sp)
    80003e38:	e84a                	sd	s2,16(sp)
    80003e3a:	e44e                	sd	s3,8(sp)
    80003e3c:	e052                	sd	s4,0(sp)
    80003e3e:	1800                	addi	s0,sp,48
    80003e40:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003e42:	05050493          	addi	s1,a0,80
    80003e46:	08050913          	addi	s2,a0,128
    80003e4a:	a021                	j	80003e52 <itrunc+0x22>
    80003e4c:	0491                	addi	s1,s1,4
    80003e4e:	01248d63          	beq	s1,s2,80003e68 <itrunc+0x38>
    if(ip->addrs[i]){
    80003e52:	408c                	lw	a1,0(s1)
    80003e54:	dde5                	beqz	a1,80003e4c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003e56:	0009a503          	lw	a0,0(s3)
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	90c080e7          	jalr	-1780(ra) # 80003766 <bfree>
      ip->addrs[i] = 0;
    80003e62:	0004a023          	sw	zero,0(s1)
    80003e66:	b7dd                	j	80003e4c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003e68:	0809a583          	lw	a1,128(s3)
    80003e6c:	e185                	bnez	a1,80003e8c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003e6e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003e72:	854e                	mv	a0,s3
    80003e74:	00000097          	auipc	ra,0x0
    80003e78:	de4080e7          	jalr	-540(ra) # 80003c58 <iupdate>
}
    80003e7c:	70a2                	ld	ra,40(sp)
    80003e7e:	7402                	ld	s0,32(sp)
    80003e80:	64e2                	ld	s1,24(sp)
    80003e82:	6942                	ld	s2,16(sp)
    80003e84:	69a2                	ld	s3,8(sp)
    80003e86:	6a02                	ld	s4,0(sp)
    80003e88:	6145                	addi	sp,sp,48
    80003e8a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003e8c:	0009a503          	lw	a0,0(s3)
    80003e90:	fffff097          	auipc	ra,0xfffff
    80003e94:	690080e7          	jalr	1680(ra) # 80003520 <bread>
    80003e98:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003e9a:	05850493          	addi	s1,a0,88
    80003e9e:	45850913          	addi	s2,a0,1112
    80003ea2:	a811                	j	80003eb6 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003ea4:	0009a503          	lw	a0,0(s3)
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	8be080e7          	jalr	-1858(ra) # 80003766 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003eb0:	0491                	addi	s1,s1,4
    80003eb2:	01248563          	beq	s1,s2,80003ebc <itrunc+0x8c>
      if(a[j])
    80003eb6:	408c                	lw	a1,0(s1)
    80003eb8:	dde5                	beqz	a1,80003eb0 <itrunc+0x80>
    80003eba:	b7ed                	j	80003ea4 <itrunc+0x74>
    brelse(bp);
    80003ebc:	8552                	mv	a0,s4
    80003ebe:	fffff097          	auipc	ra,0xfffff
    80003ec2:	792080e7          	jalr	1938(ra) # 80003650 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ec6:	0809a583          	lw	a1,128(s3)
    80003eca:	0009a503          	lw	a0,0(s3)
    80003ece:	00000097          	auipc	ra,0x0
    80003ed2:	898080e7          	jalr	-1896(ra) # 80003766 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ed6:	0809a023          	sw	zero,128(s3)
    80003eda:	bf51                	j	80003e6e <itrunc+0x3e>

0000000080003edc <iput>:
{
    80003edc:	1101                	addi	sp,sp,-32
    80003ede:	ec06                	sd	ra,24(sp)
    80003ee0:	e822                	sd	s0,16(sp)
    80003ee2:	e426                	sd	s1,8(sp)
    80003ee4:	e04a                	sd	s2,0(sp)
    80003ee6:	1000                	addi	s0,sp,32
    80003ee8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003eea:	0001c517          	auipc	a0,0x1c
    80003eee:	ade50513          	addi	a0,a0,-1314 # 8001f9c8 <itable>
    80003ef2:	ffffd097          	auipc	ra,0xffffd
    80003ef6:	cf2080e7          	jalr	-782(ra) # 80000be4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003efa:	4498                	lw	a4,8(s1)
    80003efc:	4785                	li	a5,1
    80003efe:	02f70363          	beq	a4,a5,80003f24 <iput+0x48>
  ip->ref--;
    80003f02:	449c                	lw	a5,8(s1)
    80003f04:	37fd                	addiw	a5,a5,-1
    80003f06:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003f08:	0001c517          	auipc	a0,0x1c
    80003f0c:	ac050513          	addi	a0,a0,-1344 # 8001f9c8 <itable>
    80003f10:	ffffd097          	auipc	ra,0xffffd
    80003f14:	d88080e7          	jalr	-632(ra) # 80000c98 <release>
}
    80003f18:	60e2                	ld	ra,24(sp)
    80003f1a:	6442                	ld	s0,16(sp)
    80003f1c:	64a2                	ld	s1,8(sp)
    80003f1e:	6902                	ld	s2,0(sp)
    80003f20:	6105                	addi	sp,sp,32
    80003f22:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003f24:	40bc                	lw	a5,64(s1)
    80003f26:	dff1                	beqz	a5,80003f02 <iput+0x26>
    80003f28:	04a49783          	lh	a5,74(s1)
    80003f2c:	fbf9                	bnez	a5,80003f02 <iput+0x26>
    acquiresleep(&ip->lock);
    80003f2e:	01048913          	addi	s2,s1,16
    80003f32:	854a                	mv	a0,s2
    80003f34:	00001097          	auipc	ra,0x1
    80003f38:	ab8080e7          	jalr	-1352(ra) # 800049ec <acquiresleep>
    release(&itable.lock);
    80003f3c:	0001c517          	auipc	a0,0x1c
    80003f40:	a8c50513          	addi	a0,a0,-1396 # 8001f9c8 <itable>
    80003f44:	ffffd097          	auipc	ra,0xffffd
    80003f48:	d54080e7          	jalr	-684(ra) # 80000c98 <release>
    itrunc(ip);
    80003f4c:	8526                	mv	a0,s1
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	ee2080e7          	jalr	-286(ra) # 80003e30 <itrunc>
    ip->type = 0;
    80003f56:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003f5a:	8526                	mv	a0,s1
    80003f5c:	00000097          	auipc	ra,0x0
    80003f60:	cfc080e7          	jalr	-772(ra) # 80003c58 <iupdate>
    ip->valid = 0;
    80003f64:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003f68:	854a                	mv	a0,s2
    80003f6a:	00001097          	auipc	ra,0x1
    80003f6e:	ad8080e7          	jalr	-1320(ra) # 80004a42 <releasesleep>
    acquire(&itable.lock);
    80003f72:	0001c517          	auipc	a0,0x1c
    80003f76:	a5650513          	addi	a0,a0,-1450 # 8001f9c8 <itable>
    80003f7a:	ffffd097          	auipc	ra,0xffffd
    80003f7e:	c6a080e7          	jalr	-918(ra) # 80000be4 <acquire>
    80003f82:	b741                	j	80003f02 <iput+0x26>

0000000080003f84 <iunlockput>:
{
    80003f84:	1101                	addi	sp,sp,-32
    80003f86:	ec06                	sd	ra,24(sp)
    80003f88:	e822                	sd	s0,16(sp)
    80003f8a:	e426                	sd	s1,8(sp)
    80003f8c:	1000                	addi	s0,sp,32
    80003f8e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003f90:	00000097          	auipc	ra,0x0
    80003f94:	e54080e7          	jalr	-428(ra) # 80003de4 <iunlock>
  iput(ip);
    80003f98:	8526                	mv	a0,s1
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	f42080e7          	jalr	-190(ra) # 80003edc <iput>
}
    80003fa2:	60e2                	ld	ra,24(sp)
    80003fa4:	6442                	ld	s0,16(sp)
    80003fa6:	64a2                	ld	s1,8(sp)
    80003fa8:	6105                	addi	sp,sp,32
    80003faa:	8082                	ret

0000000080003fac <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003fac:	1141                	addi	sp,sp,-16
    80003fae:	e422                	sd	s0,8(sp)
    80003fb0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003fb2:	411c                	lw	a5,0(a0)
    80003fb4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003fb6:	415c                	lw	a5,4(a0)
    80003fb8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003fba:	04451783          	lh	a5,68(a0)
    80003fbe:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003fc2:	04a51783          	lh	a5,74(a0)
    80003fc6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003fca:	04c56783          	lwu	a5,76(a0)
    80003fce:	e99c                	sd	a5,16(a1)
}
    80003fd0:	6422                	ld	s0,8(sp)
    80003fd2:	0141                	addi	sp,sp,16
    80003fd4:	8082                	ret

0000000080003fd6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fd6:	457c                	lw	a5,76(a0)
    80003fd8:	0ed7e963          	bltu	a5,a3,800040ca <readi+0xf4>
{
    80003fdc:	7159                	addi	sp,sp,-112
    80003fde:	f486                	sd	ra,104(sp)
    80003fe0:	f0a2                	sd	s0,96(sp)
    80003fe2:	eca6                	sd	s1,88(sp)
    80003fe4:	e8ca                	sd	s2,80(sp)
    80003fe6:	e4ce                	sd	s3,72(sp)
    80003fe8:	e0d2                	sd	s4,64(sp)
    80003fea:	fc56                	sd	s5,56(sp)
    80003fec:	f85a                	sd	s6,48(sp)
    80003fee:	f45e                	sd	s7,40(sp)
    80003ff0:	f062                	sd	s8,32(sp)
    80003ff2:	ec66                	sd	s9,24(sp)
    80003ff4:	e86a                	sd	s10,16(sp)
    80003ff6:	e46e                	sd	s11,8(sp)
    80003ff8:	1880                	addi	s0,sp,112
    80003ffa:	8baa                	mv	s7,a0
    80003ffc:	8c2e                	mv	s8,a1
    80003ffe:	8ab2                	mv	s5,a2
    80004000:	84b6                	mv	s1,a3
    80004002:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004004:	9f35                	addw	a4,a4,a3
    return 0;
    80004006:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004008:	0ad76063          	bltu	a4,a3,800040a8 <readi+0xd2>
  if(off + n > ip->size)
    8000400c:	00e7f463          	bgeu	a5,a4,80004014 <readi+0x3e>
    n = ip->size - off;
    80004010:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004014:	0a0b0963          	beqz	s6,800040c6 <readi+0xf0>
    80004018:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000401a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000401e:	5cfd                	li	s9,-1
    80004020:	a82d                	j	8000405a <readi+0x84>
    80004022:	020a1d93          	slli	s11,s4,0x20
    80004026:	020ddd93          	srli	s11,s11,0x20
    8000402a:	05890613          	addi	a2,s2,88
    8000402e:	86ee                	mv	a3,s11
    80004030:	963a                	add	a2,a2,a4
    80004032:	85d6                	mv	a1,s5
    80004034:	8562                	mv	a0,s8
    80004036:	fffff097          	auipc	ra,0xfffff
    8000403a:	9b4080e7          	jalr	-1612(ra) # 800029ea <either_copyout>
    8000403e:	05950d63          	beq	a0,s9,80004098 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004042:	854a                	mv	a0,s2
    80004044:	fffff097          	auipc	ra,0xfffff
    80004048:	60c080e7          	jalr	1548(ra) # 80003650 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000404c:	013a09bb          	addw	s3,s4,s3
    80004050:	009a04bb          	addw	s1,s4,s1
    80004054:	9aee                	add	s5,s5,s11
    80004056:	0569f763          	bgeu	s3,s6,800040a4 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000405a:	000ba903          	lw	s2,0(s7)
    8000405e:	00a4d59b          	srliw	a1,s1,0xa
    80004062:	855e                	mv	a0,s7
    80004064:	00000097          	auipc	ra,0x0
    80004068:	8b0080e7          	jalr	-1872(ra) # 80003914 <bmap>
    8000406c:	0005059b          	sext.w	a1,a0
    80004070:	854a                	mv	a0,s2
    80004072:	fffff097          	auipc	ra,0xfffff
    80004076:	4ae080e7          	jalr	1198(ra) # 80003520 <bread>
    8000407a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000407c:	3ff4f713          	andi	a4,s1,1023
    80004080:	40ed07bb          	subw	a5,s10,a4
    80004084:	413b06bb          	subw	a3,s6,s3
    80004088:	8a3e                	mv	s4,a5
    8000408a:	2781                	sext.w	a5,a5
    8000408c:	0006861b          	sext.w	a2,a3
    80004090:	f8f679e3          	bgeu	a2,a5,80004022 <readi+0x4c>
    80004094:	8a36                	mv	s4,a3
    80004096:	b771                	j	80004022 <readi+0x4c>
      brelse(bp);
    80004098:	854a                	mv	a0,s2
    8000409a:	fffff097          	auipc	ra,0xfffff
    8000409e:	5b6080e7          	jalr	1462(ra) # 80003650 <brelse>
      tot = -1;
    800040a2:	59fd                	li	s3,-1
  }
  return tot;
    800040a4:	0009851b          	sext.w	a0,s3
}
    800040a8:	70a6                	ld	ra,104(sp)
    800040aa:	7406                	ld	s0,96(sp)
    800040ac:	64e6                	ld	s1,88(sp)
    800040ae:	6946                	ld	s2,80(sp)
    800040b0:	69a6                	ld	s3,72(sp)
    800040b2:	6a06                	ld	s4,64(sp)
    800040b4:	7ae2                	ld	s5,56(sp)
    800040b6:	7b42                	ld	s6,48(sp)
    800040b8:	7ba2                	ld	s7,40(sp)
    800040ba:	7c02                	ld	s8,32(sp)
    800040bc:	6ce2                	ld	s9,24(sp)
    800040be:	6d42                	ld	s10,16(sp)
    800040c0:	6da2                	ld	s11,8(sp)
    800040c2:	6165                	addi	sp,sp,112
    800040c4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800040c6:	89da                	mv	s3,s6
    800040c8:	bff1                	j	800040a4 <readi+0xce>
    return 0;
    800040ca:	4501                	li	a0,0
}
    800040cc:	8082                	ret

00000000800040ce <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040ce:	457c                	lw	a5,76(a0)
    800040d0:	10d7e863          	bltu	a5,a3,800041e0 <writei+0x112>
{
    800040d4:	7159                	addi	sp,sp,-112
    800040d6:	f486                	sd	ra,104(sp)
    800040d8:	f0a2                	sd	s0,96(sp)
    800040da:	eca6                	sd	s1,88(sp)
    800040dc:	e8ca                	sd	s2,80(sp)
    800040de:	e4ce                	sd	s3,72(sp)
    800040e0:	e0d2                	sd	s4,64(sp)
    800040e2:	fc56                	sd	s5,56(sp)
    800040e4:	f85a                	sd	s6,48(sp)
    800040e6:	f45e                	sd	s7,40(sp)
    800040e8:	f062                	sd	s8,32(sp)
    800040ea:	ec66                	sd	s9,24(sp)
    800040ec:	e86a                	sd	s10,16(sp)
    800040ee:	e46e                	sd	s11,8(sp)
    800040f0:	1880                	addi	s0,sp,112
    800040f2:	8b2a                	mv	s6,a0
    800040f4:	8c2e                	mv	s8,a1
    800040f6:	8ab2                	mv	s5,a2
    800040f8:	8936                	mv	s2,a3
    800040fa:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800040fc:	00e687bb          	addw	a5,a3,a4
    80004100:	0ed7e263          	bltu	a5,a3,800041e4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004104:	00043737          	lui	a4,0x43
    80004108:	0ef76063          	bltu	a4,a5,800041e8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000410c:	0c0b8863          	beqz	s7,800041dc <writei+0x10e>
    80004110:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004112:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004116:	5cfd                	li	s9,-1
    80004118:	a091                	j	8000415c <writei+0x8e>
    8000411a:	02099d93          	slli	s11,s3,0x20
    8000411e:	020ddd93          	srli	s11,s11,0x20
    80004122:	05848513          	addi	a0,s1,88
    80004126:	86ee                	mv	a3,s11
    80004128:	8656                	mv	a2,s5
    8000412a:	85e2                	mv	a1,s8
    8000412c:	953a                	add	a0,a0,a4
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	912080e7          	jalr	-1774(ra) # 80002a40 <either_copyin>
    80004136:	07950263          	beq	a0,s9,8000419a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000413a:	8526                	mv	a0,s1
    8000413c:	00000097          	auipc	ra,0x0
    80004140:	790080e7          	jalr	1936(ra) # 800048cc <log_write>
    brelse(bp);
    80004144:	8526                	mv	a0,s1
    80004146:	fffff097          	auipc	ra,0xfffff
    8000414a:	50a080e7          	jalr	1290(ra) # 80003650 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000414e:	01498a3b          	addw	s4,s3,s4
    80004152:	0129893b          	addw	s2,s3,s2
    80004156:	9aee                	add	s5,s5,s11
    80004158:	057a7663          	bgeu	s4,s7,800041a4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000415c:	000b2483          	lw	s1,0(s6)
    80004160:	00a9559b          	srliw	a1,s2,0xa
    80004164:	855a                	mv	a0,s6
    80004166:	fffff097          	auipc	ra,0xfffff
    8000416a:	7ae080e7          	jalr	1966(ra) # 80003914 <bmap>
    8000416e:	0005059b          	sext.w	a1,a0
    80004172:	8526                	mv	a0,s1
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	3ac080e7          	jalr	940(ra) # 80003520 <bread>
    8000417c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000417e:	3ff97713          	andi	a4,s2,1023
    80004182:	40ed07bb          	subw	a5,s10,a4
    80004186:	414b86bb          	subw	a3,s7,s4
    8000418a:	89be                	mv	s3,a5
    8000418c:	2781                	sext.w	a5,a5
    8000418e:	0006861b          	sext.w	a2,a3
    80004192:	f8f674e3          	bgeu	a2,a5,8000411a <writei+0x4c>
    80004196:	89b6                	mv	s3,a3
    80004198:	b749                	j	8000411a <writei+0x4c>
      brelse(bp);
    8000419a:	8526                	mv	a0,s1
    8000419c:	fffff097          	auipc	ra,0xfffff
    800041a0:	4b4080e7          	jalr	1204(ra) # 80003650 <brelse>
  }

  if(off > ip->size)
    800041a4:	04cb2783          	lw	a5,76(s6)
    800041a8:	0127f463          	bgeu	a5,s2,800041b0 <writei+0xe2>
    ip->size = off;
    800041ac:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800041b0:	855a                	mv	a0,s6
    800041b2:	00000097          	auipc	ra,0x0
    800041b6:	aa6080e7          	jalr	-1370(ra) # 80003c58 <iupdate>

  return tot;
    800041ba:	000a051b          	sext.w	a0,s4
}
    800041be:	70a6                	ld	ra,104(sp)
    800041c0:	7406                	ld	s0,96(sp)
    800041c2:	64e6                	ld	s1,88(sp)
    800041c4:	6946                	ld	s2,80(sp)
    800041c6:	69a6                	ld	s3,72(sp)
    800041c8:	6a06                	ld	s4,64(sp)
    800041ca:	7ae2                	ld	s5,56(sp)
    800041cc:	7b42                	ld	s6,48(sp)
    800041ce:	7ba2                	ld	s7,40(sp)
    800041d0:	7c02                	ld	s8,32(sp)
    800041d2:	6ce2                	ld	s9,24(sp)
    800041d4:	6d42                	ld	s10,16(sp)
    800041d6:	6da2                	ld	s11,8(sp)
    800041d8:	6165                	addi	sp,sp,112
    800041da:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800041dc:	8a5e                	mv	s4,s7
    800041de:	bfc9                	j	800041b0 <writei+0xe2>
    return -1;
    800041e0:	557d                	li	a0,-1
}
    800041e2:	8082                	ret
    return -1;
    800041e4:	557d                	li	a0,-1
    800041e6:	bfe1                	j	800041be <writei+0xf0>
    return -1;
    800041e8:	557d                	li	a0,-1
    800041ea:	bfd1                	j	800041be <writei+0xf0>

00000000800041ec <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800041ec:	1141                	addi	sp,sp,-16
    800041ee:	e406                	sd	ra,8(sp)
    800041f0:	e022                	sd	s0,0(sp)
    800041f2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800041f4:	4639                	li	a2,14
    800041f6:	ffffd097          	auipc	ra,0xffffd
    800041fa:	bc2080e7          	jalr	-1086(ra) # 80000db8 <strncmp>
}
    800041fe:	60a2                	ld	ra,8(sp)
    80004200:	6402                	ld	s0,0(sp)
    80004202:	0141                	addi	sp,sp,16
    80004204:	8082                	ret

0000000080004206 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004206:	7139                	addi	sp,sp,-64
    80004208:	fc06                	sd	ra,56(sp)
    8000420a:	f822                	sd	s0,48(sp)
    8000420c:	f426                	sd	s1,40(sp)
    8000420e:	f04a                	sd	s2,32(sp)
    80004210:	ec4e                	sd	s3,24(sp)
    80004212:	e852                	sd	s4,16(sp)
    80004214:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004216:	04451703          	lh	a4,68(a0)
    8000421a:	4785                	li	a5,1
    8000421c:	00f71a63          	bne	a4,a5,80004230 <dirlookup+0x2a>
    80004220:	892a                	mv	s2,a0
    80004222:	89ae                	mv	s3,a1
    80004224:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004226:	457c                	lw	a5,76(a0)
    80004228:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000422a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000422c:	e79d                	bnez	a5,8000425a <dirlookup+0x54>
    8000422e:	a8a5                	j	800042a6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004230:	00004517          	auipc	a0,0x4
    80004234:	4a050513          	addi	a0,a0,1184 # 800086d0 <syscalls+0x1d8>
    80004238:	ffffc097          	auipc	ra,0xffffc
    8000423c:	306080e7          	jalr	774(ra) # 8000053e <panic>
      panic("dirlookup read");
    80004240:	00004517          	auipc	a0,0x4
    80004244:	4a850513          	addi	a0,a0,1192 # 800086e8 <syscalls+0x1f0>
    80004248:	ffffc097          	auipc	ra,0xffffc
    8000424c:	2f6080e7          	jalr	758(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004250:	24c1                	addiw	s1,s1,16
    80004252:	04c92783          	lw	a5,76(s2)
    80004256:	04f4f763          	bgeu	s1,a5,800042a4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000425a:	4741                	li	a4,16
    8000425c:	86a6                	mv	a3,s1
    8000425e:	fc040613          	addi	a2,s0,-64
    80004262:	4581                	li	a1,0
    80004264:	854a                	mv	a0,s2
    80004266:	00000097          	auipc	ra,0x0
    8000426a:	d70080e7          	jalr	-656(ra) # 80003fd6 <readi>
    8000426e:	47c1                	li	a5,16
    80004270:	fcf518e3          	bne	a0,a5,80004240 <dirlookup+0x3a>
    if(de.inum == 0)
    80004274:	fc045783          	lhu	a5,-64(s0)
    80004278:	dfe1                	beqz	a5,80004250 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000427a:	fc240593          	addi	a1,s0,-62
    8000427e:	854e                	mv	a0,s3
    80004280:	00000097          	auipc	ra,0x0
    80004284:	f6c080e7          	jalr	-148(ra) # 800041ec <namecmp>
    80004288:	f561                	bnez	a0,80004250 <dirlookup+0x4a>
      if(poff)
    8000428a:	000a0463          	beqz	s4,80004292 <dirlookup+0x8c>
        *poff = off;
    8000428e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004292:	fc045583          	lhu	a1,-64(s0)
    80004296:	00092503          	lw	a0,0(s2)
    8000429a:	fffff097          	auipc	ra,0xfffff
    8000429e:	754080e7          	jalr	1876(ra) # 800039ee <iget>
    800042a2:	a011                	j	800042a6 <dirlookup+0xa0>
  return 0;
    800042a4:	4501                	li	a0,0
}
    800042a6:	70e2                	ld	ra,56(sp)
    800042a8:	7442                	ld	s0,48(sp)
    800042aa:	74a2                	ld	s1,40(sp)
    800042ac:	7902                	ld	s2,32(sp)
    800042ae:	69e2                	ld	s3,24(sp)
    800042b0:	6a42                	ld	s4,16(sp)
    800042b2:	6121                	addi	sp,sp,64
    800042b4:	8082                	ret

00000000800042b6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800042b6:	711d                	addi	sp,sp,-96
    800042b8:	ec86                	sd	ra,88(sp)
    800042ba:	e8a2                	sd	s0,80(sp)
    800042bc:	e4a6                	sd	s1,72(sp)
    800042be:	e0ca                	sd	s2,64(sp)
    800042c0:	fc4e                	sd	s3,56(sp)
    800042c2:	f852                	sd	s4,48(sp)
    800042c4:	f456                	sd	s5,40(sp)
    800042c6:	f05a                	sd	s6,32(sp)
    800042c8:	ec5e                	sd	s7,24(sp)
    800042ca:	e862                	sd	s8,16(sp)
    800042cc:	e466                	sd	s9,8(sp)
    800042ce:	1080                	addi	s0,sp,96
    800042d0:	84aa                	mv	s1,a0
    800042d2:	8b2e                	mv	s6,a1
    800042d4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800042d6:	00054703          	lbu	a4,0(a0)
    800042da:	02f00793          	li	a5,47
    800042de:	02f70363          	beq	a4,a5,80004304 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800042e2:	ffffd097          	auipc	ra,0xffffd
    800042e6:	6ce080e7          	jalr	1742(ra) # 800019b0 <myproc>
    800042ea:	15853503          	ld	a0,344(a0)
    800042ee:	00000097          	auipc	ra,0x0
    800042f2:	9f6080e7          	jalr	-1546(ra) # 80003ce4 <idup>
    800042f6:	89aa                	mv	s3,a0
  while(*path == '/')
    800042f8:	02f00913          	li	s2,47
  len = path - s;
    800042fc:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800042fe:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004300:	4c05                	li	s8,1
    80004302:	a865                	j	800043ba <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004304:	4585                	li	a1,1
    80004306:	4505                	li	a0,1
    80004308:	fffff097          	auipc	ra,0xfffff
    8000430c:	6e6080e7          	jalr	1766(ra) # 800039ee <iget>
    80004310:	89aa                	mv	s3,a0
    80004312:	b7dd                	j	800042f8 <namex+0x42>
      iunlockput(ip);
    80004314:	854e                	mv	a0,s3
    80004316:	00000097          	auipc	ra,0x0
    8000431a:	c6e080e7          	jalr	-914(ra) # 80003f84 <iunlockput>
      return 0;
    8000431e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004320:	854e                	mv	a0,s3
    80004322:	60e6                	ld	ra,88(sp)
    80004324:	6446                	ld	s0,80(sp)
    80004326:	64a6                	ld	s1,72(sp)
    80004328:	6906                	ld	s2,64(sp)
    8000432a:	79e2                	ld	s3,56(sp)
    8000432c:	7a42                	ld	s4,48(sp)
    8000432e:	7aa2                	ld	s5,40(sp)
    80004330:	7b02                	ld	s6,32(sp)
    80004332:	6be2                	ld	s7,24(sp)
    80004334:	6c42                	ld	s8,16(sp)
    80004336:	6ca2                	ld	s9,8(sp)
    80004338:	6125                	addi	sp,sp,96
    8000433a:	8082                	ret
      iunlock(ip);
    8000433c:	854e                	mv	a0,s3
    8000433e:	00000097          	auipc	ra,0x0
    80004342:	aa6080e7          	jalr	-1370(ra) # 80003de4 <iunlock>
      return ip;
    80004346:	bfe9                	j	80004320 <namex+0x6a>
      iunlockput(ip);
    80004348:	854e                	mv	a0,s3
    8000434a:	00000097          	auipc	ra,0x0
    8000434e:	c3a080e7          	jalr	-966(ra) # 80003f84 <iunlockput>
      return 0;
    80004352:	89d2                	mv	s3,s4
    80004354:	b7f1                	j	80004320 <namex+0x6a>
  len = path - s;
    80004356:	40b48633          	sub	a2,s1,a1
    8000435a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000435e:	094cd463          	bge	s9,s4,800043e6 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004362:	4639                	li	a2,14
    80004364:	8556                	mv	a0,s5
    80004366:	ffffd097          	auipc	ra,0xffffd
    8000436a:	9da080e7          	jalr	-1574(ra) # 80000d40 <memmove>
  while(*path == '/')
    8000436e:	0004c783          	lbu	a5,0(s1)
    80004372:	01279763          	bne	a5,s2,80004380 <namex+0xca>
    path++;
    80004376:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004378:	0004c783          	lbu	a5,0(s1)
    8000437c:	ff278de3          	beq	a5,s2,80004376 <namex+0xc0>
    ilock(ip);
    80004380:	854e                	mv	a0,s3
    80004382:	00000097          	auipc	ra,0x0
    80004386:	9a0080e7          	jalr	-1632(ra) # 80003d22 <ilock>
    if(ip->type != T_DIR){
    8000438a:	04499783          	lh	a5,68(s3)
    8000438e:	f98793e3          	bne	a5,s8,80004314 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004392:	000b0563          	beqz	s6,8000439c <namex+0xe6>
    80004396:	0004c783          	lbu	a5,0(s1)
    8000439a:	d3cd                	beqz	a5,8000433c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000439c:	865e                	mv	a2,s7
    8000439e:	85d6                	mv	a1,s5
    800043a0:	854e                	mv	a0,s3
    800043a2:	00000097          	auipc	ra,0x0
    800043a6:	e64080e7          	jalr	-412(ra) # 80004206 <dirlookup>
    800043aa:	8a2a                	mv	s4,a0
    800043ac:	dd51                	beqz	a0,80004348 <namex+0x92>
    iunlockput(ip);
    800043ae:	854e                	mv	a0,s3
    800043b0:	00000097          	auipc	ra,0x0
    800043b4:	bd4080e7          	jalr	-1068(ra) # 80003f84 <iunlockput>
    ip = next;
    800043b8:	89d2                	mv	s3,s4
  while(*path == '/')
    800043ba:	0004c783          	lbu	a5,0(s1)
    800043be:	05279763          	bne	a5,s2,8000440c <namex+0x156>
    path++;
    800043c2:	0485                	addi	s1,s1,1
  while(*path == '/')
    800043c4:	0004c783          	lbu	a5,0(s1)
    800043c8:	ff278de3          	beq	a5,s2,800043c2 <namex+0x10c>
  if(*path == 0)
    800043cc:	c79d                	beqz	a5,800043fa <namex+0x144>
    path++;
    800043ce:	85a6                	mv	a1,s1
  len = path - s;
    800043d0:	8a5e                	mv	s4,s7
    800043d2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800043d4:	01278963          	beq	a5,s2,800043e6 <namex+0x130>
    800043d8:	dfbd                	beqz	a5,80004356 <namex+0xa0>
    path++;
    800043da:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800043dc:	0004c783          	lbu	a5,0(s1)
    800043e0:	ff279ce3          	bne	a5,s2,800043d8 <namex+0x122>
    800043e4:	bf8d                	j	80004356 <namex+0xa0>
    memmove(name, s, len);
    800043e6:	2601                	sext.w	a2,a2
    800043e8:	8556                	mv	a0,s5
    800043ea:	ffffd097          	auipc	ra,0xffffd
    800043ee:	956080e7          	jalr	-1706(ra) # 80000d40 <memmove>
    name[len] = 0;
    800043f2:	9a56                	add	s4,s4,s5
    800043f4:	000a0023          	sb	zero,0(s4)
    800043f8:	bf9d                	j	8000436e <namex+0xb8>
  if(nameiparent){
    800043fa:	f20b03e3          	beqz	s6,80004320 <namex+0x6a>
    iput(ip);
    800043fe:	854e                	mv	a0,s3
    80004400:	00000097          	auipc	ra,0x0
    80004404:	adc080e7          	jalr	-1316(ra) # 80003edc <iput>
    return 0;
    80004408:	4981                	li	s3,0
    8000440a:	bf19                	j	80004320 <namex+0x6a>
  if(*path == 0)
    8000440c:	d7fd                	beqz	a5,800043fa <namex+0x144>
  while(*path != '/' && *path != 0)
    8000440e:	0004c783          	lbu	a5,0(s1)
    80004412:	85a6                	mv	a1,s1
    80004414:	b7d1                	j	800043d8 <namex+0x122>

0000000080004416 <dirlink>:
{
    80004416:	7139                	addi	sp,sp,-64
    80004418:	fc06                	sd	ra,56(sp)
    8000441a:	f822                	sd	s0,48(sp)
    8000441c:	f426                	sd	s1,40(sp)
    8000441e:	f04a                	sd	s2,32(sp)
    80004420:	ec4e                	sd	s3,24(sp)
    80004422:	e852                	sd	s4,16(sp)
    80004424:	0080                	addi	s0,sp,64
    80004426:	892a                	mv	s2,a0
    80004428:	8a2e                	mv	s4,a1
    8000442a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000442c:	4601                	li	a2,0
    8000442e:	00000097          	auipc	ra,0x0
    80004432:	dd8080e7          	jalr	-552(ra) # 80004206 <dirlookup>
    80004436:	e93d                	bnez	a0,800044ac <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004438:	04c92483          	lw	s1,76(s2)
    8000443c:	c49d                	beqz	s1,8000446a <dirlink+0x54>
    8000443e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004440:	4741                	li	a4,16
    80004442:	86a6                	mv	a3,s1
    80004444:	fc040613          	addi	a2,s0,-64
    80004448:	4581                	li	a1,0
    8000444a:	854a                	mv	a0,s2
    8000444c:	00000097          	auipc	ra,0x0
    80004450:	b8a080e7          	jalr	-1142(ra) # 80003fd6 <readi>
    80004454:	47c1                	li	a5,16
    80004456:	06f51163          	bne	a0,a5,800044b8 <dirlink+0xa2>
    if(de.inum == 0)
    8000445a:	fc045783          	lhu	a5,-64(s0)
    8000445e:	c791                	beqz	a5,8000446a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004460:	24c1                	addiw	s1,s1,16
    80004462:	04c92783          	lw	a5,76(s2)
    80004466:	fcf4ede3          	bltu	s1,a5,80004440 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000446a:	4639                	li	a2,14
    8000446c:	85d2                	mv	a1,s4
    8000446e:	fc240513          	addi	a0,s0,-62
    80004472:	ffffd097          	auipc	ra,0xffffd
    80004476:	982080e7          	jalr	-1662(ra) # 80000df4 <strncpy>
  de.inum = inum;
    8000447a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000447e:	4741                	li	a4,16
    80004480:	86a6                	mv	a3,s1
    80004482:	fc040613          	addi	a2,s0,-64
    80004486:	4581                	li	a1,0
    80004488:	854a                	mv	a0,s2
    8000448a:	00000097          	auipc	ra,0x0
    8000448e:	c44080e7          	jalr	-956(ra) # 800040ce <writei>
    80004492:	872a                	mv	a4,a0
    80004494:	47c1                	li	a5,16
  return 0;
    80004496:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004498:	02f71863          	bne	a4,a5,800044c8 <dirlink+0xb2>
}
    8000449c:	70e2                	ld	ra,56(sp)
    8000449e:	7442                	ld	s0,48(sp)
    800044a0:	74a2                	ld	s1,40(sp)
    800044a2:	7902                	ld	s2,32(sp)
    800044a4:	69e2                	ld	s3,24(sp)
    800044a6:	6a42                	ld	s4,16(sp)
    800044a8:	6121                	addi	sp,sp,64
    800044aa:	8082                	ret
    iput(ip);
    800044ac:	00000097          	auipc	ra,0x0
    800044b0:	a30080e7          	jalr	-1488(ra) # 80003edc <iput>
    return -1;
    800044b4:	557d                	li	a0,-1
    800044b6:	b7dd                	j	8000449c <dirlink+0x86>
      panic("dirlink read");
    800044b8:	00004517          	auipc	a0,0x4
    800044bc:	24050513          	addi	a0,a0,576 # 800086f8 <syscalls+0x200>
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	07e080e7          	jalr	126(ra) # 8000053e <panic>
    panic("dirlink");
    800044c8:	00004517          	auipc	a0,0x4
    800044cc:	34050513          	addi	a0,a0,832 # 80008808 <syscalls+0x310>
    800044d0:	ffffc097          	auipc	ra,0xffffc
    800044d4:	06e080e7          	jalr	110(ra) # 8000053e <panic>

00000000800044d8 <namei>:

struct inode*
namei(char *path)
{
    800044d8:	1101                	addi	sp,sp,-32
    800044da:	ec06                	sd	ra,24(sp)
    800044dc:	e822                	sd	s0,16(sp)
    800044de:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800044e0:	fe040613          	addi	a2,s0,-32
    800044e4:	4581                	li	a1,0
    800044e6:	00000097          	auipc	ra,0x0
    800044ea:	dd0080e7          	jalr	-560(ra) # 800042b6 <namex>
}
    800044ee:	60e2                	ld	ra,24(sp)
    800044f0:	6442                	ld	s0,16(sp)
    800044f2:	6105                	addi	sp,sp,32
    800044f4:	8082                	ret

00000000800044f6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800044f6:	1141                	addi	sp,sp,-16
    800044f8:	e406                	sd	ra,8(sp)
    800044fa:	e022                	sd	s0,0(sp)
    800044fc:	0800                	addi	s0,sp,16
    800044fe:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004500:	4585                	li	a1,1
    80004502:	00000097          	auipc	ra,0x0
    80004506:	db4080e7          	jalr	-588(ra) # 800042b6 <namex>
}
    8000450a:	60a2                	ld	ra,8(sp)
    8000450c:	6402                	ld	s0,0(sp)
    8000450e:	0141                	addi	sp,sp,16
    80004510:	8082                	ret

0000000080004512 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004512:	1101                	addi	sp,sp,-32
    80004514:	ec06                	sd	ra,24(sp)
    80004516:	e822                	sd	s0,16(sp)
    80004518:	e426                	sd	s1,8(sp)
    8000451a:	e04a                	sd	s2,0(sp)
    8000451c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000451e:	0001d917          	auipc	s2,0x1d
    80004522:	f5290913          	addi	s2,s2,-174 # 80021470 <log>
    80004526:	01892583          	lw	a1,24(s2)
    8000452a:	02892503          	lw	a0,40(s2)
    8000452e:	fffff097          	auipc	ra,0xfffff
    80004532:	ff2080e7          	jalr	-14(ra) # 80003520 <bread>
    80004536:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004538:	02c92683          	lw	a3,44(s2)
    8000453c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000453e:	02d05763          	blez	a3,8000456c <write_head+0x5a>
    80004542:	0001d797          	auipc	a5,0x1d
    80004546:	f5e78793          	addi	a5,a5,-162 # 800214a0 <log+0x30>
    8000454a:	05c50713          	addi	a4,a0,92
    8000454e:	36fd                	addiw	a3,a3,-1
    80004550:	1682                	slli	a3,a3,0x20
    80004552:	9281                	srli	a3,a3,0x20
    80004554:	068a                	slli	a3,a3,0x2
    80004556:	0001d617          	auipc	a2,0x1d
    8000455a:	f4e60613          	addi	a2,a2,-178 # 800214a4 <log+0x34>
    8000455e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004560:	4390                	lw	a2,0(a5)
    80004562:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004564:	0791                	addi	a5,a5,4
    80004566:	0711                	addi	a4,a4,4
    80004568:	fed79ce3          	bne	a5,a3,80004560 <write_head+0x4e>
  }
  bwrite(buf);
    8000456c:	8526                	mv	a0,s1
    8000456e:	fffff097          	auipc	ra,0xfffff
    80004572:	0a4080e7          	jalr	164(ra) # 80003612 <bwrite>
  brelse(buf);
    80004576:	8526                	mv	a0,s1
    80004578:	fffff097          	auipc	ra,0xfffff
    8000457c:	0d8080e7          	jalr	216(ra) # 80003650 <brelse>
}
    80004580:	60e2                	ld	ra,24(sp)
    80004582:	6442                	ld	s0,16(sp)
    80004584:	64a2                	ld	s1,8(sp)
    80004586:	6902                	ld	s2,0(sp)
    80004588:	6105                	addi	sp,sp,32
    8000458a:	8082                	ret

000000008000458c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000458c:	0001d797          	auipc	a5,0x1d
    80004590:	f107a783          	lw	a5,-240(a5) # 8002149c <log+0x2c>
    80004594:	0af05d63          	blez	a5,8000464e <install_trans+0xc2>
{
    80004598:	7139                	addi	sp,sp,-64
    8000459a:	fc06                	sd	ra,56(sp)
    8000459c:	f822                	sd	s0,48(sp)
    8000459e:	f426                	sd	s1,40(sp)
    800045a0:	f04a                	sd	s2,32(sp)
    800045a2:	ec4e                	sd	s3,24(sp)
    800045a4:	e852                	sd	s4,16(sp)
    800045a6:	e456                	sd	s5,8(sp)
    800045a8:	e05a                	sd	s6,0(sp)
    800045aa:	0080                	addi	s0,sp,64
    800045ac:	8b2a                	mv	s6,a0
    800045ae:	0001da97          	auipc	s5,0x1d
    800045b2:	ef2a8a93          	addi	s5,s5,-270 # 800214a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045b6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045b8:	0001d997          	auipc	s3,0x1d
    800045bc:	eb898993          	addi	s3,s3,-328 # 80021470 <log>
    800045c0:	a035                	j	800045ec <install_trans+0x60>
      bunpin(dbuf);
    800045c2:	8526                	mv	a0,s1
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	166080e7          	jalr	358(ra) # 8000372a <bunpin>
    brelse(lbuf);
    800045cc:	854a                	mv	a0,s2
    800045ce:	fffff097          	auipc	ra,0xfffff
    800045d2:	082080e7          	jalr	130(ra) # 80003650 <brelse>
    brelse(dbuf);
    800045d6:	8526                	mv	a0,s1
    800045d8:	fffff097          	auipc	ra,0xfffff
    800045dc:	078080e7          	jalr	120(ra) # 80003650 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045e0:	2a05                	addiw	s4,s4,1
    800045e2:	0a91                	addi	s5,s5,4
    800045e4:	02c9a783          	lw	a5,44(s3)
    800045e8:	04fa5963          	bge	s4,a5,8000463a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800045ec:	0189a583          	lw	a1,24(s3)
    800045f0:	014585bb          	addw	a1,a1,s4
    800045f4:	2585                	addiw	a1,a1,1
    800045f6:	0289a503          	lw	a0,40(s3)
    800045fa:	fffff097          	auipc	ra,0xfffff
    800045fe:	f26080e7          	jalr	-218(ra) # 80003520 <bread>
    80004602:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004604:	000aa583          	lw	a1,0(s5)
    80004608:	0289a503          	lw	a0,40(s3)
    8000460c:	fffff097          	auipc	ra,0xfffff
    80004610:	f14080e7          	jalr	-236(ra) # 80003520 <bread>
    80004614:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004616:	40000613          	li	a2,1024
    8000461a:	05890593          	addi	a1,s2,88
    8000461e:	05850513          	addi	a0,a0,88
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	71e080e7          	jalr	1822(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000462a:	8526                	mv	a0,s1
    8000462c:	fffff097          	auipc	ra,0xfffff
    80004630:	fe6080e7          	jalr	-26(ra) # 80003612 <bwrite>
    if(recovering == 0)
    80004634:	f80b1ce3          	bnez	s6,800045cc <install_trans+0x40>
    80004638:	b769                	j	800045c2 <install_trans+0x36>
}
    8000463a:	70e2                	ld	ra,56(sp)
    8000463c:	7442                	ld	s0,48(sp)
    8000463e:	74a2                	ld	s1,40(sp)
    80004640:	7902                	ld	s2,32(sp)
    80004642:	69e2                	ld	s3,24(sp)
    80004644:	6a42                	ld	s4,16(sp)
    80004646:	6aa2                	ld	s5,8(sp)
    80004648:	6b02                	ld	s6,0(sp)
    8000464a:	6121                	addi	sp,sp,64
    8000464c:	8082                	ret
    8000464e:	8082                	ret

0000000080004650 <initlog>:
{
    80004650:	7179                	addi	sp,sp,-48
    80004652:	f406                	sd	ra,40(sp)
    80004654:	f022                	sd	s0,32(sp)
    80004656:	ec26                	sd	s1,24(sp)
    80004658:	e84a                	sd	s2,16(sp)
    8000465a:	e44e                	sd	s3,8(sp)
    8000465c:	1800                	addi	s0,sp,48
    8000465e:	892a                	mv	s2,a0
    80004660:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004662:	0001d497          	auipc	s1,0x1d
    80004666:	e0e48493          	addi	s1,s1,-498 # 80021470 <log>
    8000466a:	00004597          	auipc	a1,0x4
    8000466e:	09e58593          	addi	a1,a1,158 # 80008708 <syscalls+0x210>
    80004672:	8526                	mv	a0,s1
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	4e0080e7          	jalr	1248(ra) # 80000b54 <initlock>
  log.start = sb->logstart;
    8000467c:	0149a583          	lw	a1,20(s3)
    80004680:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004682:	0109a783          	lw	a5,16(s3)
    80004686:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004688:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000468c:	854a                	mv	a0,s2
    8000468e:	fffff097          	auipc	ra,0xfffff
    80004692:	e92080e7          	jalr	-366(ra) # 80003520 <bread>
  log.lh.n = lh->n;
    80004696:	4d3c                	lw	a5,88(a0)
    80004698:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000469a:	02f05563          	blez	a5,800046c4 <initlog+0x74>
    8000469e:	05c50713          	addi	a4,a0,92
    800046a2:	0001d697          	auipc	a3,0x1d
    800046a6:	dfe68693          	addi	a3,a3,-514 # 800214a0 <log+0x30>
    800046aa:	37fd                	addiw	a5,a5,-1
    800046ac:	1782                	slli	a5,a5,0x20
    800046ae:	9381                	srli	a5,a5,0x20
    800046b0:	078a                	slli	a5,a5,0x2
    800046b2:	06050613          	addi	a2,a0,96
    800046b6:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800046b8:	4310                	lw	a2,0(a4)
    800046ba:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800046bc:	0711                	addi	a4,a4,4
    800046be:	0691                	addi	a3,a3,4
    800046c0:	fef71ce3          	bne	a4,a5,800046b8 <initlog+0x68>
  brelse(buf);
    800046c4:	fffff097          	auipc	ra,0xfffff
    800046c8:	f8c080e7          	jalr	-116(ra) # 80003650 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800046cc:	4505                	li	a0,1
    800046ce:	00000097          	auipc	ra,0x0
    800046d2:	ebe080e7          	jalr	-322(ra) # 8000458c <install_trans>
  log.lh.n = 0;
    800046d6:	0001d797          	auipc	a5,0x1d
    800046da:	dc07a323          	sw	zero,-570(a5) # 8002149c <log+0x2c>
  write_head(); // clear the log
    800046de:	00000097          	auipc	ra,0x0
    800046e2:	e34080e7          	jalr	-460(ra) # 80004512 <write_head>
}
    800046e6:	70a2                	ld	ra,40(sp)
    800046e8:	7402                	ld	s0,32(sp)
    800046ea:	64e2                	ld	s1,24(sp)
    800046ec:	6942                	ld	s2,16(sp)
    800046ee:	69a2                	ld	s3,8(sp)
    800046f0:	6145                	addi	sp,sp,48
    800046f2:	8082                	ret

00000000800046f4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800046f4:	1101                	addi	sp,sp,-32
    800046f6:	ec06                	sd	ra,24(sp)
    800046f8:	e822                	sd	s0,16(sp)
    800046fa:	e426                	sd	s1,8(sp)
    800046fc:	e04a                	sd	s2,0(sp)
    800046fe:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004700:	0001d517          	auipc	a0,0x1d
    80004704:	d7050513          	addi	a0,a0,-656 # 80021470 <log>
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	4dc080e7          	jalr	1244(ra) # 80000be4 <acquire>
  while(1){
    if(log.committing){
    80004710:	0001d497          	auipc	s1,0x1d
    80004714:	d6048493          	addi	s1,s1,-672 # 80021470 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004718:	4979                	li	s2,30
    8000471a:	a039                	j	80004728 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000471c:	85a6                	mv	a1,s1
    8000471e:	8526                	mv	a0,s1
    80004720:	ffffe097          	auipc	ra,0xffffe
    80004724:	dc8080e7          	jalr	-568(ra) # 800024e8 <sleep>
    if(log.committing){
    80004728:	50dc                	lw	a5,36(s1)
    8000472a:	fbed                	bnez	a5,8000471c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000472c:	509c                	lw	a5,32(s1)
    8000472e:	0017871b          	addiw	a4,a5,1
    80004732:	0007069b          	sext.w	a3,a4
    80004736:	0027179b          	slliw	a5,a4,0x2
    8000473a:	9fb9                	addw	a5,a5,a4
    8000473c:	0017979b          	slliw	a5,a5,0x1
    80004740:	54d8                	lw	a4,44(s1)
    80004742:	9fb9                	addw	a5,a5,a4
    80004744:	00f95963          	bge	s2,a5,80004756 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004748:	85a6                	mv	a1,s1
    8000474a:	8526                	mv	a0,s1
    8000474c:	ffffe097          	auipc	ra,0xffffe
    80004750:	d9c080e7          	jalr	-612(ra) # 800024e8 <sleep>
    80004754:	bfd1                	j	80004728 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004756:	0001d517          	auipc	a0,0x1d
    8000475a:	d1a50513          	addi	a0,a0,-742 # 80021470 <log>
    8000475e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004760:	ffffc097          	auipc	ra,0xffffc
    80004764:	538080e7          	jalr	1336(ra) # 80000c98 <release>
      break;
    }
  }
}
    80004768:	60e2                	ld	ra,24(sp)
    8000476a:	6442                	ld	s0,16(sp)
    8000476c:	64a2                	ld	s1,8(sp)
    8000476e:	6902                	ld	s2,0(sp)
    80004770:	6105                	addi	sp,sp,32
    80004772:	8082                	ret

0000000080004774 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004774:	7139                	addi	sp,sp,-64
    80004776:	fc06                	sd	ra,56(sp)
    80004778:	f822                	sd	s0,48(sp)
    8000477a:	f426                	sd	s1,40(sp)
    8000477c:	f04a                	sd	s2,32(sp)
    8000477e:	ec4e                	sd	s3,24(sp)
    80004780:	e852                	sd	s4,16(sp)
    80004782:	e456                	sd	s5,8(sp)
    80004784:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004786:	0001d497          	auipc	s1,0x1d
    8000478a:	cea48493          	addi	s1,s1,-790 # 80021470 <log>
    8000478e:	8526                	mv	a0,s1
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	454080e7          	jalr	1108(ra) # 80000be4 <acquire>
  log.outstanding -= 1;
    80004798:	509c                	lw	a5,32(s1)
    8000479a:	37fd                	addiw	a5,a5,-1
    8000479c:	0007891b          	sext.w	s2,a5
    800047a0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800047a2:	50dc                	lw	a5,36(s1)
    800047a4:	efb9                	bnez	a5,80004802 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800047a6:	06091663          	bnez	s2,80004812 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800047aa:	0001d497          	auipc	s1,0x1d
    800047ae:	cc648493          	addi	s1,s1,-826 # 80021470 <log>
    800047b2:	4785                	li	a5,1
    800047b4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800047b6:	8526                	mv	a0,s1
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	4e0080e7          	jalr	1248(ra) # 80000c98 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800047c0:	54dc                	lw	a5,44(s1)
    800047c2:	06f04763          	bgtz	a5,80004830 <end_op+0xbc>
    acquire(&log.lock);
    800047c6:	0001d497          	auipc	s1,0x1d
    800047ca:	caa48493          	addi	s1,s1,-854 # 80021470 <log>
    800047ce:	8526                	mv	a0,s1
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	414080e7          	jalr	1044(ra) # 80000be4 <acquire>
    log.committing = 0;
    800047d8:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800047dc:	8526                	mv	a0,s1
    800047de:	ffffe097          	auipc	ra,0xffffe
    800047e2:	fc8080e7          	jalr	-56(ra) # 800027a6 <wakeup>
    release(&log.lock);
    800047e6:	8526                	mv	a0,s1
    800047e8:	ffffc097          	auipc	ra,0xffffc
    800047ec:	4b0080e7          	jalr	1200(ra) # 80000c98 <release>
}
    800047f0:	70e2                	ld	ra,56(sp)
    800047f2:	7442                	ld	s0,48(sp)
    800047f4:	74a2                	ld	s1,40(sp)
    800047f6:	7902                	ld	s2,32(sp)
    800047f8:	69e2                	ld	s3,24(sp)
    800047fa:	6a42                	ld	s4,16(sp)
    800047fc:	6aa2                	ld	s5,8(sp)
    800047fe:	6121                	addi	sp,sp,64
    80004800:	8082                	ret
    panic("log.committing");
    80004802:	00004517          	auipc	a0,0x4
    80004806:	f0e50513          	addi	a0,a0,-242 # 80008710 <syscalls+0x218>
    8000480a:	ffffc097          	auipc	ra,0xffffc
    8000480e:	d34080e7          	jalr	-716(ra) # 8000053e <panic>
    wakeup(&log);
    80004812:	0001d497          	auipc	s1,0x1d
    80004816:	c5e48493          	addi	s1,s1,-930 # 80021470 <log>
    8000481a:	8526                	mv	a0,s1
    8000481c:	ffffe097          	auipc	ra,0xffffe
    80004820:	f8a080e7          	jalr	-118(ra) # 800027a6 <wakeup>
  release(&log.lock);
    80004824:	8526                	mv	a0,s1
    80004826:	ffffc097          	auipc	ra,0xffffc
    8000482a:	472080e7          	jalr	1138(ra) # 80000c98 <release>
  if(do_commit){
    8000482e:	b7c9                	j	800047f0 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004830:	0001da97          	auipc	s5,0x1d
    80004834:	c70a8a93          	addi	s5,s5,-912 # 800214a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004838:	0001da17          	auipc	s4,0x1d
    8000483c:	c38a0a13          	addi	s4,s4,-968 # 80021470 <log>
    80004840:	018a2583          	lw	a1,24(s4)
    80004844:	012585bb          	addw	a1,a1,s2
    80004848:	2585                	addiw	a1,a1,1
    8000484a:	028a2503          	lw	a0,40(s4)
    8000484e:	fffff097          	auipc	ra,0xfffff
    80004852:	cd2080e7          	jalr	-814(ra) # 80003520 <bread>
    80004856:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004858:	000aa583          	lw	a1,0(s5)
    8000485c:	028a2503          	lw	a0,40(s4)
    80004860:	fffff097          	auipc	ra,0xfffff
    80004864:	cc0080e7          	jalr	-832(ra) # 80003520 <bread>
    80004868:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000486a:	40000613          	li	a2,1024
    8000486e:	05850593          	addi	a1,a0,88
    80004872:	05848513          	addi	a0,s1,88
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	4ca080e7          	jalr	1226(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    8000487e:	8526                	mv	a0,s1
    80004880:	fffff097          	auipc	ra,0xfffff
    80004884:	d92080e7          	jalr	-622(ra) # 80003612 <bwrite>
    brelse(from);
    80004888:	854e                	mv	a0,s3
    8000488a:	fffff097          	auipc	ra,0xfffff
    8000488e:	dc6080e7          	jalr	-570(ra) # 80003650 <brelse>
    brelse(to);
    80004892:	8526                	mv	a0,s1
    80004894:	fffff097          	auipc	ra,0xfffff
    80004898:	dbc080e7          	jalr	-580(ra) # 80003650 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000489c:	2905                	addiw	s2,s2,1
    8000489e:	0a91                	addi	s5,s5,4
    800048a0:	02ca2783          	lw	a5,44(s4)
    800048a4:	f8f94ee3          	blt	s2,a5,80004840 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800048a8:	00000097          	auipc	ra,0x0
    800048ac:	c6a080e7          	jalr	-918(ra) # 80004512 <write_head>
    install_trans(0); // Now install writes to home locations
    800048b0:	4501                	li	a0,0
    800048b2:	00000097          	auipc	ra,0x0
    800048b6:	cda080e7          	jalr	-806(ra) # 8000458c <install_trans>
    log.lh.n = 0;
    800048ba:	0001d797          	auipc	a5,0x1d
    800048be:	be07a123          	sw	zero,-1054(a5) # 8002149c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800048c2:	00000097          	auipc	ra,0x0
    800048c6:	c50080e7          	jalr	-944(ra) # 80004512 <write_head>
    800048ca:	bdf5                	j	800047c6 <end_op+0x52>

00000000800048cc <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800048cc:	1101                	addi	sp,sp,-32
    800048ce:	ec06                	sd	ra,24(sp)
    800048d0:	e822                	sd	s0,16(sp)
    800048d2:	e426                	sd	s1,8(sp)
    800048d4:	e04a                	sd	s2,0(sp)
    800048d6:	1000                	addi	s0,sp,32
    800048d8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800048da:	0001d917          	auipc	s2,0x1d
    800048de:	b9690913          	addi	s2,s2,-1130 # 80021470 <log>
    800048e2:	854a                	mv	a0,s2
    800048e4:	ffffc097          	auipc	ra,0xffffc
    800048e8:	300080e7          	jalr	768(ra) # 80000be4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800048ec:	02c92603          	lw	a2,44(s2)
    800048f0:	47f5                	li	a5,29
    800048f2:	06c7c563          	blt	a5,a2,8000495c <log_write+0x90>
    800048f6:	0001d797          	auipc	a5,0x1d
    800048fa:	b967a783          	lw	a5,-1130(a5) # 8002148c <log+0x1c>
    800048fe:	37fd                	addiw	a5,a5,-1
    80004900:	04f65e63          	bge	a2,a5,8000495c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004904:	0001d797          	auipc	a5,0x1d
    80004908:	b8c7a783          	lw	a5,-1140(a5) # 80021490 <log+0x20>
    8000490c:	06f05063          	blez	a5,8000496c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004910:	4781                	li	a5,0
    80004912:	06c05563          	blez	a2,8000497c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004916:	44cc                	lw	a1,12(s1)
    80004918:	0001d717          	auipc	a4,0x1d
    8000491c:	b8870713          	addi	a4,a4,-1144 # 800214a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004920:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004922:	4314                	lw	a3,0(a4)
    80004924:	04b68c63          	beq	a3,a1,8000497c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004928:	2785                	addiw	a5,a5,1
    8000492a:	0711                	addi	a4,a4,4
    8000492c:	fef61be3          	bne	a2,a5,80004922 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004930:	0621                	addi	a2,a2,8
    80004932:	060a                	slli	a2,a2,0x2
    80004934:	0001d797          	auipc	a5,0x1d
    80004938:	b3c78793          	addi	a5,a5,-1220 # 80021470 <log>
    8000493c:	963e                	add	a2,a2,a5
    8000493e:	44dc                	lw	a5,12(s1)
    80004940:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004942:	8526                	mv	a0,s1
    80004944:	fffff097          	auipc	ra,0xfffff
    80004948:	daa080e7          	jalr	-598(ra) # 800036ee <bpin>
    log.lh.n++;
    8000494c:	0001d717          	auipc	a4,0x1d
    80004950:	b2470713          	addi	a4,a4,-1244 # 80021470 <log>
    80004954:	575c                	lw	a5,44(a4)
    80004956:	2785                	addiw	a5,a5,1
    80004958:	d75c                	sw	a5,44(a4)
    8000495a:	a835                	j	80004996 <log_write+0xca>
    panic("too big a transaction");
    8000495c:	00004517          	auipc	a0,0x4
    80004960:	dc450513          	addi	a0,a0,-572 # 80008720 <syscalls+0x228>
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	bda080e7          	jalr	-1062(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000496c:	00004517          	auipc	a0,0x4
    80004970:	dcc50513          	addi	a0,a0,-564 # 80008738 <syscalls+0x240>
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	bca080e7          	jalr	-1078(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000497c:	00878713          	addi	a4,a5,8
    80004980:	00271693          	slli	a3,a4,0x2
    80004984:	0001d717          	auipc	a4,0x1d
    80004988:	aec70713          	addi	a4,a4,-1300 # 80021470 <log>
    8000498c:	9736                	add	a4,a4,a3
    8000498e:	44d4                	lw	a3,12(s1)
    80004990:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004992:	faf608e3          	beq	a2,a5,80004942 <log_write+0x76>
  }
  release(&log.lock);
    80004996:	0001d517          	auipc	a0,0x1d
    8000499a:	ada50513          	addi	a0,a0,-1318 # 80021470 <log>
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	2fa080e7          	jalr	762(ra) # 80000c98 <release>
}
    800049a6:	60e2                	ld	ra,24(sp)
    800049a8:	6442                	ld	s0,16(sp)
    800049aa:	64a2                	ld	s1,8(sp)
    800049ac:	6902                	ld	s2,0(sp)
    800049ae:	6105                	addi	sp,sp,32
    800049b0:	8082                	ret

00000000800049b2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800049b2:	1101                	addi	sp,sp,-32
    800049b4:	ec06                	sd	ra,24(sp)
    800049b6:	e822                	sd	s0,16(sp)
    800049b8:	e426                	sd	s1,8(sp)
    800049ba:	e04a                	sd	s2,0(sp)
    800049bc:	1000                	addi	s0,sp,32
    800049be:	84aa                	mv	s1,a0
    800049c0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800049c2:	00004597          	auipc	a1,0x4
    800049c6:	d9658593          	addi	a1,a1,-618 # 80008758 <syscalls+0x260>
    800049ca:	0521                	addi	a0,a0,8
    800049cc:	ffffc097          	auipc	ra,0xffffc
    800049d0:	188080e7          	jalr	392(ra) # 80000b54 <initlock>
  lk->name = name;
    800049d4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800049d8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049dc:	0204a423          	sw	zero,40(s1)
}
    800049e0:	60e2                	ld	ra,24(sp)
    800049e2:	6442                	ld	s0,16(sp)
    800049e4:	64a2                	ld	s1,8(sp)
    800049e6:	6902                	ld	s2,0(sp)
    800049e8:	6105                	addi	sp,sp,32
    800049ea:	8082                	ret

00000000800049ec <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800049ec:	1101                	addi	sp,sp,-32
    800049ee:	ec06                	sd	ra,24(sp)
    800049f0:	e822                	sd	s0,16(sp)
    800049f2:	e426                	sd	s1,8(sp)
    800049f4:	e04a                	sd	s2,0(sp)
    800049f6:	1000                	addi	s0,sp,32
    800049f8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049fa:	00850913          	addi	s2,a0,8
    800049fe:	854a                	mv	a0,s2
    80004a00:	ffffc097          	auipc	ra,0xffffc
    80004a04:	1e4080e7          	jalr	484(ra) # 80000be4 <acquire>
  while (lk->locked) {
    80004a08:	409c                	lw	a5,0(s1)
    80004a0a:	cb89                	beqz	a5,80004a1c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004a0c:	85ca                	mv	a1,s2
    80004a0e:	8526                	mv	a0,s1
    80004a10:	ffffe097          	auipc	ra,0xffffe
    80004a14:	ad8080e7          	jalr	-1320(ra) # 800024e8 <sleep>
  while (lk->locked) {
    80004a18:	409c                	lw	a5,0(s1)
    80004a1a:	fbed                	bnez	a5,80004a0c <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004a1c:	4785                	li	a5,1
    80004a1e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004a20:	ffffd097          	auipc	ra,0xffffd
    80004a24:	f90080e7          	jalr	-112(ra) # 800019b0 <myproc>
    80004a28:	591c                	lw	a5,48(a0)
    80004a2a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004a2c:	854a                	mv	a0,s2
    80004a2e:	ffffc097          	auipc	ra,0xffffc
    80004a32:	26a080e7          	jalr	618(ra) # 80000c98 <release>
}
    80004a36:	60e2                	ld	ra,24(sp)
    80004a38:	6442                	ld	s0,16(sp)
    80004a3a:	64a2                	ld	s1,8(sp)
    80004a3c:	6902                	ld	s2,0(sp)
    80004a3e:	6105                	addi	sp,sp,32
    80004a40:	8082                	ret

0000000080004a42 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004a42:	1101                	addi	sp,sp,-32
    80004a44:	ec06                	sd	ra,24(sp)
    80004a46:	e822                	sd	s0,16(sp)
    80004a48:	e426                	sd	s1,8(sp)
    80004a4a:	e04a                	sd	s2,0(sp)
    80004a4c:	1000                	addi	s0,sp,32
    80004a4e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004a50:	00850913          	addi	s2,a0,8
    80004a54:	854a                	mv	a0,s2
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	18e080e7          	jalr	398(ra) # 80000be4 <acquire>
  lk->locked = 0;
    80004a5e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004a62:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004a66:	8526                	mv	a0,s1
    80004a68:	ffffe097          	auipc	ra,0xffffe
    80004a6c:	d3e080e7          	jalr	-706(ra) # 800027a6 <wakeup>
  release(&lk->lk);
    80004a70:	854a                	mv	a0,s2
    80004a72:	ffffc097          	auipc	ra,0xffffc
    80004a76:	226080e7          	jalr	550(ra) # 80000c98 <release>
}
    80004a7a:	60e2                	ld	ra,24(sp)
    80004a7c:	6442                	ld	s0,16(sp)
    80004a7e:	64a2                	ld	s1,8(sp)
    80004a80:	6902                	ld	s2,0(sp)
    80004a82:	6105                	addi	sp,sp,32
    80004a84:	8082                	ret

0000000080004a86 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004a86:	7179                	addi	sp,sp,-48
    80004a88:	f406                	sd	ra,40(sp)
    80004a8a:	f022                	sd	s0,32(sp)
    80004a8c:	ec26                	sd	s1,24(sp)
    80004a8e:	e84a                	sd	s2,16(sp)
    80004a90:	e44e                	sd	s3,8(sp)
    80004a92:	1800                	addi	s0,sp,48
    80004a94:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004a96:	00850913          	addi	s2,a0,8
    80004a9a:	854a                	mv	a0,s2
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	148080e7          	jalr	328(ra) # 80000be4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004aa4:	409c                	lw	a5,0(s1)
    80004aa6:	ef99                	bnez	a5,80004ac4 <holdingsleep+0x3e>
    80004aa8:	4481                	li	s1,0
  release(&lk->lk);
    80004aaa:	854a                	mv	a0,s2
    80004aac:	ffffc097          	auipc	ra,0xffffc
    80004ab0:	1ec080e7          	jalr	492(ra) # 80000c98 <release>
  return r;
}
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	70a2                	ld	ra,40(sp)
    80004ab8:	7402                	ld	s0,32(sp)
    80004aba:	64e2                	ld	s1,24(sp)
    80004abc:	6942                	ld	s2,16(sp)
    80004abe:	69a2                	ld	s3,8(sp)
    80004ac0:	6145                	addi	sp,sp,48
    80004ac2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004ac4:	0284a983          	lw	s3,40(s1)
    80004ac8:	ffffd097          	auipc	ra,0xffffd
    80004acc:	ee8080e7          	jalr	-280(ra) # 800019b0 <myproc>
    80004ad0:	5904                	lw	s1,48(a0)
    80004ad2:	413484b3          	sub	s1,s1,s3
    80004ad6:	0014b493          	seqz	s1,s1
    80004ada:	bfc1                	j	80004aaa <holdingsleep+0x24>

0000000080004adc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004adc:	1141                	addi	sp,sp,-16
    80004ade:	e406                	sd	ra,8(sp)
    80004ae0:	e022                	sd	s0,0(sp)
    80004ae2:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004ae4:	00004597          	auipc	a1,0x4
    80004ae8:	c8458593          	addi	a1,a1,-892 # 80008768 <syscalls+0x270>
    80004aec:	0001d517          	auipc	a0,0x1d
    80004af0:	acc50513          	addi	a0,a0,-1332 # 800215b8 <ftable>
    80004af4:	ffffc097          	auipc	ra,0xffffc
    80004af8:	060080e7          	jalr	96(ra) # 80000b54 <initlock>
}
    80004afc:	60a2                	ld	ra,8(sp)
    80004afe:	6402                	ld	s0,0(sp)
    80004b00:	0141                	addi	sp,sp,16
    80004b02:	8082                	ret

0000000080004b04 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004b04:	1101                	addi	sp,sp,-32
    80004b06:	ec06                	sd	ra,24(sp)
    80004b08:	e822                	sd	s0,16(sp)
    80004b0a:	e426                	sd	s1,8(sp)
    80004b0c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004b0e:	0001d517          	auipc	a0,0x1d
    80004b12:	aaa50513          	addi	a0,a0,-1366 # 800215b8 <ftable>
    80004b16:	ffffc097          	auipc	ra,0xffffc
    80004b1a:	0ce080e7          	jalr	206(ra) # 80000be4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b1e:	0001d497          	auipc	s1,0x1d
    80004b22:	ab248493          	addi	s1,s1,-1358 # 800215d0 <ftable+0x18>
    80004b26:	0001e717          	auipc	a4,0x1e
    80004b2a:	a4a70713          	addi	a4,a4,-1462 # 80022570 <ftable+0xfb8>
    if(f->ref == 0){
    80004b2e:	40dc                	lw	a5,4(s1)
    80004b30:	cf99                	beqz	a5,80004b4e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004b32:	02848493          	addi	s1,s1,40
    80004b36:	fee49ce3          	bne	s1,a4,80004b2e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004b3a:	0001d517          	auipc	a0,0x1d
    80004b3e:	a7e50513          	addi	a0,a0,-1410 # 800215b8 <ftable>
    80004b42:	ffffc097          	auipc	ra,0xffffc
    80004b46:	156080e7          	jalr	342(ra) # 80000c98 <release>
  return 0;
    80004b4a:	4481                	li	s1,0
    80004b4c:	a819                	j	80004b62 <filealloc+0x5e>
      f->ref = 1;
    80004b4e:	4785                	li	a5,1
    80004b50:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004b52:	0001d517          	auipc	a0,0x1d
    80004b56:	a6650513          	addi	a0,a0,-1434 # 800215b8 <ftable>
    80004b5a:	ffffc097          	auipc	ra,0xffffc
    80004b5e:	13e080e7          	jalr	318(ra) # 80000c98 <release>
}
    80004b62:	8526                	mv	a0,s1
    80004b64:	60e2                	ld	ra,24(sp)
    80004b66:	6442                	ld	s0,16(sp)
    80004b68:	64a2                	ld	s1,8(sp)
    80004b6a:	6105                	addi	sp,sp,32
    80004b6c:	8082                	ret

0000000080004b6e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004b6e:	1101                	addi	sp,sp,-32
    80004b70:	ec06                	sd	ra,24(sp)
    80004b72:	e822                	sd	s0,16(sp)
    80004b74:	e426                	sd	s1,8(sp)
    80004b76:	1000                	addi	s0,sp,32
    80004b78:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004b7a:	0001d517          	auipc	a0,0x1d
    80004b7e:	a3e50513          	addi	a0,a0,-1474 # 800215b8 <ftable>
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	062080e7          	jalr	98(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004b8a:	40dc                	lw	a5,4(s1)
    80004b8c:	02f05263          	blez	a5,80004bb0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004b90:	2785                	addiw	a5,a5,1
    80004b92:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004b94:	0001d517          	auipc	a0,0x1d
    80004b98:	a2450513          	addi	a0,a0,-1500 # 800215b8 <ftable>
    80004b9c:	ffffc097          	auipc	ra,0xffffc
    80004ba0:	0fc080e7          	jalr	252(ra) # 80000c98 <release>
  return f;
}
    80004ba4:	8526                	mv	a0,s1
    80004ba6:	60e2                	ld	ra,24(sp)
    80004ba8:	6442                	ld	s0,16(sp)
    80004baa:	64a2                	ld	s1,8(sp)
    80004bac:	6105                	addi	sp,sp,32
    80004bae:	8082                	ret
    panic("filedup");
    80004bb0:	00004517          	auipc	a0,0x4
    80004bb4:	bc050513          	addi	a0,a0,-1088 # 80008770 <syscalls+0x278>
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	986080e7          	jalr	-1658(ra) # 8000053e <panic>

0000000080004bc0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004bc0:	7139                	addi	sp,sp,-64
    80004bc2:	fc06                	sd	ra,56(sp)
    80004bc4:	f822                	sd	s0,48(sp)
    80004bc6:	f426                	sd	s1,40(sp)
    80004bc8:	f04a                	sd	s2,32(sp)
    80004bca:	ec4e                	sd	s3,24(sp)
    80004bcc:	e852                	sd	s4,16(sp)
    80004bce:	e456                	sd	s5,8(sp)
    80004bd0:	0080                	addi	s0,sp,64
    80004bd2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004bd4:	0001d517          	auipc	a0,0x1d
    80004bd8:	9e450513          	addi	a0,a0,-1564 # 800215b8 <ftable>
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	008080e7          	jalr	8(ra) # 80000be4 <acquire>
  if(f->ref < 1)
    80004be4:	40dc                	lw	a5,4(s1)
    80004be6:	06f05163          	blez	a5,80004c48 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004bea:	37fd                	addiw	a5,a5,-1
    80004bec:	0007871b          	sext.w	a4,a5
    80004bf0:	c0dc                	sw	a5,4(s1)
    80004bf2:	06e04363          	bgtz	a4,80004c58 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004bf6:	0004a903          	lw	s2,0(s1)
    80004bfa:	0094ca83          	lbu	s5,9(s1)
    80004bfe:	0104ba03          	ld	s4,16(s1)
    80004c02:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004c06:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004c0a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004c0e:	0001d517          	auipc	a0,0x1d
    80004c12:	9aa50513          	addi	a0,a0,-1622 # 800215b8 <ftable>
    80004c16:	ffffc097          	auipc	ra,0xffffc
    80004c1a:	082080e7          	jalr	130(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    80004c1e:	4785                	li	a5,1
    80004c20:	04f90d63          	beq	s2,a5,80004c7a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004c24:	3979                	addiw	s2,s2,-2
    80004c26:	4785                	li	a5,1
    80004c28:	0527e063          	bltu	a5,s2,80004c68 <fileclose+0xa8>
    begin_op();
    80004c2c:	00000097          	auipc	ra,0x0
    80004c30:	ac8080e7          	jalr	-1336(ra) # 800046f4 <begin_op>
    iput(ff.ip);
    80004c34:	854e                	mv	a0,s3
    80004c36:	fffff097          	auipc	ra,0xfffff
    80004c3a:	2a6080e7          	jalr	678(ra) # 80003edc <iput>
    end_op();
    80004c3e:	00000097          	auipc	ra,0x0
    80004c42:	b36080e7          	jalr	-1226(ra) # 80004774 <end_op>
    80004c46:	a00d                	j	80004c68 <fileclose+0xa8>
    panic("fileclose");
    80004c48:	00004517          	auipc	a0,0x4
    80004c4c:	b3050513          	addi	a0,a0,-1232 # 80008778 <syscalls+0x280>
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	8ee080e7          	jalr	-1810(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004c58:	0001d517          	auipc	a0,0x1d
    80004c5c:	96050513          	addi	a0,a0,-1696 # 800215b8 <ftable>
    80004c60:	ffffc097          	auipc	ra,0xffffc
    80004c64:	038080e7          	jalr	56(ra) # 80000c98 <release>
  }
}
    80004c68:	70e2                	ld	ra,56(sp)
    80004c6a:	7442                	ld	s0,48(sp)
    80004c6c:	74a2                	ld	s1,40(sp)
    80004c6e:	7902                	ld	s2,32(sp)
    80004c70:	69e2                	ld	s3,24(sp)
    80004c72:	6a42                	ld	s4,16(sp)
    80004c74:	6aa2                	ld	s5,8(sp)
    80004c76:	6121                	addi	sp,sp,64
    80004c78:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004c7a:	85d6                	mv	a1,s5
    80004c7c:	8552                	mv	a0,s4
    80004c7e:	00000097          	auipc	ra,0x0
    80004c82:	34c080e7          	jalr	844(ra) # 80004fca <pipeclose>
    80004c86:	b7cd                	j	80004c68 <fileclose+0xa8>

0000000080004c88 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004c88:	715d                	addi	sp,sp,-80
    80004c8a:	e486                	sd	ra,72(sp)
    80004c8c:	e0a2                	sd	s0,64(sp)
    80004c8e:	fc26                	sd	s1,56(sp)
    80004c90:	f84a                	sd	s2,48(sp)
    80004c92:	f44e                	sd	s3,40(sp)
    80004c94:	0880                	addi	s0,sp,80
    80004c96:	84aa                	mv	s1,a0
    80004c98:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004c9a:	ffffd097          	auipc	ra,0xffffd
    80004c9e:	d16080e7          	jalr	-746(ra) # 800019b0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ca2:	409c                	lw	a5,0(s1)
    80004ca4:	37f9                	addiw	a5,a5,-2
    80004ca6:	4705                	li	a4,1
    80004ca8:	04f76763          	bltu	a4,a5,80004cf6 <filestat+0x6e>
    80004cac:	892a                	mv	s2,a0
    ilock(f->ip);
    80004cae:	6c88                	ld	a0,24(s1)
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	072080e7          	jalr	114(ra) # 80003d22 <ilock>
    stati(f->ip, &st);
    80004cb8:	fb840593          	addi	a1,s0,-72
    80004cbc:	6c88                	ld	a0,24(s1)
    80004cbe:	fffff097          	auipc	ra,0xfffff
    80004cc2:	2ee080e7          	jalr	750(ra) # 80003fac <stati>
    iunlock(f->ip);
    80004cc6:	6c88                	ld	a0,24(s1)
    80004cc8:	fffff097          	auipc	ra,0xfffff
    80004ccc:	11c080e7          	jalr	284(ra) # 80003de4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004cd0:	46e1                	li	a3,24
    80004cd2:	fb840613          	addi	a2,s0,-72
    80004cd6:	85ce                	mv	a1,s3
    80004cd8:	05893503          	ld	a0,88(s2)
    80004cdc:	ffffd097          	auipc	ra,0xffffd
    80004ce0:	996080e7          	jalr	-1642(ra) # 80001672 <copyout>
    80004ce4:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ce8:	60a6                	ld	ra,72(sp)
    80004cea:	6406                	ld	s0,64(sp)
    80004cec:	74e2                	ld	s1,56(sp)
    80004cee:	7942                	ld	s2,48(sp)
    80004cf0:	79a2                	ld	s3,40(sp)
    80004cf2:	6161                	addi	sp,sp,80
    80004cf4:	8082                	ret
  return -1;
    80004cf6:	557d                	li	a0,-1
    80004cf8:	bfc5                	j	80004ce8 <filestat+0x60>

0000000080004cfa <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004cfa:	7179                	addi	sp,sp,-48
    80004cfc:	f406                	sd	ra,40(sp)
    80004cfe:	f022                	sd	s0,32(sp)
    80004d00:	ec26                	sd	s1,24(sp)
    80004d02:	e84a                	sd	s2,16(sp)
    80004d04:	e44e                	sd	s3,8(sp)
    80004d06:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004d08:	00854783          	lbu	a5,8(a0)
    80004d0c:	c3d5                	beqz	a5,80004db0 <fileread+0xb6>
    80004d0e:	84aa                	mv	s1,a0
    80004d10:	89ae                	mv	s3,a1
    80004d12:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d14:	411c                	lw	a5,0(a0)
    80004d16:	4705                	li	a4,1
    80004d18:	04e78963          	beq	a5,a4,80004d6a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d1c:	470d                	li	a4,3
    80004d1e:	04e78d63          	beq	a5,a4,80004d78 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d22:	4709                	li	a4,2
    80004d24:	06e79e63          	bne	a5,a4,80004da0 <fileread+0xa6>
    ilock(f->ip);
    80004d28:	6d08                	ld	a0,24(a0)
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	ff8080e7          	jalr	-8(ra) # 80003d22 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004d32:	874a                	mv	a4,s2
    80004d34:	5094                	lw	a3,32(s1)
    80004d36:	864e                	mv	a2,s3
    80004d38:	4585                	li	a1,1
    80004d3a:	6c88                	ld	a0,24(s1)
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	29a080e7          	jalr	666(ra) # 80003fd6 <readi>
    80004d44:	892a                	mv	s2,a0
    80004d46:	00a05563          	blez	a0,80004d50 <fileread+0x56>
      f->off += r;
    80004d4a:	509c                	lw	a5,32(s1)
    80004d4c:	9fa9                	addw	a5,a5,a0
    80004d4e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004d50:	6c88                	ld	a0,24(s1)
    80004d52:	fffff097          	auipc	ra,0xfffff
    80004d56:	092080e7          	jalr	146(ra) # 80003de4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004d5a:	854a                	mv	a0,s2
    80004d5c:	70a2                	ld	ra,40(sp)
    80004d5e:	7402                	ld	s0,32(sp)
    80004d60:	64e2                	ld	s1,24(sp)
    80004d62:	6942                	ld	s2,16(sp)
    80004d64:	69a2                	ld	s3,8(sp)
    80004d66:	6145                	addi	sp,sp,48
    80004d68:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004d6a:	6908                	ld	a0,16(a0)
    80004d6c:	00000097          	auipc	ra,0x0
    80004d70:	3c8080e7          	jalr	968(ra) # 80005134 <piperead>
    80004d74:	892a                	mv	s2,a0
    80004d76:	b7d5                	j	80004d5a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004d78:	02451783          	lh	a5,36(a0)
    80004d7c:	03079693          	slli	a3,a5,0x30
    80004d80:	92c1                	srli	a3,a3,0x30
    80004d82:	4725                	li	a4,9
    80004d84:	02d76863          	bltu	a4,a3,80004db4 <fileread+0xba>
    80004d88:	0792                	slli	a5,a5,0x4
    80004d8a:	0001c717          	auipc	a4,0x1c
    80004d8e:	78e70713          	addi	a4,a4,1934 # 80021518 <devsw>
    80004d92:	97ba                	add	a5,a5,a4
    80004d94:	639c                	ld	a5,0(a5)
    80004d96:	c38d                	beqz	a5,80004db8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004d98:	4505                	li	a0,1
    80004d9a:	9782                	jalr	a5
    80004d9c:	892a                	mv	s2,a0
    80004d9e:	bf75                	j	80004d5a <fileread+0x60>
    panic("fileread");
    80004da0:	00004517          	auipc	a0,0x4
    80004da4:	9e850513          	addi	a0,a0,-1560 # 80008788 <syscalls+0x290>
    80004da8:	ffffb097          	auipc	ra,0xffffb
    80004dac:	796080e7          	jalr	1942(ra) # 8000053e <panic>
    return -1;
    80004db0:	597d                	li	s2,-1
    80004db2:	b765                	j	80004d5a <fileread+0x60>
      return -1;
    80004db4:	597d                	li	s2,-1
    80004db6:	b755                	j	80004d5a <fileread+0x60>
    80004db8:	597d                	li	s2,-1
    80004dba:	b745                	j	80004d5a <fileread+0x60>

0000000080004dbc <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004dbc:	715d                	addi	sp,sp,-80
    80004dbe:	e486                	sd	ra,72(sp)
    80004dc0:	e0a2                	sd	s0,64(sp)
    80004dc2:	fc26                	sd	s1,56(sp)
    80004dc4:	f84a                	sd	s2,48(sp)
    80004dc6:	f44e                	sd	s3,40(sp)
    80004dc8:	f052                	sd	s4,32(sp)
    80004dca:	ec56                	sd	s5,24(sp)
    80004dcc:	e85a                	sd	s6,16(sp)
    80004dce:	e45e                	sd	s7,8(sp)
    80004dd0:	e062                	sd	s8,0(sp)
    80004dd2:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004dd4:	00954783          	lbu	a5,9(a0)
    80004dd8:	10078663          	beqz	a5,80004ee4 <filewrite+0x128>
    80004ddc:	892a                	mv	s2,a0
    80004dde:	8aae                	mv	s5,a1
    80004de0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004de2:	411c                	lw	a5,0(a0)
    80004de4:	4705                	li	a4,1
    80004de6:	02e78263          	beq	a5,a4,80004e0a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004dea:	470d                	li	a4,3
    80004dec:	02e78663          	beq	a5,a4,80004e18 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004df0:	4709                	li	a4,2
    80004df2:	0ee79163          	bne	a5,a4,80004ed4 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004df6:	0ac05d63          	blez	a2,80004eb0 <filewrite+0xf4>
    int i = 0;
    80004dfa:	4981                	li	s3,0
    80004dfc:	6b05                	lui	s6,0x1
    80004dfe:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004e02:	6b85                	lui	s7,0x1
    80004e04:	c00b8b9b          	addiw	s7,s7,-1024
    80004e08:	a861                	j	80004ea0 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004e0a:	6908                	ld	a0,16(a0)
    80004e0c:	00000097          	auipc	ra,0x0
    80004e10:	22e080e7          	jalr	558(ra) # 8000503a <pipewrite>
    80004e14:	8a2a                	mv	s4,a0
    80004e16:	a045                	j	80004eb6 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004e18:	02451783          	lh	a5,36(a0)
    80004e1c:	03079693          	slli	a3,a5,0x30
    80004e20:	92c1                	srli	a3,a3,0x30
    80004e22:	4725                	li	a4,9
    80004e24:	0cd76263          	bltu	a4,a3,80004ee8 <filewrite+0x12c>
    80004e28:	0792                	slli	a5,a5,0x4
    80004e2a:	0001c717          	auipc	a4,0x1c
    80004e2e:	6ee70713          	addi	a4,a4,1774 # 80021518 <devsw>
    80004e32:	97ba                	add	a5,a5,a4
    80004e34:	679c                	ld	a5,8(a5)
    80004e36:	cbdd                	beqz	a5,80004eec <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004e38:	4505                	li	a0,1
    80004e3a:	9782                	jalr	a5
    80004e3c:	8a2a                	mv	s4,a0
    80004e3e:	a8a5                	j	80004eb6 <filewrite+0xfa>
    80004e40:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004e44:	00000097          	auipc	ra,0x0
    80004e48:	8b0080e7          	jalr	-1872(ra) # 800046f4 <begin_op>
      ilock(f->ip);
    80004e4c:	01893503          	ld	a0,24(s2)
    80004e50:	fffff097          	auipc	ra,0xfffff
    80004e54:	ed2080e7          	jalr	-302(ra) # 80003d22 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004e58:	8762                	mv	a4,s8
    80004e5a:	02092683          	lw	a3,32(s2)
    80004e5e:	01598633          	add	a2,s3,s5
    80004e62:	4585                	li	a1,1
    80004e64:	01893503          	ld	a0,24(s2)
    80004e68:	fffff097          	auipc	ra,0xfffff
    80004e6c:	266080e7          	jalr	614(ra) # 800040ce <writei>
    80004e70:	84aa                	mv	s1,a0
    80004e72:	00a05763          	blez	a0,80004e80 <filewrite+0xc4>
        f->off += r;
    80004e76:	02092783          	lw	a5,32(s2)
    80004e7a:	9fa9                	addw	a5,a5,a0
    80004e7c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004e80:	01893503          	ld	a0,24(s2)
    80004e84:	fffff097          	auipc	ra,0xfffff
    80004e88:	f60080e7          	jalr	-160(ra) # 80003de4 <iunlock>
      end_op();
    80004e8c:	00000097          	auipc	ra,0x0
    80004e90:	8e8080e7          	jalr	-1816(ra) # 80004774 <end_op>

      if(r != n1){
    80004e94:	009c1f63          	bne	s8,s1,80004eb2 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004e98:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e9c:	0149db63          	bge	s3,s4,80004eb2 <filewrite+0xf6>
      int n1 = n - i;
    80004ea0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004ea4:	84be                	mv	s1,a5
    80004ea6:	2781                	sext.w	a5,a5
    80004ea8:	f8fb5ce3          	bge	s6,a5,80004e40 <filewrite+0x84>
    80004eac:	84de                	mv	s1,s7
    80004eae:	bf49                	j	80004e40 <filewrite+0x84>
    int i = 0;
    80004eb0:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004eb2:	013a1f63          	bne	s4,s3,80004ed0 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004eb6:	8552                	mv	a0,s4
    80004eb8:	60a6                	ld	ra,72(sp)
    80004eba:	6406                	ld	s0,64(sp)
    80004ebc:	74e2                	ld	s1,56(sp)
    80004ebe:	7942                	ld	s2,48(sp)
    80004ec0:	79a2                	ld	s3,40(sp)
    80004ec2:	7a02                	ld	s4,32(sp)
    80004ec4:	6ae2                	ld	s5,24(sp)
    80004ec6:	6b42                	ld	s6,16(sp)
    80004ec8:	6ba2                	ld	s7,8(sp)
    80004eca:	6c02                	ld	s8,0(sp)
    80004ecc:	6161                	addi	sp,sp,80
    80004ece:	8082                	ret
    ret = (i == n ? n : -1);
    80004ed0:	5a7d                	li	s4,-1
    80004ed2:	b7d5                	j	80004eb6 <filewrite+0xfa>
    panic("filewrite");
    80004ed4:	00004517          	auipc	a0,0x4
    80004ed8:	8c450513          	addi	a0,a0,-1852 # 80008798 <syscalls+0x2a0>
    80004edc:	ffffb097          	auipc	ra,0xffffb
    80004ee0:	662080e7          	jalr	1634(ra) # 8000053e <panic>
    return -1;
    80004ee4:	5a7d                	li	s4,-1
    80004ee6:	bfc1                	j	80004eb6 <filewrite+0xfa>
      return -1;
    80004ee8:	5a7d                	li	s4,-1
    80004eea:	b7f1                	j	80004eb6 <filewrite+0xfa>
    80004eec:	5a7d                	li	s4,-1
    80004eee:	b7e1                	j	80004eb6 <filewrite+0xfa>

0000000080004ef0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ef0:	7179                	addi	sp,sp,-48
    80004ef2:	f406                	sd	ra,40(sp)
    80004ef4:	f022                	sd	s0,32(sp)
    80004ef6:	ec26                	sd	s1,24(sp)
    80004ef8:	e84a                	sd	s2,16(sp)
    80004efa:	e44e                	sd	s3,8(sp)
    80004efc:	e052                	sd	s4,0(sp)
    80004efe:	1800                	addi	s0,sp,48
    80004f00:	84aa                	mv	s1,a0
    80004f02:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004f04:	0005b023          	sd	zero,0(a1)
    80004f08:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004f0c:	00000097          	auipc	ra,0x0
    80004f10:	bf8080e7          	jalr	-1032(ra) # 80004b04 <filealloc>
    80004f14:	e088                	sd	a0,0(s1)
    80004f16:	c551                	beqz	a0,80004fa2 <pipealloc+0xb2>
    80004f18:	00000097          	auipc	ra,0x0
    80004f1c:	bec080e7          	jalr	-1044(ra) # 80004b04 <filealloc>
    80004f20:	00aa3023          	sd	a0,0(s4)
    80004f24:	c92d                	beqz	a0,80004f96 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004f26:	ffffc097          	auipc	ra,0xffffc
    80004f2a:	bce080e7          	jalr	-1074(ra) # 80000af4 <kalloc>
    80004f2e:	892a                	mv	s2,a0
    80004f30:	c125                	beqz	a0,80004f90 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004f32:	4985                	li	s3,1
    80004f34:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004f38:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004f3c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004f40:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004f44:	00004597          	auipc	a1,0x4
    80004f48:	86458593          	addi	a1,a1,-1948 # 800087a8 <syscalls+0x2b0>
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	c08080e7          	jalr	-1016(ra) # 80000b54 <initlock>
  (*f0)->type = FD_PIPE;
    80004f54:	609c                	ld	a5,0(s1)
    80004f56:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004f5a:	609c                	ld	a5,0(s1)
    80004f5c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004f60:	609c                	ld	a5,0(s1)
    80004f62:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004f66:	609c                	ld	a5,0(s1)
    80004f68:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004f6c:	000a3783          	ld	a5,0(s4)
    80004f70:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004f74:	000a3783          	ld	a5,0(s4)
    80004f78:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004f7c:	000a3783          	ld	a5,0(s4)
    80004f80:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004f84:	000a3783          	ld	a5,0(s4)
    80004f88:	0127b823          	sd	s2,16(a5)
  return 0;
    80004f8c:	4501                	li	a0,0
    80004f8e:	a025                	j	80004fb6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004f90:	6088                	ld	a0,0(s1)
    80004f92:	e501                	bnez	a0,80004f9a <pipealloc+0xaa>
    80004f94:	a039                	j	80004fa2 <pipealloc+0xb2>
    80004f96:	6088                	ld	a0,0(s1)
    80004f98:	c51d                	beqz	a0,80004fc6 <pipealloc+0xd6>
    fileclose(*f0);
    80004f9a:	00000097          	auipc	ra,0x0
    80004f9e:	c26080e7          	jalr	-986(ra) # 80004bc0 <fileclose>
  if(*f1)
    80004fa2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004fa6:	557d                	li	a0,-1
  if(*f1)
    80004fa8:	c799                	beqz	a5,80004fb6 <pipealloc+0xc6>
    fileclose(*f1);
    80004faa:	853e                	mv	a0,a5
    80004fac:	00000097          	auipc	ra,0x0
    80004fb0:	c14080e7          	jalr	-1004(ra) # 80004bc0 <fileclose>
  return -1;
    80004fb4:	557d                	li	a0,-1
}
    80004fb6:	70a2                	ld	ra,40(sp)
    80004fb8:	7402                	ld	s0,32(sp)
    80004fba:	64e2                	ld	s1,24(sp)
    80004fbc:	6942                	ld	s2,16(sp)
    80004fbe:	69a2                	ld	s3,8(sp)
    80004fc0:	6a02                	ld	s4,0(sp)
    80004fc2:	6145                	addi	sp,sp,48
    80004fc4:	8082                	ret
  return -1;
    80004fc6:	557d                	li	a0,-1
    80004fc8:	b7fd                	j	80004fb6 <pipealloc+0xc6>

0000000080004fca <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004fca:	1101                	addi	sp,sp,-32
    80004fcc:	ec06                	sd	ra,24(sp)
    80004fce:	e822                	sd	s0,16(sp)
    80004fd0:	e426                	sd	s1,8(sp)
    80004fd2:	e04a                	sd	s2,0(sp)
    80004fd4:	1000                	addi	s0,sp,32
    80004fd6:	84aa                	mv	s1,a0
    80004fd8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004fda:	ffffc097          	auipc	ra,0xffffc
    80004fde:	c0a080e7          	jalr	-1014(ra) # 80000be4 <acquire>
  if(writable){
    80004fe2:	02090d63          	beqz	s2,8000501c <pipeclose+0x52>
    pi->writeopen = 0;
    80004fe6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004fea:	21848513          	addi	a0,s1,536
    80004fee:	ffffd097          	auipc	ra,0xffffd
    80004ff2:	7b8080e7          	jalr	1976(ra) # 800027a6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ff6:	2204b783          	ld	a5,544(s1)
    80004ffa:	eb95                	bnez	a5,8000502e <pipeclose+0x64>
    release(&pi->lock);
    80004ffc:	8526                	mv	a0,s1
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	c9a080e7          	jalr	-870(ra) # 80000c98 <release>
    kfree((char*)pi);
    80005006:	8526                	mv	a0,s1
    80005008:	ffffc097          	auipc	ra,0xffffc
    8000500c:	9f0080e7          	jalr	-1552(ra) # 800009f8 <kfree>
  } else
    release(&pi->lock);
}
    80005010:	60e2                	ld	ra,24(sp)
    80005012:	6442                	ld	s0,16(sp)
    80005014:	64a2                	ld	s1,8(sp)
    80005016:	6902                	ld	s2,0(sp)
    80005018:	6105                	addi	sp,sp,32
    8000501a:	8082                	ret
    pi->readopen = 0;
    8000501c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005020:	21c48513          	addi	a0,s1,540
    80005024:	ffffd097          	auipc	ra,0xffffd
    80005028:	782080e7          	jalr	1922(ra) # 800027a6 <wakeup>
    8000502c:	b7e9                	j	80004ff6 <pipeclose+0x2c>
    release(&pi->lock);
    8000502e:	8526                	mv	a0,s1
    80005030:	ffffc097          	auipc	ra,0xffffc
    80005034:	c68080e7          	jalr	-920(ra) # 80000c98 <release>
}
    80005038:	bfe1                	j	80005010 <pipeclose+0x46>

000000008000503a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000503a:	7159                	addi	sp,sp,-112
    8000503c:	f486                	sd	ra,104(sp)
    8000503e:	f0a2                	sd	s0,96(sp)
    80005040:	eca6                	sd	s1,88(sp)
    80005042:	e8ca                	sd	s2,80(sp)
    80005044:	e4ce                	sd	s3,72(sp)
    80005046:	e0d2                	sd	s4,64(sp)
    80005048:	fc56                	sd	s5,56(sp)
    8000504a:	f85a                	sd	s6,48(sp)
    8000504c:	f45e                	sd	s7,40(sp)
    8000504e:	f062                	sd	s8,32(sp)
    80005050:	ec66                	sd	s9,24(sp)
    80005052:	1880                	addi	s0,sp,112
    80005054:	84aa                	mv	s1,a0
    80005056:	8aae                	mv	s5,a1
    80005058:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000505a:	ffffd097          	auipc	ra,0xffffd
    8000505e:	956080e7          	jalr	-1706(ra) # 800019b0 <myproc>
    80005062:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005064:	8526                	mv	a0,s1
    80005066:	ffffc097          	auipc	ra,0xffffc
    8000506a:	b7e080e7          	jalr	-1154(ra) # 80000be4 <acquire>
  while(i < n){
    8000506e:	0d405163          	blez	s4,80005130 <pipewrite+0xf6>
    80005072:	8ba6                	mv	s7,s1
  int i = 0;
    80005074:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005076:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005078:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000507c:	21c48c13          	addi	s8,s1,540
    80005080:	a08d                	j	800050e2 <pipewrite+0xa8>
      release(&pi->lock);
    80005082:	8526                	mv	a0,s1
    80005084:	ffffc097          	auipc	ra,0xffffc
    80005088:	c14080e7          	jalr	-1004(ra) # 80000c98 <release>
      return -1;
    8000508c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000508e:	854a                	mv	a0,s2
    80005090:	70a6                	ld	ra,104(sp)
    80005092:	7406                	ld	s0,96(sp)
    80005094:	64e6                	ld	s1,88(sp)
    80005096:	6946                	ld	s2,80(sp)
    80005098:	69a6                	ld	s3,72(sp)
    8000509a:	6a06                	ld	s4,64(sp)
    8000509c:	7ae2                	ld	s5,56(sp)
    8000509e:	7b42                	ld	s6,48(sp)
    800050a0:	7ba2                	ld	s7,40(sp)
    800050a2:	7c02                	ld	s8,32(sp)
    800050a4:	6ce2                	ld	s9,24(sp)
    800050a6:	6165                	addi	sp,sp,112
    800050a8:	8082                	ret
      wakeup(&pi->nread);
    800050aa:	8566                	mv	a0,s9
    800050ac:	ffffd097          	auipc	ra,0xffffd
    800050b0:	6fa080e7          	jalr	1786(ra) # 800027a6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800050b4:	85de                	mv	a1,s7
    800050b6:	8562                	mv	a0,s8
    800050b8:	ffffd097          	auipc	ra,0xffffd
    800050bc:	430080e7          	jalr	1072(ra) # 800024e8 <sleep>
    800050c0:	a839                	j	800050de <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800050c2:	21c4a783          	lw	a5,540(s1)
    800050c6:	0017871b          	addiw	a4,a5,1
    800050ca:	20e4ae23          	sw	a4,540(s1)
    800050ce:	1ff7f793          	andi	a5,a5,511
    800050d2:	97a6                	add	a5,a5,s1
    800050d4:	f9f44703          	lbu	a4,-97(s0)
    800050d8:	00e78c23          	sb	a4,24(a5)
      i++;
    800050dc:	2905                	addiw	s2,s2,1
  while(i < n){
    800050de:	03495d63          	bge	s2,s4,80005118 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    800050e2:	2204a783          	lw	a5,544(s1)
    800050e6:	dfd1                	beqz	a5,80005082 <pipewrite+0x48>
    800050e8:	0289a783          	lw	a5,40(s3)
    800050ec:	fbd9                	bnez	a5,80005082 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800050ee:	2184a783          	lw	a5,536(s1)
    800050f2:	21c4a703          	lw	a4,540(s1)
    800050f6:	2007879b          	addiw	a5,a5,512
    800050fa:	faf708e3          	beq	a4,a5,800050aa <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800050fe:	4685                	li	a3,1
    80005100:	01590633          	add	a2,s2,s5
    80005104:	f9f40593          	addi	a1,s0,-97
    80005108:	0589b503          	ld	a0,88(s3)
    8000510c:	ffffc097          	auipc	ra,0xffffc
    80005110:	5f2080e7          	jalr	1522(ra) # 800016fe <copyin>
    80005114:	fb6517e3          	bne	a0,s6,800050c2 <pipewrite+0x88>
  wakeup(&pi->nread);
    80005118:	21848513          	addi	a0,s1,536
    8000511c:	ffffd097          	auipc	ra,0xffffd
    80005120:	68a080e7          	jalr	1674(ra) # 800027a6 <wakeup>
  release(&pi->lock);
    80005124:	8526                	mv	a0,s1
    80005126:	ffffc097          	auipc	ra,0xffffc
    8000512a:	b72080e7          	jalr	-1166(ra) # 80000c98 <release>
  return i;
    8000512e:	b785                	j	8000508e <pipewrite+0x54>
  int i = 0;
    80005130:	4901                	li	s2,0
    80005132:	b7dd                	j	80005118 <pipewrite+0xde>

0000000080005134 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005134:	715d                	addi	sp,sp,-80
    80005136:	e486                	sd	ra,72(sp)
    80005138:	e0a2                	sd	s0,64(sp)
    8000513a:	fc26                	sd	s1,56(sp)
    8000513c:	f84a                	sd	s2,48(sp)
    8000513e:	f44e                	sd	s3,40(sp)
    80005140:	f052                	sd	s4,32(sp)
    80005142:	ec56                	sd	s5,24(sp)
    80005144:	e85a                	sd	s6,16(sp)
    80005146:	0880                	addi	s0,sp,80
    80005148:	84aa                	mv	s1,a0
    8000514a:	892e                	mv	s2,a1
    8000514c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000514e:	ffffd097          	auipc	ra,0xffffd
    80005152:	862080e7          	jalr	-1950(ra) # 800019b0 <myproc>
    80005156:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005158:	8b26                	mv	s6,s1
    8000515a:	8526                	mv	a0,s1
    8000515c:	ffffc097          	auipc	ra,0xffffc
    80005160:	a88080e7          	jalr	-1400(ra) # 80000be4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005164:	2184a703          	lw	a4,536(s1)
    80005168:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000516c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005170:	02f71463          	bne	a4,a5,80005198 <piperead+0x64>
    80005174:	2244a783          	lw	a5,548(s1)
    80005178:	c385                	beqz	a5,80005198 <piperead+0x64>
    if(pr->killed){
    8000517a:	028a2783          	lw	a5,40(s4)
    8000517e:	ebc1                	bnez	a5,8000520e <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005180:	85da                	mv	a1,s6
    80005182:	854e                	mv	a0,s3
    80005184:	ffffd097          	auipc	ra,0xffffd
    80005188:	364080e7          	jalr	868(ra) # 800024e8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000518c:	2184a703          	lw	a4,536(s1)
    80005190:	21c4a783          	lw	a5,540(s1)
    80005194:	fef700e3          	beq	a4,a5,80005174 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005198:	09505263          	blez	s5,8000521c <piperead+0xe8>
    8000519c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000519e:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800051a0:	2184a783          	lw	a5,536(s1)
    800051a4:	21c4a703          	lw	a4,540(s1)
    800051a8:	02f70d63          	beq	a4,a5,800051e2 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800051ac:	0017871b          	addiw	a4,a5,1
    800051b0:	20e4ac23          	sw	a4,536(s1)
    800051b4:	1ff7f793          	andi	a5,a5,511
    800051b8:	97a6                	add	a5,a5,s1
    800051ba:	0187c783          	lbu	a5,24(a5)
    800051be:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800051c2:	4685                	li	a3,1
    800051c4:	fbf40613          	addi	a2,s0,-65
    800051c8:	85ca                	mv	a1,s2
    800051ca:	058a3503          	ld	a0,88(s4)
    800051ce:	ffffc097          	auipc	ra,0xffffc
    800051d2:	4a4080e7          	jalr	1188(ra) # 80001672 <copyout>
    800051d6:	01650663          	beq	a0,s6,800051e2 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800051da:	2985                	addiw	s3,s3,1
    800051dc:	0905                	addi	s2,s2,1
    800051de:	fd3a91e3          	bne	s5,s3,800051a0 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800051e2:	21c48513          	addi	a0,s1,540
    800051e6:	ffffd097          	auipc	ra,0xffffd
    800051ea:	5c0080e7          	jalr	1472(ra) # 800027a6 <wakeup>
  release(&pi->lock);
    800051ee:	8526                	mv	a0,s1
    800051f0:	ffffc097          	auipc	ra,0xffffc
    800051f4:	aa8080e7          	jalr	-1368(ra) # 80000c98 <release>
  return i;
}
    800051f8:	854e                	mv	a0,s3
    800051fa:	60a6                	ld	ra,72(sp)
    800051fc:	6406                	ld	s0,64(sp)
    800051fe:	74e2                	ld	s1,56(sp)
    80005200:	7942                	ld	s2,48(sp)
    80005202:	79a2                	ld	s3,40(sp)
    80005204:	7a02                	ld	s4,32(sp)
    80005206:	6ae2                	ld	s5,24(sp)
    80005208:	6b42                	ld	s6,16(sp)
    8000520a:	6161                	addi	sp,sp,80
    8000520c:	8082                	ret
      release(&pi->lock);
    8000520e:	8526                	mv	a0,s1
    80005210:	ffffc097          	auipc	ra,0xffffc
    80005214:	a88080e7          	jalr	-1400(ra) # 80000c98 <release>
      return -1;
    80005218:	59fd                	li	s3,-1
    8000521a:	bff9                	j	800051f8 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000521c:	4981                	li	s3,0
    8000521e:	b7d1                	j	800051e2 <piperead+0xae>

0000000080005220 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005220:	df010113          	addi	sp,sp,-528
    80005224:	20113423          	sd	ra,520(sp)
    80005228:	20813023          	sd	s0,512(sp)
    8000522c:	ffa6                	sd	s1,504(sp)
    8000522e:	fbca                	sd	s2,496(sp)
    80005230:	f7ce                	sd	s3,488(sp)
    80005232:	f3d2                	sd	s4,480(sp)
    80005234:	efd6                	sd	s5,472(sp)
    80005236:	ebda                	sd	s6,464(sp)
    80005238:	e7de                	sd	s7,456(sp)
    8000523a:	e3e2                	sd	s8,448(sp)
    8000523c:	ff66                	sd	s9,440(sp)
    8000523e:	fb6a                	sd	s10,432(sp)
    80005240:	f76e                	sd	s11,424(sp)
    80005242:	0c00                	addi	s0,sp,528
    80005244:	84aa                	mv	s1,a0
    80005246:	dea43c23          	sd	a0,-520(s0)
    8000524a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000524e:	ffffc097          	auipc	ra,0xffffc
    80005252:	762080e7          	jalr	1890(ra) # 800019b0 <myproc>
    80005256:	892a                	mv	s2,a0

  begin_op();
    80005258:	fffff097          	auipc	ra,0xfffff
    8000525c:	49c080e7          	jalr	1180(ra) # 800046f4 <begin_op>

  if((ip = namei(path)) == 0){
    80005260:	8526                	mv	a0,s1
    80005262:	fffff097          	auipc	ra,0xfffff
    80005266:	276080e7          	jalr	630(ra) # 800044d8 <namei>
    8000526a:	c92d                	beqz	a0,800052dc <exec+0xbc>
    8000526c:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000526e:	fffff097          	auipc	ra,0xfffff
    80005272:	ab4080e7          	jalr	-1356(ra) # 80003d22 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005276:	04000713          	li	a4,64
    8000527a:	4681                	li	a3,0
    8000527c:	e5040613          	addi	a2,s0,-432
    80005280:	4581                	li	a1,0
    80005282:	8526                	mv	a0,s1
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	d52080e7          	jalr	-686(ra) # 80003fd6 <readi>
    8000528c:	04000793          	li	a5,64
    80005290:	00f51a63          	bne	a0,a5,800052a4 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005294:	e5042703          	lw	a4,-432(s0)
    80005298:	464c47b7          	lui	a5,0x464c4
    8000529c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800052a0:	04f70463          	beq	a4,a5,800052e8 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800052a4:	8526                	mv	a0,s1
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	cde080e7          	jalr	-802(ra) # 80003f84 <iunlockput>
    end_op();
    800052ae:	fffff097          	auipc	ra,0xfffff
    800052b2:	4c6080e7          	jalr	1222(ra) # 80004774 <end_op>
  }
  return -1;
    800052b6:	557d                	li	a0,-1
}
    800052b8:	20813083          	ld	ra,520(sp)
    800052bc:	20013403          	ld	s0,512(sp)
    800052c0:	74fe                	ld	s1,504(sp)
    800052c2:	795e                	ld	s2,496(sp)
    800052c4:	79be                	ld	s3,488(sp)
    800052c6:	7a1e                	ld	s4,480(sp)
    800052c8:	6afe                	ld	s5,472(sp)
    800052ca:	6b5e                	ld	s6,464(sp)
    800052cc:	6bbe                	ld	s7,456(sp)
    800052ce:	6c1e                	ld	s8,448(sp)
    800052d0:	7cfa                	ld	s9,440(sp)
    800052d2:	7d5a                	ld	s10,432(sp)
    800052d4:	7dba                	ld	s11,424(sp)
    800052d6:	21010113          	addi	sp,sp,528
    800052da:	8082                	ret
    end_op();
    800052dc:	fffff097          	auipc	ra,0xfffff
    800052e0:	498080e7          	jalr	1176(ra) # 80004774 <end_op>
    return -1;
    800052e4:	557d                	li	a0,-1
    800052e6:	bfc9                	j	800052b8 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    800052e8:	854a                	mv	a0,s2
    800052ea:	ffffc097          	auipc	ra,0xffffc
    800052ee:	7da080e7          	jalr	2010(ra) # 80001ac4 <proc_pagetable>
    800052f2:	8baa                	mv	s7,a0
    800052f4:	d945                	beqz	a0,800052a4 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052f6:	e7042983          	lw	s3,-400(s0)
    800052fa:	e8845783          	lhu	a5,-376(s0)
    800052fe:	c7ad                	beqz	a5,80005368 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005300:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005302:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80005304:	6c85                	lui	s9,0x1
    80005306:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000530a:	def43823          	sd	a5,-528(s0)
    8000530e:	a42d                	j	80005538 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005310:	00003517          	auipc	a0,0x3
    80005314:	4a050513          	addi	a0,a0,1184 # 800087b0 <syscalls+0x2b8>
    80005318:	ffffb097          	auipc	ra,0xffffb
    8000531c:	226080e7          	jalr	550(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005320:	8756                	mv	a4,s5
    80005322:	012d86bb          	addw	a3,s11,s2
    80005326:	4581                	li	a1,0
    80005328:	8526                	mv	a0,s1
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	cac080e7          	jalr	-852(ra) # 80003fd6 <readi>
    80005332:	2501                	sext.w	a0,a0
    80005334:	1aaa9963          	bne	s5,a0,800054e6 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80005338:	6785                	lui	a5,0x1
    8000533a:	0127893b          	addw	s2,a5,s2
    8000533e:	77fd                	lui	a5,0xfffff
    80005340:	01478a3b          	addw	s4,a5,s4
    80005344:	1f897163          	bgeu	s2,s8,80005526 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80005348:	02091593          	slli	a1,s2,0x20
    8000534c:	9181                	srli	a1,a1,0x20
    8000534e:	95ea                	add	a1,a1,s10
    80005350:	855e                	mv	a0,s7
    80005352:	ffffc097          	auipc	ra,0xffffc
    80005356:	d1c080e7          	jalr	-740(ra) # 8000106e <walkaddr>
    8000535a:	862a                	mv	a2,a0
    if(pa == 0)
    8000535c:	d955                	beqz	a0,80005310 <exec+0xf0>
      n = PGSIZE;
    8000535e:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005360:	fd9a70e3          	bgeu	s4,s9,80005320 <exec+0x100>
      n = sz - i;
    80005364:	8ad2                	mv	s5,s4
    80005366:	bf6d                	j	80005320 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005368:	4901                	li	s2,0
  iunlockput(ip);
    8000536a:	8526                	mv	a0,s1
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	c18080e7          	jalr	-1000(ra) # 80003f84 <iunlockput>
  end_op();
    80005374:	fffff097          	auipc	ra,0xfffff
    80005378:	400080e7          	jalr	1024(ra) # 80004774 <end_op>
  p = myproc();
    8000537c:	ffffc097          	auipc	ra,0xffffc
    80005380:	634080e7          	jalr	1588(ra) # 800019b0 <myproc>
    80005384:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005386:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    8000538a:	6785                	lui	a5,0x1
    8000538c:	17fd                	addi	a5,a5,-1
    8000538e:	993e                	add	s2,s2,a5
    80005390:	757d                	lui	a0,0xfffff
    80005392:	00a977b3          	and	a5,s2,a0
    80005396:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000539a:	6609                	lui	a2,0x2
    8000539c:	963e                	add	a2,a2,a5
    8000539e:	85be                	mv	a1,a5
    800053a0:	855e                	mv	a0,s7
    800053a2:	ffffc097          	auipc	ra,0xffffc
    800053a6:	080080e7          	jalr	128(ra) # 80001422 <uvmalloc>
    800053aa:	8b2a                	mv	s6,a0
  ip = 0;
    800053ac:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800053ae:	12050c63          	beqz	a0,800054e6 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    800053b2:	75f9                	lui	a1,0xffffe
    800053b4:	95aa                	add	a1,a1,a0
    800053b6:	855e                	mv	a0,s7
    800053b8:	ffffc097          	auipc	ra,0xffffc
    800053bc:	288080e7          	jalr	648(ra) # 80001640 <uvmclear>
  stackbase = sp - PGSIZE;
    800053c0:	7c7d                	lui	s8,0xfffff
    800053c2:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800053c4:	e0043783          	ld	a5,-512(s0)
    800053c8:	6388                	ld	a0,0(a5)
    800053ca:	c535                	beqz	a0,80005436 <exec+0x216>
    800053cc:	e9040993          	addi	s3,s0,-368
    800053d0:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800053d4:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800053d6:	ffffc097          	auipc	ra,0xffffc
    800053da:	a8e080e7          	jalr	-1394(ra) # 80000e64 <strlen>
    800053de:	2505                	addiw	a0,a0,1
    800053e0:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800053e4:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800053e8:	13896363          	bltu	s2,s8,8000550e <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800053ec:	e0043d83          	ld	s11,-512(s0)
    800053f0:	000dba03          	ld	s4,0(s11)
    800053f4:	8552                	mv	a0,s4
    800053f6:	ffffc097          	auipc	ra,0xffffc
    800053fa:	a6e080e7          	jalr	-1426(ra) # 80000e64 <strlen>
    800053fe:	0015069b          	addiw	a3,a0,1
    80005402:	8652                	mv	a2,s4
    80005404:	85ca                	mv	a1,s2
    80005406:	855e                	mv	a0,s7
    80005408:	ffffc097          	auipc	ra,0xffffc
    8000540c:	26a080e7          	jalr	618(ra) # 80001672 <copyout>
    80005410:	10054363          	bltz	a0,80005516 <exec+0x2f6>
    ustack[argc] = sp;
    80005414:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005418:	0485                	addi	s1,s1,1
    8000541a:	008d8793          	addi	a5,s11,8
    8000541e:	e0f43023          	sd	a5,-512(s0)
    80005422:	008db503          	ld	a0,8(s11)
    80005426:	c911                	beqz	a0,8000543a <exec+0x21a>
    if(argc >= MAXARG)
    80005428:	09a1                	addi	s3,s3,8
    8000542a:	fb3c96e3          	bne	s9,s3,800053d6 <exec+0x1b6>
  sz = sz1;
    8000542e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005432:	4481                	li	s1,0
    80005434:	a84d                	j	800054e6 <exec+0x2c6>
  sp = sz;
    80005436:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005438:	4481                	li	s1,0
  ustack[argc] = 0;
    8000543a:	00349793          	slli	a5,s1,0x3
    8000543e:	f9040713          	addi	a4,s0,-112
    80005442:	97ba                	add	a5,a5,a4
    80005444:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    80005448:	00148693          	addi	a3,s1,1
    8000544c:	068e                	slli	a3,a3,0x3
    8000544e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005452:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005456:	01897663          	bgeu	s2,s8,80005462 <exec+0x242>
  sz = sz1;
    8000545a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000545e:	4481                	li	s1,0
    80005460:	a059                	j	800054e6 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005462:	e9040613          	addi	a2,s0,-368
    80005466:	85ca                	mv	a1,s2
    80005468:	855e                	mv	a0,s7
    8000546a:	ffffc097          	auipc	ra,0xffffc
    8000546e:	208080e7          	jalr	520(ra) # 80001672 <copyout>
    80005472:	0a054663          	bltz	a0,8000551e <exec+0x2fe>
  p->trapframe->a1 = sp;
    80005476:	060ab783          	ld	a5,96(s5)
    8000547a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000547e:	df843783          	ld	a5,-520(s0)
    80005482:	0007c703          	lbu	a4,0(a5)
    80005486:	cf11                	beqz	a4,800054a2 <exec+0x282>
    80005488:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000548a:	02f00693          	li	a3,47
    8000548e:	a039                	j	8000549c <exec+0x27c>
      last = s+1;
    80005490:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005494:	0785                	addi	a5,a5,1
    80005496:	fff7c703          	lbu	a4,-1(a5)
    8000549a:	c701                	beqz	a4,800054a2 <exec+0x282>
    if(*s == '/')
    8000549c:	fed71ce3          	bne	a4,a3,80005494 <exec+0x274>
    800054a0:	bfc5                	j	80005490 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    800054a2:	4641                	li	a2,16
    800054a4:	df843583          	ld	a1,-520(s0)
    800054a8:	160a8513          	addi	a0,s5,352
    800054ac:	ffffc097          	auipc	ra,0xffffc
    800054b0:	986080e7          	jalr	-1658(ra) # 80000e32 <safestrcpy>
  oldpagetable = p->pagetable;
    800054b4:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800054b8:	057abc23          	sd	s7,88(s5)
  p->sz = sz;
    800054bc:	056ab823          	sd	s6,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800054c0:	060ab783          	ld	a5,96(s5)
    800054c4:	e6843703          	ld	a4,-408(s0)
    800054c8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800054ca:	060ab783          	ld	a5,96(s5)
    800054ce:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800054d2:	85ea                	mv	a1,s10
    800054d4:	ffffc097          	auipc	ra,0xffffc
    800054d8:	68c080e7          	jalr	1676(ra) # 80001b60 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800054dc:	0004851b          	sext.w	a0,s1
    800054e0:	bbe1                	j	800052b8 <exec+0x98>
    800054e2:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800054e6:	e0843583          	ld	a1,-504(s0)
    800054ea:	855e                	mv	a0,s7
    800054ec:	ffffc097          	auipc	ra,0xffffc
    800054f0:	674080e7          	jalr	1652(ra) # 80001b60 <proc_freepagetable>
  if(ip){
    800054f4:	da0498e3          	bnez	s1,800052a4 <exec+0x84>
  return -1;
    800054f8:	557d                	li	a0,-1
    800054fa:	bb7d                	j	800052b8 <exec+0x98>
    800054fc:	e1243423          	sd	s2,-504(s0)
    80005500:	b7dd                	j	800054e6 <exec+0x2c6>
    80005502:	e1243423          	sd	s2,-504(s0)
    80005506:	b7c5                	j	800054e6 <exec+0x2c6>
    80005508:	e1243423          	sd	s2,-504(s0)
    8000550c:	bfe9                	j	800054e6 <exec+0x2c6>
  sz = sz1;
    8000550e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005512:	4481                	li	s1,0
    80005514:	bfc9                	j	800054e6 <exec+0x2c6>
  sz = sz1;
    80005516:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000551a:	4481                	li	s1,0
    8000551c:	b7e9                	j	800054e6 <exec+0x2c6>
  sz = sz1;
    8000551e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005522:	4481                	li	s1,0
    80005524:	b7c9                	j	800054e6 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005526:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000552a:	2b05                	addiw	s6,s6,1
    8000552c:	0389899b          	addiw	s3,s3,56
    80005530:	e8845783          	lhu	a5,-376(s0)
    80005534:	e2fb5be3          	bge	s6,a5,8000536a <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005538:	2981                	sext.w	s3,s3
    8000553a:	03800713          	li	a4,56
    8000553e:	86ce                	mv	a3,s3
    80005540:	e1840613          	addi	a2,s0,-488
    80005544:	4581                	li	a1,0
    80005546:	8526                	mv	a0,s1
    80005548:	fffff097          	auipc	ra,0xfffff
    8000554c:	a8e080e7          	jalr	-1394(ra) # 80003fd6 <readi>
    80005550:	03800793          	li	a5,56
    80005554:	f8f517e3          	bne	a0,a5,800054e2 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80005558:	e1842783          	lw	a5,-488(s0)
    8000555c:	4705                	li	a4,1
    8000555e:	fce796e3          	bne	a5,a4,8000552a <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005562:	e4043603          	ld	a2,-448(s0)
    80005566:	e3843783          	ld	a5,-456(s0)
    8000556a:	f8f669e3          	bltu	a2,a5,800054fc <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000556e:	e2843783          	ld	a5,-472(s0)
    80005572:	963e                	add	a2,a2,a5
    80005574:	f8f667e3          	bltu	a2,a5,80005502 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005578:	85ca                	mv	a1,s2
    8000557a:	855e                	mv	a0,s7
    8000557c:	ffffc097          	auipc	ra,0xffffc
    80005580:	ea6080e7          	jalr	-346(ra) # 80001422 <uvmalloc>
    80005584:	e0a43423          	sd	a0,-504(s0)
    80005588:	d141                	beqz	a0,80005508 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    8000558a:	e2843d03          	ld	s10,-472(s0)
    8000558e:	df043783          	ld	a5,-528(s0)
    80005592:	00fd77b3          	and	a5,s10,a5
    80005596:	fba1                	bnez	a5,800054e6 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005598:	e2042d83          	lw	s11,-480(s0)
    8000559c:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800055a0:	f80c03e3          	beqz	s8,80005526 <exec+0x306>
    800055a4:	8a62                	mv	s4,s8
    800055a6:	4901                	li	s2,0
    800055a8:	b345                	j	80005348 <exec+0x128>

00000000800055aa <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800055aa:	7179                	addi	sp,sp,-48
    800055ac:	f406                	sd	ra,40(sp)
    800055ae:	f022                	sd	s0,32(sp)
    800055b0:	ec26                	sd	s1,24(sp)
    800055b2:	e84a                	sd	s2,16(sp)
    800055b4:	1800                	addi	s0,sp,48
    800055b6:	892e                	mv	s2,a1
    800055b8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800055ba:	fdc40593          	addi	a1,s0,-36
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	a78080e7          	jalr	-1416(ra) # 80003036 <argint>
    800055c6:	04054063          	bltz	a0,80005606 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800055ca:	fdc42703          	lw	a4,-36(s0)
    800055ce:	47bd                	li	a5,15
    800055d0:	02e7ed63          	bltu	a5,a4,8000560a <argfd+0x60>
    800055d4:	ffffc097          	auipc	ra,0xffffc
    800055d8:	3dc080e7          	jalr	988(ra) # 800019b0 <myproc>
    800055dc:	fdc42703          	lw	a4,-36(s0)
    800055e0:	01a70793          	addi	a5,a4,26
    800055e4:	078e                	slli	a5,a5,0x3
    800055e6:	953e                	add	a0,a0,a5
    800055e8:	651c                	ld	a5,8(a0)
    800055ea:	c395                	beqz	a5,8000560e <argfd+0x64>
    return -1;
  if(pfd)
    800055ec:	00090463          	beqz	s2,800055f4 <argfd+0x4a>
    *pfd = fd;
    800055f0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800055f4:	4501                	li	a0,0
  if(pf)
    800055f6:	c091                	beqz	s1,800055fa <argfd+0x50>
    *pf = f;
    800055f8:	e09c                	sd	a5,0(s1)
}
    800055fa:	70a2                	ld	ra,40(sp)
    800055fc:	7402                	ld	s0,32(sp)
    800055fe:	64e2                	ld	s1,24(sp)
    80005600:	6942                	ld	s2,16(sp)
    80005602:	6145                	addi	sp,sp,48
    80005604:	8082                	ret
    return -1;
    80005606:	557d                	li	a0,-1
    80005608:	bfcd                	j	800055fa <argfd+0x50>
    return -1;
    8000560a:	557d                	li	a0,-1
    8000560c:	b7fd                	j	800055fa <argfd+0x50>
    8000560e:	557d                	li	a0,-1
    80005610:	b7ed                	j	800055fa <argfd+0x50>

0000000080005612 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005612:	1101                	addi	sp,sp,-32
    80005614:	ec06                	sd	ra,24(sp)
    80005616:	e822                	sd	s0,16(sp)
    80005618:	e426                	sd	s1,8(sp)
    8000561a:	1000                	addi	s0,sp,32
    8000561c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000561e:	ffffc097          	auipc	ra,0xffffc
    80005622:	392080e7          	jalr	914(ra) # 800019b0 <myproc>
    80005626:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005628:	0d850793          	addi	a5,a0,216 # fffffffffffff0d8 <end+0xffffffff7ffd90d8>
    8000562c:	4501                	li	a0,0
    8000562e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005630:	6398                	ld	a4,0(a5)
    80005632:	cb19                	beqz	a4,80005648 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005634:	2505                	addiw	a0,a0,1
    80005636:	07a1                	addi	a5,a5,8
    80005638:	fed51ce3          	bne	a0,a3,80005630 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000563c:	557d                	li	a0,-1
}
    8000563e:	60e2                	ld	ra,24(sp)
    80005640:	6442                	ld	s0,16(sp)
    80005642:	64a2                	ld	s1,8(sp)
    80005644:	6105                	addi	sp,sp,32
    80005646:	8082                	ret
      p->ofile[fd] = f;
    80005648:	01a50793          	addi	a5,a0,26
    8000564c:	078e                	slli	a5,a5,0x3
    8000564e:	963e                	add	a2,a2,a5
    80005650:	e604                	sd	s1,8(a2)
      return fd;
    80005652:	b7f5                	j	8000563e <fdalloc+0x2c>

0000000080005654 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005654:	715d                	addi	sp,sp,-80
    80005656:	e486                	sd	ra,72(sp)
    80005658:	e0a2                	sd	s0,64(sp)
    8000565a:	fc26                	sd	s1,56(sp)
    8000565c:	f84a                	sd	s2,48(sp)
    8000565e:	f44e                	sd	s3,40(sp)
    80005660:	f052                	sd	s4,32(sp)
    80005662:	ec56                	sd	s5,24(sp)
    80005664:	0880                	addi	s0,sp,80
    80005666:	89ae                	mv	s3,a1
    80005668:	8ab2                	mv	s5,a2
    8000566a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000566c:	fb040593          	addi	a1,s0,-80
    80005670:	fffff097          	auipc	ra,0xfffff
    80005674:	e86080e7          	jalr	-378(ra) # 800044f6 <nameiparent>
    80005678:	892a                	mv	s2,a0
    8000567a:	12050f63          	beqz	a0,800057b8 <create+0x164>
    return 0;

  ilock(dp);
    8000567e:	ffffe097          	auipc	ra,0xffffe
    80005682:	6a4080e7          	jalr	1700(ra) # 80003d22 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005686:	4601                	li	a2,0
    80005688:	fb040593          	addi	a1,s0,-80
    8000568c:	854a                	mv	a0,s2
    8000568e:	fffff097          	auipc	ra,0xfffff
    80005692:	b78080e7          	jalr	-1160(ra) # 80004206 <dirlookup>
    80005696:	84aa                	mv	s1,a0
    80005698:	c921                	beqz	a0,800056e8 <create+0x94>
    iunlockput(dp);
    8000569a:	854a                	mv	a0,s2
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	8e8080e7          	jalr	-1816(ra) # 80003f84 <iunlockput>
    ilock(ip);
    800056a4:	8526                	mv	a0,s1
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	67c080e7          	jalr	1660(ra) # 80003d22 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800056ae:	2981                	sext.w	s3,s3
    800056b0:	4789                	li	a5,2
    800056b2:	02f99463          	bne	s3,a5,800056da <create+0x86>
    800056b6:	0444d783          	lhu	a5,68(s1)
    800056ba:	37f9                	addiw	a5,a5,-2
    800056bc:	17c2                	slli	a5,a5,0x30
    800056be:	93c1                	srli	a5,a5,0x30
    800056c0:	4705                	li	a4,1
    800056c2:	00f76c63          	bltu	a4,a5,800056da <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800056c6:	8526                	mv	a0,s1
    800056c8:	60a6                	ld	ra,72(sp)
    800056ca:	6406                	ld	s0,64(sp)
    800056cc:	74e2                	ld	s1,56(sp)
    800056ce:	7942                	ld	s2,48(sp)
    800056d0:	79a2                	ld	s3,40(sp)
    800056d2:	7a02                	ld	s4,32(sp)
    800056d4:	6ae2                	ld	s5,24(sp)
    800056d6:	6161                	addi	sp,sp,80
    800056d8:	8082                	ret
    iunlockput(ip);
    800056da:	8526                	mv	a0,s1
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	8a8080e7          	jalr	-1880(ra) # 80003f84 <iunlockput>
    return 0;
    800056e4:	4481                	li	s1,0
    800056e6:	b7c5                	j	800056c6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800056e8:	85ce                	mv	a1,s3
    800056ea:	00092503          	lw	a0,0(s2)
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	49c080e7          	jalr	1180(ra) # 80003b8a <ialloc>
    800056f6:	84aa                	mv	s1,a0
    800056f8:	c529                	beqz	a0,80005742 <create+0xee>
  ilock(ip);
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	628080e7          	jalr	1576(ra) # 80003d22 <ilock>
  ip->major = major;
    80005702:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005706:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000570a:	4785                	li	a5,1
    8000570c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005710:	8526                	mv	a0,s1
    80005712:	ffffe097          	auipc	ra,0xffffe
    80005716:	546080e7          	jalr	1350(ra) # 80003c58 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000571a:	2981                	sext.w	s3,s3
    8000571c:	4785                	li	a5,1
    8000571e:	02f98a63          	beq	s3,a5,80005752 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80005722:	40d0                	lw	a2,4(s1)
    80005724:	fb040593          	addi	a1,s0,-80
    80005728:	854a                	mv	a0,s2
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	cec080e7          	jalr	-788(ra) # 80004416 <dirlink>
    80005732:	06054b63          	bltz	a0,800057a8 <create+0x154>
  iunlockput(dp);
    80005736:	854a                	mv	a0,s2
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	84c080e7          	jalr	-1972(ra) # 80003f84 <iunlockput>
  return ip;
    80005740:	b759                	j	800056c6 <create+0x72>
    panic("create: ialloc");
    80005742:	00003517          	auipc	a0,0x3
    80005746:	08e50513          	addi	a0,a0,142 # 800087d0 <syscalls+0x2d8>
    8000574a:	ffffb097          	auipc	ra,0xffffb
    8000574e:	df4080e7          	jalr	-524(ra) # 8000053e <panic>
    dp->nlink++;  // for ".."
    80005752:	04a95783          	lhu	a5,74(s2)
    80005756:	2785                	addiw	a5,a5,1
    80005758:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000575c:	854a                	mv	a0,s2
    8000575e:	ffffe097          	auipc	ra,0xffffe
    80005762:	4fa080e7          	jalr	1274(ra) # 80003c58 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005766:	40d0                	lw	a2,4(s1)
    80005768:	00003597          	auipc	a1,0x3
    8000576c:	07858593          	addi	a1,a1,120 # 800087e0 <syscalls+0x2e8>
    80005770:	8526                	mv	a0,s1
    80005772:	fffff097          	auipc	ra,0xfffff
    80005776:	ca4080e7          	jalr	-860(ra) # 80004416 <dirlink>
    8000577a:	00054f63          	bltz	a0,80005798 <create+0x144>
    8000577e:	00492603          	lw	a2,4(s2)
    80005782:	00003597          	auipc	a1,0x3
    80005786:	06658593          	addi	a1,a1,102 # 800087e8 <syscalls+0x2f0>
    8000578a:	8526                	mv	a0,s1
    8000578c:	fffff097          	auipc	ra,0xfffff
    80005790:	c8a080e7          	jalr	-886(ra) # 80004416 <dirlink>
    80005794:	f80557e3          	bgez	a0,80005722 <create+0xce>
      panic("create dots");
    80005798:	00003517          	auipc	a0,0x3
    8000579c:	05850513          	addi	a0,a0,88 # 800087f0 <syscalls+0x2f8>
    800057a0:	ffffb097          	auipc	ra,0xffffb
    800057a4:	d9e080e7          	jalr	-610(ra) # 8000053e <panic>
    panic("create: dirlink");
    800057a8:	00003517          	auipc	a0,0x3
    800057ac:	05850513          	addi	a0,a0,88 # 80008800 <syscalls+0x308>
    800057b0:	ffffb097          	auipc	ra,0xffffb
    800057b4:	d8e080e7          	jalr	-626(ra) # 8000053e <panic>
    return 0;
    800057b8:	84aa                	mv	s1,a0
    800057ba:	b731                	j	800056c6 <create+0x72>

00000000800057bc <sys_dup>:
{
    800057bc:	7179                	addi	sp,sp,-48
    800057be:	f406                	sd	ra,40(sp)
    800057c0:	f022                	sd	s0,32(sp)
    800057c2:	ec26                	sd	s1,24(sp)
    800057c4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800057c6:	fd840613          	addi	a2,s0,-40
    800057ca:	4581                	li	a1,0
    800057cc:	4501                	li	a0,0
    800057ce:	00000097          	auipc	ra,0x0
    800057d2:	ddc080e7          	jalr	-548(ra) # 800055aa <argfd>
    return -1;
    800057d6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800057d8:	02054363          	bltz	a0,800057fe <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800057dc:	fd843503          	ld	a0,-40(s0)
    800057e0:	00000097          	auipc	ra,0x0
    800057e4:	e32080e7          	jalr	-462(ra) # 80005612 <fdalloc>
    800057e8:	84aa                	mv	s1,a0
    return -1;
    800057ea:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800057ec:	00054963          	bltz	a0,800057fe <sys_dup+0x42>
  filedup(f);
    800057f0:	fd843503          	ld	a0,-40(s0)
    800057f4:	fffff097          	auipc	ra,0xfffff
    800057f8:	37a080e7          	jalr	890(ra) # 80004b6e <filedup>
  return fd;
    800057fc:	87a6                	mv	a5,s1
}
    800057fe:	853e                	mv	a0,a5
    80005800:	70a2                	ld	ra,40(sp)
    80005802:	7402                	ld	s0,32(sp)
    80005804:	64e2                	ld	s1,24(sp)
    80005806:	6145                	addi	sp,sp,48
    80005808:	8082                	ret

000000008000580a <sys_read>:
{
    8000580a:	7179                	addi	sp,sp,-48
    8000580c:	f406                	sd	ra,40(sp)
    8000580e:	f022                	sd	s0,32(sp)
    80005810:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005812:	fe840613          	addi	a2,s0,-24
    80005816:	4581                	li	a1,0
    80005818:	4501                	li	a0,0
    8000581a:	00000097          	auipc	ra,0x0
    8000581e:	d90080e7          	jalr	-624(ra) # 800055aa <argfd>
    return -1;
    80005822:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005824:	04054163          	bltz	a0,80005866 <sys_read+0x5c>
    80005828:	fe440593          	addi	a1,s0,-28
    8000582c:	4509                	li	a0,2
    8000582e:	ffffe097          	auipc	ra,0xffffe
    80005832:	808080e7          	jalr	-2040(ra) # 80003036 <argint>
    return -1;
    80005836:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005838:	02054763          	bltz	a0,80005866 <sys_read+0x5c>
    8000583c:	fd840593          	addi	a1,s0,-40
    80005840:	4505                	li	a0,1
    80005842:	ffffe097          	auipc	ra,0xffffe
    80005846:	816080e7          	jalr	-2026(ra) # 80003058 <argaddr>
    return -1;
    8000584a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000584c:	00054d63          	bltz	a0,80005866 <sys_read+0x5c>
  return fileread(f, p, n);
    80005850:	fe442603          	lw	a2,-28(s0)
    80005854:	fd843583          	ld	a1,-40(s0)
    80005858:	fe843503          	ld	a0,-24(s0)
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	49e080e7          	jalr	1182(ra) # 80004cfa <fileread>
    80005864:	87aa                	mv	a5,a0
}
    80005866:	853e                	mv	a0,a5
    80005868:	70a2                	ld	ra,40(sp)
    8000586a:	7402                	ld	s0,32(sp)
    8000586c:	6145                	addi	sp,sp,48
    8000586e:	8082                	ret

0000000080005870 <sys_write>:
{
    80005870:	7179                	addi	sp,sp,-48
    80005872:	f406                	sd	ra,40(sp)
    80005874:	f022                	sd	s0,32(sp)
    80005876:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005878:	fe840613          	addi	a2,s0,-24
    8000587c:	4581                	li	a1,0
    8000587e:	4501                	li	a0,0
    80005880:	00000097          	auipc	ra,0x0
    80005884:	d2a080e7          	jalr	-726(ra) # 800055aa <argfd>
    return -1;
    80005888:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000588a:	04054163          	bltz	a0,800058cc <sys_write+0x5c>
    8000588e:	fe440593          	addi	a1,s0,-28
    80005892:	4509                	li	a0,2
    80005894:	ffffd097          	auipc	ra,0xffffd
    80005898:	7a2080e7          	jalr	1954(ra) # 80003036 <argint>
    return -1;
    8000589c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000589e:	02054763          	bltz	a0,800058cc <sys_write+0x5c>
    800058a2:	fd840593          	addi	a1,s0,-40
    800058a6:	4505                	li	a0,1
    800058a8:	ffffd097          	auipc	ra,0xffffd
    800058ac:	7b0080e7          	jalr	1968(ra) # 80003058 <argaddr>
    return -1;
    800058b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800058b2:	00054d63          	bltz	a0,800058cc <sys_write+0x5c>
  return filewrite(f, p, n);
    800058b6:	fe442603          	lw	a2,-28(s0)
    800058ba:	fd843583          	ld	a1,-40(s0)
    800058be:	fe843503          	ld	a0,-24(s0)
    800058c2:	fffff097          	auipc	ra,0xfffff
    800058c6:	4fa080e7          	jalr	1274(ra) # 80004dbc <filewrite>
    800058ca:	87aa                	mv	a5,a0
}
    800058cc:	853e                	mv	a0,a5
    800058ce:	70a2                	ld	ra,40(sp)
    800058d0:	7402                	ld	s0,32(sp)
    800058d2:	6145                	addi	sp,sp,48
    800058d4:	8082                	ret

00000000800058d6 <sys_close>:
{
    800058d6:	1101                	addi	sp,sp,-32
    800058d8:	ec06                	sd	ra,24(sp)
    800058da:	e822                	sd	s0,16(sp)
    800058dc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800058de:	fe040613          	addi	a2,s0,-32
    800058e2:	fec40593          	addi	a1,s0,-20
    800058e6:	4501                	li	a0,0
    800058e8:	00000097          	auipc	ra,0x0
    800058ec:	cc2080e7          	jalr	-830(ra) # 800055aa <argfd>
    return -1;
    800058f0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800058f2:	02054463          	bltz	a0,8000591a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800058f6:	ffffc097          	auipc	ra,0xffffc
    800058fa:	0ba080e7          	jalr	186(ra) # 800019b0 <myproc>
    800058fe:	fec42783          	lw	a5,-20(s0)
    80005902:	07e9                	addi	a5,a5,26
    80005904:	078e                	slli	a5,a5,0x3
    80005906:	97aa                	add	a5,a5,a0
    80005908:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000590c:	fe043503          	ld	a0,-32(s0)
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	2b0080e7          	jalr	688(ra) # 80004bc0 <fileclose>
  return 0;
    80005918:	4781                	li	a5,0
}
    8000591a:	853e                	mv	a0,a5
    8000591c:	60e2                	ld	ra,24(sp)
    8000591e:	6442                	ld	s0,16(sp)
    80005920:	6105                	addi	sp,sp,32
    80005922:	8082                	ret

0000000080005924 <sys_fstat>:
{
    80005924:	1101                	addi	sp,sp,-32
    80005926:	ec06                	sd	ra,24(sp)
    80005928:	e822                	sd	s0,16(sp)
    8000592a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000592c:	fe840613          	addi	a2,s0,-24
    80005930:	4581                	li	a1,0
    80005932:	4501                	li	a0,0
    80005934:	00000097          	auipc	ra,0x0
    80005938:	c76080e7          	jalr	-906(ra) # 800055aa <argfd>
    return -1;
    8000593c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000593e:	02054563          	bltz	a0,80005968 <sys_fstat+0x44>
    80005942:	fe040593          	addi	a1,s0,-32
    80005946:	4505                	li	a0,1
    80005948:	ffffd097          	auipc	ra,0xffffd
    8000594c:	710080e7          	jalr	1808(ra) # 80003058 <argaddr>
    return -1;
    80005950:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005952:	00054b63          	bltz	a0,80005968 <sys_fstat+0x44>
  return filestat(f, st);
    80005956:	fe043583          	ld	a1,-32(s0)
    8000595a:	fe843503          	ld	a0,-24(s0)
    8000595e:	fffff097          	auipc	ra,0xfffff
    80005962:	32a080e7          	jalr	810(ra) # 80004c88 <filestat>
    80005966:	87aa                	mv	a5,a0
}
    80005968:	853e                	mv	a0,a5
    8000596a:	60e2                	ld	ra,24(sp)
    8000596c:	6442                	ld	s0,16(sp)
    8000596e:	6105                	addi	sp,sp,32
    80005970:	8082                	ret

0000000080005972 <sys_link>:
{
    80005972:	7169                	addi	sp,sp,-304
    80005974:	f606                	sd	ra,296(sp)
    80005976:	f222                	sd	s0,288(sp)
    80005978:	ee26                	sd	s1,280(sp)
    8000597a:	ea4a                	sd	s2,272(sp)
    8000597c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000597e:	08000613          	li	a2,128
    80005982:	ed040593          	addi	a1,s0,-304
    80005986:	4501                	li	a0,0
    80005988:	ffffd097          	auipc	ra,0xffffd
    8000598c:	6f2080e7          	jalr	1778(ra) # 8000307a <argstr>
    return -1;
    80005990:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005992:	10054e63          	bltz	a0,80005aae <sys_link+0x13c>
    80005996:	08000613          	li	a2,128
    8000599a:	f5040593          	addi	a1,s0,-176
    8000599e:	4505                	li	a0,1
    800059a0:	ffffd097          	auipc	ra,0xffffd
    800059a4:	6da080e7          	jalr	1754(ra) # 8000307a <argstr>
    return -1;
    800059a8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800059aa:	10054263          	bltz	a0,80005aae <sys_link+0x13c>
  begin_op();
    800059ae:	fffff097          	auipc	ra,0xfffff
    800059b2:	d46080e7          	jalr	-698(ra) # 800046f4 <begin_op>
  if((ip = namei(old)) == 0){
    800059b6:	ed040513          	addi	a0,s0,-304
    800059ba:	fffff097          	auipc	ra,0xfffff
    800059be:	b1e080e7          	jalr	-1250(ra) # 800044d8 <namei>
    800059c2:	84aa                	mv	s1,a0
    800059c4:	c551                	beqz	a0,80005a50 <sys_link+0xde>
  ilock(ip);
    800059c6:	ffffe097          	auipc	ra,0xffffe
    800059ca:	35c080e7          	jalr	860(ra) # 80003d22 <ilock>
  if(ip->type == T_DIR){
    800059ce:	04449703          	lh	a4,68(s1)
    800059d2:	4785                	li	a5,1
    800059d4:	08f70463          	beq	a4,a5,80005a5c <sys_link+0xea>
  ip->nlink++;
    800059d8:	04a4d783          	lhu	a5,74(s1)
    800059dc:	2785                	addiw	a5,a5,1
    800059de:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800059e2:	8526                	mv	a0,s1
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	274080e7          	jalr	628(ra) # 80003c58 <iupdate>
  iunlock(ip);
    800059ec:	8526                	mv	a0,s1
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	3f6080e7          	jalr	1014(ra) # 80003de4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800059f6:	fd040593          	addi	a1,s0,-48
    800059fa:	f5040513          	addi	a0,s0,-176
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	af8080e7          	jalr	-1288(ra) # 800044f6 <nameiparent>
    80005a06:	892a                	mv	s2,a0
    80005a08:	c935                	beqz	a0,80005a7c <sys_link+0x10a>
  ilock(dp);
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	318080e7          	jalr	792(ra) # 80003d22 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005a12:	00092703          	lw	a4,0(s2)
    80005a16:	409c                	lw	a5,0(s1)
    80005a18:	04f71d63          	bne	a4,a5,80005a72 <sys_link+0x100>
    80005a1c:	40d0                	lw	a2,4(s1)
    80005a1e:	fd040593          	addi	a1,s0,-48
    80005a22:	854a                	mv	a0,s2
    80005a24:	fffff097          	auipc	ra,0xfffff
    80005a28:	9f2080e7          	jalr	-1550(ra) # 80004416 <dirlink>
    80005a2c:	04054363          	bltz	a0,80005a72 <sys_link+0x100>
  iunlockput(dp);
    80005a30:	854a                	mv	a0,s2
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	552080e7          	jalr	1362(ra) # 80003f84 <iunlockput>
  iput(ip);
    80005a3a:	8526                	mv	a0,s1
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	4a0080e7          	jalr	1184(ra) # 80003edc <iput>
  end_op();
    80005a44:	fffff097          	auipc	ra,0xfffff
    80005a48:	d30080e7          	jalr	-720(ra) # 80004774 <end_op>
  return 0;
    80005a4c:	4781                	li	a5,0
    80005a4e:	a085                	j	80005aae <sys_link+0x13c>
    end_op();
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	d24080e7          	jalr	-732(ra) # 80004774 <end_op>
    return -1;
    80005a58:	57fd                	li	a5,-1
    80005a5a:	a891                	j	80005aae <sys_link+0x13c>
    iunlockput(ip);
    80005a5c:	8526                	mv	a0,s1
    80005a5e:	ffffe097          	auipc	ra,0xffffe
    80005a62:	526080e7          	jalr	1318(ra) # 80003f84 <iunlockput>
    end_op();
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	d0e080e7          	jalr	-754(ra) # 80004774 <end_op>
    return -1;
    80005a6e:	57fd                	li	a5,-1
    80005a70:	a83d                	j	80005aae <sys_link+0x13c>
    iunlockput(dp);
    80005a72:	854a                	mv	a0,s2
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	510080e7          	jalr	1296(ra) # 80003f84 <iunlockput>
  ilock(ip);
    80005a7c:	8526                	mv	a0,s1
    80005a7e:	ffffe097          	auipc	ra,0xffffe
    80005a82:	2a4080e7          	jalr	676(ra) # 80003d22 <ilock>
  ip->nlink--;
    80005a86:	04a4d783          	lhu	a5,74(s1)
    80005a8a:	37fd                	addiw	a5,a5,-1
    80005a8c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a90:	8526                	mv	a0,s1
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	1c6080e7          	jalr	454(ra) # 80003c58 <iupdate>
  iunlockput(ip);
    80005a9a:	8526                	mv	a0,s1
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	4e8080e7          	jalr	1256(ra) # 80003f84 <iunlockput>
  end_op();
    80005aa4:	fffff097          	auipc	ra,0xfffff
    80005aa8:	cd0080e7          	jalr	-816(ra) # 80004774 <end_op>
  return -1;
    80005aac:	57fd                	li	a5,-1
}
    80005aae:	853e                	mv	a0,a5
    80005ab0:	70b2                	ld	ra,296(sp)
    80005ab2:	7412                	ld	s0,288(sp)
    80005ab4:	64f2                	ld	s1,280(sp)
    80005ab6:	6952                	ld	s2,272(sp)
    80005ab8:	6155                	addi	sp,sp,304
    80005aba:	8082                	ret

0000000080005abc <sys_unlink>:
{
    80005abc:	7151                	addi	sp,sp,-240
    80005abe:	f586                	sd	ra,232(sp)
    80005ac0:	f1a2                	sd	s0,224(sp)
    80005ac2:	eda6                	sd	s1,216(sp)
    80005ac4:	e9ca                	sd	s2,208(sp)
    80005ac6:	e5ce                	sd	s3,200(sp)
    80005ac8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005aca:	08000613          	li	a2,128
    80005ace:	f3040593          	addi	a1,s0,-208
    80005ad2:	4501                	li	a0,0
    80005ad4:	ffffd097          	auipc	ra,0xffffd
    80005ad8:	5a6080e7          	jalr	1446(ra) # 8000307a <argstr>
    80005adc:	18054163          	bltz	a0,80005c5e <sys_unlink+0x1a2>
  begin_op();
    80005ae0:	fffff097          	auipc	ra,0xfffff
    80005ae4:	c14080e7          	jalr	-1004(ra) # 800046f4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005ae8:	fb040593          	addi	a1,s0,-80
    80005aec:	f3040513          	addi	a0,s0,-208
    80005af0:	fffff097          	auipc	ra,0xfffff
    80005af4:	a06080e7          	jalr	-1530(ra) # 800044f6 <nameiparent>
    80005af8:	84aa                	mv	s1,a0
    80005afa:	c979                	beqz	a0,80005bd0 <sys_unlink+0x114>
  ilock(dp);
    80005afc:	ffffe097          	auipc	ra,0xffffe
    80005b00:	226080e7          	jalr	550(ra) # 80003d22 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005b04:	00003597          	auipc	a1,0x3
    80005b08:	cdc58593          	addi	a1,a1,-804 # 800087e0 <syscalls+0x2e8>
    80005b0c:	fb040513          	addi	a0,s0,-80
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	6dc080e7          	jalr	1756(ra) # 800041ec <namecmp>
    80005b18:	14050a63          	beqz	a0,80005c6c <sys_unlink+0x1b0>
    80005b1c:	00003597          	auipc	a1,0x3
    80005b20:	ccc58593          	addi	a1,a1,-820 # 800087e8 <syscalls+0x2f0>
    80005b24:	fb040513          	addi	a0,s0,-80
    80005b28:	ffffe097          	auipc	ra,0xffffe
    80005b2c:	6c4080e7          	jalr	1732(ra) # 800041ec <namecmp>
    80005b30:	12050e63          	beqz	a0,80005c6c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005b34:	f2c40613          	addi	a2,s0,-212
    80005b38:	fb040593          	addi	a1,s0,-80
    80005b3c:	8526                	mv	a0,s1
    80005b3e:	ffffe097          	auipc	ra,0xffffe
    80005b42:	6c8080e7          	jalr	1736(ra) # 80004206 <dirlookup>
    80005b46:	892a                	mv	s2,a0
    80005b48:	12050263          	beqz	a0,80005c6c <sys_unlink+0x1b0>
  ilock(ip);
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	1d6080e7          	jalr	470(ra) # 80003d22 <ilock>
  if(ip->nlink < 1)
    80005b54:	04a91783          	lh	a5,74(s2)
    80005b58:	08f05263          	blez	a5,80005bdc <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005b5c:	04491703          	lh	a4,68(s2)
    80005b60:	4785                	li	a5,1
    80005b62:	08f70563          	beq	a4,a5,80005bec <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005b66:	4641                	li	a2,16
    80005b68:	4581                	li	a1,0
    80005b6a:	fc040513          	addi	a0,s0,-64
    80005b6e:	ffffb097          	auipc	ra,0xffffb
    80005b72:	172080e7          	jalr	370(ra) # 80000ce0 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b76:	4741                	li	a4,16
    80005b78:	f2c42683          	lw	a3,-212(s0)
    80005b7c:	fc040613          	addi	a2,s0,-64
    80005b80:	4581                	li	a1,0
    80005b82:	8526                	mv	a0,s1
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	54a080e7          	jalr	1354(ra) # 800040ce <writei>
    80005b8c:	47c1                	li	a5,16
    80005b8e:	0af51563          	bne	a0,a5,80005c38 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b92:	04491703          	lh	a4,68(s2)
    80005b96:	4785                	li	a5,1
    80005b98:	0af70863          	beq	a4,a5,80005c48 <sys_unlink+0x18c>
  iunlockput(dp);
    80005b9c:	8526                	mv	a0,s1
    80005b9e:	ffffe097          	auipc	ra,0xffffe
    80005ba2:	3e6080e7          	jalr	998(ra) # 80003f84 <iunlockput>
  ip->nlink--;
    80005ba6:	04a95783          	lhu	a5,74(s2)
    80005baa:	37fd                	addiw	a5,a5,-1
    80005bac:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005bb0:	854a                	mv	a0,s2
    80005bb2:	ffffe097          	auipc	ra,0xffffe
    80005bb6:	0a6080e7          	jalr	166(ra) # 80003c58 <iupdate>
  iunlockput(ip);
    80005bba:	854a                	mv	a0,s2
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	3c8080e7          	jalr	968(ra) # 80003f84 <iunlockput>
  end_op();
    80005bc4:	fffff097          	auipc	ra,0xfffff
    80005bc8:	bb0080e7          	jalr	-1104(ra) # 80004774 <end_op>
  return 0;
    80005bcc:	4501                	li	a0,0
    80005bce:	a84d                	j	80005c80 <sys_unlink+0x1c4>
    end_op();
    80005bd0:	fffff097          	auipc	ra,0xfffff
    80005bd4:	ba4080e7          	jalr	-1116(ra) # 80004774 <end_op>
    return -1;
    80005bd8:	557d                	li	a0,-1
    80005bda:	a05d                	j	80005c80 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005bdc:	00003517          	auipc	a0,0x3
    80005be0:	c3450513          	addi	a0,a0,-972 # 80008810 <syscalls+0x318>
    80005be4:	ffffb097          	auipc	ra,0xffffb
    80005be8:	95a080e7          	jalr	-1702(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005bec:	04c92703          	lw	a4,76(s2)
    80005bf0:	02000793          	li	a5,32
    80005bf4:	f6e7f9e3          	bgeu	a5,a4,80005b66 <sys_unlink+0xaa>
    80005bf8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005bfc:	4741                	li	a4,16
    80005bfe:	86ce                	mv	a3,s3
    80005c00:	f1840613          	addi	a2,s0,-232
    80005c04:	4581                	li	a1,0
    80005c06:	854a                	mv	a0,s2
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	3ce080e7          	jalr	974(ra) # 80003fd6 <readi>
    80005c10:	47c1                	li	a5,16
    80005c12:	00f51b63          	bne	a0,a5,80005c28 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005c16:	f1845783          	lhu	a5,-232(s0)
    80005c1a:	e7a1                	bnez	a5,80005c62 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005c1c:	29c1                	addiw	s3,s3,16
    80005c1e:	04c92783          	lw	a5,76(s2)
    80005c22:	fcf9ede3          	bltu	s3,a5,80005bfc <sys_unlink+0x140>
    80005c26:	b781                	j	80005b66 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005c28:	00003517          	auipc	a0,0x3
    80005c2c:	c0050513          	addi	a0,a0,-1024 # 80008828 <syscalls+0x330>
    80005c30:	ffffb097          	auipc	ra,0xffffb
    80005c34:	90e080e7          	jalr	-1778(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005c38:	00003517          	auipc	a0,0x3
    80005c3c:	c0850513          	addi	a0,a0,-1016 # 80008840 <syscalls+0x348>
    80005c40:	ffffb097          	auipc	ra,0xffffb
    80005c44:	8fe080e7          	jalr	-1794(ra) # 8000053e <panic>
    dp->nlink--;
    80005c48:	04a4d783          	lhu	a5,74(s1)
    80005c4c:	37fd                	addiw	a5,a5,-1
    80005c4e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005c52:	8526                	mv	a0,s1
    80005c54:	ffffe097          	auipc	ra,0xffffe
    80005c58:	004080e7          	jalr	4(ra) # 80003c58 <iupdate>
    80005c5c:	b781                	j	80005b9c <sys_unlink+0xe0>
    return -1;
    80005c5e:	557d                	li	a0,-1
    80005c60:	a005                	j	80005c80 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005c62:	854a                	mv	a0,s2
    80005c64:	ffffe097          	auipc	ra,0xffffe
    80005c68:	320080e7          	jalr	800(ra) # 80003f84 <iunlockput>
  iunlockput(dp);
    80005c6c:	8526                	mv	a0,s1
    80005c6e:	ffffe097          	auipc	ra,0xffffe
    80005c72:	316080e7          	jalr	790(ra) # 80003f84 <iunlockput>
  end_op();
    80005c76:	fffff097          	auipc	ra,0xfffff
    80005c7a:	afe080e7          	jalr	-1282(ra) # 80004774 <end_op>
  return -1;
    80005c7e:	557d                	li	a0,-1
}
    80005c80:	70ae                	ld	ra,232(sp)
    80005c82:	740e                	ld	s0,224(sp)
    80005c84:	64ee                	ld	s1,216(sp)
    80005c86:	694e                	ld	s2,208(sp)
    80005c88:	69ae                	ld	s3,200(sp)
    80005c8a:	616d                	addi	sp,sp,240
    80005c8c:	8082                	ret

0000000080005c8e <sys_open>:

uint64
sys_open(void)
{
    80005c8e:	7131                	addi	sp,sp,-192
    80005c90:	fd06                	sd	ra,184(sp)
    80005c92:	f922                	sd	s0,176(sp)
    80005c94:	f526                	sd	s1,168(sp)
    80005c96:	f14a                	sd	s2,160(sp)
    80005c98:	ed4e                	sd	s3,152(sp)
    80005c9a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c9c:	08000613          	li	a2,128
    80005ca0:	f5040593          	addi	a1,s0,-176
    80005ca4:	4501                	li	a0,0
    80005ca6:	ffffd097          	auipc	ra,0xffffd
    80005caa:	3d4080e7          	jalr	980(ra) # 8000307a <argstr>
    return -1;
    80005cae:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005cb0:	0c054163          	bltz	a0,80005d72 <sys_open+0xe4>
    80005cb4:	f4c40593          	addi	a1,s0,-180
    80005cb8:	4505                	li	a0,1
    80005cba:	ffffd097          	auipc	ra,0xffffd
    80005cbe:	37c080e7          	jalr	892(ra) # 80003036 <argint>
    80005cc2:	0a054863          	bltz	a0,80005d72 <sys_open+0xe4>

  begin_op();
    80005cc6:	fffff097          	auipc	ra,0xfffff
    80005cca:	a2e080e7          	jalr	-1490(ra) # 800046f4 <begin_op>

  if(omode & O_CREATE){
    80005cce:	f4c42783          	lw	a5,-180(s0)
    80005cd2:	2007f793          	andi	a5,a5,512
    80005cd6:	cbdd                	beqz	a5,80005d8c <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005cd8:	4681                	li	a3,0
    80005cda:	4601                	li	a2,0
    80005cdc:	4589                	li	a1,2
    80005cde:	f5040513          	addi	a0,s0,-176
    80005ce2:	00000097          	auipc	ra,0x0
    80005ce6:	972080e7          	jalr	-1678(ra) # 80005654 <create>
    80005cea:	892a                	mv	s2,a0
    if(ip == 0){
    80005cec:	c959                	beqz	a0,80005d82 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005cee:	04491703          	lh	a4,68(s2)
    80005cf2:	478d                	li	a5,3
    80005cf4:	00f71763          	bne	a4,a5,80005d02 <sys_open+0x74>
    80005cf8:	04695703          	lhu	a4,70(s2)
    80005cfc:	47a5                	li	a5,9
    80005cfe:	0ce7ec63          	bltu	a5,a4,80005dd6 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005d02:	fffff097          	auipc	ra,0xfffff
    80005d06:	e02080e7          	jalr	-510(ra) # 80004b04 <filealloc>
    80005d0a:	89aa                	mv	s3,a0
    80005d0c:	10050263          	beqz	a0,80005e10 <sys_open+0x182>
    80005d10:	00000097          	auipc	ra,0x0
    80005d14:	902080e7          	jalr	-1790(ra) # 80005612 <fdalloc>
    80005d18:	84aa                	mv	s1,a0
    80005d1a:	0e054663          	bltz	a0,80005e06 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005d1e:	04491703          	lh	a4,68(s2)
    80005d22:	478d                	li	a5,3
    80005d24:	0cf70463          	beq	a4,a5,80005dec <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005d28:	4789                	li	a5,2
    80005d2a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005d2e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005d32:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005d36:	f4c42783          	lw	a5,-180(s0)
    80005d3a:	0017c713          	xori	a4,a5,1
    80005d3e:	8b05                	andi	a4,a4,1
    80005d40:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005d44:	0037f713          	andi	a4,a5,3
    80005d48:	00e03733          	snez	a4,a4
    80005d4c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005d50:	4007f793          	andi	a5,a5,1024
    80005d54:	c791                	beqz	a5,80005d60 <sys_open+0xd2>
    80005d56:	04491703          	lh	a4,68(s2)
    80005d5a:	4789                	li	a5,2
    80005d5c:	08f70f63          	beq	a4,a5,80005dfa <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005d60:	854a                	mv	a0,s2
    80005d62:	ffffe097          	auipc	ra,0xffffe
    80005d66:	082080e7          	jalr	130(ra) # 80003de4 <iunlock>
  end_op();
    80005d6a:	fffff097          	auipc	ra,0xfffff
    80005d6e:	a0a080e7          	jalr	-1526(ra) # 80004774 <end_op>

  return fd;
}
    80005d72:	8526                	mv	a0,s1
    80005d74:	70ea                	ld	ra,184(sp)
    80005d76:	744a                	ld	s0,176(sp)
    80005d78:	74aa                	ld	s1,168(sp)
    80005d7a:	790a                	ld	s2,160(sp)
    80005d7c:	69ea                	ld	s3,152(sp)
    80005d7e:	6129                	addi	sp,sp,192
    80005d80:	8082                	ret
      end_op();
    80005d82:	fffff097          	auipc	ra,0xfffff
    80005d86:	9f2080e7          	jalr	-1550(ra) # 80004774 <end_op>
      return -1;
    80005d8a:	b7e5                	j	80005d72 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005d8c:	f5040513          	addi	a0,s0,-176
    80005d90:	ffffe097          	auipc	ra,0xffffe
    80005d94:	748080e7          	jalr	1864(ra) # 800044d8 <namei>
    80005d98:	892a                	mv	s2,a0
    80005d9a:	c905                	beqz	a0,80005dca <sys_open+0x13c>
    ilock(ip);
    80005d9c:	ffffe097          	auipc	ra,0xffffe
    80005da0:	f86080e7          	jalr	-122(ra) # 80003d22 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005da4:	04491703          	lh	a4,68(s2)
    80005da8:	4785                	li	a5,1
    80005daa:	f4f712e3          	bne	a4,a5,80005cee <sys_open+0x60>
    80005dae:	f4c42783          	lw	a5,-180(s0)
    80005db2:	dba1                	beqz	a5,80005d02 <sys_open+0x74>
      iunlockput(ip);
    80005db4:	854a                	mv	a0,s2
    80005db6:	ffffe097          	auipc	ra,0xffffe
    80005dba:	1ce080e7          	jalr	462(ra) # 80003f84 <iunlockput>
      end_op();
    80005dbe:	fffff097          	auipc	ra,0xfffff
    80005dc2:	9b6080e7          	jalr	-1610(ra) # 80004774 <end_op>
      return -1;
    80005dc6:	54fd                	li	s1,-1
    80005dc8:	b76d                	j	80005d72 <sys_open+0xe4>
      end_op();
    80005dca:	fffff097          	auipc	ra,0xfffff
    80005dce:	9aa080e7          	jalr	-1622(ra) # 80004774 <end_op>
      return -1;
    80005dd2:	54fd                	li	s1,-1
    80005dd4:	bf79                	j	80005d72 <sys_open+0xe4>
    iunlockput(ip);
    80005dd6:	854a                	mv	a0,s2
    80005dd8:	ffffe097          	auipc	ra,0xffffe
    80005ddc:	1ac080e7          	jalr	428(ra) # 80003f84 <iunlockput>
    end_op();
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	994080e7          	jalr	-1644(ra) # 80004774 <end_op>
    return -1;
    80005de8:	54fd                	li	s1,-1
    80005dea:	b761                	j	80005d72 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005dec:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005df0:	04691783          	lh	a5,70(s2)
    80005df4:	02f99223          	sh	a5,36(s3)
    80005df8:	bf2d                	j	80005d32 <sys_open+0xa4>
    itrunc(ip);
    80005dfa:	854a                	mv	a0,s2
    80005dfc:	ffffe097          	auipc	ra,0xffffe
    80005e00:	034080e7          	jalr	52(ra) # 80003e30 <itrunc>
    80005e04:	bfb1                	j	80005d60 <sys_open+0xd2>
      fileclose(f);
    80005e06:	854e                	mv	a0,s3
    80005e08:	fffff097          	auipc	ra,0xfffff
    80005e0c:	db8080e7          	jalr	-584(ra) # 80004bc0 <fileclose>
    iunlockput(ip);
    80005e10:	854a                	mv	a0,s2
    80005e12:	ffffe097          	auipc	ra,0xffffe
    80005e16:	172080e7          	jalr	370(ra) # 80003f84 <iunlockput>
    end_op();
    80005e1a:	fffff097          	auipc	ra,0xfffff
    80005e1e:	95a080e7          	jalr	-1702(ra) # 80004774 <end_op>
    return -1;
    80005e22:	54fd                	li	s1,-1
    80005e24:	b7b9                	j	80005d72 <sys_open+0xe4>

0000000080005e26 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005e26:	7175                	addi	sp,sp,-144
    80005e28:	e506                	sd	ra,136(sp)
    80005e2a:	e122                	sd	s0,128(sp)
    80005e2c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005e2e:	fffff097          	auipc	ra,0xfffff
    80005e32:	8c6080e7          	jalr	-1850(ra) # 800046f4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005e36:	08000613          	li	a2,128
    80005e3a:	f7040593          	addi	a1,s0,-144
    80005e3e:	4501                	li	a0,0
    80005e40:	ffffd097          	auipc	ra,0xffffd
    80005e44:	23a080e7          	jalr	570(ra) # 8000307a <argstr>
    80005e48:	02054963          	bltz	a0,80005e7a <sys_mkdir+0x54>
    80005e4c:	4681                	li	a3,0
    80005e4e:	4601                	li	a2,0
    80005e50:	4585                	li	a1,1
    80005e52:	f7040513          	addi	a0,s0,-144
    80005e56:	fffff097          	auipc	ra,0xfffff
    80005e5a:	7fe080e7          	jalr	2046(ra) # 80005654 <create>
    80005e5e:	cd11                	beqz	a0,80005e7a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e60:	ffffe097          	auipc	ra,0xffffe
    80005e64:	124080e7          	jalr	292(ra) # 80003f84 <iunlockput>
  end_op();
    80005e68:	fffff097          	auipc	ra,0xfffff
    80005e6c:	90c080e7          	jalr	-1780(ra) # 80004774 <end_op>
  return 0;
    80005e70:	4501                	li	a0,0
}
    80005e72:	60aa                	ld	ra,136(sp)
    80005e74:	640a                	ld	s0,128(sp)
    80005e76:	6149                	addi	sp,sp,144
    80005e78:	8082                	ret
    end_op();
    80005e7a:	fffff097          	auipc	ra,0xfffff
    80005e7e:	8fa080e7          	jalr	-1798(ra) # 80004774 <end_op>
    return -1;
    80005e82:	557d                	li	a0,-1
    80005e84:	b7fd                	j	80005e72 <sys_mkdir+0x4c>

0000000080005e86 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005e86:	7135                	addi	sp,sp,-160
    80005e88:	ed06                	sd	ra,152(sp)
    80005e8a:	e922                	sd	s0,144(sp)
    80005e8c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e8e:	fffff097          	auipc	ra,0xfffff
    80005e92:	866080e7          	jalr	-1946(ra) # 800046f4 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e96:	08000613          	li	a2,128
    80005e9a:	f7040593          	addi	a1,s0,-144
    80005e9e:	4501                	li	a0,0
    80005ea0:	ffffd097          	auipc	ra,0xffffd
    80005ea4:	1da080e7          	jalr	474(ra) # 8000307a <argstr>
    80005ea8:	04054a63          	bltz	a0,80005efc <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005eac:	f6c40593          	addi	a1,s0,-148
    80005eb0:	4505                	li	a0,1
    80005eb2:	ffffd097          	auipc	ra,0xffffd
    80005eb6:	184080e7          	jalr	388(ra) # 80003036 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005eba:	04054163          	bltz	a0,80005efc <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ebe:	f6840593          	addi	a1,s0,-152
    80005ec2:	4509                	li	a0,2
    80005ec4:	ffffd097          	auipc	ra,0xffffd
    80005ec8:	172080e7          	jalr	370(ra) # 80003036 <argint>
     argint(1, &major) < 0 ||
    80005ecc:	02054863          	bltz	a0,80005efc <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ed0:	f6841683          	lh	a3,-152(s0)
    80005ed4:	f6c41603          	lh	a2,-148(s0)
    80005ed8:	458d                	li	a1,3
    80005eda:	f7040513          	addi	a0,s0,-144
    80005ede:	fffff097          	auipc	ra,0xfffff
    80005ee2:	776080e7          	jalr	1910(ra) # 80005654 <create>
     argint(2, &minor) < 0 ||
    80005ee6:	c919                	beqz	a0,80005efc <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ee8:	ffffe097          	auipc	ra,0xffffe
    80005eec:	09c080e7          	jalr	156(ra) # 80003f84 <iunlockput>
  end_op();
    80005ef0:	fffff097          	auipc	ra,0xfffff
    80005ef4:	884080e7          	jalr	-1916(ra) # 80004774 <end_op>
  return 0;
    80005ef8:	4501                	li	a0,0
    80005efa:	a031                	j	80005f06 <sys_mknod+0x80>
    end_op();
    80005efc:	fffff097          	auipc	ra,0xfffff
    80005f00:	878080e7          	jalr	-1928(ra) # 80004774 <end_op>
    return -1;
    80005f04:	557d                	li	a0,-1
}
    80005f06:	60ea                	ld	ra,152(sp)
    80005f08:	644a                	ld	s0,144(sp)
    80005f0a:	610d                	addi	sp,sp,160
    80005f0c:	8082                	ret

0000000080005f0e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005f0e:	7135                	addi	sp,sp,-160
    80005f10:	ed06                	sd	ra,152(sp)
    80005f12:	e922                	sd	s0,144(sp)
    80005f14:	e526                	sd	s1,136(sp)
    80005f16:	e14a                	sd	s2,128(sp)
    80005f18:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005f1a:	ffffc097          	auipc	ra,0xffffc
    80005f1e:	a96080e7          	jalr	-1386(ra) # 800019b0 <myproc>
    80005f22:	892a                	mv	s2,a0
  
  begin_op();
    80005f24:	ffffe097          	auipc	ra,0xffffe
    80005f28:	7d0080e7          	jalr	2000(ra) # 800046f4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005f2c:	08000613          	li	a2,128
    80005f30:	f6040593          	addi	a1,s0,-160
    80005f34:	4501                	li	a0,0
    80005f36:	ffffd097          	auipc	ra,0xffffd
    80005f3a:	144080e7          	jalr	324(ra) # 8000307a <argstr>
    80005f3e:	04054b63          	bltz	a0,80005f94 <sys_chdir+0x86>
    80005f42:	f6040513          	addi	a0,s0,-160
    80005f46:	ffffe097          	auipc	ra,0xffffe
    80005f4a:	592080e7          	jalr	1426(ra) # 800044d8 <namei>
    80005f4e:	84aa                	mv	s1,a0
    80005f50:	c131                	beqz	a0,80005f94 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005f52:	ffffe097          	auipc	ra,0xffffe
    80005f56:	dd0080e7          	jalr	-560(ra) # 80003d22 <ilock>
  if(ip->type != T_DIR){
    80005f5a:	04449703          	lh	a4,68(s1)
    80005f5e:	4785                	li	a5,1
    80005f60:	04f71063          	bne	a4,a5,80005fa0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005f64:	8526                	mv	a0,s1
    80005f66:	ffffe097          	auipc	ra,0xffffe
    80005f6a:	e7e080e7          	jalr	-386(ra) # 80003de4 <iunlock>
  iput(p->cwd);
    80005f6e:	15893503          	ld	a0,344(s2)
    80005f72:	ffffe097          	auipc	ra,0xffffe
    80005f76:	f6a080e7          	jalr	-150(ra) # 80003edc <iput>
  end_op();
    80005f7a:	ffffe097          	auipc	ra,0xffffe
    80005f7e:	7fa080e7          	jalr	2042(ra) # 80004774 <end_op>
  p->cwd = ip;
    80005f82:	14993c23          	sd	s1,344(s2)
  return 0;
    80005f86:	4501                	li	a0,0
}
    80005f88:	60ea                	ld	ra,152(sp)
    80005f8a:	644a                	ld	s0,144(sp)
    80005f8c:	64aa                	ld	s1,136(sp)
    80005f8e:	690a                	ld	s2,128(sp)
    80005f90:	610d                	addi	sp,sp,160
    80005f92:	8082                	ret
    end_op();
    80005f94:	ffffe097          	auipc	ra,0xffffe
    80005f98:	7e0080e7          	jalr	2016(ra) # 80004774 <end_op>
    return -1;
    80005f9c:	557d                	li	a0,-1
    80005f9e:	b7ed                	j	80005f88 <sys_chdir+0x7a>
    iunlockput(ip);
    80005fa0:	8526                	mv	a0,s1
    80005fa2:	ffffe097          	auipc	ra,0xffffe
    80005fa6:	fe2080e7          	jalr	-30(ra) # 80003f84 <iunlockput>
    end_op();
    80005faa:	ffffe097          	auipc	ra,0xffffe
    80005fae:	7ca080e7          	jalr	1994(ra) # 80004774 <end_op>
    return -1;
    80005fb2:	557d                	li	a0,-1
    80005fb4:	bfd1                	j	80005f88 <sys_chdir+0x7a>

0000000080005fb6 <sys_exec>:

uint64
sys_exec(void)
{
    80005fb6:	7145                	addi	sp,sp,-464
    80005fb8:	e786                	sd	ra,456(sp)
    80005fba:	e3a2                	sd	s0,448(sp)
    80005fbc:	ff26                	sd	s1,440(sp)
    80005fbe:	fb4a                	sd	s2,432(sp)
    80005fc0:	f74e                	sd	s3,424(sp)
    80005fc2:	f352                	sd	s4,416(sp)
    80005fc4:	ef56                	sd	s5,408(sp)
    80005fc6:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fc8:	08000613          	li	a2,128
    80005fcc:	f4040593          	addi	a1,s0,-192
    80005fd0:	4501                	li	a0,0
    80005fd2:	ffffd097          	auipc	ra,0xffffd
    80005fd6:	0a8080e7          	jalr	168(ra) # 8000307a <argstr>
    return -1;
    80005fda:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005fdc:	0c054a63          	bltz	a0,800060b0 <sys_exec+0xfa>
    80005fe0:	e3840593          	addi	a1,s0,-456
    80005fe4:	4505                	li	a0,1
    80005fe6:	ffffd097          	auipc	ra,0xffffd
    80005fea:	072080e7          	jalr	114(ra) # 80003058 <argaddr>
    80005fee:	0c054163          	bltz	a0,800060b0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ff2:	10000613          	li	a2,256
    80005ff6:	4581                	li	a1,0
    80005ff8:	e4040513          	addi	a0,s0,-448
    80005ffc:	ffffb097          	auipc	ra,0xffffb
    80006000:	ce4080e7          	jalr	-796(ra) # 80000ce0 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006004:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006008:	89a6                	mv	s3,s1
    8000600a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000600c:	02000a13          	li	s4,32
    80006010:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006014:	00391513          	slli	a0,s2,0x3
    80006018:	e3040593          	addi	a1,s0,-464
    8000601c:	e3843783          	ld	a5,-456(s0)
    80006020:	953e                	add	a0,a0,a5
    80006022:	ffffd097          	auipc	ra,0xffffd
    80006026:	f7a080e7          	jalr	-134(ra) # 80002f9c <fetchaddr>
    8000602a:	02054a63          	bltz	a0,8000605e <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    8000602e:	e3043783          	ld	a5,-464(s0)
    80006032:	c3b9                	beqz	a5,80006078 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006034:	ffffb097          	auipc	ra,0xffffb
    80006038:	ac0080e7          	jalr	-1344(ra) # 80000af4 <kalloc>
    8000603c:	85aa                	mv	a1,a0
    8000603e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006042:	cd11                	beqz	a0,8000605e <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006044:	6605                	lui	a2,0x1
    80006046:	e3043503          	ld	a0,-464(s0)
    8000604a:	ffffd097          	auipc	ra,0xffffd
    8000604e:	fa4080e7          	jalr	-92(ra) # 80002fee <fetchstr>
    80006052:	00054663          	bltz	a0,8000605e <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006056:	0905                	addi	s2,s2,1
    80006058:	09a1                	addi	s3,s3,8
    8000605a:	fb491be3          	bne	s2,s4,80006010 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000605e:	10048913          	addi	s2,s1,256
    80006062:	6088                	ld	a0,0(s1)
    80006064:	c529                	beqz	a0,800060ae <sys_exec+0xf8>
    kfree(argv[i]);
    80006066:	ffffb097          	auipc	ra,0xffffb
    8000606a:	992080e7          	jalr	-1646(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000606e:	04a1                	addi	s1,s1,8
    80006070:	ff2499e3          	bne	s1,s2,80006062 <sys_exec+0xac>
  return -1;
    80006074:	597d                	li	s2,-1
    80006076:	a82d                	j	800060b0 <sys_exec+0xfa>
      argv[i] = 0;
    80006078:	0a8e                	slli	s5,s5,0x3
    8000607a:	fc040793          	addi	a5,s0,-64
    8000607e:	9abe                	add	s5,s5,a5
    80006080:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006084:	e4040593          	addi	a1,s0,-448
    80006088:	f4040513          	addi	a0,s0,-192
    8000608c:	fffff097          	auipc	ra,0xfffff
    80006090:	194080e7          	jalr	404(ra) # 80005220 <exec>
    80006094:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006096:	10048993          	addi	s3,s1,256
    8000609a:	6088                	ld	a0,0(s1)
    8000609c:	c911                	beqz	a0,800060b0 <sys_exec+0xfa>
    kfree(argv[i]);
    8000609e:	ffffb097          	auipc	ra,0xffffb
    800060a2:	95a080e7          	jalr	-1702(ra) # 800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800060a6:	04a1                	addi	s1,s1,8
    800060a8:	ff3499e3          	bne	s1,s3,8000609a <sys_exec+0xe4>
    800060ac:	a011                	j	800060b0 <sys_exec+0xfa>
  return -1;
    800060ae:	597d                	li	s2,-1
}
    800060b0:	854a                	mv	a0,s2
    800060b2:	60be                	ld	ra,456(sp)
    800060b4:	641e                	ld	s0,448(sp)
    800060b6:	74fa                	ld	s1,440(sp)
    800060b8:	795a                	ld	s2,432(sp)
    800060ba:	79ba                	ld	s3,424(sp)
    800060bc:	7a1a                	ld	s4,416(sp)
    800060be:	6afa                	ld	s5,408(sp)
    800060c0:	6179                	addi	sp,sp,464
    800060c2:	8082                	ret

00000000800060c4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800060c4:	7139                	addi	sp,sp,-64
    800060c6:	fc06                	sd	ra,56(sp)
    800060c8:	f822                	sd	s0,48(sp)
    800060ca:	f426                	sd	s1,40(sp)
    800060cc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800060ce:	ffffc097          	auipc	ra,0xffffc
    800060d2:	8e2080e7          	jalr	-1822(ra) # 800019b0 <myproc>
    800060d6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800060d8:	fd840593          	addi	a1,s0,-40
    800060dc:	4501                	li	a0,0
    800060de:	ffffd097          	auipc	ra,0xffffd
    800060e2:	f7a080e7          	jalr	-134(ra) # 80003058 <argaddr>
    return -1;
    800060e6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800060e8:	0e054063          	bltz	a0,800061c8 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800060ec:	fc840593          	addi	a1,s0,-56
    800060f0:	fd040513          	addi	a0,s0,-48
    800060f4:	fffff097          	auipc	ra,0xfffff
    800060f8:	dfc080e7          	jalr	-516(ra) # 80004ef0 <pipealloc>
    return -1;
    800060fc:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800060fe:	0c054563          	bltz	a0,800061c8 <sys_pipe+0x104>
  fd0 = -1;
    80006102:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006106:	fd043503          	ld	a0,-48(s0)
    8000610a:	fffff097          	auipc	ra,0xfffff
    8000610e:	508080e7          	jalr	1288(ra) # 80005612 <fdalloc>
    80006112:	fca42223          	sw	a0,-60(s0)
    80006116:	08054c63          	bltz	a0,800061ae <sys_pipe+0xea>
    8000611a:	fc843503          	ld	a0,-56(s0)
    8000611e:	fffff097          	auipc	ra,0xfffff
    80006122:	4f4080e7          	jalr	1268(ra) # 80005612 <fdalloc>
    80006126:	fca42023          	sw	a0,-64(s0)
    8000612a:	06054863          	bltz	a0,8000619a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000612e:	4691                	li	a3,4
    80006130:	fc440613          	addi	a2,s0,-60
    80006134:	fd843583          	ld	a1,-40(s0)
    80006138:	6ca8                	ld	a0,88(s1)
    8000613a:	ffffb097          	auipc	ra,0xffffb
    8000613e:	538080e7          	jalr	1336(ra) # 80001672 <copyout>
    80006142:	02054063          	bltz	a0,80006162 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006146:	4691                	li	a3,4
    80006148:	fc040613          	addi	a2,s0,-64
    8000614c:	fd843583          	ld	a1,-40(s0)
    80006150:	0591                	addi	a1,a1,4
    80006152:	6ca8                	ld	a0,88(s1)
    80006154:	ffffb097          	auipc	ra,0xffffb
    80006158:	51e080e7          	jalr	1310(ra) # 80001672 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000615c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000615e:	06055563          	bgez	a0,800061c8 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006162:	fc442783          	lw	a5,-60(s0)
    80006166:	07e9                	addi	a5,a5,26
    80006168:	078e                	slli	a5,a5,0x3
    8000616a:	97a6                	add	a5,a5,s1
    8000616c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80006170:	fc042503          	lw	a0,-64(s0)
    80006174:	0569                	addi	a0,a0,26
    80006176:	050e                	slli	a0,a0,0x3
    80006178:	9526                	add	a0,a0,s1
    8000617a:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    8000617e:	fd043503          	ld	a0,-48(s0)
    80006182:	fffff097          	auipc	ra,0xfffff
    80006186:	a3e080e7          	jalr	-1474(ra) # 80004bc0 <fileclose>
    fileclose(wf);
    8000618a:	fc843503          	ld	a0,-56(s0)
    8000618e:	fffff097          	auipc	ra,0xfffff
    80006192:	a32080e7          	jalr	-1486(ra) # 80004bc0 <fileclose>
    return -1;
    80006196:	57fd                	li	a5,-1
    80006198:	a805                	j	800061c8 <sys_pipe+0x104>
    if(fd0 >= 0)
    8000619a:	fc442783          	lw	a5,-60(s0)
    8000619e:	0007c863          	bltz	a5,800061ae <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    800061a2:	01a78513          	addi	a0,a5,26
    800061a6:	050e                	slli	a0,a0,0x3
    800061a8:	9526                	add	a0,a0,s1
    800061aa:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800061ae:	fd043503          	ld	a0,-48(s0)
    800061b2:	fffff097          	auipc	ra,0xfffff
    800061b6:	a0e080e7          	jalr	-1522(ra) # 80004bc0 <fileclose>
    fileclose(wf);
    800061ba:	fc843503          	ld	a0,-56(s0)
    800061be:	fffff097          	auipc	ra,0xfffff
    800061c2:	a02080e7          	jalr	-1534(ra) # 80004bc0 <fileclose>
    return -1;
    800061c6:	57fd                	li	a5,-1
}
    800061c8:	853e                	mv	a0,a5
    800061ca:	70e2                	ld	ra,56(sp)
    800061cc:	7442                	ld	s0,48(sp)
    800061ce:	74a2                	ld	s1,40(sp)
    800061d0:	6121                	addi	sp,sp,64
    800061d2:	8082                	ret
	...

00000000800061e0 <kernelvec>:
    800061e0:	7111                	addi	sp,sp,-256
    800061e2:	e006                	sd	ra,0(sp)
    800061e4:	e40a                	sd	sp,8(sp)
    800061e6:	e80e                	sd	gp,16(sp)
    800061e8:	ec12                	sd	tp,24(sp)
    800061ea:	f016                	sd	t0,32(sp)
    800061ec:	f41a                	sd	t1,40(sp)
    800061ee:	f81e                	sd	t2,48(sp)
    800061f0:	fc22                	sd	s0,56(sp)
    800061f2:	e0a6                	sd	s1,64(sp)
    800061f4:	e4aa                	sd	a0,72(sp)
    800061f6:	e8ae                	sd	a1,80(sp)
    800061f8:	ecb2                	sd	a2,88(sp)
    800061fa:	f0b6                	sd	a3,96(sp)
    800061fc:	f4ba                	sd	a4,104(sp)
    800061fe:	f8be                	sd	a5,112(sp)
    80006200:	fcc2                	sd	a6,120(sp)
    80006202:	e146                	sd	a7,128(sp)
    80006204:	e54a                	sd	s2,136(sp)
    80006206:	e94e                	sd	s3,144(sp)
    80006208:	ed52                	sd	s4,152(sp)
    8000620a:	f156                	sd	s5,160(sp)
    8000620c:	f55a                	sd	s6,168(sp)
    8000620e:	f95e                	sd	s7,176(sp)
    80006210:	fd62                	sd	s8,184(sp)
    80006212:	e1e6                	sd	s9,192(sp)
    80006214:	e5ea                	sd	s10,200(sp)
    80006216:	e9ee                	sd	s11,208(sp)
    80006218:	edf2                	sd	t3,216(sp)
    8000621a:	f1f6                	sd	t4,224(sp)
    8000621c:	f5fa                	sd	t5,232(sp)
    8000621e:	f9fe                	sd	t6,240(sp)
    80006220:	c49fc0ef          	jal	ra,80002e68 <kerneltrap>
    80006224:	6082                	ld	ra,0(sp)
    80006226:	6122                	ld	sp,8(sp)
    80006228:	61c2                	ld	gp,16(sp)
    8000622a:	7282                	ld	t0,32(sp)
    8000622c:	7322                	ld	t1,40(sp)
    8000622e:	73c2                	ld	t2,48(sp)
    80006230:	7462                	ld	s0,56(sp)
    80006232:	6486                	ld	s1,64(sp)
    80006234:	6526                	ld	a0,72(sp)
    80006236:	65c6                	ld	a1,80(sp)
    80006238:	6666                	ld	a2,88(sp)
    8000623a:	7686                	ld	a3,96(sp)
    8000623c:	7726                	ld	a4,104(sp)
    8000623e:	77c6                	ld	a5,112(sp)
    80006240:	7866                	ld	a6,120(sp)
    80006242:	688a                	ld	a7,128(sp)
    80006244:	692a                	ld	s2,136(sp)
    80006246:	69ca                	ld	s3,144(sp)
    80006248:	6a6a                	ld	s4,152(sp)
    8000624a:	7a8a                	ld	s5,160(sp)
    8000624c:	7b2a                	ld	s6,168(sp)
    8000624e:	7bca                	ld	s7,176(sp)
    80006250:	7c6a                	ld	s8,184(sp)
    80006252:	6c8e                	ld	s9,192(sp)
    80006254:	6d2e                	ld	s10,200(sp)
    80006256:	6dce                	ld	s11,208(sp)
    80006258:	6e6e                	ld	t3,216(sp)
    8000625a:	7e8e                	ld	t4,224(sp)
    8000625c:	7f2e                	ld	t5,232(sp)
    8000625e:	7fce                	ld	t6,240(sp)
    80006260:	6111                	addi	sp,sp,256
    80006262:	10200073          	sret
    80006266:	00000013          	nop
    8000626a:	00000013          	nop
    8000626e:	0001                	nop

0000000080006270 <timervec>:
    80006270:	34051573          	csrrw	a0,mscratch,a0
    80006274:	e10c                	sd	a1,0(a0)
    80006276:	e510                	sd	a2,8(a0)
    80006278:	e914                	sd	a3,16(a0)
    8000627a:	6d0c                	ld	a1,24(a0)
    8000627c:	7110                	ld	a2,32(a0)
    8000627e:	6194                	ld	a3,0(a1)
    80006280:	96b2                	add	a3,a3,a2
    80006282:	e194                	sd	a3,0(a1)
    80006284:	4589                	li	a1,2
    80006286:	14459073          	csrw	sip,a1
    8000628a:	6914                	ld	a3,16(a0)
    8000628c:	6510                	ld	a2,8(a0)
    8000628e:	610c                	ld	a1,0(a0)
    80006290:	34051573          	csrrw	a0,mscratch,a0
    80006294:	30200073          	mret
	...

000000008000629a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000629a:	1141                	addi	sp,sp,-16
    8000629c:	e422                	sd	s0,8(sp)
    8000629e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800062a0:	0c0007b7          	lui	a5,0xc000
    800062a4:	4705                	li	a4,1
    800062a6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800062a8:	c3d8                	sw	a4,4(a5)
}
    800062aa:	6422                	ld	s0,8(sp)
    800062ac:	0141                	addi	sp,sp,16
    800062ae:	8082                	ret

00000000800062b0 <plicinithart>:

void
plicinithart(void)
{
    800062b0:	1141                	addi	sp,sp,-16
    800062b2:	e406                	sd	ra,8(sp)
    800062b4:	e022                	sd	s0,0(sp)
    800062b6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062b8:	ffffb097          	auipc	ra,0xffffb
    800062bc:	6cc080e7          	jalr	1740(ra) # 80001984 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800062c0:	0085171b          	slliw	a4,a0,0x8
    800062c4:	0c0027b7          	lui	a5,0xc002
    800062c8:	97ba                	add	a5,a5,a4
    800062ca:	40200713          	li	a4,1026
    800062ce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800062d2:	00d5151b          	slliw	a0,a0,0xd
    800062d6:	0c2017b7          	lui	a5,0xc201
    800062da:	953e                	add	a0,a0,a5
    800062dc:	00052023          	sw	zero,0(a0)
}
    800062e0:	60a2                	ld	ra,8(sp)
    800062e2:	6402                	ld	s0,0(sp)
    800062e4:	0141                	addi	sp,sp,16
    800062e6:	8082                	ret

00000000800062e8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800062e8:	1141                	addi	sp,sp,-16
    800062ea:	e406                	sd	ra,8(sp)
    800062ec:	e022                	sd	s0,0(sp)
    800062ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800062f0:	ffffb097          	auipc	ra,0xffffb
    800062f4:	694080e7          	jalr	1684(ra) # 80001984 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800062f8:	00d5179b          	slliw	a5,a0,0xd
    800062fc:	0c201537          	lui	a0,0xc201
    80006300:	953e                	add	a0,a0,a5
  return irq;
}
    80006302:	4148                	lw	a0,4(a0)
    80006304:	60a2                	ld	ra,8(sp)
    80006306:	6402                	ld	s0,0(sp)
    80006308:	0141                	addi	sp,sp,16
    8000630a:	8082                	ret

000000008000630c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000630c:	1101                	addi	sp,sp,-32
    8000630e:	ec06                	sd	ra,24(sp)
    80006310:	e822                	sd	s0,16(sp)
    80006312:	e426                	sd	s1,8(sp)
    80006314:	1000                	addi	s0,sp,32
    80006316:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006318:	ffffb097          	auipc	ra,0xffffb
    8000631c:	66c080e7          	jalr	1644(ra) # 80001984 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006320:	00d5151b          	slliw	a0,a0,0xd
    80006324:	0c2017b7          	lui	a5,0xc201
    80006328:	97aa                	add	a5,a5,a0
    8000632a:	c3c4                	sw	s1,4(a5)
}
    8000632c:	60e2                	ld	ra,24(sp)
    8000632e:	6442                	ld	s0,16(sp)
    80006330:	64a2                	ld	s1,8(sp)
    80006332:	6105                	addi	sp,sp,32
    80006334:	8082                	ret

0000000080006336 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006336:	1141                	addi	sp,sp,-16
    80006338:	e406                	sd	ra,8(sp)
    8000633a:	e022                	sd	s0,0(sp)
    8000633c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000633e:	479d                	li	a5,7
    80006340:	06a7c963          	blt	a5,a0,800063b2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006344:	0001d797          	auipc	a5,0x1d
    80006348:	cbc78793          	addi	a5,a5,-836 # 80023000 <disk>
    8000634c:	00a78733          	add	a4,a5,a0
    80006350:	6789                	lui	a5,0x2
    80006352:	97ba                	add	a5,a5,a4
    80006354:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006358:	e7ad                	bnez	a5,800063c2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000635a:	00451793          	slli	a5,a0,0x4
    8000635e:	0001f717          	auipc	a4,0x1f
    80006362:	ca270713          	addi	a4,a4,-862 # 80025000 <disk+0x2000>
    80006366:	6314                	ld	a3,0(a4)
    80006368:	96be                	add	a3,a3,a5
    8000636a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000636e:	6314                	ld	a3,0(a4)
    80006370:	96be                	add	a3,a3,a5
    80006372:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006376:	6314                	ld	a3,0(a4)
    80006378:	96be                	add	a3,a3,a5
    8000637a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000637e:	6318                	ld	a4,0(a4)
    80006380:	97ba                	add	a5,a5,a4
    80006382:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006386:	0001d797          	auipc	a5,0x1d
    8000638a:	c7a78793          	addi	a5,a5,-902 # 80023000 <disk>
    8000638e:	97aa                	add	a5,a5,a0
    80006390:	6509                	lui	a0,0x2
    80006392:	953e                	add	a0,a0,a5
    80006394:	4785                	li	a5,1
    80006396:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000639a:	0001f517          	auipc	a0,0x1f
    8000639e:	c7e50513          	addi	a0,a0,-898 # 80025018 <disk+0x2018>
    800063a2:	ffffc097          	auipc	ra,0xffffc
    800063a6:	404080e7          	jalr	1028(ra) # 800027a6 <wakeup>
}
    800063aa:	60a2                	ld	ra,8(sp)
    800063ac:	6402                	ld	s0,0(sp)
    800063ae:	0141                	addi	sp,sp,16
    800063b0:	8082                	ret
    panic("free_desc 1");
    800063b2:	00002517          	auipc	a0,0x2
    800063b6:	49e50513          	addi	a0,a0,1182 # 80008850 <syscalls+0x358>
    800063ba:	ffffa097          	auipc	ra,0xffffa
    800063be:	184080e7          	jalr	388(ra) # 8000053e <panic>
    panic("free_desc 2");
    800063c2:	00002517          	auipc	a0,0x2
    800063c6:	49e50513          	addi	a0,a0,1182 # 80008860 <syscalls+0x368>
    800063ca:	ffffa097          	auipc	ra,0xffffa
    800063ce:	174080e7          	jalr	372(ra) # 8000053e <panic>

00000000800063d2 <virtio_disk_init>:
{
    800063d2:	1101                	addi	sp,sp,-32
    800063d4:	ec06                	sd	ra,24(sp)
    800063d6:	e822                	sd	s0,16(sp)
    800063d8:	e426                	sd	s1,8(sp)
    800063da:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800063dc:	00002597          	auipc	a1,0x2
    800063e0:	49458593          	addi	a1,a1,1172 # 80008870 <syscalls+0x378>
    800063e4:	0001f517          	auipc	a0,0x1f
    800063e8:	d4450513          	addi	a0,a0,-700 # 80025128 <disk+0x2128>
    800063ec:	ffffa097          	auipc	ra,0xffffa
    800063f0:	768080e7          	jalr	1896(ra) # 80000b54 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800063f4:	100017b7          	lui	a5,0x10001
    800063f8:	4398                	lw	a4,0(a5)
    800063fa:	2701                	sext.w	a4,a4
    800063fc:	747277b7          	lui	a5,0x74727
    80006400:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006404:	0ef71163          	bne	a4,a5,800064e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006408:	100017b7          	lui	a5,0x10001
    8000640c:	43dc                	lw	a5,4(a5)
    8000640e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006410:	4705                	li	a4,1
    80006412:	0ce79a63          	bne	a5,a4,800064e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006416:	100017b7          	lui	a5,0x10001
    8000641a:	479c                	lw	a5,8(a5)
    8000641c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000641e:	4709                	li	a4,2
    80006420:	0ce79363          	bne	a5,a4,800064e6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006424:	100017b7          	lui	a5,0x10001
    80006428:	47d8                	lw	a4,12(a5)
    8000642a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000642c:	554d47b7          	lui	a5,0x554d4
    80006430:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006434:	0af71963          	bne	a4,a5,800064e6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006438:	100017b7          	lui	a5,0x10001
    8000643c:	4705                	li	a4,1
    8000643e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006440:	470d                	li	a4,3
    80006442:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006444:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006446:	c7ffe737          	lui	a4,0xc7ffe
    8000644a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    8000644e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006450:	2701                	sext.w	a4,a4
    80006452:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006454:	472d                	li	a4,11
    80006456:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006458:	473d                	li	a4,15
    8000645a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000645c:	6705                	lui	a4,0x1
    8000645e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006460:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006464:	5bdc                	lw	a5,52(a5)
    80006466:	2781                	sext.w	a5,a5
  if(max == 0)
    80006468:	c7d9                	beqz	a5,800064f6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000646a:	471d                	li	a4,7
    8000646c:	08f77d63          	bgeu	a4,a5,80006506 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006470:	100014b7          	lui	s1,0x10001
    80006474:	47a1                	li	a5,8
    80006476:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006478:	6609                	lui	a2,0x2
    8000647a:	4581                	li	a1,0
    8000647c:	0001d517          	auipc	a0,0x1d
    80006480:	b8450513          	addi	a0,a0,-1148 # 80023000 <disk>
    80006484:	ffffb097          	auipc	ra,0xffffb
    80006488:	85c080e7          	jalr	-1956(ra) # 80000ce0 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000648c:	0001d717          	auipc	a4,0x1d
    80006490:	b7470713          	addi	a4,a4,-1164 # 80023000 <disk>
    80006494:	00c75793          	srli	a5,a4,0xc
    80006498:	2781                	sext.w	a5,a5
    8000649a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000649c:	0001f797          	auipc	a5,0x1f
    800064a0:	b6478793          	addi	a5,a5,-1180 # 80025000 <disk+0x2000>
    800064a4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800064a6:	0001d717          	auipc	a4,0x1d
    800064aa:	bda70713          	addi	a4,a4,-1062 # 80023080 <disk+0x80>
    800064ae:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800064b0:	0001e717          	auipc	a4,0x1e
    800064b4:	b5070713          	addi	a4,a4,-1200 # 80024000 <disk+0x1000>
    800064b8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800064ba:	4705                	li	a4,1
    800064bc:	00e78c23          	sb	a4,24(a5)
    800064c0:	00e78ca3          	sb	a4,25(a5)
    800064c4:	00e78d23          	sb	a4,26(a5)
    800064c8:	00e78da3          	sb	a4,27(a5)
    800064cc:	00e78e23          	sb	a4,28(a5)
    800064d0:	00e78ea3          	sb	a4,29(a5)
    800064d4:	00e78f23          	sb	a4,30(a5)
    800064d8:	00e78fa3          	sb	a4,31(a5)
}
    800064dc:	60e2                	ld	ra,24(sp)
    800064de:	6442                	ld	s0,16(sp)
    800064e0:	64a2                	ld	s1,8(sp)
    800064e2:	6105                	addi	sp,sp,32
    800064e4:	8082                	ret
    panic("could not find virtio disk");
    800064e6:	00002517          	auipc	a0,0x2
    800064ea:	39a50513          	addi	a0,a0,922 # 80008880 <syscalls+0x388>
    800064ee:	ffffa097          	auipc	ra,0xffffa
    800064f2:	050080e7          	jalr	80(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    800064f6:	00002517          	auipc	a0,0x2
    800064fa:	3aa50513          	addi	a0,a0,938 # 800088a0 <syscalls+0x3a8>
    800064fe:	ffffa097          	auipc	ra,0xffffa
    80006502:	040080e7          	jalr	64(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006506:	00002517          	auipc	a0,0x2
    8000650a:	3ba50513          	addi	a0,a0,954 # 800088c0 <syscalls+0x3c8>
    8000650e:	ffffa097          	auipc	ra,0xffffa
    80006512:	030080e7          	jalr	48(ra) # 8000053e <panic>

0000000080006516 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006516:	7159                	addi	sp,sp,-112
    80006518:	f486                	sd	ra,104(sp)
    8000651a:	f0a2                	sd	s0,96(sp)
    8000651c:	eca6                	sd	s1,88(sp)
    8000651e:	e8ca                	sd	s2,80(sp)
    80006520:	e4ce                	sd	s3,72(sp)
    80006522:	e0d2                	sd	s4,64(sp)
    80006524:	fc56                	sd	s5,56(sp)
    80006526:	f85a                	sd	s6,48(sp)
    80006528:	f45e                	sd	s7,40(sp)
    8000652a:	f062                	sd	s8,32(sp)
    8000652c:	ec66                	sd	s9,24(sp)
    8000652e:	e86a                	sd	s10,16(sp)
    80006530:	1880                	addi	s0,sp,112
    80006532:	892a                	mv	s2,a0
    80006534:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006536:	00c52c83          	lw	s9,12(a0)
    8000653a:	001c9c9b          	slliw	s9,s9,0x1
    8000653e:	1c82                	slli	s9,s9,0x20
    80006540:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006544:	0001f517          	auipc	a0,0x1f
    80006548:	be450513          	addi	a0,a0,-1052 # 80025128 <disk+0x2128>
    8000654c:	ffffa097          	auipc	ra,0xffffa
    80006550:	698080e7          	jalr	1688(ra) # 80000be4 <acquire>
  for(int i = 0; i < 3; i++){
    80006554:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006556:	4c21                	li	s8,8
      disk.free[i] = 0;
    80006558:	0001db97          	auipc	s7,0x1d
    8000655c:	aa8b8b93          	addi	s7,s7,-1368 # 80023000 <disk>
    80006560:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006562:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006564:	8a4e                	mv	s4,s3
    80006566:	a051                	j	800065ea <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80006568:	00fb86b3          	add	a3,s7,a5
    8000656c:	96da                	add	a3,a3,s6
    8000656e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006572:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006574:	0207c563          	bltz	a5,8000659e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006578:	2485                	addiw	s1,s1,1
    8000657a:	0711                	addi	a4,a4,4
    8000657c:	25548063          	beq	s1,s5,800067bc <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006580:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006582:	0001f697          	auipc	a3,0x1f
    80006586:	a9668693          	addi	a3,a3,-1386 # 80025018 <disk+0x2018>
    8000658a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000658c:	0006c583          	lbu	a1,0(a3)
    80006590:	fde1                	bnez	a1,80006568 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006592:	2785                	addiw	a5,a5,1
    80006594:	0685                	addi	a3,a3,1
    80006596:	ff879be3          	bne	a5,s8,8000658c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000659a:	57fd                	li	a5,-1
    8000659c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000659e:	02905a63          	blez	s1,800065d2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800065a2:	f9042503          	lw	a0,-112(s0)
    800065a6:	00000097          	auipc	ra,0x0
    800065aa:	d90080e7          	jalr	-624(ra) # 80006336 <free_desc>
      for(int j = 0; j < i; j++)
    800065ae:	4785                	li	a5,1
    800065b0:	0297d163          	bge	a5,s1,800065d2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800065b4:	f9442503          	lw	a0,-108(s0)
    800065b8:	00000097          	auipc	ra,0x0
    800065bc:	d7e080e7          	jalr	-642(ra) # 80006336 <free_desc>
      for(int j = 0; j < i; j++)
    800065c0:	4789                	li	a5,2
    800065c2:	0097d863          	bge	a5,s1,800065d2 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    800065c6:	f9842503          	lw	a0,-104(s0)
    800065ca:	00000097          	auipc	ra,0x0
    800065ce:	d6c080e7          	jalr	-660(ra) # 80006336 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800065d2:	0001f597          	auipc	a1,0x1f
    800065d6:	b5658593          	addi	a1,a1,-1194 # 80025128 <disk+0x2128>
    800065da:	0001f517          	auipc	a0,0x1f
    800065de:	a3e50513          	addi	a0,a0,-1474 # 80025018 <disk+0x2018>
    800065e2:	ffffc097          	auipc	ra,0xffffc
    800065e6:	f06080e7          	jalr	-250(ra) # 800024e8 <sleep>
  for(int i = 0; i < 3; i++){
    800065ea:	f9040713          	addi	a4,s0,-112
    800065ee:	84ce                	mv	s1,s3
    800065f0:	bf41                	j	80006580 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800065f2:	20058713          	addi	a4,a1,512
    800065f6:	00471693          	slli	a3,a4,0x4
    800065fa:	0001d717          	auipc	a4,0x1d
    800065fe:	a0670713          	addi	a4,a4,-1530 # 80023000 <disk>
    80006602:	9736                	add	a4,a4,a3
    80006604:	4685                	li	a3,1
    80006606:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000660a:	20058713          	addi	a4,a1,512
    8000660e:	00471693          	slli	a3,a4,0x4
    80006612:	0001d717          	auipc	a4,0x1d
    80006616:	9ee70713          	addi	a4,a4,-1554 # 80023000 <disk>
    8000661a:	9736                	add	a4,a4,a3
    8000661c:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006620:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006624:	7679                	lui	a2,0xffffe
    80006626:	963e                	add	a2,a2,a5
    80006628:	0001f697          	auipc	a3,0x1f
    8000662c:	9d868693          	addi	a3,a3,-1576 # 80025000 <disk+0x2000>
    80006630:	6298                	ld	a4,0(a3)
    80006632:	9732                	add	a4,a4,a2
    80006634:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006636:	6298                	ld	a4,0(a3)
    80006638:	9732                	add	a4,a4,a2
    8000663a:	4541                	li	a0,16
    8000663c:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000663e:	6298                	ld	a4,0(a3)
    80006640:	9732                	add	a4,a4,a2
    80006642:	4505                	li	a0,1
    80006644:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006648:	f9442703          	lw	a4,-108(s0)
    8000664c:	6288                	ld	a0,0(a3)
    8000664e:	962a                	add	a2,a2,a0
    80006650:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006654:	0712                	slli	a4,a4,0x4
    80006656:	6290                	ld	a2,0(a3)
    80006658:	963a                	add	a2,a2,a4
    8000665a:	05890513          	addi	a0,s2,88
    8000665e:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006660:	6294                	ld	a3,0(a3)
    80006662:	96ba                	add	a3,a3,a4
    80006664:	40000613          	li	a2,1024
    80006668:	c690                	sw	a2,8(a3)
  if(write)
    8000666a:	140d0063          	beqz	s10,800067aa <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000666e:	0001f697          	auipc	a3,0x1f
    80006672:	9926b683          	ld	a3,-1646(a3) # 80025000 <disk+0x2000>
    80006676:	96ba                	add	a3,a3,a4
    80006678:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000667c:	0001d817          	auipc	a6,0x1d
    80006680:	98480813          	addi	a6,a6,-1660 # 80023000 <disk>
    80006684:	0001f517          	auipc	a0,0x1f
    80006688:	97c50513          	addi	a0,a0,-1668 # 80025000 <disk+0x2000>
    8000668c:	6114                	ld	a3,0(a0)
    8000668e:	96ba                	add	a3,a3,a4
    80006690:	00c6d603          	lhu	a2,12(a3)
    80006694:	00166613          	ori	a2,a2,1
    80006698:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000669c:	f9842683          	lw	a3,-104(s0)
    800066a0:	6110                	ld	a2,0(a0)
    800066a2:	9732                	add	a4,a4,a2
    800066a4:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800066a8:	20058613          	addi	a2,a1,512
    800066ac:	0612                	slli	a2,a2,0x4
    800066ae:	9642                	add	a2,a2,a6
    800066b0:	577d                	li	a4,-1
    800066b2:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800066b6:	00469713          	slli	a4,a3,0x4
    800066ba:	6114                	ld	a3,0(a0)
    800066bc:	96ba                	add	a3,a3,a4
    800066be:	03078793          	addi	a5,a5,48
    800066c2:	97c2                	add	a5,a5,a6
    800066c4:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    800066c6:	611c                	ld	a5,0(a0)
    800066c8:	97ba                	add	a5,a5,a4
    800066ca:	4685                	li	a3,1
    800066cc:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800066ce:	611c                	ld	a5,0(a0)
    800066d0:	97ba                	add	a5,a5,a4
    800066d2:	4809                	li	a6,2
    800066d4:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800066d8:	611c                	ld	a5,0(a0)
    800066da:	973e                	add	a4,a4,a5
    800066dc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800066e0:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    800066e4:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800066e8:	6518                	ld	a4,8(a0)
    800066ea:	00275783          	lhu	a5,2(a4)
    800066ee:	8b9d                	andi	a5,a5,7
    800066f0:	0786                	slli	a5,a5,0x1
    800066f2:	97ba                	add	a5,a5,a4
    800066f4:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800066f8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800066fc:	6518                	ld	a4,8(a0)
    800066fe:	00275783          	lhu	a5,2(a4)
    80006702:	2785                	addiw	a5,a5,1
    80006704:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006708:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000670c:	100017b7          	lui	a5,0x10001
    80006710:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006714:	00492703          	lw	a4,4(s2)
    80006718:	4785                	li	a5,1
    8000671a:	02f71163          	bne	a4,a5,8000673c <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    8000671e:	0001f997          	auipc	s3,0x1f
    80006722:	a0a98993          	addi	s3,s3,-1526 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006726:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006728:	85ce                	mv	a1,s3
    8000672a:	854a                	mv	a0,s2
    8000672c:	ffffc097          	auipc	ra,0xffffc
    80006730:	dbc080e7          	jalr	-580(ra) # 800024e8 <sleep>
  while(b->disk == 1) {
    80006734:	00492783          	lw	a5,4(s2)
    80006738:	fe9788e3          	beq	a5,s1,80006728 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    8000673c:	f9042903          	lw	s2,-112(s0)
    80006740:	20090793          	addi	a5,s2,512
    80006744:	00479713          	slli	a4,a5,0x4
    80006748:	0001d797          	auipc	a5,0x1d
    8000674c:	8b878793          	addi	a5,a5,-1864 # 80023000 <disk>
    80006750:	97ba                	add	a5,a5,a4
    80006752:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006756:	0001f997          	auipc	s3,0x1f
    8000675a:	8aa98993          	addi	s3,s3,-1878 # 80025000 <disk+0x2000>
    8000675e:	00491713          	slli	a4,s2,0x4
    80006762:	0009b783          	ld	a5,0(s3)
    80006766:	97ba                	add	a5,a5,a4
    80006768:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000676c:	854a                	mv	a0,s2
    8000676e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006772:	00000097          	auipc	ra,0x0
    80006776:	bc4080e7          	jalr	-1084(ra) # 80006336 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000677a:	8885                	andi	s1,s1,1
    8000677c:	f0ed                	bnez	s1,8000675e <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000677e:	0001f517          	auipc	a0,0x1f
    80006782:	9aa50513          	addi	a0,a0,-1622 # 80025128 <disk+0x2128>
    80006786:	ffffa097          	auipc	ra,0xffffa
    8000678a:	512080e7          	jalr	1298(ra) # 80000c98 <release>
}
    8000678e:	70a6                	ld	ra,104(sp)
    80006790:	7406                	ld	s0,96(sp)
    80006792:	64e6                	ld	s1,88(sp)
    80006794:	6946                	ld	s2,80(sp)
    80006796:	69a6                	ld	s3,72(sp)
    80006798:	6a06                	ld	s4,64(sp)
    8000679a:	7ae2                	ld	s5,56(sp)
    8000679c:	7b42                	ld	s6,48(sp)
    8000679e:	7ba2                	ld	s7,40(sp)
    800067a0:	7c02                	ld	s8,32(sp)
    800067a2:	6ce2                	ld	s9,24(sp)
    800067a4:	6d42                	ld	s10,16(sp)
    800067a6:	6165                	addi	sp,sp,112
    800067a8:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800067aa:	0001f697          	auipc	a3,0x1f
    800067ae:	8566b683          	ld	a3,-1962(a3) # 80025000 <disk+0x2000>
    800067b2:	96ba                	add	a3,a3,a4
    800067b4:	4609                	li	a2,2
    800067b6:	00c69623          	sh	a2,12(a3)
    800067ba:	b5c9                	j	8000667c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067bc:	f9042583          	lw	a1,-112(s0)
    800067c0:	20058793          	addi	a5,a1,512
    800067c4:	0792                	slli	a5,a5,0x4
    800067c6:	0001d517          	auipc	a0,0x1d
    800067ca:	8e250513          	addi	a0,a0,-1822 # 800230a8 <disk+0xa8>
    800067ce:	953e                	add	a0,a0,a5
  if(write)
    800067d0:	e20d11e3          	bnez	s10,800065f2 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800067d4:	20058713          	addi	a4,a1,512
    800067d8:	00471693          	slli	a3,a4,0x4
    800067dc:	0001d717          	auipc	a4,0x1d
    800067e0:	82470713          	addi	a4,a4,-2012 # 80023000 <disk>
    800067e4:	9736                	add	a4,a4,a3
    800067e6:	0a072423          	sw	zero,168(a4)
    800067ea:	b505                	j	8000660a <virtio_disk_rw+0xf4>

00000000800067ec <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800067ec:	1101                	addi	sp,sp,-32
    800067ee:	ec06                	sd	ra,24(sp)
    800067f0:	e822                	sd	s0,16(sp)
    800067f2:	e426                	sd	s1,8(sp)
    800067f4:	e04a                	sd	s2,0(sp)
    800067f6:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800067f8:	0001f517          	auipc	a0,0x1f
    800067fc:	93050513          	addi	a0,a0,-1744 # 80025128 <disk+0x2128>
    80006800:	ffffa097          	auipc	ra,0xffffa
    80006804:	3e4080e7          	jalr	996(ra) # 80000be4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006808:	10001737          	lui	a4,0x10001
    8000680c:	533c                	lw	a5,96(a4)
    8000680e:	8b8d                	andi	a5,a5,3
    80006810:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006812:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006816:	0001e797          	auipc	a5,0x1e
    8000681a:	7ea78793          	addi	a5,a5,2026 # 80025000 <disk+0x2000>
    8000681e:	6b94                	ld	a3,16(a5)
    80006820:	0207d703          	lhu	a4,32(a5)
    80006824:	0026d783          	lhu	a5,2(a3)
    80006828:	06f70163          	beq	a4,a5,8000688a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000682c:	0001c917          	auipc	s2,0x1c
    80006830:	7d490913          	addi	s2,s2,2004 # 80023000 <disk>
    80006834:	0001e497          	auipc	s1,0x1e
    80006838:	7cc48493          	addi	s1,s1,1996 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000683c:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006840:	6898                	ld	a4,16(s1)
    80006842:	0204d783          	lhu	a5,32(s1)
    80006846:	8b9d                	andi	a5,a5,7
    80006848:	078e                	slli	a5,a5,0x3
    8000684a:	97ba                	add	a5,a5,a4
    8000684c:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000684e:	20078713          	addi	a4,a5,512
    80006852:	0712                	slli	a4,a4,0x4
    80006854:	974a                	add	a4,a4,s2
    80006856:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000685a:	e731                	bnez	a4,800068a6 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000685c:	20078793          	addi	a5,a5,512
    80006860:	0792                	slli	a5,a5,0x4
    80006862:	97ca                	add	a5,a5,s2
    80006864:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006866:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000686a:	ffffc097          	auipc	ra,0xffffc
    8000686e:	f3c080e7          	jalr	-196(ra) # 800027a6 <wakeup>

    disk.used_idx += 1;
    80006872:	0204d783          	lhu	a5,32(s1)
    80006876:	2785                	addiw	a5,a5,1
    80006878:	17c2                	slli	a5,a5,0x30
    8000687a:	93c1                	srli	a5,a5,0x30
    8000687c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006880:	6898                	ld	a4,16(s1)
    80006882:	00275703          	lhu	a4,2(a4)
    80006886:	faf71be3          	bne	a4,a5,8000683c <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000688a:	0001f517          	auipc	a0,0x1f
    8000688e:	89e50513          	addi	a0,a0,-1890 # 80025128 <disk+0x2128>
    80006892:	ffffa097          	auipc	ra,0xffffa
    80006896:	406080e7          	jalr	1030(ra) # 80000c98 <release>
}
    8000689a:	60e2                	ld	ra,24(sp)
    8000689c:	6442                	ld	s0,16(sp)
    8000689e:	64a2                	ld	s1,8(sp)
    800068a0:	6902                	ld	s2,0(sp)
    800068a2:	6105                	addi	sp,sp,32
    800068a4:	8082                	ret
      panic("virtio_disk_intr status");
    800068a6:	00002517          	auipc	a0,0x2
    800068aa:	03a50513          	addi	a0,a0,58 # 800088e0 <syscalls+0x3e8>
    800068ae:	ffffa097          	auipc	ra,0xffffa
    800068b2:	c90080e7          	jalr	-880(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
