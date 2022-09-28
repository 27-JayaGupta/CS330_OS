
user/_primefactors:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <primefactors>:
#include "user/user.h"
#include <stddef.h>

int pipefd[2];

void primefactors(int * primes, int i, int n){
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	0880                	addi	s0,sp,80
  10:	fac42e23          	sw	a2,-68(s0)

    
    if(n==1)
  14:	2601                	sext.w	a2,a2
  16:	4785                	li	a5,1
  18:	0af60f63          	beq	a2,a5,d6 <primefactors+0xd6>
  1c:	89aa                	mv	s3,a0
  1e:	84ae                	mv	s1,a1
    return;
    int f = fork();
  20:	00000097          	auipc	ra,0x0
  24:	4a0080e7          	jalr	1184(ra) # 4c0 <fork>
    if(f<0){
  28:	0a054f63          	bltz	a0,e6 <primefactors+0xe6>
        fprintf(2,"Error in fork. Aborting...\n");
        exit(1);
    }
    if(f==0){
  2c:	c979                	beqz	a0,102 <primefactors+0x102>
            exit(1);
        }
        primefactors(primes,i+1,a);
    }else{
        int cnt = 0;
        while(n%primes[i]==0){
  2e:	fbc42683          	lw	a3,-68(s0)
  32:	00249593          	slli	a1,s1,0x2
  36:	99ae                	add	s3,s3,a1
  38:	0009a603          	lw	a2,0(s3)
  3c:	02c6e4bb          	remw	s1,a3,a2
        int cnt = 0;
  40:	8726                	mv	a4,s1
        while(n%primes[i]==0){
  42:	e8b1                	bnez	s1,96 <primefactors+0x96>
            n/=primes[i];
  44:	02c6c7bb          	divw	a5,a3,a2
  48:	0007869b          	sext.w	a3,a5
            cnt++;
  4c:	893a                	mv	s2,a4
  4e:	2705                	addiw	a4,a4,1
        while(n%primes[i]==0){
  50:	02c7e7bb          	remw	a5,a5,a2
  54:	dbe5                	beqz	a5,44 <primefactors+0x44>
  56:	fad42e23          	sw	a3,-68(s0)
        }
        if(cnt>0){
  5a:	02e05e63          	blez	a4,96 <primefactors+0x96>
            for(int j=0;j<cnt;j++)
            printf("%d, ",primes[i]);
  5e:	00001a17          	auipc	s4,0x1
  62:	a02a0a13          	addi	s4,s4,-1534 # a60 <malloc+0x12a>
  66:	0009a583          	lw	a1,0(s3)
  6a:	8552                	mv	a0,s4
  6c:	00001097          	auipc	ra,0x1
  70:	80c080e7          	jalr	-2036(ra) # 878 <printf>
            for(int j=0;j<cnt;j++)
  74:	87a6                	mv	a5,s1
  76:	2485                	addiw	s1,s1,1
  78:	ff27c7e3          	blt	a5,s2,66 <primefactors+0x66>
            printf("[%d]\n",getpid());
  7c:	00000097          	auipc	ra,0x0
  80:	4cc080e7          	jalr	1228(ra) # 548 <getpid>
  84:	85aa                	mv	a1,a0
  86:	00001517          	auipc	a0,0x1
  8a:	9e250513          	addi	a0,a0,-1566 # a68 <malloc+0x132>
  8e:	00000097          	auipc	ra,0x0
  92:	7ea080e7          	jalr	2026(ra) # 878 <printf>

        }
        if(write(pipefd[1],&n,sizeof(n))<0){
  96:	4611                	li	a2,4
  98:	fbc40593          	addi	a1,s0,-68
  9c:	00001517          	auipc	a0,0x1
  a0:	ae852503          	lw	a0,-1304(a0) # b84 <pipefd+0x4>
  a4:	00000097          	auipc	ra,0x0
  a8:	444080e7          	jalr	1092(ra) # 4e8 <write>
  ac:	0a054063          	bltz	a0,14c <primefactors+0x14c>
            fprintf(2,"Error in write. Aborting...\n");
            exit(1);
        }
        close(pipefd[0]);
  b0:	00001497          	auipc	s1,0x1
  b4:	ad048493          	addi	s1,s1,-1328 # b80 <pipefd>
  b8:	4088                	lw	a0,0(s1)
  ba:	00000097          	auipc	ra,0x0
  be:	436080e7          	jalr	1078(ra) # 4f0 <close>
        close(pipefd[1]);
  c2:	40c8                	lw	a0,4(s1)
  c4:	00000097          	auipc	ra,0x0
  c8:	42c080e7          	jalr	1068(ra) # 4f0 <close>
        wait(NULL);
  cc:	4501                	li	a0,0
  ce:	00000097          	auipc	ra,0x0
  d2:	402080e7          	jalr	1026(ra) # 4d0 <wait>
    }

}
  d6:	60a6                	ld	ra,72(sp)
  d8:	6406                	ld	s0,64(sp)
  da:	74e2                	ld	s1,56(sp)
  dc:	7942                	ld	s2,48(sp)
  de:	79a2                	ld	s3,40(sp)
  e0:	7a02                	ld	s4,32(sp)
  e2:	6161                	addi	sp,sp,80
  e4:	8082                	ret
        fprintf(2,"Error in fork. Aborting...\n");
  e6:	00001597          	auipc	a1,0x1
  ea:	93a58593          	addi	a1,a1,-1734 # a20 <malloc+0xea>
  ee:	4509                	li	a0,2
  f0:	00000097          	auipc	ra,0x0
  f4:	75a080e7          	jalr	1882(ra) # 84a <fprintf>
        exit(1);
  f8:	4505                	li	a0,1
  fa:	00000097          	auipc	ra,0x0
  fe:	3ce080e7          	jalr	974(ra) # 4c8 <exit>
        if(read(pipefd[0],&a,sizeof(a))<0){
 102:	4611                	li	a2,4
 104:	fcc40593          	addi	a1,s0,-52
 108:	00001517          	auipc	a0,0x1
 10c:	a7852503          	lw	a0,-1416(a0) # b80 <pipefd>
 110:	00000097          	auipc	ra,0x0
 114:	3d0080e7          	jalr	976(ra) # 4e0 <read>
 118:	00054c63          	bltz	a0,130 <primefactors+0x130>
        primefactors(primes,i+1,a);
 11c:	fcc42603          	lw	a2,-52(s0)
 120:	0014859b          	addiw	a1,s1,1
 124:	854e                	mv	a0,s3
 126:	00000097          	auipc	ra,0x0
 12a:	eda080e7          	jalr	-294(ra) # 0 <primefactors>
 12e:	b765                	j	d6 <primefactors+0xd6>
            fprintf(2,"Error in read. Aborting...\n");
 130:	00001597          	auipc	a1,0x1
 134:	91058593          	addi	a1,a1,-1776 # a40 <malloc+0x10a>
 138:	4509                	li	a0,2
 13a:	00000097          	auipc	ra,0x0
 13e:	710080e7          	jalr	1808(ra) # 84a <fprintf>
            exit(1);
 142:	4505                	li	a0,1
 144:	00000097          	auipc	ra,0x0
 148:	384080e7          	jalr	900(ra) # 4c8 <exit>
            fprintf(2,"Error in write. Aborting...\n");
 14c:	00001597          	auipc	a1,0x1
 150:	92458593          	addi	a1,a1,-1756 # a70 <malloc+0x13a>
 154:	4509                	li	a0,2
 156:	00000097          	auipc	ra,0x0
 15a:	6f4080e7          	jalr	1780(ra) # 84a <fprintf>
            exit(1);
 15e:	4505                	li	a0,1
 160:	00000097          	auipc	ra,0x0
 164:	368080e7          	jalr	872(ra) # 4c8 <exit>

0000000000000168 <main>:

int main(int argc, char *argv[]){
 168:	7175                	addi	sp,sp,-144
 16a:	e506                	sd	ra,136(sp)
 16c:	e122                	sd	s0,128(sp)
 16e:	fca6                	sd	s1,120(sp)
 170:	0900                	addi	s0,sp,144

    int primes[]={2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97};
 172:	00001797          	auipc	a5,0x1
 176:	98678793          	addi	a5,a5,-1658 # af8 <malloc+0x1c2>
 17a:	f7840713          	addi	a4,s0,-136
 17e:	00001697          	auipc	a3,0x1
 182:	9da68693          	addi	a3,a3,-1574 # b58 <malloc+0x222>
 186:	0007b303          	ld	t1,0(a5)
 18a:	0087b883          	ld	a7,8(a5)
 18e:	0107b803          	ld	a6,16(a5)
 192:	6f90                	ld	a2,24(a5)
 194:	00673023          	sd	t1,0(a4)
 198:	01173423          	sd	a7,8(a4)
 19c:	01073823          	sd	a6,16(a4)
 1a0:	ef10                	sd	a2,24(a4)
 1a2:	02078793          	addi	a5,a5,32
 1a6:	02070713          	addi	a4,a4,32
 1aa:	fcd79ee3          	bne	a5,a3,186 <main+0x1e>
 1ae:	439c                	lw	a5,0(a5)
 1b0:	c31c                	sw	a5,0(a4)
    if(argc!=2){
 1b2:	4789                	li	a5,2
 1b4:	02f50063          	beq	a0,a5,1d4 <main+0x6c>
        fprintf(2,"Syntax: primefactors <int>\n");
 1b8:	00001597          	auipc	a1,0x1
 1bc:	8d858593          	addi	a1,a1,-1832 # a90 <malloc+0x15a>
 1c0:	4509                	li	a0,2
 1c2:	00000097          	auipc	ra,0x0
 1c6:	688080e7          	jalr	1672(ra) # 84a <fprintf>
        exit(1);
 1ca:	4505                	li	a0,1
 1cc:	00000097          	auipc	ra,0x0
 1d0:	2fc080e7          	jalr	764(ra) # 4c8 <exit>
    }
    int n = atoi(argv[1]);
 1d4:	6588                	ld	a0,8(a1)
 1d6:	00000097          	auipc	ra,0x0
 1da:	1f2080e7          	jalr	498(ra) # 3c8 <atoi>
 1de:	84aa                	mv	s1,a0
    if(n<2||n>100){
 1e0:	ffe5071b          	addiw	a4,a0,-2
 1e4:	06200793          	li	a5,98
 1e8:	02e7f063          	bgeu	a5,a4,208 <main+0xa0>
        fprintf(2,"Enter n between 2 and 100\n");
 1ec:	00001597          	auipc	a1,0x1
 1f0:	8c458593          	addi	a1,a1,-1852 # ab0 <malloc+0x17a>
 1f4:	4509                	li	a0,2
 1f6:	00000097          	auipc	ra,0x0
 1fa:	654080e7          	jalr	1620(ra) # 84a <fprintf>
        exit(1);
 1fe:	4505                	li	a0,1
 200:	00000097          	auipc	ra,0x0
 204:	2c8080e7          	jalr	712(ra) # 4c8 <exit>
    }
    if(pipe(pipefd)<0){
 208:	00001517          	auipc	a0,0x1
 20c:	97850513          	addi	a0,a0,-1672 # b80 <pipefd>
 210:	00000097          	auipc	ra,0x0
 214:	2c8080e7          	jalr	712(ra) # 4d8 <pipe>
 218:	00054f63          	bltz	a0,236 <main+0xce>
        fprintf(2,"Error in creating pipe. Aborting...\n");
        exit(1);
    }
    primefactors(primes,0,n);
 21c:	8626                	mv	a2,s1
 21e:	4581                	li	a1,0
 220:	f7840513          	addi	a0,s0,-136
 224:	00000097          	auipc	ra,0x0
 228:	ddc080e7          	jalr	-548(ra) # 0 <primefactors>
    exit(0);
 22c:	4501                	li	a0,0
 22e:	00000097          	auipc	ra,0x0
 232:	29a080e7          	jalr	666(ra) # 4c8 <exit>
        fprintf(2,"Error in creating pipe. Aborting...\n");
 236:	00001597          	auipc	a1,0x1
 23a:	89a58593          	addi	a1,a1,-1894 # ad0 <malloc+0x19a>
 23e:	4509                	li	a0,2
 240:	00000097          	auipc	ra,0x0
 244:	60a080e7          	jalr	1546(ra) # 84a <fprintf>
        exit(1);
 248:	4505                	li	a0,1
 24a:	00000097          	auipc	ra,0x0
 24e:	27e080e7          	jalr	638(ra) # 4c8 <exit>

0000000000000252 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 258:	87aa                	mv	a5,a0
 25a:	0585                	addi	a1,a1,1
 25c:	0785                	addi	a5,a5,1
 25e:	fff5c703          	lbu	a4,-1(a1)
 262:	fee78fa3          	sb	a4,-1(a5)
 266:	fb75                	bnez	a4,25a <strcpy+0x8>
    ;
  return os;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret

000000000000026e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 26e:	1141                	addi	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 274:	00054783          	lbu	a5,0(a0)
 278:	cb91                	beqz	a5,28c <strcmp+0x1e>
 27a:	0005c703          	lbu	a4,0(a1)
 27e:	00f71763          	bne	a4,a5,28c <strcmp+0x1e>
    p++, q++;
 282:	0505                	addi	a0,a0,1
 284:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 286:	00054783          	lbu	a5,0(a0)
 28a:	fbe5                	bnez	a5,27a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 28c:	0005c503          	lbu	a0,0(a1)
}
 290:	40a7853b          	subw	a0,a5,a0
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret

000000000000029a <strlen>:

uint
strlen(const char *s)
{
 29a:	1141                	addi	sp,sp,-16
 29c:	e422                	sd	s0,8(sp)
 29e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	cf91                	beqz	a5,2c0 <strlen+0x26>
 2a6:	0505                	addi	a0,a0,1
 2a8:	87aa                	mv	a5,a0
 2aa:	4685                	li	a3,1
 2ac:	9e89                	subw	a3,a3,a0
 2ae:	00f6853b          	addw	a0,a3,a5
 2b2:	0785                	addi	a5,a5,1
 2b4:	fff7c703          	lbu	a4,-1(a5)
 2b8:	fb7d                	bnez	a4,2ae <strlen+0x14>
    ;
  return n;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  for(n = 0; s[n]; n++)
 2c0:	4501                	li	a0,0
 2c2:	bfe5                	j	2ba <strlen+0x20>

00000000000002c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2ca:	ce09                	beqz	a2,2e4 <memset+0x20>
 2cc:	87aa                	mv	a5,a0
 2ce:	fff6071b          	addiw	a4,a2,-1
 2d2:	1702                	slli	a4,a4,0x20
 2d4:	9301                	srli	a4,a4,0x20
 2d6:	0705                	addi	a4,a4,1
 2d8:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2de:	0785                	addi	a5,a5,1
 2e0:	fee79de3          	bne	a5,a4,2da <memset+0x16>
  }
  return dst;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret

00000000000002ea <strchr>:

char*
strchr(const char *s, char c)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	cb99                	beqz	a5,30a <strchr+0x20>
    if(*s == c)
 2f6:	00f58763          	beq	a1,a5,304 <strchr+0x1a>
  for(; *s; s++)
 2fa:	0505                	addi	a0,a0,1
 2fc:	00054783          	lbu	a5,0(a0)
 300:	fbfd                	bnez	a5,2f6 <strchr+0xc>
      return (char*)s;
  return 0;
 302:	4501                	li	a0,0
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret
  return 0;
 30a:	4501                	li	a0,0
 30c:	bfe5                	j	304 <strchr+0x1a>

000000000000030e <gets>:

char*
gets(char *buf, int max)
{
 30e:	711d                	addi	sp,sp,-96
 310:	ec86                	sd	ra,88(sp)
 312:	e8a2                	sd	s0,80(sp)
 314:	e4a6                	sd	s1,72(sp)
 316:	e0ca                	sd	s2,64(sp)
 318:	fc4e                	sd	s3,56(sp)
 31a:	f852                	sd	s4,48(sp)
 31c:	f456                	sd	s5,40(sp)
 31e:	f05a                	sd	s6,32(sp)
 320:	ec5e                	sd	s7,24(sp)
 322:	1080                	addi	s0,sp,96
 324:	8baa                	mv	s7,a0
 326:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 328:	892a                	mv	s2,a0
 32a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 32c:	4aa9                	li	s5,10
 32e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 330:	89a6                	mv	s3,s1
 332:	2485                	addiw	s1,s1,1
 334:	0344d863          	bge	s1,s4,364 <gets+0x56>
    cc = read(0, &c, 1);
 338:	4605                	li	a2,1
 33a:	faf40593          	addi	a1,s0,-81
 33e:	4501                	li	a0,0
 340:	00000097          	auipc	ra,0x0
 344:	1a0080e7          	jalr	416(ra) # 4e0 <read>
    if(cc < 1)
 348:	00a05e63          	blez	a0,364 <gets+0x56>
    buf[i++] = c;
 34c:	faf44783          	lbu	a5,-81(s0)
 350:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 354:	01578763          	beq	a5,s5,362 <gets+0x54>
 358:	0905                	addi	s2,s2,1
 35a:	fd679be3          	bne	a5,s6,330 <gets+0x22>
  for(i=0; i+1 < max; ){
 35e:	89a6                	mv	s3,s1
 360:	a011                	j	364 <gets+0x56>
 362:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 364:	99de                	add	s3,s3,s7
 366:	00098023          	sb	zero,0(s3)
  return buf;
}
 36a:	855e                	mv	a0,s7
 36c:	60e6                	ld	ra,88(sp)
 36e:	6446                	ld	s0,80(sp)
 370:	64a6                	ld	s1,72(sp)
 372:	6906                	ld	s2,64(sp)
 374:	79e2                	ld	s3,56(sp)
 376:	7a42                	ld	s4,48(sp)
 378:	7aa2                	ld	s5,40(sp)
 37a:	7b02                	ld	s6,32(sp)
 37c:	6be2                	ld	s7,24(sp)
 37e:	6125                	addi	sp,sp,96
 380:	8082                	ret

0000000000000382 <stat>:

int
stat(const char *n, struct stat *st)
{
 382:	1101                	addi	sp,sp,-32
 384:	ec06                	sd	ra,24(sp)
 386:	e822                	sd	s0,16(sp)
 388:	e426                	sd	s1,8(sp)
 38a:	e04a                	sd	s2,0(sp)
 38c:	1000                	addi	s0,sp,32
 38e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 390:	4581                	li	a1,0
 392:	00000097          	auipc	ra,0x0
 396:	176080e7          	jalr	374(ra) # 508 <open>
  if(fd < 0)
 39a:	02054563          	bltz	a0,3c4 <stat+0x42>
 39e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a0:	85ca                	mv	a1,s2
 3a2:	00000097          	auipc	ra,0x0
 3a6:	17e080e7          	jalr	382(ra) # 520 <fstat>
 3aa:	892a                	mv	s2,a0
  close(fd);
 3ac:	8526                	mv	a0,s1
 3ae:	00000097          	auipc	ra,0x0
 3b2:	142080e7          	jalr	322(ra) # 4f0 <close>
  return r;
}
 3b6:	854a                	mv	a0,s2
 3b8:	60e2                	ld	ra,24(sp)
 3ba:	6442                	ld	s0,16(sp)
 3bc:	64a2                	ld	s1,8(sp)
 3be:	6902                	ld	s2,0(sp)
 3c0:	6105                	addi	sp,sp,32
 3c2:	8082                	ret
    return -1;
 3c4:	597d                	li	s2,-1
 3c6:	bfc5                	j	3b6 <stat+0x34>

00000000000003c8 <atoi>:

int
atoi(const char *s)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e422                	sd	s0,8(sp)
 3cc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3ce:	00054603          	lbu	a2,0(a0)
 3d2:	fd06079b          	addiw	a5,a2,-48
 3d6:	0ff7f793          	andi	a5,a5,255
 3da:	4725                	li	a4,9
 3dc:	02f76963          	bltu	a4,a5,40e <atoi+0x46>
 3e0:	86aa                	mv	a3,a0
  n = 0;
 3e2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3e4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3e6:	0685                	addi	a3,a3,1
 3e8:	0025179b          	slliw	a5,a0,0x2
 3ec:	9fa9                	addw	a5,a5,a0
 3ee:	0017979b          	slliw	a5,a5,0x1
 3f2:	9fb1                	addw	a5,a5,a2
 3f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3f8:	0006c603          	lbu	a2,0(a3)
 3fc:	fd06071b          	addiw	a4,a2,-48
 400:	0ff77713          	andi	a4,a4,255
 404:	fee5f1e3          	bgeu	a1,a4,3e6 <atoi+0x1e>
  return n;
}
 408:	6422                	ld	s0,8(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret
  n = 0;
 40e:	4501                	li	a0,0
 410:	bfe5                	j	408 <atoi+0x40>

0000000000000412 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e422                	sd	s0,8(sp)
 416:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 418:	02b57663          	bgeu	a0,a1,444 <memmove+0x32>
    while(n-- > 0)
 41c:	02c05163          	blez	a2,43e <memmove+0x2c>
 420:	fff6079b          	addiw	a5,a2,-1
 424:	1782                	slli	a5,a5,0x20
 426:	9381                	srli	a5,a5,0x20
 428:	0785                	addi	a5,a5,1
 42a:	97aa                	add	a5,a5,a0
  dst = vdst;
 42c:	872a                	mv	a4,a0
      *dst++ = *src++;
 42e:	0585                	addi	a1,a1,1
 430:	0705                	addi	a4,a4,1
 432:	fff5c683          	lbu	a3,-1(a1)
 436:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 43a:	fee79ae3          	bne	a5,a4,42e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43e:	6422                	ld	s0,8(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret
    dst += n;
 444:	00c50733          	add	a4,a0,a2
    src += n;
 448:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 44a:	fec05ae3          	blez	a2,43e <memmove+0x2c>
 44e:	fff6079b          	addiw	a5,a2,-1
 452:	1782                	slli	a5,a5,0x20
 454:	9381                	srli	a5,a5,0x20
 456:	fff7c793          	not	a5,a5
 45a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 45c:	15fd                	addi	a1,a1,-1
 45e:	177d                	addi	a4,a4,-1
 460:	0005c683          	lbu	a3,0(a1)
 464:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 468:	fee79ae3          	bne	a5,a4,45c <memmove+0x4a>
 46c:	bfc9                	j	43e <memmove+0x2c>

000000000000046e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e422                	sd	s0,8(sp)
 472:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 474:	ca05                	beqz	a2,4a4 <memcmp+0x36>
 476:	fff6069b          	addiw	a3,a2,-1
 47a:	1682                	slli	a3,a3,0x20
 47c:	9281                	srli	a3,a3,0x20
 47e:	0685                	addi	a3,a3,1
 480:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 482:	00054783          	lbu	a5,0(a0)
 486:	0005c703          	lbu	a4,0(a1)
 48a:	00e79863          	bne	a5,a4,49a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48e:	0505                	addi	a0,a0,1
    p2++;
 490:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 492:	fed518e3          	bne	a0,a3,482 <memcmp+0x14>
  }
  return 0;
 496:	4501                	li	a0,0
 498:	a019                	j	49e <memcmp+0x30>
      return *p1 - *p2;
 49a:	40e7853b          	subw	a0,a5,a4
}
 49e:	6422                	ld	s0,8(sp)
 4a0:	0141                	addi	sp,sp,16
 4a2:	8082                	ret
  return 0;
 4a4:	4501                	li	a0,0
 4a6:	bfe5                	j	49e <memcmp+0x30>

00000000000004a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a8:	1141                	addi	sp,sp,-16
 4aa:	e406                	sd	ra,8(sp)
 4ac:	e022                	sd	s0,0(sp)
 4ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f62080e7          	jalr	-158(ra) # 412 <memmove>
}
 4b8:	60a2                	ld	ra,8(sp)
 4ba:	6402                	ld	s0,0(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret

00000000000004c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c0:	4885                	li	a7,1
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c8:	4889                	li	a7,2
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d0:	488d                	li	a7,3
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d8:	4891                	li	a7,4
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <read>:
.global read
read:
 li a7, SYS_read
 4e0:	4895                	li	a7,5
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <write>:
.global write
write:
 li a7, SYS_write
 4e8:	48c1                	li	a7,16
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <close>:
.global close
close:
 li a7, SYS_close
 4f0:	48d5                	li	a7,21
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f8:	4899                	li	a7,6
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <exec>:
.global exec
exec:
 li a7, SYS_exec
 500:	489d                	li	a7,7
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <open>:
.global open
open:
 li a7, SYS_open
 508:	48bd                	li	a7,15
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 510:	48c5                	li	a7,17
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 518:	48c9                	li	a7,18
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 520:	48a1                	li	a7,8
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <link>:
.global link
link:
 li a7, SYS_link
 528:	48cd                	li	a7,19
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 530:	48d1                	li	a7,20
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 538:	48a5                	li	a7,9
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <dup>:
.global dup
dup:
 li a7, SYS_dup
 540:	48a9                	li	a7,10
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 548:	48ad                	li	a7,11
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 550:	48b1                	li	a7,12
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 558:	48b5                	li	a7,13
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 560:	48b9                	li	a7,14
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 568:	48d9                	li	a7,22
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <yield>:
.global yield
yield:
 li a7, SYS_yield
 570:	48dd                	li	a7,23
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 578:	48e1                	li	a7,24
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 580:	48e5                	li	a7,25
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 588:	48e9                	li	a7,26
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <ps>:
.global ps
ps:
 li a7, SYS_ps
 590:	48ed                	li	a7,27
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 598:	48f1                	li	a7,28
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5a0:	1101                	addi	sp,sp,-32
 5a2:	ec06                	sd	ra,24(sp)
 5a4:	e822                	sd	s0,16(sp)
 5a6:	1000                	addi	s0,sp,32
 5a8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5ac:	4605                	li	a2,1
 5ae:	fef40593          	addi	a1,s0,-17
 5b2:	00000097          	auipc	ra,0x0
 5b6:	f36080e7          	jalr	-202(ra) # 4e8 <write>
}
 5ba:	60e2                	ld	ra,24(sp)
 5bc:	6442                	ld	s0,16(sp)
 5be:	6105                	addi	sp,sp,32
 5c0:	8082                	ret

00000000000005c2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5c2:	7139                	addi	sp,sp,-64
 5c4:	fc06                	sd	ra,56(sp)
 5c6:	f822                	sd	s0,48(sp)
 5c8:	f426                	sd	s1,40(sp)
 5ca:	f04a                	sd	s2,32(sp)
 5cc:	ec4e                	sd	s3,24(sp)
 5ce:	0080                	addi	s0,sp,64
 5d0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5d2:	c299                	beqz	a3,5d8 <printint+0x16>
 5d4:	0805c863          	bltz	a1,664 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5d8:	2581                	sext.w	a1,a1
  neg = 0;
 5da:	4881                	li	a7,0
 5dc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5e0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5e2:	2601                	sext.w	a2,a2
 5e4:	00000517          	auipc	a0,0x0
 5e8:	58450513          	addi	a0,a0,1412 # b68 <digits>
 5ec:	883a                	mv	a6,a4
 5ee:	2705                	addiw	a4,a4,1
 5f0:	02c5f7bb          	remuw	a5,a1,a2
 5f4:	1782                	slli	a5,a5,0x20
 5f6:	9381                	srli	a5,a5,0x20
 5f8:	97aa                	add	a5,a5,a0
 5fa:	0007c783          	lbu	a5,0(a5)
 5fe:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 602:	0005879b          	sext.w	a5,a1
 606:	02c5d5bb          	divuw	a1,a1,a2
 60a:	0685                	addi	a3,a3,1
 60c:	fec7f0e3          	bgeu	a5,a2,5ec <printint+0x2a>
  if(neg)
 610:	00088b63          	beqz	a7,626 <printint+0x64>
    buf[i++] = '-';
 614:	fd040793          	addi	a5,s0,-48
 618:	973e                	add	a4,a4,a5
 61a:	02d00793          	li	a5,45
 61e:	fef70823          	sb	a5,-16(a4)
 622:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 626:	02e05863          	blez	a4,656 <printint+0x94>
 62a:	fc040793          	addi	a5,s0,-64
 62e:	00e78933          	add	s2,a5,a4
 632:	fff78993          	addi	s3,a5,-1
 636:	99ba                	add	s3,s3,a4
 638:	377d                	addiw	a4,a4,-1
 63a:	1702                	slli	a4,a4,0x20
 63c:	9301                	srli	a4,a4,0x20
 63e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 642:	fff94583          	lbu	a1,-1(s2)
 646:	8526                	mv	a0,s1
 648:	00000097          	auipc	ra,0x0
 64c:	f58080e7          	jalr	-168(ra) # 5a0 <putc>
  while(--i >= 0)
 650:	197d                	addi	s2,s2,-1
 652:	ff3918e3          	bne	s2,s3,642 <printint+0x80>
}
 656:	70e2                	ld	ra,56(sp)
 658:	7442                	ld	s0,48(sp)
 65a:	74a2                	ld	s1,40(sp)
 65c:	7902                	ld	s2,32(sp)
 65e:	69e2                	ld	s3,24(sp)
 660:	6121                	addi	sp,sp,64
 662:	8082                	ret
    x = -xx;
 664:	40b005bb          	negw	a1,a1
    neg = 1;
 668:	4885                	li	a7,1
    x = -xx;
 66a:	bf8d                	j	5dc <printint+0x1a>

