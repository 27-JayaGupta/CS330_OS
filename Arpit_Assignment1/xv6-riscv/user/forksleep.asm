
user/_forksleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


int main(int argc, char * argv[]){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32

    if(argc!=3){
   c:	478d                	li	a5,3
   e:	02f50063          	beq	a0,a5,2e <main+0x2e>
        fprintf(2,"usage: forksleep <int> <int>\n");
  12:	00001597          	auipc	a1,0x1
  16:	91658593          	addi	a1,a1,-1770 # 928 <malloc+0xe4>
  1a:	4509                	li	a0,2
  1c:	00000097          	auipc	ra,0x0
  20:	73c080e7          	jalr	1852(ra) # 758 <fprintf>
        exit(1);
  24:	4505                	li	a0,1
  26:	00000097          	auipc	ra,0x0
  2a:	3b0080e7          	jalr	944(ra) # 3d6 <exit>
  2e:	84ae                	mv	s1,a1
    }
    int m = atoi(argv[1]);
  30:	6588                	ld	a0,8(a1)
  32:	00000097          	auipc	ra,0x0
  36:	2a4080e7          	jalr	676(ra) # 2d6 <atoi>
  3a:	892a                	mv	s2,a0
    int n = atoi(argv[2]);
  3c:	6888                	ld	a0,16(s1)
  3e:	00000097          	auipc	ra,0x0
  42:	298080e7          	jalr	664(ra) # 2d6 <atoi>
  46:	84aa                	mv	s1,a0
    if(m<0){
  48:	02094563          	bltz	s2,72 <main+0x72>
        fprintf(2,"Error: first argument should be positive. Aborting...\n");
        exit(1);
    }
    if(n!=0&&n!=1){
  4c:	0005079b          	sext.w	a5,a0
  50:	4705                	li	a4,1
  52:	02f77e63          	bgeu	a4,a5,8e <main+0x8e>
        fprintf(2,"Error: second argument can only be 0 or 1. Aborting...\n");
  56:	00001597          	auipc	a1,0x1
  5a:	92a58593          	addi	a1,a1,-1750 # 980 <malloc+0x13c>
  5e:	4509                	li	a0,2
  60:	00000097          	auipc	ra,0x0
  64:	6f8080e7          	jalr	1784(ra) # 758 <fprintf>
        exit(1);
  68:	4505                	li	a0,1
  6a:	00000097          	auipc	ra,0x0
  6e:	36c080e7          	jalr	876(ra) # 3d6 <exit>
        fprintf(2,"Error: first argument should be positive. Aborting...\n");
  72:	00001597          	auipc	a1,0x1
  76:	8d658593          	addi	a1,a1,-1834 # 948 <malloc+0x104>
  7a:	4509                	li	a0,2
  7c:	00000097          	auipc	ra,0x0
  80:	6dc080e7          	jalr	1756(ra) # 758 <fprintf>
        exit(1);
  84:	4505                	li	a0,1
  86:	00000097          	auipc	ra,0x0
  8a:	350080e7          	jalr	848(ra) # 3d6 <exit>
    }
    int f = fork();
  8e:	00000097          	auipc	ra,0x0
  92:	340080e7          	jalr	832(ra) # 3ce <fork>
    if(f<0){
  96:	02054663          	bltz	a0,c2 <main+0xc2>
        fprintf(2,"Error in fork. Aborting...\n");
        exit(1);
    }else if(f==0){
  9a:	e92d                	bnez	a0,10c <main+0x10c>
        if(n==0){
  9c:	c0a9                	beqz	s1,de <main+0xde>
            sleep(m);
            printf("%d: Child\n",getpid());
            exit(0);
        }else if(n==1){
            printf("%d: Child\n",getpid());
  9e:	00000097          	auipc	ra,0x0
  a2:	3b8080e7          	jalr	952(ra) # 456 <getpid>
  a6:	85aa                	mv	a1,a0
  a8:	00001517          	auipc	a0,0x1
  ac:	93050513          	addi	a0,a0,-1744 # 9d8 <malloc+0x194>
  b0:	00000097          	auipc	ra,0x0
  b4:	6d6080e7          	jalr	1750(ra) # 786 <printf>
            exit(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	31c080e7          	jalr	796(ra) # 3d6 <exit>
        fprintf(2,"Error in fork. Aborting...\n");
  c2:	00001597          	auipc	a1,0x1
  c6:	8f658593          	addi	a1,a1,-1802 # 9b8 <malloc+0x174>
  ca:	4509                	li	a0,2
  cc:	00000097          	auipc	ra,0x0
  d0:	68c080e7          	jalr	1676(ra) # 758 <fprintf>
        exit(1);
  d4:	4505                	li	a0,1
  d6:	00000097          	auipc	ra,0x0
  da:	300080e7          	jalr	768(ra) # 3d6 <exit>
            sleep(m);
  de:	854a                	mv	a0,s2
  e0:	00000097          	auipc	ra,0x0
  e4:	386080e7          	jalr	902(ra) # 466 <sleep>
            printf("%d: Child\n",getpid());
  e8:	00000097          	auipc	ra,0x0
  ec:	36e080e7          	jalr	878(ra) # 456 <getpid>
  f0:	85aa                	mv	a1,a0
  f2:	00001517          	auipc	a0,0x1
  f6:	8e650513          	addi	a0,a0,-1818 # 9d8 <malloc+0x194>
  fa:	00000097          	auipc	ra,0x0
  fe:	68c080e7          	jalr	1676(ra) # 786 <printf>
            exit(0);
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	2d2080e7          	jalr	722(ra) # 3d6 <exit>
        }
    }else{
        if(n==0){
 10c:	c885                	beqz	s1,13c <main+0x13c>
            printf("%d: Parent\n",getpid());
            exit(0);
        }else if(n==1){
            sleep(m);
 10e:	854a                	mv	a0,s2
 110:	00000097          	auipc	ra,0x0
 114:	356080e7          	jalr	854(ra) # 466 <sleep>
            printf("%d: Parent\n",getpid());
 118:	00000097          	auipc	ra,0x0
 11c:	33e080e7          	jalr	830(ra) # 456 <getpid>
 120:	85aa                	mv	a1,a0
 122:	00001517          	auipc	a0,0x1
 126:	8c650513          	addi	a0,a0,-1850 # 9e8 <malloc+0x1a4>
 12a:	00000097          	auipc	ra,0x0
 12e:	65c080e7          	jalr	1628(ra) # 786 <printf>
            exit(0);
 132:	4501                	li	a0,0
 134:	00000097          	auipc	ra,0x0
 138:	2a2080e7          	jalr	674(ra) # 3d6 <exit>
            printf("%d: Parent\n",getpid());
 13c:	00000097          	auipc	ra,0x0
 140:	31a080e7          	jalr	794(ra) # 456 <getpid>
 144:	85aa                	mv	a1,a0
 146:	00001517          	auipc	a0,0x1
 14a:	8a250513          	addi	a0,a0,-1886 # 9e8 <malloc+0x1a4>
 14e:	00000097          	auipc	ra,0x0
 152:	638080e7          	jalr	1592(ra) # 786 <printf>
            exit(0);
 156:	4501                	li	a0,0
 158:	00000097          	auipc	ra,0x0
 15c:	27e080e7          	jalr	638(ra) # 3d6 <exit>

0000000000000160 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 166:	87aa                	mv	a5,a0
 168:	0585                	addi	a1,a1,1
 16a:	0785                	addi	a5,a5,1
 16c:	fff5c703          	lbu	a4,-1(a1)
 170:	fee78fa3          	sb	a4,-1(a5)
 174:	fb75                	bnez	a4,168 <strcpy+0x8>
    ;
  return os;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret

000000000000017c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17c:	1141                	addi	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb91                	beqz	a5,19a <strcmp+0x1e>
 188:	0005c703          	lbu	a4,0(a1)
 18c:	00f71763          	bne	a4,a5,19a <strcmp+0x1e>
    p++, q++;
 190:	0505                	addi	a0,a0,1
 192:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 194:	00054783          	lbu	a5,0(a0)
 198:	fbe5                	bnez	a5,188 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 19a:	0005c503          	lbu	a0,0(a1)
}
 19e:	40a7853b          	subw	a0,a5,a0
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret

00000000000001a8 <strlen>:

uint
strlen(const char *s)
{
 1a8:	1141                	addi	sp,sp,-16
 1aa:	e422                	sd	s0,8(sp)
 1ac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	cf91                	beqz	a5,1ce <strlen+0x26>
 1b4:	0505                	addi	a0,a0,1
 1b6:	87aa                	mv	a5,a0
 1b8:	4685                	li	a3,1
 1ba:	9e89                	subw	a3,a3,a0
 1bc:	00f6853b          	addw	a0,a3,a5
 1c0:	0785                	addi	a5,a5,1
 1c2:	fff7c703          	lbu	a4,-1(a5)
 1c6:	fb7d                	bnez	a4,1bc <strlen+0x14>
    ;
  return n;
}
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret
  for(n = 0; s[n]; n++)
 1ce:	4501                	li	a0,0
 1d0:	bfe5                	j	1c8 <strlen+0x20>

00000000000001d2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e422                	sd	s0,8(sp)
 1d6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1d8:	ce09                	beqz	a2,1f2 <memset+0x20>
 1da:	87aa                	mv	a5,a0
 1dc:	fff6071b          	addiw	a4,a2,-1
 1e0:	1702                	slli	a4,a4,0x20
 1e2:	9301                	srli	a4,a4,0x20
 1e4:	0705                	addi	a4,a4,1
 1e6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ec:	0785                	addi	a5,a5,1
 1ee:	fee79de3          	bne	a5,a4,1e8 <memset+0x16>
  }
  return dst;
}
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret

00000000000001f8 <strchr>:

char*
strchr(const char *s, char c)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1fe:	00054783          	lbu	a5,0(a0)
 202:	cb99                	beqz	a5,218 <strchr+0x20>
    if(*s == c)
 204:	00f58763          	beq	a1,a5,212 <strchr+0x1a>
  for(; *s; s++)
 208:	0505                	addi	a0,a0,1
 20a:	00054783          	lbu	a5,0(a0)
 20e:	fbfd                	bnez	a5,204 <strchr+0xc>
      return (char*)s;
  return 0;
 210:	4501                	li	a0,0
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret
  return 0;
 218:	4501                	li	a0,0
 21a:	bfe5                	j	212 <strchr+0x1a>

000000000000021c <gets>:

char*
gets(char *buf, int max)
{
 21c:	711d                	addi	sp,sp,-96
 21e:	ec86                	sd	ra,88(sp)
 220:	e8a2                	sd	s0,80(sp)
 222:	e4a6                	sd	s1,72(sp)
 224:	e0ca                	sd	s2,64(sp)
 226:	fc4e                	sd	s3,56(sp)
 228:	f852                	sd	s4,48(sp)
 22a:	f456                	sd	s5,40(sp)
 22c:	f05a                	sd	s6,32(sp)
 22e:	ec5e                	sd	s7,24(sp)
 230:	1080                	addi	s0,sp,96
 232:	8baa                	mv	s7,a0
 234:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 236:	892a                	mv	s2,a0
 238:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 23a:	4aa9                	li	s5,10
 23c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 23e:	89a6                	mv	s3,s1
 240:	2485                	addiw	s1,s1,1
 242:	0344d863          	bge	s1,s4,272 <gets+0x56>
    cc = read(0, &c, 1);
 246:	4605                	li	a2,1
 248:	faf40593          	addi	a1,s0,-81
 24c:	4501                	li	a0,0
 24e:	00000097          	auipc	ra,0x0
 252:	1a0080e7          	jalr	416(ra) # 3ee <read>
    if(cc < 1)
 256:	00a05e63          	blez	a0,272 <gets+0x56>
    buf[i++] = c;
 25a:	faf44783          	lbu	a5,-81(s0)
 25e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 262:	01578763          	beq	a5,s5,270 <gets+0x54>
 266:	0905                	addi	s2,s2,1
 268:	fd679be3          	bne	a5,s6,23e <gets+0x22>
  for(i=0; i+1 < max; ){
 26c:	89a6                	mv	s3,s1
 26e:	a011                	j	272 <gets+0x56>
 270:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 272:	99de                	add	s3,s3,s7
 274:	00098023          	sb	zero,0(s3)
  return buf;
}
 278:	855e                	mv	a0,s7
 27a:	60e6                	ld	ra,88(sp)
 27c:	6446                	ld	s0,80(sp)
 27e:	64a6                	ld	s1,72(sp)
 280:	6906                	ld	s2,64(sp)
 282:	79e2                	ld	s3,56(sp)
 284:	7a42                	ld	s4,48(sp)
 286:	7aa2                	ld	s5,40(sp)
 288:	7b02                	ld	s6,32(sp)
 28a:	6be2                	ld	s7,24(sp)
 28c:	6125                	addi	sp,sp,96
 28e:	8082                	ret

0000000000000290 <stat>:

int
stat(const char *n, struct stat *st)
{
 290:	1101                	addi	sp,sp,-32
 292:	ec06                	sd	ra,24(sp)
 294:	e822                	sd	s0,16(sp)
 296:	e426                	sd	s1,8(sp)
 298:	e04a                	sd	s2,0(sp)
 29a:	1000                	addi	s0,sp,32
 29c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29e:	4581                	li	a1,0
 2a0:	00000097          	auipc	ra,0x0
 2a4:	176080e7          	jalr	374(ra) # 416 <open>
  if(fd < 0)
 2a8:	02054563          	bltz	a0,2d2 <stat+0x42>
 2ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ae:	85ca                	mv	a1,s2
 2b0:	00000097          	auipc	ra,0x0
 2b4:	17e080e7          	jalr	382(ra) # 42e <fstat>
 2b8:	892a                	mv	s2,a0
  close(fd);
 2ba:	8526                	mv	a0,s1
 2bc:	00000097          	auipc	ra,0x0
 2c0:	142080e7          	jalr	322(ra) # 3fe <close>
  return r;
}
 2c4:	854a                	mv	a0,s2
 2c6:	60e2                	ld	ra,24(sp)
 2c8:	6442                	ld	s0,16(sp)
 2ca:	64a2                	ld	s1,8(sp)
 2cc:	6902                	ld	s2,0(sp)
 2ce:	6105                	addi	sp,sp,32
 2d0:	8082                	ret
    return -1;
 2d2:	597d                	li	s2,-1
 2d4:	bfc5                	j	2c4 <stat+0x34>

00000000000002d6 <atoi>:

int
atoi(const char *s)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2dc:	00054603          	lbu	a2,0(a0)
 2e0:	fd06079b          	addiw	a5,a2,-48
 2e4:	0ff7f793          	andi	a5,a5,255
 2e8:	4725                	li	a4,9
 2ea:	02f76963          	bltu	a4,a5,31c <atoi+0x46>
 2ee:	86aa                	mv	a3,a0
  n = 0;
 2f0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2f2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2f4:	0685                	addi	a3,a3,1
 2f6:	0025179b          	slliw	a5,a0,0x2
 2fa:	9fa9                	addw	a5,a5,a0
 2fc:	0017979b          	slliw	a5,a5,0x1
 300:	9fb1                	addw	a5,a5,a2
 302:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 306:	0006c603          	lbu	a2,0(a3)
 30a:	fd06071b          	addiw	a4,a2,-48
 30e:	0ff77713          	andi	a4,a4,255
 312:	fee5f1e3          	bgeu	a1,a4,2f4 <atoi+0x1e>
  return n;
}
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret
  n = 0;
 31c:	4501                	li	a0,0
 31e:	bfe5                	j	316 <atoi+0x40>

0000000000000320 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e422                	sd	s0,8(sp)
 324:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 326:	02b57663          	bgeu	a0,a1,352 <memmove+0x32>
    while(n-- > 0)
 32a:	02c05163          	blez	a2,34c <memmove+0x2c>
 32e:	fff6079b          	addiw	a5,a2,-1
 332:	1782                	slli	a5,a5,0x20
 334:	9381                	srli	a5,a5,0x20
 336:	0785                	addi	a5,a5,1
 338:	97aa                	add	a5,a5,a0
  dst = vdst;
 33a:	872a                	mv	a4,a0
      *dst++ = *src++;
 33c:	0585                	addi	a1,a1,1
 33e:	0705                	addi	a4,a4,1
 340:	fff5c683          	lbu	a3,-1(a1)
 344:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 348:	fee79ae3          	bne	a5,a4,33c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 34c:	6422                	ld	s0,8(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
    dst += n;
 352:	00c50733          	add	a4,a0,a2
    src += n;
 356:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 358:	fec05ae3          	blez	a2,34c <memmove+0x2c>
 35c:	fff6079b          	addiw	a5,a2,-1
 360:	1782                	slli	a5,a5,0x20
 362:	9381                	srli	a5,a5,0x20
 364:	fff7c793          	not	a5,a5
 368:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 36a:	15fd                	addi	a1,a1,-1
 36c:	177d                	addi	a4,a4,-1
 36e:	0005c683          	lbu	a3,0(a1)
 372:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 376:	fee79ae3          	bne	a5,a4,36a <memmove+0x4a>
 37a:	bfc9                	j	34c <memmove+0x2c>

000000000000037c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e422                	sd	s0,8(sp)
 380:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 382:	ca05                	beqz	a2,3b2 <memcmp+0x36>
 384:	fff6069b          	addiw	a3,a2,-1
 388:	1682                	slli	a3,a3,0x20
 38a:	9281                	srli	a3,a3,0x20
 38c:	0685                	addi	a3,a3,1
 38e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 390:	00054783          	lbu	a5,0(a0)
 394:	0005c703          	lbu	a4,0(a1)
 398:	00e79863          	bne	a5,a4,3a8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 39c:	0505                	addi	a0,a0,1
    p2++;
 39e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a0:	fed518e3          	bne	a0,a3,390 <memcmp+0x14>
  }
  return 0;
 3a4:	4501                	li	a0,0
 3a6:	a019                	j	3ac <memcmp+0x30>
      return *p1 - *p2;
 3a8:	40e7853b          	subw	a0,a5,a4
}
 3ac:	6422                	ld	s0,8(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret
  return 0;
 3b2:	4501                	li	a0,0
 3b4:	bfe5                	j	3ac <memcmp+0x30>

00000000000003b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e406                	sd	ra,8(sp)
 3ba:	e022                	sd	s0,0(sp)
 3bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3be:	00000097          	auipc	ra,0x0
 3c2:	f62080e7          	jalr	-158(ra) # 320 <memmove>
}
 3c6:	60a2                	ld	ra,8(sp)
 3c8:	6402                	ld	s0,0(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret

00000000000003ce <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ce:	4885                	li	a7,1
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d6:	4889                	li	a7,2
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <wait>:
.global wait
wait:
 li a7, SYS_wait
 3de:	488d                	li	a7,3
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e6:	4891                	li	a7,4
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <read>:
.global read
read:
 li a7, SYS_read
 3ee:	4895                	li	a7,5
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <write>:
.global write
write:
 li a7, SYS_write
 3f6:	48c1                	li	a7,16
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <close>:
.global close
close:
 li a7, SYS_close
 3fe:	48d5                	li	a7,21
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <kill>:
.global kill
kill:
 li a7, SYS_kill
 406:	4899                	li	a7,6
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <exec>:
.global exec
exec:
 li a7, SYS_exec
 40e:	489d                	li	a7,7
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <open>:
.global open
open:
 li a7, SYS_open
 416:	48bd                	li	a7,15
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 41e:	48c5                	li	a7,17
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 426:	48c9                	li	a7,18
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 42e:	48a1                	li	a7,8
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <link>:
.global link
link:
 li a7, SYS_link
 436:	48cd                	li	a7,19
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 43e:	48d1                	li	a7,20
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 446:	48a5                	li	a7,9
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <dup>:
.global dup
dup:
 li a7, SYS_dup
 44e:	48a9                	li	a7,10
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 456:	48ad                	li	a7,11
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 45e:	48b1                	li	a7,12
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 466:	48b5                	li	a7,13
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 46e:	48b9                	li	a7,14
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 476:	48d9                	li	a7,22
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <yield>:
.global yield
yield:
 li a7, SYS_yield
 47e:	48dd                	li	a7,23
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 486:	48e1                	li	a7,24
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 48e:	48e5                	li	a7,25
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 496:	48e9                	li	a7,26
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <ps>:
.global ps
ps:
 li a7, SYS_ps
 49e:	48ed                	li	a7,27
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 4a6:	48f1                	li	a7,28
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ae:	1101                	addi	sp,sp,-32
 4b0:	ec06                	sd	ra,24(sp)
 4b2:	e822                	sd	s0,16(sp)
 4b4:	1000                	addi	s0,sp,32
 4b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ba:	4605                	li	a2,1
 4bc:	fef40593          	addi	a1,s0,-17
 4c0:	00000097          	auipc	ra,0x0
 4c4:	f36080e7          	jalr	-202(ra) # 3f6 <write>
}
 4c8:	60e2                	ld	ra,24(sp)
 4ca:	6442                	ld	s0,16(sp)
 4cc:	6105                	addi	sp,sp,32
 4ce:	8082                	ret

