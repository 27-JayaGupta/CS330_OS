
user/_ps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16

    ps();
   8:	00000097          	auipc	ra,0x0
   c:	350080e7          	jalr	848(ra) # 358 <ps>
    exit(0);
  10:	4501                	li	a0,0
  12:	00000097          	auipc	ra,0x0
  16:	27e080e7          	jalr	638(ra) # 290 <exit>

000000000000001a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  1a:	1141                	addi	sp,sp,-16
  1c:	e422                	sd	s0,8(sp)
  1e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  20:	87aa                	mv	a5,a0
  22:	0585                	addi	a1,a1,1
  24:	0785                	addi	a5,a5,1
  26:	fff5c703          	lbu	a4,-1(a1)
  2a:	fee78fa3          	sb	a4,-1(a5)
  2e:	fb75                	bnez	a4,22 <strcpy+0x8>
    ;
  return os;
}
  30:	6422                	ld	s0,8(sp)
  32:	0141                	addi	sp,sp,16
  34:	8082                	ret

0000000000000036 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  36:	1141                	addi	sp,sp,-16
  38:	e422                	sd	s0,8(sp)
  3a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  3c:	00054783          	lbu	a5,0(a0)
  40:	cb91                	beqz	a5,54 <strcmp+0x1e>
  42:	0005c703          	lbu	a4,0(a1)
  46:	00f71763          	bne	a4,a5,54 <strcmp+0x1e>
    p++, q++;
  4a:	0505                	addi	a0,a0,1
  4c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  4e:	00054783          	lbu	a5,0(a0)
  52:	fbe5                	bnez	a5,42 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  54:	0005c503          	lbu	a0,0(a1)
}
  58:	40a7853b          	subw	a0,a5,a0
  5c:	6422                	ld	s0,8(sp)
  5e:	0141                	addi	sp,sp,16
  60:	8082                	ret

0000000000000062 <strlen>:

uint
strlen(const char *s)
{
  62:	1141                	addi	sp,sp,-16
  64:	e422                	sd	s0,8(sp)
  66:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  68:	00054783          	lbu	a5,0(a0)
  6c:	cf91                	beqz	a5,88 <strlen+0x26>
  6e:	0505                	addi	a0,a0,1
  70:	87aa                	mv	a5,a0
  72:	4685                	li	a3,1
  74:	9e89                	subw	a3,a3,a0
  76:	00f6853b          	addw	a0,a3,a5
  7a:	0785                	addi	a5,a5,1
  7c:	fff7c703          	lbu	a4,-1(a5)
  80:	fb7d                	bnez	a4,76 <strlen+0x14>
    ;
  return n;
}
  82:	6422                	ld	s0,8(sp)
  84:	0141                	addi	sp,sp,16
  86:	8082                	ret
  for(n = 0; s[n]; n++)
  88:	4501                	li	a0,0
  8a:	bfe5                	j	82 <strlen+0x20>

000000000000008c <memset>:

void*
memset(void *dst, int c, uint n)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  92:	ce09                	beqz	a2,ac <memset+0x20>
  94:	87aa                	mv	a5,a0
  96:	fff6071b          	addiw	a4,a2,-1
  9a:	1702                	slli	a4,a4,0x20
  9c:	9301                	srli	a4,a4,0x20
  9e:	0705                	addi	a4,a4,1
  a0:	972a                	add	a4,a4,a0
    cdst[i] = c;
  a2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  a6:	0785                	addi	a5,a5,1
  a8:	fee79de3          	bne	a5,a4,a2 <memset+0x16>
  }
  return dst;
}
  ac:	6422                	ld	s0,8(sp)
  ae:	0141                	addi	sp,sp,16
  b0:	8082                	ret

00000000000000b2 <strchr>:

char*
strchr(const char *s, char c)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e422                	sd	s0,8(sp)
  b6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	cb99                	beqz	a5,d2 <strchr+0x20>
    if(*s == c)
  be:	00f58763          	beq	a1,a5,cc <strchr+0x1a>
  for(; *s; s++)
  c2:	0505                	addi	a0,a0,1
  c4:	00054783          	lbu	a5,0(a0)
  c8:	fbfd                	bnez	a5,be <strchr+0xc>
      return (char*)s;
  return 0;
  ca:	4501                	li	a0,0
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret
  return 0;
  d2:	4501                	li	a0,0
  d4:	bfe5                	j	cc <strchr+0x1a>

00000000000000d6 <gets>:

