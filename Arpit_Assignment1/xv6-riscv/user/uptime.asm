
user/_uptime:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <uptime_wrapper>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void uptime_wrapper(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16

    printf("Seconds since system woke up %d\n",uptime()/10);
   8:	00000097          	auipc	ra,0x0
   c:	34e080e7          	jalr	846(ra) # 356 <uptime>
  10:	45a9                	li	a1,10
  12:	02b545bb          	divw	a1,a0,a1
  16:	00000517          	auipc	a0,0x0
  1a:	7fa50513          	addi	a0,a0,2042 # 810 <malloc+0xe4>
  1e:	00000097          	auipc	ra,0x0
  22:	650080e7          	jalr	1616(ra) # 66e <printf>

}
  26:	60a2                	ld	ra,8(sp)
  28:	6402                	ld	s0,0(sp)
  2a:	0141                	addi	sp,sp,16
  2c:	8082                	ret

000000000000002e <main>:

int main(){
  2e:	1141                	addi	sp,sp,-16
  30:	e406                	sd	ra,8(sp)
  32:	e022                	sd	s0,0(sp)
  34:	0800                	addi	s0,sp,16

    uptime_wrapper();
  36:	00000097          	auipc	ra,0x0
  3a:	fca080e7          	jalr	-54(ra) # 0 <uptime_wrapper>
    exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	27e080e7          	jalr	638(ra) # 2be <exit>

0000000000000048 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  48:	1141                	addi	sp,sp,-16
  4a:	e422                	sd	s0,8(sp)
  4c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4e:	87aa                	mv	a5,a0
  50:	0585                	addi	a1,a1,1
  52:	0785                	addi	a5,a5,1
  54:	fff5c703          	lbu	a4,-1(a1)
  58:	fee78fa3          	sb	a4,-1(a5)
  5c:	fb75                	bnez	a4,50 <strcpy+0x8>
    ;
  return os;
}
  5e:	6422                	ld	s0,8(sp)
  60:	0141                	addi	sp,sp,16
  62:	8082                	ret

0000000000000064 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  64:	1141                	addi	sp,sp,-16
  66:	e422                	sd	s0,8(sp)
  68:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  6a:	00054783          	lbu	a5,0(a0)
  6e:	cb91                	beqz	a5,82 <strcmp+0x1e>
  70:	0005c703          	lbu	a4,0(a1)
  74:	00f71763          	bne	a4,a5,82 <strcmp+0x1e>
    p++, q++;
  78:	0505                	addi	a0,a0,1
  7a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7c:	00054783          	lbu	a5,0(a0)
  80:	fbe5                	bnez	a5,70 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  82:	0005c503          	lbu	a0,0(a1)
}
  86:	40a7853b          	subw	a0,a5,a0
  8a:	6422                	ld	s0,8(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret

0000000000000090 <strlen>:

uint
strlen(const char *s)
{
  90:	1141                	addi	sp,sp,-16
  92:	e422                	sd	s0,8(sp)
  94:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  96:	00054783          	lbu	a5,0(a0)
  9a:	cf91                	beqz	a5,b6 <strlen+0x26>
  9c:	0505                	addi	a0,a0,1
  9e:	87aa                	mv	a5,a0
  a0:	4685                	li	a3,1
  a2:	9e89                	subw	a3,a3,a0
  a4:	00f6853b          	addw	a0,a3,a5
  a8:	0785                	addi	a5,a5,1
  aa:	fff7c703          	lbu	a4,-1(a5)
  ae:	fb7d                	bnez	a4,a4 <strlen+0x14>
    ;
  return n;
}
  b0:	6422                	ld	s0,8(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret
  for(n = 0; s[n]; n++)
  b6:	4501                	li	a0,0
  b8:	bfe5                	j	b0 <strlen+0x20>

00000000000000ba <memset>:

void*
memset(void *dst, int c, uint n)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c0:	ce09                	beqz	a2,da <memset+0x20>
  c2:	87aa                	mv	a5,a0
  c4:	fff6071b          	addiw	a4,a2,-1
  c8:	1702                	slli	a4,a4,0x20
  ca:	9301                	srli	a4,a4,0x20
  cc:	0705                	addi	a4,a4,1
  ce:	972a                	add	a4,a4,a0
    cdst[i] = c;
  d0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d4:	0785                	addi	a5,a5,1
  d6:	fee79de3          	bne	a5,a4,d0 <memset+0x16>
  }
  return dst;
}
  da:	6422                	ld	s0,8(sp)
  dc:	0141                	addi	sp,sp,16
  de:	8082                	ret