00000000000004d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d0:	7139                	addi	sp,sp,-64
 4d2:	fc06                	sd	ra,56(sp)
 4d4:	f822                	sd	s0,48(sp)
 4d6:	f426                	sd	s1,40(sp)
 4d8:	f04a                	sd	s2,32(sp)
 4da:	ec4e                	sd	s3,24(sp)
 4dc:	0080                	addi	s0,sp,64
 4de:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e0:	c299                	beqz	a3,4e6 <printint+0x16>
 4e2:	0805c863          	bltz	a1,572 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e6:	2581                	sext.w	a1,a1
  neg = 0;
 4e8:	4881                	li	a7,0
 4ea:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ee:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f0:	2601                	sext.w	a2,a2
 4f2:	00000517          	auipc	a0,0x0
 4f6:	50e50513          	addi	a0,a0,1294 # a00 <digits>
 4fa:	883a                	mv	a6,a4
 4fc:	2705                	addiw	a4,a4,1
 4fe:	02c5f7bb          	remuw	a5,a1,a2
 502:	1782                	slli	a5,a5,0x20
 504:	9381                	srli	a5,a5,0x20
 506:	97aa                	add	a5,a5,a0
 508:	0007c783          	lbu	a5,0(a5)
 50c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 510:	0005879b          	sext.w	a5,a1
 514:	02c5d5bb          	divuw	a1,a1,a2
 518:	0685                	addi	a3,a3,1
 51a:	fec7f0e3          	bgeu	a5,a2,4fa <printint+0x2a>
  if(neg)
 51e:	00088b63          	beqz	a7,534 <printint+0x64>
    buf[i++] = '-';
 522:	fd040793          	addi	a5,s0,-48
 526:	973e                	add	a4,a4,a5
 528:	02d00793          	li	a5,45
 52c:	fef70823          	sb	a5,-16(a4)
 530:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 534:	02e05863          	blez	a4,564 <printint+0x94>
 538:	fc040793          	addi	a5,s0,-64
 53c:	00e78933          	add	s2,a5,a4
 540:	fff78993          	addi	s3,a5,-1
 544:	99ba                	add	s3,s3,a4
 546:	377d                	addiw	a4,a4,-1
 548:	1702                	slli	a4,a4,0x20
 54a:	9301                	srli	a4,a4,0x20
 54c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 550:	fff94583          	lbu	a1,-1(s2)
 554:	8526                	mv	a0,s1
 556:	00000097          	auipc	ra,0x0
 55a:	f58080e7          	jalr	-168(ra) # 4ae <putc>
  while(--i >= 0)
 55e:	197d                	addi	s2,s2,-1
 560:	ff3918e3          	bne	s2,s3,550 <printint+0x80>
}
 564:	70e2                	ld	ra,56(sp)
 566:	7442                	ld	s0,48(sp)
 568:	74a2                	ld	s1,40(sp)
 56a:	7902                	ld	s2,32(sp)
 56c:	69e2                	ld	s3,24(sp)
 56e:	6121                	addi	sp,sp,64
 570:	8082                	ret
    x = -xx;
 572:	40b005bb          	negw	a1,a1
    neg = 1;
 576:	4885                	li	a7,1
    x = -xx;
 578:	bf8d                	j	4ea <printint+0x1a>