char*
gets(char *buf, int max)
{
  d6:	711d                	addi	sp,sp,-96
  d8:	ec86                	sd	ra,88(sp)
  da:	e8a2                	sd	s0,80(sp)
  dc:	e4a6                	sd	s1,72(sp)
  de:	e0ca                	sd	s2,64(sp)
  e0:	fc4e                	sd	s3,56(sp)
  e2:	f852                	sd	s4,48(sp)
  e4:	f456                	sd	s5,40(sp)
  e6:	f05a                	sd	s6,32(sp)
  e8:	ec5e                	sd	s7,24(sp)
  ea:	1080                	addi	s0,sp,96
  ec:	8baa                	mv	s7,a0
  ee:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  f0:	892a                	mv	s2,a0
  f2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
  f4:	4aa9                	li	s5,10
  f6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
  f8:	89a6                	mv	s3,s1
  fa:	2485                	addiw	s1,s1,1
  fc:	0344d863          	bge	s1,s4,12c <gets+0x56>
    cc = read(0, &c, 1);
 100:	4605                	li	a2,1
 102:	faf40593          	addi	a1,s0,-81
 106:	4501                	li	a0,0
 108:	00000097          	auipc	ra,0x0
 10c:	1a0080e7          	jalr	416(ra) # 2a8 <read>
    if(cc < 1)
 110:	00a05e63          	blez	a0,12c <gets+0x56>
    buf[i++] = c;
 114:	faf44783          	lbu	a5,-81(s0)
 118:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 11c:	01578763          	beq	a5,s5,12a <gets+0x54>
 120:	0905                	addi	s2,s2,1
 122:	fd679be3          	bne	a5,s6,f8 <gets+0x22>
  for(i=0; i+1 < max; ){
 126:	89a6                	mv	s3,s1
 128:	a011                	j	12c <gets+0x56>
 12a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 12c:	99de                	add	s3,s3,s7
 12e:	00098023          	sb	zero,0(s3)
  return buf;
}
 132:	855e                	mv	a0,s7
 134:	60e6                	ld	ra,88(sp)
 136:	6446                	ld	s0,80(sp)
 138:	64a6                	ld	s1,72(sp)
 13a:	6906                	ld	s2,64(sp)
 13c:	79e2                	ld	s3,56(sp)
 13e:	7a42                	ld	s4,48(sp)
 140:	7aa2                	ld	s5,40(sp)
 142:	7b02                	ld	s6,32(sp)
 144:	6be2                	ld	s7,24(sp)
 146:	6125                	addi	sp,sp,96
 148:	8082                	ret

000000000000014a <stat>:

int
stat(const char *n, struct stat *st)
{
 14a:	1101                	addi	sp,sp,-32
 14c:	ec06                	sd	ra,24(sp)
 14e:	e822                	sd	s0,16(sp)
 150:	e426                	sd	s1,8(sp)
 152:	e04a                	sd	s2,0(sp)
 154:	1000                	addi	s0,sp,32
 156:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 158:	4581                	li	a1,0
 15a:	00000097          	auipc	ra,0x0
 15e:	176080e7          	jalr	374(ra) # 2d0 <open>
  if(fd < 0)
 162:	02054563          	bltz	a0,18c <stat+0x42>
 166:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 168:	85ca                	mv	a1,s2
 16a:	00000097          	auipc	ra,0x0
 16e:	17e080e7          	jalr	382(ra) # 2e8 <fstat>
 172:	892a                	mv	s2,a0
  close(fd);
 174:	8526                	mv	a0,s1
 176:	00000097          	auipc	ra,0x0
 17a:	142080e7          	jalr	322(ra) # 2b8 <close>
  return r;
}
 17e:	854a                	mv	a0,s2
 180:	60e2                	ld	ra,24(sp)
 182:	6442                	ld	s0,16(sp)
 184:	64a2                	ld	s1,8(sp)
 186:	6902                	ld	s2,0(sp)
 188:	6105                	addi	sp,sp,32
 18a:	8082                	ret
    return -1;
 18c:	597d                	li	s2,-1
 18e:	bfc5                	j	17e <stat+0x34>

0000000000000190 <atoi>:

int
atoi(const char *s)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 196:	00054603          	lbu	a2,0(a0)
 19a:	fd06079b          	addiw	a5,a2,-48
 19e:	0ff7f793          	andi	a5,a5,255
 1a2:	4725                	li	a4,9
 1a4:	02f76963          	bltu	a4,a5,1d6 <atoi+0x46>
 1a8:	86aa                	mv	a3,a0
  n = 0;
 1aa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1ac:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ae:	0685                	addi	a3,a3,1
 1b0:	0025179b          	slliw	a5,a0,0x2
 1b4:	9fa9                	addw	a5,a5,a0
 1b6:	0017979b          	slliw	a5,a5,0x1
 1ba:	9fb1                	addw	a5,a5,a2
 1bc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c0:	0006c603          	lbu	a2,0(a3)
 1c4:	fd06071b          	addiw	a4,a2,-48
 1c8:	0ff77713          	andi	a4,a4,255
 1cc:	fee5f1e3          	bgeu	a1,a4,1ae <atoi+0x1e>
  return n;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret
  n = 0;
 1d6:	4501                	li	a0,0
 1d8:	bfe5                	j	1d0 <atoi+0x40>

00000000000001da <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1da:	1141                	addi	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e0:	02b57663          	bgeu	a0,a1,20c <memmove+0x32>
    while(n-- > 0)
 1e4:	02c05163          	blez	a2,206 <memmove+0x2c>
 1e8:	fff6079b          	addiw	a5,a2,-1
 1ec:	1782                	slli	a5,a5,0x20
 1ee:	9381                	srli	a5,a5,0x20
 1f0:	0785                	addi	a5,a5,1
 1f2:	97aa                	add	a5,a5,a0
  dst = vdst;
 1f4:	872a                	mv	a4,a0
      *dst++ = *src++;
 1f6:	0585                	addi	a1,a1,1
 1f8:	0705                	addi	a4,a4,1
 1fa:	fff5c683          	lbu	a3,-1(a1)
 1fe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 202:	fee79ae3          	bne	a5,a4,1f6 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret
    dst += n;
 20c:	00c50733          	add	a4,a0,a2
    src += n;
 210:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 212:	fec05ae3          	blez	a2,206 <memmove+0x2c>
 216:	fff6079b          	addiw	a5,a2,-1
 21a:	1782                	slli	a5,a5,0x20
 21c:	9381                	srli	a5,a5,0x20
 21e:	fff7c793          	not	a5,a5
 222:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 224:	15fd                	addi	a1,a1,-1
 226:	177d                	addi	a4,a4,-1
 228:	0005c683          	lbu	a3,0(a1)
 22c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 230:	fee79ae3          	bne	a5,a4,224 <memmove+0x4a>
 234:	bfc9                	j	206 <memmove+0x2c>

0000000000000236 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 23c:	ca05                	beqz	a2,26c <memcmp+0x36>
 23e:	fff6069b          	addiw	a3,a2,-1
 242:	1682                	slli	a3,a3,0x20
 244:	9281                	srli	a3,a3,0x20
 246:	0685                	addi	a3,a3,1
 248:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 24a:	00054783          	lbu	a5,0(a0)
 24e:	0005c703          	lbu	a4,0(a1)
 252:	00e79863          	bne	a5,a4,262 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 256:	0505                	addi	a0,a0,1
    p2++;
 258:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 25a:	fed518e3          	bne	a0,a3,24a <memcmp+0x14>
  }
  return 0;
 25e:	4501                	li	a0,0
 260:	a019                	j	266 <memcmp+0x30>
      return *p1 - *p2;
 262:	40e7853b          	subw	a0,a5,a4
}
 266:	6422                	ld	s0,8(sp)
 268:	0141                	addi	sp,sp,16
 26a:	8082                	ret
  return 0;
 26c:	4501                	li	a0,0
 26e:	bfe5                	j	266 <memcmp+0x30>