00000000000000e0 <strchr>:

char*
strchr(const char *s, char c)
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e422                	sd	s0,8(sp)
  e4:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e6:	00054783          	lbu	a5,0(a0)
  ea:	cb99                	beqz	a5,100 <strchr+0x20>
    if(*s == c)
  ec:	00f58763          	beq	a1,a5,fa <strchr+0x1a>
  for(; *s; s++)
  f0:	0505                	addi	a0,a0,1
  f2:	00054783          	lbu	a5,0(a0)
  f6:	fbfd                	bnez	a5,ec <strchr+0xc>
      return (char*)s;
  return 0;
  f8:	4501                	li	a0,0
}
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret
  return 0;
 100:	4501                	li	a0,0
 102:	bfe5                	j	fa <strchr+0x1a>

0000000000000104 <gets>:

char*
gets(char *buf, int max)
{
 104:	711d                	addi	sp,sp,-96
 106:	ec86                	sd	ra,88(sp)
 108:	e8a2                	sd	s0,80(sp)
 10a:	e4a6                	sd	s1,72(sp)
 10c:	e0ca                	sd	s2,64(sp)
 10e:	fc4e                	sd	s3,56(sp)
 110:	f852                	sd	s4,48(sp)
 112:	f456                	sd	s5,40(sp)
 114:	f05a                	sd	s6,32(sp)
 116:	ec5e                	sd	s7,24(sp)
 118:	1080                	addi	s0,sp,96
 11a:	8baa                	mv	s7,a0
 11c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11e:	892a                	mv	s2,a0
 120:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 122:	4aa9                	li	s5,10
 124:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 126:	89a6                	mv	s3,s1
 128:	2485                	addiw	s1,s1,1
 12a:	0344d863          	bge	s1,s4,15a <gets+0x56>
    cc = read(0, &c, 1);
 12e:	4605                	li	a2,1
 130:	faf40593          	addi	a1,s0,-81
 134:	4501                	li	a0,0
 136:	00000097          	auipc	ra,0x0
 13a:	1a0080e7          	jalr	416(ra) # 2d6 <read>
    if(cc < 1)
 13e:	00a05e63          	blez	a0,15a <gets+0x56>
    buf[i++] = c;
 142:	faf44783          	lbu	a5,-81(s0)
 146:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 14a:	01578763          	beq	a5,s5,158 <gets+0x54>
 14e:	0905                	addi	s2,s2,1
 150:	fd679be3          	bne	a5,s6,126 <gets+0x22>
  for(i=0; i+1 < max; ){
 154:	89a6                	mv	s3,s1
 156:	a011                	j	15a <gets+0x56>
 158:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 15a:	99de                	add	s3,s3,s7
 15c:	00098023          	sb	zero,0(s3)
  return buf;
}
 160:	855e                	mv	a0,s7
 162:	60e6                	ld	ra,88(sp)
 164:	6446                	ld	s0,80(sp)
 166:	64a6                	ld	s1,72(sp)
 168:	6906                	ld	s2,64(sp)
 16a:	79e2                	ld	s3,56(sp)
 16c:	7a42                	ld	s4,48(sp)
 16e:	7aa2                	ld	s5,40(sp)
 170:	7b02                	ld	s6,32(sp)
 172:	6be2                	ld	s7,24(sp)
 174:	6125                	addi	sp,sp,96
 176:	8082                	ret

0000000000000178 <stat>:

int
stat(const char *n, struct stat *st)
{
 178:	1101                	addi	sp,sp,-32
 17a:	ec06                	sd	ra,24(sp)
 17c:	e822                	sd	s0,16(sp)
 17e:	e426                	sd	s1,8(sp)
 180:	e04a                	sd	s2,0(sp)
 182:	1000                	addi	s0,sp,32
 184:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 186:	4581                	li	a1,0
 188:	00000097          	auipc	ra,0x0
 18c:	176080e7          	jalr	374(ra) # 2fe <open>
  if(fd < 0)
 190:	02054563          	bltz	a0,1ba <stat+0x42>
 194:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 196:	85ca                	mv	a1,s2
 198:	00000097          	auipc	ra,0x0
 19c:	17e080e7          	jalr	382(ra) # 316 <fstat>
 1a0:	892a                	mv	s2,a0
  close(fd);
 1a2:	8526                	mv	a0,s1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	142080e7          	jalr	322(ra) # 2e6 <close>
  return r;
}
 1ac:	854a                	mv	a0,s2
 1ae:	60e2                	ld	ra,24(sp)
 1b0:	6442                	ld	s0,16(sp)
 1b2:	64a2                	ld	s1,8(sp)
 1b4:	6902                	ld	s2,0(sp)
 1b6:	6105                	addi	sp,sp,32
 1b8:	8082                	ret
    return -1;
 1ba:	597d                	li	s2,-1
 1bc:	bfc5                	j	1ac <stat+0x34>

00000000000001be <atoi>:

int
atoi(const char *s)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1c4:	00054603          	lbu	a2,0(a0)
 1c8:	fd06079b          	addiw	a5,a2,-48
 1cc:	0ff7f793          	andi	a5,a5,255
 1d0:	4725                	li	a4,9
 1d2:	02f76963          	bltu	a4,a5,204 <atoi+0x46>
 1d6:	86aa                	mv	a3,a0
  n = 0;
 1d8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1da:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1dc:	0685                	addi	a3,a3,1
 1de:	0025179b          	slliw	a5,a0,0x2
 1e2:	9fa9                	addw	a5,a5,a0
 1e4:	0017979b          	slliw	a5,a5,0x1
 1e8:	9fb1                	addw	a5,a5,a2
 1ea:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ee:	0006c603          	lbu	a2,0(a3)
 1f2:	fd06071b          	addiw	a4,a2,-48
 1f6:	0ff77713          	andi	a4,a4,255
 1fa:	fee5f1e3          	bgeu	a1,a4,1dc <atoi+0x1e>
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  n = 0;
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <atoi+0x40>

0000000000000208 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 20e:	02b57663          	bgeu	a0,a1,23a <memmove+0x32>
    while(n-- > 0)
 212:	02c05163          	blez	a2,234 <memmove+0x2c>
 216:	fff6079b          	addiw	a5,a2,-1
 21a:	1782                	slli	a5,a5,0x20
 21c:	9381                	srli	a5,a5,0x20
 21e:	0785                	addi	a5,a5,1
 220:	97aa                	add	a5,a5,a0
  dst = vdst;
 222:	872a                	mv	a4,a0
      *dst++ = *src++;
 224:	0585                	addi	a1,a1,1
 226:	0705                	addi	a4,a4,1
 228:	fff5c683          	lbu	a3,-1(a1)
 22c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 230:	fee79ae3          	bne	a5,a4,224 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret
    dst += n;
 23a:	00c50733          	add	a4,a0,a2
    src += n;
 23e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 240:	fec05ae3          	blez	a2,234 <memmove+0x2c>
 244:	fff6079b          	addiw	a5,a2,-1
 248:	1782                	slli	a5,a5,0x20
 24a:	9381                	srli	a5,a5,0x20
 24c:	fff7c793          	not	a5,a5
 250:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 252:	15fd                	addi	a1,a1,-1
 254:	177d                	addi	a4,a4,-1
 256:	0005c683          	lbu	a3,0(a1)
 25a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 25e:	fee79ae3          	bne	a5,a4,252 <memmove+0x4a>
 262:	bfc9                	j	234 <memmove+0x2c>

0000000000000264 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 26a:	ca05                	beqz	a2,29a <memcmp+0x36>
 26c:	fff6069b          	addiw	a3,a2,-1
 270:	1682                	slli	a3,a3,0x20
 272:	9281                	srli	a3,a3,0x20
 274:	0685                	addi	a3,a3,1
 276:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 278:	00054783          	lbu	a5,0(a0)
 27c:	0005c703          	lbu	a4,0(a1)
 280:	00e79863          	bne	a5,a4,290 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 284:	0505                	addi	a0,a0,1
    p2++;
 286:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 288:	fed518e3          	bne	a0,a3,278 <memcmp+0x14>
  }
  return 0;
 28c:	4501                	li	a0,0
 28e:	a019                	j	294 <memcmp+0x30>
      return *p1 - *p2;
 290:	40e7853b          	subw	a0,a5,a4
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  return 0;
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <memcmp+0x30>