000000000000057a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57a:	7119                	addi	sp,sp,-128
 57c:	fc86                	sd	ra,120(sp)
 57e:	f8a2                	sd	s0,112(sp)
 580:	f4a6                	sd	s1,104(sp)
 582:	f0ca                	sd	s2,96(sp)
 584:	ecce                	sd	s3,88(sp)
 586:	e8d2                	sd	s4,80(sp)
 588:	e4d6                	sd	s5,72(sp)
 58a:	e0da                	sd	s6,64(sp)
 58c:	fc5e                	sd	s7,56(sp)
 58e:	f862                	sd	s8,48(sp)
 590:	f466                	sd	s9,40(sp)
 592:	f06a                	sd	s10,32(sp)
 594:	ec6e                	sd	s11,24(sp)
 596:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 598:	0005c903          	lbu	s2,0(a1)
 59c:	18090f63          	beqz	s2,73a <vprintf+0x1c0>
 5a0:	8aaa                	mv	s5,a0
 5a2:	8b32                	mv	s6,a2
 5a4:	00158493          	addi	s1,a1,1
  state = 0;
 5a8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5aa:	02500a13          	li	s4,37
      if(c == 'd'){
 5ae:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5b2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5b6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5ba:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5be:	00000b97          	auipc	s7,0x0
 5c2:	442b8b93          	addi	s7,s7,1090 # a00 <digits>
 5c6:	a839                	j	5e4 <vprintf+0x6a>
        putc(fd, c);
 5c8:	85ca                	mv	a1,s2
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	ee2080e7          	jalr	-286(ra) # 4ae <putc>
 5d4:	a019                	j	5da <vprintf+0x60>
    } else if(state == '%'){
 5d6:	01498f63          	beq	s3,s4,5f4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5da:	0485                	addi	s1,s1,1
 5dc:	fff4c903          	lbu	s2,-1(s1)
 5e0:	14090d63          	beqz	s2,73a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5e4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5e8:	fe0997e3          	bnez	s3,5d6 <vprintf+0x5c>
      if(c == '%'){
 5ec:	fd479ee3          	bne	a5,s4,5c8 <vprintf+0x4e>
        state = '%';
 5f0:	89be                	mv	s3,a5
 5f2:	b7e5                	j	5da <vprintf+0x60>
      if(c == 'd'){
 5f4:	05878063          	beq	a5,s8,634 <vprintf+0xba>
      } else if(c == 'l') {
 5f8:	05978c63          	beq	a5,s9,650 <vprintf+0xd6>
      } else if(c == 'x') {
 5fc:	07a78863          	beq	a5,s10,66c <vprintf+0xf2>
      } else if(c == 'p') {
 600:	09b78463          	beq	a5,s11,688 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 604:	07300713          	li	a4,115
 608:	0ce78663          	beq	a5,a4,6d4 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 60c:	06300713          	li	a4,99
 610:	0ee78e63          	beq	a5,a4,70c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 614:	11478863          	beq	a5,s4,724 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 618:	85d2                	mv	a1,s4
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e92080e7          	jalr	-366(ra) # 4ae <putc>
        putc(fd, c);
 624:	85ca                	mv	a1,s2
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e86080e7          	jalr	-378(ra) # 4ae <putc>
      }
      state = 0;
 630:	4981                	li	s3,0
 632:	b765                	j	5da <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 634:	008b0913          	addi	s2,s6,8
 638:	4685                	li	a3,1
 63a:	4629                	li	a2,10
 63c:	000b2583          	lw	a1,0(s6)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e8e080e7          	jalr	-370(ra) # 4d0 <printint>
 64a:	8b4a                	mv	s6,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b771                	j	5da <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 650:	008b0913          	addi	s2,s6,8
 654:	4681                	li	a3,0
 656:	4629                	li	a2,10
 658:	000b2583          	lw	a1,0(s6)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e72080e7          	jalr	-398(ra) # 4d0 <printint>
 666:	8b4a                	mv	s6,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	bf85                	j	5da <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 66c:	008b0913          	addi	s2,s6,8
 670:	4681                	li	a3,0
 672:	4641                	li	a2,16
 674:	000b2583          	lw	a1,0(s6)
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e56080e7          	jalr	-426(ra) # 4d0 <printint>
 682:	8b4a                	mv	s6,s2
      state = 0;
 684:	4981                	li	s3,0
 686:	bf91                	j	5da <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 688:	008b0793          	addi	a5,s6,8
 68c:	f8f43423          	sd	a5,-120(s0)
 690:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 694:	03000593          	li	a1,48
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e14080e7          	jalr	-492(ra) # 4ae <putc>
  putc(fd, 'x');
 6a2:	85ea                	mv	a1,s10
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e08080e7          	jalr	-504(ra) # 4ae <putc>
 6ae:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b0:	03c9d793          	srli	a5,s3,0x3c
 6b4:	97de                	add	a5,a5,s7
 6b6:	0007c583          	lbu	a1,0(a5)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	df2080e7          	jalr	-526(ra) # 4ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c4:	0992                	slli	s3,s3,0x4
 6c6:	397d                	addiw	s2,s2,-1
 6c8:	fe0914e3          	bnez	s2,6b0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6cc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b721                	j	5da <vprintf+0x60>
        s = va_arg(ap, char*);
 6d4:	008b0993          	addi	s3,s6,8
 6d8:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6dc:	02090163          	beqz	s2,6fe <vprintf+0x184>
        while(*s != 0){
 6e0:	00094583          	lbu	a1,0(s2)
 6e4:	c9a1                	beqz	a1,734 <vprintf+0x1ba>
          putc(fd, *s);
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	dc6080e7          	jalr	-570(ra) # 4ae <putc>
          s++;
 6f0:	0905                	addi	s2,s2,1
        while(*s != 0){
 6f2:	00094583          	lbu	a1,0(s2)
 6f6:	f9e5                	bnez	a1,6e6 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6f8:	8b4e                	mv	s6,s3
      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	bdf9                	j	5da <vprintf+0x60>
          s = "(null)";
 6fe:	00000917          	auipc	s2,0x0
 702:	2fa90913          	addi	s2,s2,762 # 9f8 <malloc+0x1b4>
        while(*s != 0){
 706:	02800593          	li	a1,40
 70a:	bff1                	j	6e6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 70c:	008b0913          	addi	s2,s6,8
 710:	000b4583          	lbu	a1,0(s6)
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	d98080e7          	jalr	-616(ra) # 4ae <putc>
 71e:	8b4a                	mv	s6,s2
      state = 0;
 720:	4981                	li	s3,0
 722:	bd65                	j	5da <vprintf+0x60>
        putc(fd, c);
 724:	85d2                	mv	a1,s4
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	d86080e7          	jalr	-634(ra) # 4ae <putc>
      state = 0;
 730:	4981                	li	s3,0
 732:	b565                	j	5da <vprintf+0x60>
        s = va_arg(ap, char*);
 734:	8b4e                	mv	s6,s3
      state = 0;
 736:	4981                	li	s3,0
 738:	b54d                	j	5da <vprintf+0x60>
    }
  }
}
 73a:	70e6                	ld	ra,120(sp)
 73c:	7446                	ld	s0,112(sp)
 73e:	74a6                	ld	s1,104(sp)
 740:	7906                	ld	s2,96(sp)
 742:	69e6                	ld	s3,88(sp)
 744:	6a46                	ld	s4,80(sp)
 746:	6aa6                	ld	s5,72(sp)
 748:	6b06                	ld	s6,64(sp)
 74a:	7be2                	ld	s7,56(sp)
 74c:	7c42                	ld	s8,48(sp)
 74e:	7ca2                	ld	s9,40(sp)
 750:	7d02                	ld	s10,32(sp)
 752:	6de2                	ld	s11,24(sp)
 754:	6109                	addi	sp,sp,128
 756:	8082                	ret

0000000000000758 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 758:	715d                	addi	sp,sp,-80
 75a:	ec06                	sd	ra,24(sp)
 75c:	e822                	sd	s0,16(sp)
 75e:	1000                	addi	s0,sp,32
 760:	e010                	sd	a2,0(s0)
 762:	e414                	sd	a3,8(s0)
 764:	e818                	sd	a4,16(s0)
 766:	ec1c                	sd	a5,24(s0)
 768:	03043023          	sd	a6,32(s0)
 76c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 770:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 774:	8622                	mv	a2,s0
 776:	00000097          	auipc	ra,0x0
 77a:	e04080e7          	jalr	-508(ra) # 57a <vprintf>
}
 77e:	60e2                	ld	ra,24(sp)
 780:	6442                	ld	s0,16(sp)
 782:	6161                	addi	sp,sp,80
 784:	8082                	ret

0000000000000786 <printf>:

void
printf(const char *fmt, ...)
{
 786:	711d                	addi	sp,sp,-96
 788:	ec06                	sd	ra,24(sp)
 78a:	e822                	sd	s0,16(sp)
 78c:	1000                	addi	s0,sp,32
 78e:	e40c                	sd	a1,8(s0)
 790:	e810                	sd	a2,16(s0)
 792:	ec14                	sd	a3,24(s0)
 794:	f018                	sd	a4,32(s0)
 796:	f41c                	sd	a5,40(s0)
 798:	03043823          	sd	a6,48(s0)
 79c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7a0:	00840613          	addi	a2,s0,8
 7a4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7a8:	85aa                	mv	a1,a0
 7aa:	4505                	li	a0,1
 7ac:	00000097          	auipc	ra,0x0
 7b0:	dce080e7          	jalr	-562(ra) # 57a <vprintf>
}
 7b4:	60e2                	ld	ra,24(sp)
 7b6:	6442                	ld	s0,16(sp)
 7b8:	6125                	addi	sp,sp,96
 7ba:	8082                	ret

00000000000007bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7bc:	1141                	addi	sp,sp,-16
 7be:	e422                	sd	s0,8(sp)
 7c0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7c2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c6:	00000797          	auipc	a5,0x0
 7ca:	2527b783          	ld	a5,594(a5) # a18 <freep>
 7ce:	a805                	j	7fe <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7d0:	4618                	lw	a4,8(a2)
 7d2:	9db9                	addw	a1,a1,a4
 7d4:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d8:	6398                	ld	a4,0(a5)
 7da:	6318                	ld	a4,0(a4)
 7dc:	fee53823          	sd	a4,-16(a0)
 7e0:	a091                	j	824 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7e2:	ff852703          	lw	a4,-8(a0)
 7e6:	9e39                	addw	a2,a2,a4
 7e8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7ea:	ff053703          	ld	a4,-16(a0)
 7ee:	e398                	sd	a4,0(a5)
 7f0:	a099                	j	836 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	6398                	ld	a4,0(a5)
 7f4:	00e7e463          	bltu	a5,a4,7fc <free+0x40>
 7f8:	00e6ea63          	bltu	a3,a4,80c <free+0x50>
{
 7fc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7fe:	fed7fae3          	bgeu	a5,a3,7f2 <free+0x36>
 802:	6398                	ld	a4,0(a5)
 804:	00e6e463          	bltu	a3,a4,80c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 808:	fee7eae3          	bltu	a5,a4,7fc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 80c:	ff852583          	lw	a1,-8(a0)
 810:	6390                	ld	a2,0(a5)
 812:	02059713          	slli	a4,a1,0x20
 816:	9301                	srli	a4,a4,0x20
 818:	0712                	slli	a4,a4,0x4
 81a:	9736                	add	a4,a4,a3
 81c:	fae60ae3          	beq	a2,a4,7d0 <free+0x14>
    bp->s.ptr = p->s.ptr;
 820:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 824:	4790                	lw	a2,8(a5)
 826:	02061713          	slli	a4,a2,0x20
 82a:	9301                	srli	a4,a4,0x20
 82c:	0712                	slli	a4,a4,0x4
 82e:	973e                	add	a4,a4,a5
 830:	fae689e3          	beq	a3,a4,7e2 <free+0x26>
  } else
    p->s.ptr = bp;
 834:	e394                	sd	a3,0(a5)
  freep = p;
 836:	00000717          	auipc	a4,0x0
 83a:	1ef73123          	sd	a5,482(a4) # a18 <freep>
}
 83e:	6422                	ld	s0,8(sp)
 840:	0141                	addi	sp,sp,16
 842:	8082                	ret