0000000000000270 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 270:	1141                	addi	sp,sp,-16
 272:	e406                	sd	ra,8(sp)
 274:	e022                	sd	s0,0(sp)
 276:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 278:	00000097          	auipc	ra,0x0
 27c:	f62080e7          	jalr	-158(ra) # 1da <memmove>
}
 280:	60a2                	ld	ra,8(sp)
 282:	6402                	ld	s0,0(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret

0000000000000288 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 288:	4885                	li	a7,1
 ecall
 28a:	00000073          	ecall
 ret
 28e:	8082                	ret

0000000000000290 <exit>:
.global exit
exit:
 li a7, SYS_exit
 290:	4889                	li	a7,2
 ecall
 292:	00000073          	ecall
 ret
 296:	8082                	ret

0000000000000298 <wait>:
.global wait
wait:
 li a7, SYS_wait
 298:	488d                	li	a7,3
 ecall
 29a:	00000073          	ecall
 ret
 29e:	8082                	ret

00000000000002a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2a0:	4891                	li	a7,4
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <read>:
.global read
read:
 li a7, SYS_read
 2a8:	4895                	li	a7,5
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <write>:
.global write
write:
 li a7, SYS_write
 2b0:	48c1                	li	a7,16
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <close>:
.global close
close:
 li a7, SYS_close
 2b8:	48d5                	li	a7,21
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2c0:	4899                	li	a7,6
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2c8:	489d                	li	a7,7
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <open>:
.global open
open:
 li a7, SYS_open
 2d0:	48bd                	li	a7,15
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2d8:	48c5                	li	a7,17
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2e0:	48c9                	li	a7,18
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2e8:	48a1                	li	a7,8
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <link>:
.global link
link:
 li a7, SYS_link
 2f0:	48cd                	li	a7,19
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2f8:	48d1                	li	a7,20
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 300:	48a5                	li	a7,9
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <dup>:
.global dup
dup:
 li a7, SYS_dup
 308:	48a9                	li	a7,10
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 310:	48ad                	li	a7,11
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 318:	48b1                	li	a7,12
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 320:	48b5                	li	a7,13
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 328:	48b9                	li	a7,14
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 330:	48d9                	li	a7,22
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <yield>:
.global yield
yield:
 li a7, SYS_yield
 338:	48dd                	li	a7,23
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 340:	48e1                	li	a7,24
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 348:	48e5                	li	a7,25
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 350:	48e9                	li	a7,26
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <ps>:
.global ps
ps:
 li a7, SYS_ps
 358:	48ed                	li	a7,27
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 360:	48f1                	li	a7,28
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 368:	1101                	addi	sp,sp,-32
 36a:	ec06                	sd	ra,24(sp)
 36c:	e822                	sd	s0,16(sp)
 36e:	1000                	addi	s0,sp,32
 370:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 374:	4605                	li	a2,1
 376:	fef40593          	addi	a1,s0,-17
 37a:	00000097          	auipc	ra,0x0
 37e:	f36080e7          	jalr	-202(ra) # 2b0 <write>
}
 382:	60e2                	ld	ra,24(sp)
 384:	6442                	ld	s0,16(sp)
 386:	6105                	addi	sp,sp,32
 388:	8082                	ret