000000000000029e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e406                	sd	ra,8(sp)
 2a2:	e022                	sd	s0,0(sp)
 2a4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2a6:	00000097          	auipc	ra,0x0
 2aa:	f62080e7          	jalr	-158(ra) # 208 <memmove>
}
 2ae:	60a2                	ld	ra,8(sp)
 2b0:	6402                	ld	s0,0(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret

00000000000002b6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2b6:	4885                	li	a7,1
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <exit>:
.global exit
exit:
 li a7, SYS_exit
 2be:	4889                	li	a7,2
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2c6:	488d                	li	a7,3
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ce:	4891                	li	a7,4
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <read>:
.global read
read:
 li a7, SYS_read
 2d6:	4895                	li	a7,5
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <write>:
.global write
write:
 li a7, SYS_write
 2de:	48c1                	li	a7,16
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <close>:
.global close
close:
 li a7, SYS_close
 2e6:	48d5                	li	a7,21
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <kill>:
.global kill
kill:
 li a7, SYS_kill
 2ee:	4899                	li	a7,6
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2f6:	489d                	li	a7,7
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <open>:
.global open
open:
 li a7, SYS_open
 2fe:	48bd                	li	a7,15
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 306:	48c5                	li	a7,17
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 30e:	48c9                	li	a7,18
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 316:	48a1                	li	a7,8
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <link>:
.global link
link:
 li a7, SYS_link
 31e:	48cd                	li	a7,19
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 326:	48d1                	li	a7,20
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 32e:	48a5                	li	a7,9
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <dup>:
.global dup
dup:
 li a7, SYS_dup
 336:	48a9                	li	a7,10
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 33e:	48ad                	li	a7,11
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 346:	48b1                	li	a7,12
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 34e:	48b5                	li	a7,13
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 356:	48b9                	li	a7,14
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 35e:	48d9                	li	a7,22
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <yield>:
.global yield
yield:
 li a7, SYS_yield
 366:	48dd                	li	a7,23
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 36e:	48e1                	li	a7,24
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 376:	48e5                	li	a7,25
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 37e:	48e9                	li	a7,26
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <ps>:
.global ps
ps:
 li a7, SYS_ps
 386:	48ed                	li	a7,27
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 38e:	48f1                	li	a7,28
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 396:	1101                	addi	sp,sp,-32
 398:	ec06                	sd	ra,24(sp)
 39a:	e822                	sd	s0,16(sp)
 39c:	1000                	addi	s0,sp,32
 39e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a2:	4605                	li	a2,1
 3a4:	fef40593          	addi	a1,s0,-17
 3a8:	00000097          	auipc	ra,0x0
 3ac:	f36080e7          	jalr	-202(ra) # 2de <write>
}
 3b0:	60e2                	ld	ra,24(sp)
 3b2:	6442                	ld	s0,16(sp)
 3b4:	6105                	addi	sp,sp,32
 3b6:	8082                	ret