0000000000000844 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 844:	7139                	addi	sp,sp,-64
 846:	fc06                	sd	ra,56(sp)
 848:	f822                	sd	s0,48(sp)
 84a:	f426                	sd	s1,40(sp)
 84c:	f04a                	sd	s2,32(sp)
 84e:	ec4e                	sd	s3,24(sp)
 850:	e852                	sd	s4,16(sp)
 852:	e456                	sd	s5,8(sp)
 854:	e05a                	sd	s6,0(sp)
 856:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 858:	02051493          	slli	s1,a0,0x20
 85c:	9081                	srli	s1,s1,0x20
 85e:	04bd                	addi	s1,s1,15
 860:	8091                	srli	s1,s1,0x4
 862:	0014899b          	addiw	s3,s1,1
 866:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 868:	00000517          	auipc	a0,0x0
 86c:	1b053503          	ld	a0,432(a0) # a18 <freep>
 870:	c515                	beqz	a0,89c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 872:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 874:	4798                	lw	a4,8(a5)
 876:	02977f63          	bgeu	a4,s1,8b4 <malloc+0x70>
 87a:	8a4e                	mv	s4,s3
 87c:	0009871b          	sext.w	a4,s3
 880:	6685                	lui	a3,0x1
 882:	00d77363          	bgeu	a4,a3,888 <malloc+0x44>
 886:	6a05                	lui	s4,0x1
 888:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 88c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 890:	00000917          	auipc	s2,0x0
 894:	18890913          	addi	s2,s2,392 # a18 <freep>
  if(p == (char*)-1)
 898:	5afd                	li	s5,-1
 89a:	a88d                	j	90c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 89c:	00000797          	auipc	a5,0x0
 8a0:	18478793          	addi	a5,a5,388 # a20 <base>
 8a4:	00000717          	auipc	a4,0x0
 8a8:	16f73a23          	sd	a5,372(a4) # a18 <freep>
 8ac:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ae:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8b2:	b7e1                	j	87a <malloc+0x36>
      if(p->s.size == nunits)
 8b4:	02e48b63          	beq	s1,a4,8ea <malloc+0xa6>
        p->s.size -= nunits;
 8b8:	4137073b          	subw	a4,a4,s3
 8bc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8be:	1702                	slli	a4,a4,0x20
 8c0:	9301                	srli	a4,a4,0x20
 8c2:	0712                	slli	a4,a4,0x4
 8c4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	14a73723          	sd	a0,334(a4) # a18 <freep>
      return (void*)(p + 1);
 8d2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8d6:	70e2                	ld	ra,56(sp)
 8d8:	7442                	ld	s0,48(sp)
 8da:	74a2                	ld	s1,40(sp)
 8dc:	7902                	ld	s2,32(sp)
 8de:	69e2                	ld	s3,24(sp)
 8e0:	6a42                	ld	s4,16(sp)
 8e2:	6aa2                	ld	s5,8(sp)
 8e4:	6b02                	ld	s6,0(sp)
 8e6:	6121                	addi	sp,sp,64
 8e8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ea:	6398                	ld	a4,0(a5)
 8ec:	e118                	sd	a4,0(a0)
 8ee:	bff1                	j	8ca <malloc+0x86>
  hp->s.size = nu;
 8f0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8f4:	0541                	addi	a0,a0,16
 8f6:	00000097          	auipc	ra,0x0
 8fa:	ec6080e7          	jalr	-314(ra) # 7bc <free>
  return freep;
 8fe:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 902:	d971                	beqz	a0,8d6 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 904:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 906:	4798                	lw	a4,8(a5)
 908:	fa9776e3          	bgeu	a4,s1,8b4 <malloc+0x70>
    if(p == freep)
 90c:	00093703          	ld	a4,0(s2)
 910:	853e                	mv	a0,a5
 912:	fef719e3          	bne	a4,a5,904 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 916:	8552                	mv	a0,s4
 918:	00000097          	auipc	ra,0x0
 91c:	b46080e7          	jalr	-1210(ra) # 45e <sbrk>
  if(p == (char*)-1)
 920:	fd5518e3          	bne	a0,s5,8f0 <malloc+0xac>
        return 0;
 924:	4501                	li	a0,0
 926:	bf45                	j	8d6 <malloc+0x92>