000000000000038a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 38a:	7139                	addi	sp,sp,-64
 38c:	fc06                	sd	ra,56(sp)
 38e:	f822                	sd	s0,48(sp)
 390:	f426                	sd	s1,40(sp)
 392:	f04a                	sd	s2,32(sp)
 394:	ec4e                	sd	s3,24(sp)
 396:	0080                	addi	s0,sp,64
 398:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 39a:	c299                	beqz	a3,3a0 <printint+0x16>
 39c:	0805c863          	bltz	a1,42c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3a0:	2581                	sext.w	a1,a1
  neg = 0;
 3a2:	4881                	li	a7,0
 3a4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3a8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3aa:	2601                	sext.w	a2,a2
 3ac:	00000517          	auipc	a0,0x0
 3b0:	44450513          	addi	a0,a0,1092 # 7f0 <digits>
 3b4:	883a                	mv	a6,a4
 3b6:	2705                	addiw	a4,a4,1
 3b8:	02c5f7bb          	remuw	a5,a1,a2
 3bc:	1782                	slli	a5,a5,0x20
 3be:	9381                	srli	a5,a5,0x20
 3c0:	97aa                	add	a5,a5,a0
 3c2:	0007c783          	lbu	a5,0(a5)
 3c6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ca:	0005879b          	sext.w	a5,a1
 3ce:	02c5d5bb          	divuw	a1,a1,a2
 3d2:	0685                	addi	a3,a3,1
 3d4:	fec7f0e3          	bgeu	a5,a2,3b4 <printint+0x2a>
  if(neg)
 3d8:	00088b63          	beqz	a7,3ee <printint+0x64>
    buf[i++] = '-';
 3dc:	fd040793          	addi	a5,s0,-48
 3e0:	973e                	add	a4,a4,a5
 3e2:	02d00793          	li	a5,45
 3e6:	fef70823          	sb	a5,-16(a4)
 3ea:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3ee:	02e05863          	blez	a4,41e <printint+0x94>
 3f2:	fc040793          	addi	a5,s0,-64
 3f6:	00e78933          	add	s2,a5,a4
 3fa:	fff78993          	addi	s3,a5,-1
 3fe:	99ba                	add	s3,s3,a4
 400:	377d                	addiw	a4,a4,-1
 402:	1702                	slli	a4,a4,0x20
 404:	9301                	srli	a4,a4,0x20
 406:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 40a:	fff94583          	lbu	a1,-1(s2)
 40e:	8526                	mv	a0,s1
 410:	00000097          	auipc	ra,0x0
 414:	f58080e7          	jalr	-168(ra) # 368 <putc>
  while(--i >= 0)
 418:	197d                	addi	s2,s2,-1
 41a:	ff3918e3          	bne	s2,s3,40a <printint+0x80>
}
 41e:	70e2                	ld	ra,56(sp)
 420:	7442                	ld	s0,48(sp)
 422:	74a2                	ld	s1,40(sp)
 424:	7902                	ld	s2,32(sp)
 426:	69e2                	ld	s3,24(sp)
 428:	6121                	addi	sp,sp,64
 42a:	8082                	ret
    x = -xx;
 42c:	40b005bb          	negw	a1,a1
    neg = 1;
 430:	4885                	li	a7,1
    x = -xx;
 432:	bf8d                	j	3a4 <printint+0x1a>