00000000000003b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b8:	7139                	addi	sp,sp,-64
 3ba:	fc06                	sd	ra,56(sp)
 3bc:	f822                	sd	s0,48(sp)
 3be:	f426                	sd	s1,40(sp)
 3c0:	f04a                	sd	s2,32(sp)
 3c2:	ec4e                	sd	s3,24(sp)
 3c4:	0080                	addi	s0,sp,64
 3c6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c8:	c299                	beqz	a3,3ce <printint+0x16>
 3ca:	0805c863          	bltz	a1,45a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ce:	2581                	sext.w	a1,a1
  neg = 0;
 3d0:	4881                	li	a7,0
 3d2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3d6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3d8:	2601                	sext.w	a2,a2
 3da:	00000517          	auipc	a0,0x0
 3de:	46650513          	addi	a0,a0,1126 # 840 <digits>
 3e2:	883a                	mv	a6,a4
 3e4:	2705                	addiw	a4,a4,1
 3e6:	02c5f7bb          	remuw	a5,a1,a2
 3ea:	1782                	slli	a5,a5,0x20
 3ec:	9381                	srli	a5,a5,0x20
 3ee:	97aa                	add	a5,a5,a0
 3f0:	0007c783          	lbu	a5,0(a5)
 3f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3f8:	0005879b          	sext.w	a5,a1
 3fc:	02c5d5bb          	divuw	a1,a1,a2
 400:	0685                	addi	a3,a3,1
 402:	fec7f0e3          	bgeu	a5,a2,3e2 <printint+0x2a>
  if(neg)
 406:	00088b63          	beqz	a7,41c <printint+0x64>
    buf[i++] = '-';
 40a:	fd040793          	addi	a5,s0,-48
 40e:	973e                	add	a4,a4,a5
 410:	02d00793          	li	a5,45
 414:	fef70823          	sb	a5,-16(a4)
 418:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 41c:	02e05863          	blez	a4,44c <printint+0x94>
 420:	fc040793          	addi	a5,s0,-64
 424:	00e78933          	add	s2,a5,a4
 428:	fff78993          	addi	s3,a5,-1
 42c:	99ba                	add	s3,s3,a4
 42e:	377d                	addiw	a4,a4,-1
 430:	1702                	slli	a4,a4,0x20
 432:	9301                	srli	a4,a4,0x20
 434:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 438:	fff94583          	lbu	a1,-1(s2)
 43c:	8526                	mv	a0,s1
 43e:	00000097          	auipc	ra,0x0
 442:	f58080e7          	jalr	-168(ra) # 396 <putc>
  while(--i >= 0)
 446:	197d                	addi	s2,s2,-1
 448:	ff3918e3          	bne	s2,s3,438 <printint+0x80>
}
 44c:	70e2                	ld	ra,56(sp)
 44e:	7442                	ld	s0,48(sp)
 450:	74a2                	ld	s1,40(sp)
 452:	7902                	ld	s2,32(sp)
 454:	69e2                	ld	s3,24(sp)
 456:	6121                	addi	sp,sp,64
 458:	8082                	ret
    x = -xx;
 45a:	40b005bb          	negw	a1,a1
    neg = 1;
 45e:	4885                	li	a7,1
    x = -xx;
 460:	bf8d                	j	3d2 <printint+0x1a>