000000000000066c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 66c:	7119                	addi	sp,sp,-128
 66e:	fc86                	sd	ra,120(sp)
 670:	f8a2                	sd	s0,112(sp)
 672:	f4a6                	sd	s1,104(sp)
 674:	f0ca                	sd	s2,96(sp)
 676:	ecce                	sd	s3,88(sp)
 678:	e8d2                	sd	s4,80(sp)
 67a:	e4d6                	sd	s5,72(sp)
 67c:	e0da                	sd	s6,64(sp)
 67e:	fc5e                	sd	s7,56(sp)
 680:	f862                	sd	s8,48(sp)
 682:	f466                	sd	s9,40(sp)
 684:	f06a                	sd	s10,32(sp)
 686:	ec6e                	sd	s11,24(sp)
 688:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 68a:	0005c903          	lbu	s2,0(a1)
 68e:	18090f63          	beqz	s2,82c <vprintf+0x1c0>
 692:	8aaa                	mv	s5,a0
 694:	8b32                	mv	s6,a2
 696:	00158493          	addi	s1,a1,1
  state = 0;
 69a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 69c:	02500a13          	li	s4,37
      if(c == 'd'){
 6a0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 6a4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6a8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6ac:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b0:	00000b97          	auipc	s7,0x0
 6b4:	4b8b8b93          	addi	s7,s7,1208 # b68 <digits>
 6b8:	a839                	j	6d6 <vprintf+0x6a>
        putc(fd, c);
 6ba:	85ca                	mv	a1,s2
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	ee2080e7          	jalr	-286(ra) # 5a0 <putc>
 6c6:	a019                	j	6cc <vprintf+0x60>
    } else if(state == '%'){
 6c8:	01498f63          	beq	s3,s4,6e6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6cc:	0485                	addi	s1,s1,1
 6ce:	fff4c903          	lbu	s2,-1(s1)
 6d2:	14090d63          	beqz	s2,82c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6d6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6da:	fe0997e3          	bnez	s3,6c8 <vprintf+0x5c>
      if(c == '%'){
 6de:	fd479ee3          	bne	a5,s4,6ba <vprintf+0x4e>
        state = '%';
 6e2:	89be                	mv	s3,a5
 6e4:	b7e5                	j	6cc <vprintf+0x60>
      if(c == 'd'){
 6e6:	05878063          	beq	a5,s8,726 <vprintf+0xba>
      } else if(c == 'l') {
 6ea:	05978c63          	beq	a5,s9,742 <vprintf+0xd6>
      } else if(c == 'x') {
 6ee:	07a78863          	beq	a5,s10,75e <vprintf+0xf2>
      } else if(c == 'p') {
 6f2:	09b78463          	beq	a5,s11,77a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6f6:	07300713          	li	a4,115
 6fa:	0ce78663          	beq	a5,a4,7c6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6fe:	06300713          	li	a4,99
 702:	0ee78e63          	beq	a5,a4,7fe <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 706:	11478863          	beq	a5,s4,816 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 70a:	85d2                	mv	a1,s4
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	e92080e7          	jalr	-366(ra) # 5a0 <putc>
        putc(fd, c);
 716:	85ca                	mv	a1,s2
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	e86080e7          	jalr	-378(ra) # 5a0 <putc>
      }
      state = 0;
 722:	4981                	li	s3,0
 724:	b765                	j	6cc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 726:	008b0913          	addi	s2,s6,8
 72a:	4685                	li	a3,1
 72c:	4629                	li	a2,10
 72e:	000b2583          	lw	a1,0(s6)
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	e8e080e7          	jalr	-370(ra) # 5c2 <printint>
 73c:	8b4a                	mv	s6,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	b771                	j	6cc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 742:	008b0913          	addi	s2,s6,8
 746:	4681                	li	a3,0
 748:	4629                	li	a2,10
 74a:	000b2583          	lw	a1,0(s6)
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	e72080e7          	jalr	-398(ra) # 5c2 <printint>
 758:	8b4a                	mv	s6,s2
      state = 0;
 75a:	4981                	li	s3,0
 75c:	bf85                	j	6cc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 75e:	008b0913          	addi	s2,s6,8
 762:	4681                	li	a3,0
 764:	4641                	li	a2,16
 766:	000b2583          	lw	a1,0(s6)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	e56080e7          	jalr	-426(ra) # 5c2 <printint>
 774:	8b4a                	mv	s6,s2
      state = 0;
 776:	4981                	li	s3,0
 778:	bf91                	j	6cc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 77a:	008b0793          	addi	a5,s6,8
 77e:	f8f43423          	sd	a5,-120(s0)
 782:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 786:	03000593          	li	a1,48
 78a:	8556                	mv	a0,s5
 78c:	00000097          	auipc	ra,0x0
 790:	e14080e7          	jalr	-492(ra) # 5a0 <putc>
  putc(fd, 'x');
 794:	85ea                	mv	a1,s10
 796:	8556                	mv	a0,s5
 798:	00000097          	auipc	ra,0x0
 79c:	e08080e7          	jalr	-504(ra) # 5a0 <putc>
 7a0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a2:	03c9d793          	srli	a5,s3,0x3c
 7a6:	97de                	add	a5,a5,s7
 7a8:	0007c583          	lbu	a1,0(a5)
 7ac:	8556                	mv	a0,s5
 7ae:	00000097          	auipc	ra,0x0
 7b2:	df2080e7          	jalr	-526(ra) # 5a0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b6:	0992                	slli	s3,s3,0x4
 7b8:	397d                	addiw	s2,s2,-1
 7ba:	fe0914e3          	bnez	s2,7a2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7be:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	b721                	j	6cc <vprintf+0x60>
        s = va_arg(ap, char*);
 7c6:	008b0993          	addi	s3,s6,8
 7ca:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7ce:	02090163          	beqz	s2,7f0 <vprintf+0x184>
        while(*s != 0){
 7d2:	00094583          	lbu	a1,0(s2)
 7d6:	c9a1                	beqz	a1,826 <vprintf+0x1ba>
          putc(fd, *s);
 7d8:	8556                	mv	a0,s5
 7da:	00000097          	auipc	ra,0x0
 7de:	dc6080e7          	jalr	-570(ra) # 5a0 <putc>
          s++;
 7e2:	0905                	addi	s2,s2,1
        while(*s != 0){
 7e4:	00094583          	lbu	a1,0(s2)
 7e8:	f9e5                	bnez	a1,7d8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7ea:	8b4e                	mv	s6,s3
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	bdf9                	j	6cc <vprintf+0x60>
          s = "(null)";
 7f0:	00000917          	auipc	s2,0x0
 7f4:	37090913          	addi	s2,s2,880 # b60 <malloc+0x22a>
        while(*s != 0){
 7f8:	02800593          	li	a1,40
 7fc:	bff1                	j	7d8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7fe:	008b0913          	addi	s2,s6,8
 802:	000b4583          	lbu	a1,0(s6)
 806:	8556                	mv	a0,s5
 808:	00000097          	auipc	ra,0x0
 80c:	d98080e7          	jalr	-616(ra) # 5a0 <putc>
 810:	8b4a                	mv	s6,s2
      state = 0;
 812:	4981                	li	s3,0
 814:	bd65                	j	6cc <vprintf+0x60>
        putc(fd, c);
 816:	85d2                	mv	a1,s4
 818:	8556                	mv	a0,s5
 81a:	00000097          	auipc	ra,0x0
 81e:	d86080e7          	jalr	-634(ra) # 5a0 <putc>
      state = 0;
 822:	4981                	li	s3,0
 824:	b565                	j	6cc <vprintf+0x60>
        s = va_arg(ap, char*);
 826:	8b4e                	mv	s6,s3
      state = 0;
 828:	4981                	li	s3,0
 82a:	b54d                	j	6cc <vprintf+0x60>
    }
  }
}
 82c:	70e6                	ld	ra,120(sp)
 82e:	7446                	ld	s0,112(sp)
 830:	74a6                	ld	s1,104(sp)
 832:	7906                	ld	s2,96(sp)
 834:	69e6                	ld	s3,88(sp)
 836:	6a46                	ld	s4,80(sp)
 838:	6aa6                	ld	s5,72(sp)
 83a:	6b06                	ld	s6,64(sp)
 83c:	7be2                	ld	s7,56(sp)
 83e:	7c42                	ld	s8,48(sp)
 840:	7ca2                	ld	s9,40(sp)
 842:	7d02                	ld	s10,32(sp)
 844:	6de2                	ld	s11,24(sp)
 846:	6109                	addi	sp,sp,128
 848:	8082                	ret

000000000000084a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 84a:	715d                	addi	sp,sp,-80
 84c:	ec06                	sd	ra,24(sp)
 84e:	e822                	sd	s0,16(sp)
 850:	1000                	addi	s0,sp,32
 852:	e010                	sd	a2,0(s0)
 854:	e414                	sd	a3,8(s0)
 856:	e818                	sd	a4,16(s0)
 858:	ec1c                	sd	a5,24(s0)
 85a:	03043023          	sd	a6,32(s0)
 85e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 862:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 866:	8622                	mv	a2,s0
 868:	00000097          	auipc	ra,0x0
 86c:	e04080e7          	jalr	-508(ra) # 66c <vprintf>
}
 870:	60e2                	ld	ra,24(sp)
 872:	6442                	ld	s0,16(sp)
 874:	6161                	addi	sp,sp,80
 876:	8082                	ret

0000000000000878 <printf>:

void
printf(const char *fmt, ...)
{
 878:	711d                	addi	sp,sp,-96
 87a:	ec06                	sd	ra,24(sp)
 87c:	e822                	sd	s0,16(sp)
 87e:	1000                	addi	s0,sp,32
 880:	e40c                	sd	a1,8(s0)
 882:	e810                	sd	a2,16(s0)
 884:	ec14                	sd	a3,24(s0)
 886:	f018                	sd	a4,32(s0)
 888:	f41c                	sd	a5,40(s0)
 88a:	03043823          	sd	a6,48(s0)
 88e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 892:	00840613          	addi	a2,s0,8
 896:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 89a:	85aa                	mv	a1,a0
 89c:	4505                	li	a0,1
 89e:	00000097          	auipc	ra,0x0
 8a2:	dce080e7          	jalr	-562(ra) # 66c <vprintf>
}
 8a6:	60e2                	ld	ra,24(sp)
 8a8:	6442                	ld	s0,16(sp)
 8aa:	6125                	addi	sp,sp,96
 8ac:	8082                	ret

00000000000008ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ae:	1141                	addi	sp,sp,-16
 8b0:	e422                	sd	s0,8(sp)
 8b2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8b4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b8:	00000797          	auipc	a5,0x0
 8bc:	2d07b783          	ld	a5,720(a5) # b88 <freep>
 8c0:	a805                	j	8f0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8c2:	4618                	lw	a4,8(a2)
 8c4:	9db9                	addw	a1,a1,a4
 8c6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ca:	6398                	ld	a4,0(a5)
 8cc:	6318                	ld	a4,0(a4)
 8ce:	fee53823          	sd	a4,-16(a0)
 8d2:	a091                	j	916 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8d4:	ff852703          	lw	a4,-8(a0)
 8d8:	9e39                	addw	a2,a2,a4
 8da:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8dc:	ff053703          	ld	a4,-16(a0)
 8e0:	e398                	sd	a4,0(a5)
 8e2:	a099                	j	928 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e4:	6398                	ld	a4,0(a5)
 8e6:	00e7e463          	bltu	a5,a4,8ee <free+0x40>
 8ea:	00e6ea63          	bltu	a3,a4,8fe <free+0x50>
{
 8ee:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f0:	fed7fae3          	bgeu	a5,a3,8e4 <free+0x36>
 8f4:	6398                	ld	a4,0(a5)
 8f6:	00e6e463          	bltu	a3,a4,8fe <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8fa:	fee7eae3          	bltu	a5,a4,8ee <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8fe:	ff852583          	lw	a1,-8(a0)
 902:	6390                	ld	a2,0(a5)
 904:	02059713          	slli	a4,a1,0x20
 908:	9301                	srli	a4,a4,0x20
 90a:	0712                	slli	a4,a4,0x4
 90c:	9736                	add	a4,a4,a3
 90e:	fae60ae3          	beq	a2,a4,8c2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 912:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 916:	4790                	lw	a2,8(a5)
 918:	02061713          	slli	a4,a2,0x20
 91c:	9301                	srli	a4,a4,0x20
 91e:	0712                	slli	a4,a4,0x4
 920:	973e                	add	a4,a4,a5
 922:	fae689e3          	beq	a3,a4,8d4 <free+0x26>
  } else
    p->s.ptr = bp;
 926:	e394                	sd	a3,0(a5)
  freep = p;
 928:	00000717          	auipc	a4,0x0
 92c:	26f73023          	sd	a5,608(a4) # b88 <freep>
}
 930:	6422                	ld	s0,8(sp)
 932:	0141                	addi	sp,sp,16
 934:	8082                	ret