0000000000000434 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 434:	7119                	addi	sp,sp,-128
 436:	fc86                	sd	ra,120(sp)
 438:	f8a2                	sd	s0,112(sp)
 43a:	f4a6                	sd	s1,104(sp)
 43c:	f0ca                	sd	s2,96(sp)
 43e:	ecce                	sd	s3,88(sp)
 440:	e8d2                	sd	s4,80(sp)
 442:	e4d6                	sd	s5,72(sp)
 444:	e0da                	sd	s6,64(sp)
 446:	fc5e                	sd	s7,56(sp)
 448:	f862                	sd	s8,48(sp)
 44a:	f466                	sd	s9,40(sp)
 44c:	f06a                	sd	s10,32(sp)
 44e:	ec6e                	sd	s11,24(sp)
 450:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 452:	0005c903          	lbu	s2,0(a1)
 456:	18090f63          	beqz	s2,5f4 <vprintf+0x1c0>
 45a:	8aaa                	mv	s5,a0
 45c:	8b32                	mv	s6,a2
 45e:	00158493          	addi	s1,a1,1
  state = 0;
 462:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 464:	02500a13          	li	s4,37
      if(c == 'd'){
 468:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 46c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 470:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 474:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 478:	00000b97          	auipc	s7,0x0
 47c:	378b8b93          	addi	s7,s7,888 # 7f0 <digits>
 480:	a839                	j	49e <vprintf+0x6a>
        putc(fd, c);
 482:	85ca                	mv	a1,s2
 484:	8556                	mv	a0,s5
 486:	00000097          	auipc	ra,0x0
 48a:	ee2080e7          	jalr	-286(ra) # 368 <putc>
 48e:	a019                	j	494 <vprintf+0x60>
    } else if(state == '%'){
 490:	01498f63          	beq	s3,s4,4ae <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 494:	0485                	addi	s1,s1,1
 496:	fff4c903          	lbu	s2,-1(s1)
 49a:	14090d63          	beqz	s2,5f4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 49e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4a2:	fe0997e3          	bnez	s3,490 <vprintf+0x5c>
      if(c == '%'){
 4a6:	fd479ee3          	bne	a5,s4,482 <vprintf+0x4e>
        state = '%';
 4aa:	89be                	mv	s3,a5
 4ac:	b7e5                	j	494 <vprintf+0x60>
      if(c == 'd'){
 4ae:	05878063          	beq	a5,s8,4ee <vprintf+0xba>
      } else if(c == 'l') {
 4b2:	05978c63          	beq	a5,s9,50a <vprintf+0xd6>
      } else if(c == 'x') {
 4b6:	07a78863          	beq	a5,s10,526 <vprintf+0xf2>
      } else if(c == 'p') {
 4ba:	09b78463          	beq	a5,s11,542 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4be:	07300713          	li	a4,115
 4c2:	0ce78663          	beq	a5,a4,58e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4c6:	06300713          	li	a4,99
 4ca:	0ee78e63          	beq	a5,a4,5c6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4ce:	11478863          	beq	a5,s4,5de <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4d2:	85d2                	mv	a1,s4
 4d4:	8556                	mv	a0,s5
 4d6:	00000097          	auipc	ra,0x0
 4da:	e92080e7          	jalr	-366(ra) # 368 <putc>
        putc(fd, c);
 4de:	85ca                	mv	a1,s2
 4e0:	8556                	mv	a0,s5
 4e2:	00000097          	auipc	ra,0x0
 4e6:	e86080e7          	jalr	-378(ra) # 368 <putc>
      }
      state = 0;
 4ea:	4981                	li	s3,0
 4ec:	b765                	j	494 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4ee:	008b0913          	addi	s2,s6,8
 4f2:	4685                	li	a3,1
 4f4:	4629                	li	a2,10
 4f6:	000b2583          	lw	a1,0(s6)
 4fa:	8556                	mv	a0,s5
 4fc:	00000097          	auipc	ra,0x0
 500:	e8e080e7          	jalr	-370(ra) # 38a <printint>
 504:	8b4a                	mv	s6,s2
      state = 0;
 506:	4981                	li	s3,0
 508:	b771                	j	494 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 50a:	008b0913          	addi	s2,s6,8
 50e:	4681                	li	a3,0
 510:	4629                	li	a2,10
 512:	000b2583          	lw	a1,0(s6)
 516:	8556                	mv	a0,s5
 518:	00000097          	auipc	ra,0x0
 51c:	e72080e7          	jalr	-398(ra) # 38a <printint>
 520:	8b4a                	mv	s6,s2
      state = 0;
 522:	4981                	li	s3,0
 524:	bf85                	j	494 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 526:	008b0913          	addi	s2,s6,8
 52a:	4681                	li	a3,0
 52c:	4641                	li	a2,16
 52e:	000b2583          	lw	a1,0(s6)
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	e56080e7          	jalr	-426(ra) # 38a <printint>
 53c:	8b4a                	mv	s6,s2
      state = 0;
 53e:	4981                	li	s3,0
 540:	bf91                	j	494 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 542:	008b0793          	addi	a5,s6,8
 546:	f8f43423          	sd	a5,-120(s0)
 54a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 54e:	03000593          	li	a1,48
 552:	8556                	mv	a0,s5
 554:	00000097          	auipc	ra,0x0
 558:	e14080e7          	jalr	-492(ra) # 368 <putc>
  putc(fd, 'x');
 55c:	85ea                	mv	a1,s10
 55e:	8556                	mv	a0,s5
 560:	00000097          	auipc	ra,0x0
 564:	e08080e7          	jalr	-504(ra) # 368 <putc>
 568:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56a:	03c9d793          	srli	a5,s3,0x3c
 56e:	97de                	add	a5,a5,s7
 570:	0007c583          	lbu	a1,0(a5)
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	df2080e7          	jalr	-526(ra) # 368 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 57e:	0992                	slli	s3,s3,0x4
 580:	397d                	addiw	s2,s2,-1
 582:	fe0914e3          	bnez	s2,56a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 586:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 58a:	4981                	li	s3,0
 58c:	b721                	j	494 <vprintf+0x60>
        s = va_arg(ap, char*);
 58e:	008b0993          	addi	s3,s6,8
 592:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 596:	02090163          	beqz	s2,5b8 <vprintf+0x184>
        while(*s != 0){
 59a:	00094583          	lbu	a1,0(s2)
 59e:	c9a1                	beqz	a1,5ee <vprintf+0x1ba>
          putc(fd, *s);
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	dc6080e7          	jalr	-570(ra) # 368 <putc>
          s++;
 5aa:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ac:	00094583          	lbu	a1,0(s2)
 5b0:	f9e5                	bnez	a1,5a0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5b2:	8b4e                	mv	s6,s3
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	bdf9                	j	494 <vprintf+0x60>
          s = "(null)";
 5b8:	00000917          	auipc	s2,0x0
 5bc:	23090913          	addi	s2,s2,560 # 7e8 <malloc+0xea>
        while(*s != 0){
 5c0:	02800593          	li	a1,40
 5c4:	bff1                	j	5a0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5c6:	008b0913          	addi	s2,s6,8
 5ca:	000b4583          	lbu	a1,0(s6)
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	d98080e7          	jalr	-616(ra) # 368 <putc>
 5d8:	8b4a                	mv	s6,s2
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	bd65                	j	494 <vprintf+0x60>
        putc(fd, c);
 5de:	85d2                	mv	a1,s4
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	d86080e7          	jalr	-634(ra) # 368 <putc>
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b565                	j	494 <vprintf+0x60>
        s = va_arg(ap, char*);
 5ee:	8b4e                	mv	s6,s3
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b54d                	j	494 <vprintf+0x60>
    }
  }
}
 5f4:	70e6                	ld	ra,120(sp)
 5f6:	7446                	ld	s0,112(sp)
 5f8:	74a6                	ld	s1,104(sp)
 5fa:	7906                	ld	s2,96(sp)
 5fc:	69e6                	ld	s3,88(sp)
 5fe:	6a46                	ld	s4,80(sp)
 600:	6aa6                	ld	s5,72(sp)
 602:	6b06                	ld	s6,64(sp)
 604:	7be2                	ld	s7,56(sp)
 606:	7c42                	ld	s8,48(sp)
 608:	7ca2                	ld	s9,40(sp)
 60a:	7d02                	ld	s10,32(sp)
 60c:	6de2                	ld	s11,24(sp)
 60e:	6109                	addi	sp,sp,128
 610:	8082                	ret

0000000000000612 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 612:	715d                	addi	sp,sp,-80
 614:	ec06                	sd	ra,24(sp)
 616:	e822                	sd	s0,16(sp)
 618:	1000                	addi	s0,sp,32
 61a:	e010                	sd	a2,0(s0)
 61c:	e414                	sd	a3,8(s0)
 61e:	e818                	sd	a4,16(s0)
 620:	ec1c                	sd	a5,24(s0)
 622:	03043023          	sd	a6,32(s0)
 626:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 62a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 62e:	8622                	mv	a2,s0
 630:	00000097          	auipc	ra,0x0
 634:	e04080e7          	jalr	-508(ra) # 434 <vprintf>
}
 638:	60e2                	ld	ra,24(sp)
 63a:	6442                	ld	s0,16(sp)
 63c:	6161                	addi	sp,sp,80
 63e:	8082                	ret