0000000000000462 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 462:	7119                	addi	sp,sp,-128
 464:	fc86                	sd	ra,120(sp)
 466:	f8a2                	sd	s0,112(sp)
 468:	f4a6                	sd	s1,104(sp)
 46a:	f0ca                	sd	s2,96(sp)
 46c:	ecce                	sd	s3,88(sp)
 46e:	e8d2                	sd	s4,80(sp)
 470:	e4d6                	sd	s5,72(sp)
 472:	e0da                	sd	s6,64(sp)
 474:	fc5e                	sd	s7,56(sp)
 476:	f862                	sd	s8,48(sp)
 478:	f466                	sd	s9,40(sp)
 47a:	f06a                	sd	s10,32(sp)
 47c:	ec6e                	sd	s11,24(sp)
 47e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 480:	0005c903          	lbu	s2,0(a1)
 484:	18090f63          	beqz	s2,622 <vprintf+0x1c0>
 488:	8aaa                	mv	s5,a0
 48a:	8b32                	mv	s6,a2
 48c:	00158493          	addi	s1,a1,1
  state = 0;
 490:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 492:	02500a13          	li	s4,37
      if(c == 'd'){
 496:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 49a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 49e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4a2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4a6:	00000b97          	auipc	s7,0x0
 4aa:	39ab8b93          	addi	s7,s7,922 # 840 <digits>
 4ae:	a839                	j	4cc <vprintf+0x6a>
        putc(fd, c);
 4b0:	85ca                	mv	a1,s2
 4b2:	8556                	mv	a0,s5
 4b4:	00000097          	auipc	ra,0x0
 4b8:	ee2080e7          	jalr	-286(ra) # 396 <putc>
 4bc:	a019                	j	4c2 <vprintf+0x60>
    } else if(state == '%'){
 4be:	01498f63          	beq	s3,s4,4dc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4c2:	0485                	addi	s1,s1,1
 4c4:	fff4c903          	lbu	s2,-1(s1)
 4c8:	14090d63          	beqz	s2,622 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4cc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4d0:	fe0997e3          	bnez	s3,4be <vprintf+0x5c>
      if(c == '%'){
 4d4:	fd479ee3          	bne	a5,s4,4b0 <vprintf+0x4e>
        state = '%';
 4d8:	89be                	mv	s3,a5
 4da:	b7e5                	j	4c2 <vprintf+0x60>
      if(c == 'd'){
 4dc:	05878063          	beq	a5,s8,51c <vprintf+0xba>
      } else if(c == 'l') {
 4e0:	05978c63          	beq	a5,s9,538 <vprintf+0xd6>
      } else if(c == 'x') {
 4e4:	07a78863          	beq	a5,s10,554 <vprintf+0xf2>
      } else if(c == 'p') {
 4e8:	09b78463          	beq	a5,s11,570 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4ec:	07300713          	li	a4,115
 4f0:	0ce78663          	beq	a5,a4,5bc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4f4:	06300713          	li	a4,99
 4f8:	0ee78e63          	beq	a5,a4,5f4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4fc:	11478863          	beq	a5,s4,60c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 500:	85d2                	mv	a1,s4
 502:	8556                	mv	a0,s5
 504:	00000097          	auipc	ra,0x0
 508:	e92080e7          	jalr	-366(ra) # 396 <putc>
        putc(fd, c);
 50c:	85ca                	mv	a1,s2
 50e:	8556                	mv	a0,s5
 510:	00000097          	auipc	ra,0x0
 514:	e86080e7          	jalr	-378(ra) # 396 <putc>
      }
      state = 0;
 518:	4981                	li	s3,0
 51a:	b765                	j	4c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 51c:	008b0913          	addi	s2,s6,8
 520:	4685                	li	a3,1
 522:	4629                	li	a2,10
 524:	000b2583          	lw	a1,0(s6)
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	e8e080e7          	jalr	-370(ra) # 3b8 <printint>
 532:	8b4a                	mv	s6,s2
      state = 0;
 534:	4981                	li	s3,0
 536:	b771                	j	4c2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 538:	008b0913          	addi	s2,s6,8
 53c:	4681                	li	a3,0
 53e:	4629                	li	a2,10
 540:	000b2583          	lw	a1,0(s6)
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	e72080e7          	jalr	-398(ra) # 3b8 <printint>
 54e:	8b4a                	mv	s6,s2
      state = 0;
 550:	4981                	li	s3,0
 552:	bf85                	j	4c2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 554:	008b0913          	addi	s2,s6,8
 558:	4681                	li	a3,0
 55a:	4641                	li	a2,16
 55c:	000b2583          	lw	a1,0(s6)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e56080e7          	jalr	-426(ra) # 3b8 <printint>
 56a:	8b4a                	mv	s6,s2
      state = 0;
 56c:	4981                	li	s3,0
 56e:	bf91                	j	4c2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 570:	008b0793          	addi	a5,s6,8
 574:	f8f43423          	sd	a5,-120(s0)
 578:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 57c:	03000593          	li	a1,48
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	e14080e7          	jalr	-492(ra) # 396 <putc>
  putc(fd, 'x');
 58a:	85ea                	mv	a1,s10
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	e08080e7          	jalr	-504(ra) # 396 <putc>
 596:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 598:	03c9d793          	srli	a5,s3,0x3c
 59c:	97de                	add	a5,a5,s7
 59e:	0007c583          	lbu	a1,0(a5)
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	df2080e7          	jalr	-526(ra) # 396 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5ac:	0992                	slli	s3,s3,0x4
 5ae:	397d                	addiw	s2,s2,-1
 5b0:	fe0914e3          	bnez	s2,598 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5b4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	b721                	j	4c2 <vprintf+0x60>
        s = va_arg(ap, char*);
 5bc:	008b0993          	addi	s3,s6,8
 5c0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5c4:	02090163          	beqz	s2,5e6 <vprintf+0x184>
        while(*s != 0){
 5c8:	00094583          	lbu	a1,0(s2)
 5cc:	c9a1                	beqz	a1,61c <vprintf+0x1ba>
          putc(fd, *s);
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	dc6080e7          	jalr	-570(ra) # 396 <putc>
          s++;
 5d8:	0905                	addi	s2,s2,1
        while(*s != 0){
 5da:	00094583          	lbu	a1,0(s2)
 5de:	f9e5                	bnez	a1,5ce <vprintf+0x16c>
        s = va_arg(ap, char*);
 5e0:	8b4e                	mv	s6,s3
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	bdf9                	j	4c2 <vprintf+0x60>
          s = "(null)";
 5e6:	00000917          	auipc	s2,0x0
 5ea:	25290913          	addi	s2,s2,594 # 838 <malloc+0x10c>
        while(*s != 0){
 5ee:	02800593          	li	a1,40
 5f2:	bff1                	j	5ce <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5f4:	008b0913          	addi	s2,s6,8
 5f8:	000b4583          	lbu	a1,0(s6)
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	d98080e7          	jalr	-616(ra) # 396 <putc>
 606:	8b4a                	mv	s6,s2
      state = 0;
 608:	4981                	li	s3,0
 60a:	bd65                	j	4c2 <vprintf+0x60>
        putc(fd, c);
 60c:	85d2                	mv	a1,s4
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	d86080e7          	jalr	-634(ra) # 396 <putc>
      state = 0;
 618:	4981                	li	s3,0
 61a:	b565                	j	4c2 <vprintf+0x60>
        s = va_arg(ap, char*);
 61c:	8b4e                	mv	s6,s3
      state = 0;
 61e:	4981                	li	s3,0
 620:	b54d                	j	4c2 <vprintf+0x60>
    }
  }
}
 622:	70e6                	ld	ra,120(sp)
 624:	7446                	ld	s0,112(sp)
 626:	74a6                	ld	s1,104(sp)
 628:	7906                	ld	s2,96(sp)
 62a:	69e6                	ld	s3,88(sp)
 62c:	6a46                	ld	s4,80(sp)
 62e:	6aa6                	ld	s5,72(sp)
 630:	6b06                	ld	s6,64(sp)
 632:	7be2                	ld	s7,56(sp)
 634:	7c42                	ld	s8,48(sp)
 636:	7ca2                	ld	s9,40(sp)
 638:	7d02                	ld	s10,32(sp)
 63a:	6de2                	ld	s11,24(sp)
 63c:	6109                	addi	sp,sp,128
 63e:	8082                	ret

0000000000000640 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 640:	715d                	addi	sp,sp,-80
 642:	ec06                	sd	ra,24(sp)
 644:	e822                	sd	s0,16(sp)
 646:	1000                	addi	s0,sp,32
 648:	e010                	sd	a2,0(s0)
 64a:	e414                	sd	a3,8(s0)
 64c:	e818                	sd	a4,16(s0)
 64e:	ec1c                	sd	a5,24(s0)
 650:	03043023          	sd	a6,32(s0)
 654:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 658:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 65c:	8622                	mv	a2,s0
 65e:	00000097          	auipc	ra,0x0
 662:	e04080e7          	jalr	-508(ra) # 462 <vprintf>
}
 666:	60e2                	ld	ra,24(sp)
 668:	6442                	ld	s0,16(sp)
 66a:	6161                	addi	sp,sp,80
 66c:	8082                	ret

000000000000066e <printf>:

void
printf(const char *fmt, ...)
{
 66e:	711d                	addi	sp,sp,-96
 670:	ec06                	sd	ra,24(sp)
 672:	e822                	sd	s0,16(sp)
 674:	1000                	addi	s0,sp,32
 676:	e40c                	sd	a1,8(s0)
 678:	e810                	sd	a2,16(s0)
 67a:	ec14                	sd	a3,24(s0)
 67c:	f018                	sd	a4,32(s0)
 67e:	f41c                	sd	a5,40(s0)
 680:	03043823          	sd	a6,48(s0)
 684:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 688:	00840613          	addi	a2,s0,8
 68c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 690:	85aa                	mv	a1,a0
 692:	4505                	li	a0,1
 694:	00000097          	auipc	ra,0x0
 698:	dce080e7          	jalr	-562(ra) # 462 <vprintf>
}
 69c:	60e2                	ld	ra,24(sp)
 69e:	6442                	ld	s0,16(sp)
 6a0:	6125                	addi	sp,sp,96
 6a2:	8082                	ret

00000000000006a4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a4:	1141                	addi	sp,sp,-16
 6a6:	e422                	sd	s0,8(sp)
 6a8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6aa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ae:	00000797          	auipc	a5,0x0
 6b2:	1aa7b783          	ld	a5,426(a5) # 858 <freep>
 6b6:	a805                	j	6e6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6b8:	4618                	lw	a4,8(a2)
 6ba:	9db9                	addw	a1,a1,a4
 6bc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c0:	6398                	ld	a4,0(a5)
 6c2:	6318                	ld	a4,0(a4)
 6c4:	fee53823          	sd	a4,-16(a0)
 6c8:	a091                	j	70c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ca:	ff852703          	lw	a4,-8(a0)
 6ce:	9e39                	addw	a2,a2,a4
 6d0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6d2:	ff053703          	ld	a4,-16(a0)
 6d6:	e398                	sd	a4,0(a5)
 6d8:	a099                	j	71e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6da:	6398                	ld	a4,0(a5)
 6dc:	00e7e463          	bltu	a5,a4,6e4 <free+0x40>
 6e0:	00e6ea63          	bltu	a3,a4,6f4 <free+0x50>
{
 6e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e6:	fed7fae3          	bgeu	a5,a3,6da <free+0x36>
 6ea:	6398                	ld	a4,0(a5)
 6ec:	00e6e463          	bltu	a3,a4,6f4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f0:	fee7eae3          	bltu	a5,a4,6e4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6f4:	ff852583          	lw	a1,-8(a0)
 6f8:	6390                	ld	a2,0(a5)
 6fa:	02059713          	slli	a4,a1,0x20
 6fe:	9301                	srli	a4,a4,0x20
 700:	0712                	slli	a4,a4,0x4
 702:	9736                	add	a4,a4,a3
 704:	fae60ae3          	beq	a2,a4,6b8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 708:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 70c:	4790                	lw	a2,8(a5)
 70e:	02061713          	slli	a4,a2,0x20
 712:	9301                	srli	a4,a4,0x20
 714:	0712                	slli	a4,a4,0x4
 716:	973e                	add	a4,a4,a5
 718:	fae689e3          	beq	a3,a4,6ca <free+0x26>
  } else
    p->s.ptr = bp;
 71c:	e394                	sd	a3,0(a5)
  freep = p;
 71e:	00000717          	auipc	a4,0x0
 722:	12f73d23          	sd	a5,314(a4) # 858 <freep>
}
 726:	6422                	ld	s0,8(sp)
 728:	0141                	addi	sp,sp,16
 72a:	8082                	ret