0000000000000936 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 936:	7139                	addi	sp,sp,-64
 938:	fc06                	sd	ra,56(sp)
 93a:	f822                	sd	s0,48(sp)
 93c:	f426                	sd	s1,40(sp)
 93e:	f04a                	sd	s2,32(sp)
 940:	ec4e                	sd	s3,24(sp)
 942:	e852                	sd	s4,16(sp)
 944:	e456                	sd	s5,8(sp)
 946:	e05a                	sd	s6,0(sp)
 948:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 94a:	02051493          	slli	s1,a0,0x20
 94e:	9081                	srli	s1,s1,0x20
 950:	04bd                	addi	s1,s1,15
 952:	8091                	srli	s1,s1,0x4
 954:	0014899b          	addiw	s3,s1,1
 958:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 95a:	00000517          	auipc	a0,0x0
 95e:	22e53503          	ld	a0,558(a0) # b88 <freep>
 962:	c515                	beqz	a0,98e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 964:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 966:	4798                	lw	a4,8(a5)
 968:	02977f63          	bgeu	a4,s1,9a6 <malloc+0x70>
 96c:	8a4e                	mv	s4,s3
 96e:	0009871b          	sext.w	a4,s3
 972:	6685                	lui	a3,0x1
 974:	00d77363          	bgeu	a4,a3,97a <malloc+0x44>
 978:	6a05                	lui	s4,0x1
 97a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 97e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 982:	00000917          	auipc	s2,0x0
 986:	20690913          	addi	s2,s2,518 # b88 <freep>
  if(p == (char*)-1)
 98a:	5afd                	li	s5,-1
 98c:	a88d                	j	9fe <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 98e:	00000797          	auipc	a5,0x0
 992:	20278793          	addi	a5,a5,514 # b90 <base>
 996:	00000717          	auipc	a4,0x0
 99a:	1ef73923          	sd	a5,498(a4) # b88 <freep>
 99e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9a0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9a4:	b7e1                	j	96c <malloc+0x36>
      if(p->s.size == nunits)
 9a6:	02e48b63          	beq	s1,a4,9dc <malloc+0xa6>
        p->s.size -= nunits;
 9aa:	4137073b          	subw	a4,a4,s3
 9ae:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9b0:	1702                	slli	a4,a4,0x20
 9b2:	9301                	srli	a4,a4,0x20
 9b4:	0712                	slli	a4,a4,0x4
 9b6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9b8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9bc:	00000717          	auipc	a4,0x0
 9c0:	1ca73623          	sd	a0,460(a4) # b88 <freep>
      return (void*)(p + 1);
 9c4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9c8:	70e2                	ld	ra,56(sp)
 9ca:	7442                	ld	s0,48(sp)
 9cc:	74a2                	ld	s1,40(sp)
 9ce:	7902                	ld	s2,32(sp)
 9d0:	69e2                	ld	s3,24(sp)
 9d2:	6a42                	ld	s4,16(sp)
 9d4:	6aa2                	ld	s5,8(sp)
 9d6:	6b02                	ld	s6,0(sp)
 9d8:	6121                	addi	sp,sp,64
 9da:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9dc:	6398                	ld	a4,0(a5)
 9de:	e118                	sd	a4,0(a0)
 9e0:	bff1                	j	9bc <malloc+0x86>
  hp->s.size = nu;
 9e2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9e6:	0541                	addi	a0,a0,16
 9e8:	00000097          	auipc	ra,0x0
 9ec:	ec6080e7          	jalr	-314(ra) # 8ae <free>
  return freep;
 9f0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9f4:	d971                	beqz	a0,9c8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f8:	4798                	lw	a4,8(a5)
 9fa:	fa9776e3          	bgeu	a4,s1,9a6 <malloc+0x70>
    if(p == freep)
 9fe:	00093703          	ld	a4,0(s2)
 a02:	853e                	mv	a0,a5
 a04:	fef719e3          	bne	a4,a5,9f6 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a08:	8552                	mv	a0,s4
 a0a:	00000097          	auipc	ra,0x0
 a0e:	b46080e7          	jalr	-1210(ra) # 550 <sbrk>
  if(p == (char*)-1)
 a12:	fd5518e3          	bne	a0,s5,9e2 <malloc+0xac>
        return 0;
 a16:	4501                	li	a0,0
 a18:	bf45                	j	9c8 <malloc+0x92>