0000000000000640 <printf>:

void
printf(const char *fmt, ...)
{
 640:	711d                	addi	sp,sp,-96
 642:	ec06                	sd	ra,24(sp)
 644:	e822                	sd	s0,16(sp)
 646:	1000                	addi	s0,sp,32
 648:	e40c                	sd	a1,8(s0)
 64a:	e810                	sd	a2,16(s0)
 64c:	ec14                	sd	a3,24(s0)
 64e:	f018                	sd	a4,32(s0)
 650:	f41c                	sd	a5,40(s0)
 652:	03043823          	sd	a6,48(s0)
 656:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 65a:	00840613          	addi	a2,s0,8
 65e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 662:	85aa                	mv	a1,a0
 664:	4505                	li	a0,1
 666:	00000097          	auipc	ra,0x0
 66a:	dce080e7          	jalr	-562(ra) # 434 <vprintf>
}
 66e:	60e2                	ld	ra,24(sp)
 670:	6442                	ld	s0,16(sp)
 672:	6125                	addi	sp,sp,96
 674:	8082                	ret

0000000000000676 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 676:	1141                	addi	sp,sp,-16
 678:	e422                	sd	s0,8(sp)
 67a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 67c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 680:	00000797          	auipc	a5,0x0
 684:	1887b783          	ld	a5,392(a5) # 808 <freep>
 688:	a805                	j	6b8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 68a:	4618                	lw	a4,8(a2)
 68c:	9db9                	addw	a1,a1,a4
 68e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 692:	6398                	ld	a4,0(a5)
 694:	6318                	ld	a4,0(a4)
 696:	fee53823          	sd	a4,-16(a0)
 69a:	a091                	j	6de <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 69c:	ff852703          	lw	a4,-8(a0)
 6a0:	9e39                	addw	a2,a2,a4
 6a2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6a4:	ff053703          	ld	a4,-16(a0)
 6a8:	e398                	sd	a4,0(a5)
 6aa:	a099                	j	6f0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ac:	6398                	ld	a4,0(a5)
 6ae:	00e7e463          	bltu	a5,a4,6b6 <free+0x40>
 6b2:	00e6ea63          	bltu	a3,a4,6c6 <free+0x50>
{
 6b6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b8:	fed7fae3          	bgeu	a5,a3,6ac <free+0x36>
 6bc:	6398                	ld	a4,0(a5)
 6be:	00e6e463          	bltu	a3,a4,6c6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c2:	fee7eae3          	bltu	a5,a4,6b6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6c6:	ff852583          	lw	a1,-8(a0)
 6ca:	6390                	ld	a2,0(a5)
 6cc:	02059713          	slli	a4,a1,0x20
 6d0:	9301                	srli	a4,a4,0x20
 6d2:	0712                	slli	a4,a4,0x4
 6d4:	9736                	add	a4,a4,a3
 6d6:	fae60ae3          	beq	a2,a4,68a <free+0x14>
    bp->s.ptr = p->s.ptr;
 6da:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6de:	4790                	lw	a2,8(a5)
 6e0:	02061713          	slli	a4,a2,0x20
 6e4:	9301                	srli	a4,a4,0x20
 6e6:	0712                	slli	a4,a4,0x4
 6e8:	973e                	add	a4,a4,a5
 6ea:	fae689e3          	beq	a3,a4,69c <free+0x26>
  } else
    p->s.ptr = bp;
 6ee:	e394                	sd	a3,0(a5)
  freep = p;
 6f0:	00000717          	auipc	a4,0x0
 6f4:	10f73c23          	sd	a5,280(a4) # 808 <freep>
}
 6f8:	6422                	ld	s0,8(sp)
 6fa:	0141                	addi	sp,sp,16
 6fc:	8082                	ret