000000000000072c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 72c:	7139                	addi	sp,sp,-64
 72e:	fc06                	sd	ra,56(sp)
 730:	f822                	sd	s0,48(sp)
 732:	f426                	sd	s1,40(sp)
 734:	f04a                	sd	s2,32(sp)
 736:	ec4e                	sd	s3,24(sp)
 738:	e852                	sd	s4,16(sp)
 73a:	e456                	sd	s5,8(sp)
 73c:	e05a                	sd	s6,0(sp)
 73e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 740:	02051493          	slli	s1,a0,0x20
 744:	9081                	srli	s1,s1,0x20
 746:	04bd                	addi	s1,s1,15
 748:	8091                	srli	s1,s1,0x4
 74a:	0014899b          	addiw	s3,s1,1
 74e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 750:	00000517          	auipc	a0,0x0
 754:	10853503          	ld	a0,264(a0) # 858 <freep>
 758:	c515                	beqz	a0,784 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 75a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 75c:	4798                	lw	a4,8(a5)
 75e:	02977f63          	bgeu	a4,s1,79c <malloc+0x70>
 762:	8a4e                	mv	s4,s3
 764:	0009871b          	sext.w	a4,s3
 768:	6685                	lui	a3,0x1
 76a:	00d77363          	bgeu	a4,a3,770 <malloc+0x44>
 76e:	6a05                	lui	s4,0x1
 770:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 774:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 778:	00000917          	auipc	s2,0x0
 77c:	0e090913          	addi	s2,s2,224 # 858 <freep>
  if(p == (char*)-1)
 780:	5afd                	li	s5,-1
 782:	a88d                	j	7f4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 784:	00000797          	auipc	a5,0x0
 788:	0dc78793          	addi	a5,a5,220 # 860 <base>
 78c:	00000717          	auipc	a4,0x0
 790:	0cf73623          	sd	a5,204(a4) # 858 <freep>
 794:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 796:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 79a:	b7e1                	j	762 <malloc+0x36>
      if(p->s.size == nunits)
 79c:	02e48b63          	beq	s1,a4,7d2 <malloc+0xa6>
        p->s.size -= nunits;
 7a0:	4137073b          	subw	a4,a4,s3
 7a4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7a6:	1702                	slli	a4,a4,0x20
 7a8:	9301                	srli	a4,a4,0x20
 7aa:	0712                	slli	a4,a4,0x4
 7ac:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7ae:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7b2:	00000717          	auipc	a4,0x0
 7b6:	0aa73323          	sd	a0,166(a4) # 858 <freep>
      return (void*)(p + 1);
 7ba:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7be:	70e2                	ld	ra,56(sp)
 7c0:	7442                	ld	s0,48(sp)
 7c2:	74a2                	ld	s1,40(sp)
 7c4:	7902                	ld	s2,32(sp)
 7c6:	69e2                	ld	s3,24(sp)
 7c8:	6a42                	ld	s4,16(sp)
 7ca:	6aa2                	ld	s5,8(sp)
 7cc:	6b02                	ld	s6,0(sp)
 7ce:	6121                	addi	sp,sp,64
 7d0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7d2:	6398                	ld	a4,0(a5)
 7d4:	e118                	sd	a4,0(a0)
 7d6:	bff1                	j	7b2 <malloc+0x86>
  hp->s.size = nu;
 7d8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7dc:	0541                	addi	a0,a0,16
 7de:	00000097          	auipc	ra,0x0
 7e2:	ec6080e7          	jalr	-314(ra) # 6a4 <free>
  return freep;
 7e6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ea:	d971                	beqz	a0,7be <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ee:	4798                	lw	a4,8(a5)
 7f0:	fa9776e3          	bgeu	a4,s1,79c <malloc+0x70>
    if(p == freep)
 7f4:	00093703          	ld	a4,0(s2)
 7f8:	853e                	mv	a0,a5
 7fa:	fef719e3          	bne	a4,a5,7ec <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7fe:	8552                	mv	a0,s4
 800:	00000097          	auipc	ra,0x0
 804:	b46080e7          	jalr	-1210(ra) # 346 <sbrk>
  if(p == (char*)-1)
 808:	fd5518e3          	bne	a0,s5,7d8 <malloc+0xac>
        return 0;
 80c:	4501                	li	a0,0
 80e:	bf45                	j	7be <malloc+0x92>