00000000000006fe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6fe:	7139                	addi	sp,sp,-64
 700:	fc06                	sd	ra,56(sp)
 702:	f822                	sd	s0,48(sp)
 704:	f426                	sd	s1,40(sp)
 706:	f04a                	sd	s2,32(sp)
 708:	ec4e                	sd	s3,24(sp)
 70a:	e852                	sd	s4,16(sp)
 70c:	e456                	sd	s5,8(sp)
 70e:	e05a                	sd	s6,0(sp)
 710:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 712:	02051493          	slli	s1,a0,0x20
 716:	9081                	srli	s1,s1,0x20
 718:	04bd                	addi	s1,s1,15
 71a:	8091                	srli	s1,s1,0x4
 71c:	0014899b          	addiw	s3,s1,1
 720:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 722:	00000517          	auipc	a0,0x0
 726:	0e653503          	ld	a0,230(a0) # 808 <freep>
 72a:	c515                	beqz	a0,756 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 72c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 72e:	4798                	lw	a4,8(a5)
 730:	02977f63          	bgeu	a4,s1,76e <malloc+0x70>
 734:	8a4e                	mv	s4,s3
 736:	0009871b          	sext.w	a4,s3
 73a:	6685                	lui	a3,0x1
 73c:	00d77363          	bgeu	a4,a3,742 <malloc+0x44>
 740:	6a05                	lui	s4,0x1
 742:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 746:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 74a:	00000917          	auipc	s2,0x0
 74e:	0be90913          	addi	s2,s2,190 # 808 <freep>
  if(p == (char*)-1)
 752:	5afd                	li	s5,-1
 754:	a88d                	j	7c6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 756:	00000797          	auipc	a5,0x0
 75a:	0ba78793          	addi	a5,a5,186 # 810 <base>
 75e:	00000717          	auipc	a4,0x0
 762:	0af73523          	sd	a5,170(a4) # 808 <freep>
 766:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 768:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 76c:	b7e1                	j	734 <malloc+0x36>
      if(p->s.size == nunits)
 76e:	02e48b63          	beq	s1,a4,7a4 <malloc+0xa6>
        p->s.size -= nunits;
 772:	4137073b          	subw	a4,a4,s3
 776:	c798                	sw	a4,8(a5)
        p += p->s.size;
 778:	1702                	slli	a4,a4,0x20
 77a:	9301                	srli	a4,a4,0x20
 77c:	0712                	slli	a4,a4,0x4
 77e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 780:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 784:	00000717          	auipc	a4,0x0
 788:	08a73223          	sd	a0,132(a4) # 808 <freep>
      return (void*)(p + 1);
 78c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 790:	70e2                	ld	ra,56(sp)
 792:	7442                	ld	s0,48(sp)
 794:	74a2                	ld	s1,40(sp)
 796:	7902                	ld	s2,32(sp)
 798:	69e2                	ld	s3,24(sp)
 79a:	6a42                	ld	s4,16(sp)
 79c:	6aa2                	ld	s5,8(sp)
 79e:	6b02                	ld	s6,0(sp)
 7a0:	6121                	addi	sp,sp,64
 7a2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7a4:	6398                	ld	a4,0(a5)
 7a6:	e118                	sd	a4,0(a0)
 7a8:	bff1                	j	784 <malloc+0x86>
  hp->s.size = nu;
 7aa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ae:	0541                	addi	a0,a0,16
 7b0:	00000097          	auipc	ra,0x0
 7b4:	ec6080e7          	jalr	-314(ra) # 676 <free>
  return freep;
 7b8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7bc:	d971                	beqz	a0,790 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c0:	4798                	lw	a4,8(a5)
 7c2:	fa9776e3          	bgeu	a4,s1,76e <malloc+0x70>
    if(p == freep)
 7c6:	00093703          	ld	a4,0(s2)
 7ca:	853e                	mv	a0,a5
 7cc:	fef719e3          	bne	a4,a5,7be <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7d0:	8552                	mv	a0,s4
 7d2:	00000097          	auipc	ra,0x0
 7d6:	b46080e7          	jalr	-1210(ra) # 318 <sbrk>
  if(p == (char*)-1)
 7da:	fd5518e3          	bne	a0,s5,7aa <malloc+0xac>
        return 0;
 7de:	4501                	li	a0,0
 7e0:	bf45                	j	790 <malloc+0x92>
