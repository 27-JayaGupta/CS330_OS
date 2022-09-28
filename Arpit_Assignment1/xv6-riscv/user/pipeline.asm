
user/_pipeline:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fun>:
int pipefd[2];
int n,x;

void fun(int m){

    if(m==0)
   0:	12050c63          	beqz	a0,138 <fun+0x138>
void fun(int m){
   4:	7179                	addi	sp,sp,-48
   6:	f406                	sd	ra,40(sp)
   8:	f022                	sd	s0,32(sp)
   a:	ec26                	sd	s1,24(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
    return;
    int x1;
    int c;
    if(m==n){
  10:	00001797          	auipc	a5,0x1
  14:	ae47a783          	lw	a5,-1308(a5) # af4 <n>
  18:	08a78663          	beq	a5,a0,a4 <fun+0xa4>
        x1 = x+getpid();
    }
    else{
        if(read(pipefd[0],&c,4)<0){
  1c:	4611                	li	a2,4
  1e:	fd840593          	addi	a1,s0,-40
  22:	00001517          	auipc	a0,0x1
  26:	ad652503          	lw	a0,-1322(a0) # af8 <pipefd>
  2a:	00000097          	auipc	ra,0x0
  2e:	464080e7          	jalr	1124(ra) # 48e <read>
  32:	08054563          	bltz	a0,bc <fun+0xbc>
            fprintf(2,"Error in reading from pipeline. Aborting...\n");
            exit(1);
        }
        int pid = getpid();
  36:	00000097          	auipc	ra,0x0
  3a:	4c0080e7          	jalr	1216(ra) # 4f6 <getpid>
        x1 = c+pid;
  3e:	fd842783          	lw	a5,-40(s0)
  42:	9fa9                	addw	a5,a5,a0
  44:	fcf42e23          	sw	a5,-36(s0)
    }
    if(write(pipefd[1],&x1,4)<0){
  48:	4611                	li	a2,4
  4a:	fdc40593          	addi	a1,s0,-36
  4e:	00001517          	auipc	a0,0x1
  52:	aae52503          	lw	a0,-1362(a0) # afc <pipefd+0x4>
  56:	00000097          	auipc	ra,0x0
  5a:	440080e7          	jalr	1088(ra) # 496 <write>
  5e:	06054d63          	bltz	a0,d8 <fun+0xd8>
        fprintf(2,"Error in writing to pipeline. Aborting...\n");
        exit(1);
    }
    printf("%d: %d\n",getpid(),x1);
  62:	00000097          	auipc	ra,0x0
  66:	494080e7          	jalr	1172(ra) # 4f6 <getpid>
  6a:	85aa                	mv	a1,a0
  6c:	fdc42603          	lw	a2,-36(s0)
  70:	00001517          	auipc	a0,0x1
  74:	9b850513          	addi	a0,a0,-1608 # a28 <malloc+0x144>
  78:	00000097          	auipc	ra,0x0
  7c:	7ae080e7          	jalr	1966(ra) # 826 <printf>
    int f = fork();
  80:	00000097          	auipc	ra,0x0
  84:	3ee080e7          	jalr	1006(ra) # 46e <fork>
    if(f<0){
  88:	06054663          	bltz	a0,f4 <fun+0xf4>
	    fprintf(2,"Error in fork. Aborting...\n");
	    exit(1);
    }
    if(f==0){
  8c:	e151                	bnez	a0,110 <fun+0x110>
        // sleep(1);
        fun(m-1);
  8e:	fff4851b          	addiw	a0,s1,-1
  92:	00000097          	auipc	ra,0x0
  96:	f6e080e7          	jalr	-146(ra) # 0 <fun>
        // printf("%d\n",m);
        wait(NULL);
    }
    return;

}
  9a:	70a2                	ld	ra,40(sp)
  9c:	7402                	ld	s0,32(sp)
  9e:	64e2                	ld	s1,24(sp)
  a0:	6145                	addi	sp,sp,48
  a2:	8082                	ret
        x1 = x+getpid();
  a4:	00000097          	auipc	ra,0x0
  a8:	452080e7          	jalr	1106(ra) # 4f6 <getpid>
  ac:	00001797          	auipc	a5,0x1
  b0:	a447a783          	lw	a5,-1468(a5) # af0 <x>
  b4:	9fa9                	addw	a5,a5,a0
  b6:	fcf42e23          	sw	a5,-36(s0)
  ba:	b779                	j	48 <fun+0x48>
            fprintf(2,"Error in reading from pipeline. Aborting...\n");
  bc:	00001597          	auipc	a1,0x1
  c0:	90c58593          	addi	a1,a1,-1780 # 9c8 <malloc+0xe4>
  c4:	4509                	li	a0,2
  c6:	00000097          	auipc	ra,0x0
  ca:	732080e7          	jalr	1842(ra) # 7f8 <fprintf>
            exit(1);
  ce:	4505                	li	a0,1
  d0:	00000097          	auipc	ra,0x0
  d4:	3a6080e7          	jalr	934(ra) # 476 <exit>
        fprintf(2,"Error in writing to pipeline. Aborting...\n");
  d8:	00001597          	auipc	a1,0x1
  dc:	92058593          	addi	a1,a1,-1760 # 9f8 <malloc+0x114>
  e0:	4509                	li	a0,2
  e2:	00000097          	auipc	ra,0x0
  e6:	716080e7          	jalr	1814(ra) # 7f8 <fprintf>
        exit(1);
  ea:	4505                	li	a0,1
  ec:	00000097          	auipc	ra,0x0
  f0:	38a080e7          	jalr	906(ra) # 476 <exit>
	    fprintf(2,"Error in fork. Aborting...\n");
  f4:	00001597          	auipc	a1,0x1
  f8:	93c58593          	addi	a1,a1,-1732 # a30 <malloc+0x14c>
  fc:	4509                	li	a0,2
  fe:	00000097          	auipc	ra,0x0
 102:	6fa080e7          	jalr	1786(ra) # 7f8 <fprintf>
	    exit(1);
 106:	4505                	li	a0,1
 108:	00000097          	auipc	ra,0x0
 10c:	36e080e7          	jalr	878(ra) # 476 <exit>
        close(pipefd[0]);
 110:	00001497          	auipc	s1,0x1
 114:	9e848493          	addi	s1,s1,-1560 # af8 <pipefd>
 118:	4088                	lw	a0,0(s1)
 11a:	00000097          	auipc	ra,0x0
 11e:	384080e7          	jalr	900(ra) # 49e <close>
        close(pipefd[1]);
 122:	40c8                	lw	a0,4(s1)
 124:	00000097          	auipc	ra,0x0
 128:	37a080e7          	jalr	890(ra) # 49e <close>
        wait(NULL);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	350080e7          	jalr	848(ra) # 47e <wait>
 136:	b795                	j	9a <fun+0x9a>
 138:	8082                	ret

000000000000013a <main>:

int main(int argc, char * argv[]){
 13a:	1101                	addi	sp,sp,-32
 13c:	ec06                	sd	ra,24(sp)
 13e:	e822                	sd	s0,16(sp)
 140:	e426                	sd	s1,8(sp)
 142:	e04a                	sd	s2,0(sp)
 144:	1000                	addi	s0,sp,32

    if(argc!=3){
 146:	478d                	li	a5,3
 148:	02f50063          	beq	a0,a5,168 <main+0x2e>
        fprintf(2,"syntax: pipeline <int> <int>\n");
 14c:	00001597          	auipc	a1,0x1
 150:	90458593          	addi	a1,a1,-1788 # a50 <malloc+0x16c>
 154:	4509                	li	a0,2
 156:	00000097          	auipc	ra,0x0
 15a:	6a2080e7          	jalr	1698(ra) # 7f8 <fprintf>
        exit(1);
 15e:	4505                	li	a0,1
 160:	00000097          	auipc	ra,0x0
 164:	316080e7          	jalr	790(ra) # 476 <exit>
 168:	84ae                	mv	s1,a1
    }
    n = atoi(argv[1]);
 16a:	6588                	ld	a0,8(a1)
 16c:	00000097          	auipc	ra,0x0
 170:	20a080e7          	jalr	522(ra) # 376 <atoi>
 174:	00001917          	auipc	s2,0x1
 178:	98090913          	addi	s2,s2,-1664 # af4 <n>
 17c:	00a92023          	sw	a0,0(s2)
    x = atoi(argv[2]);
 180:	6888                	ld	a0,16(s1)
 182:	00000097          	auipc	ra,0x0
 186:	1f4080e7          	jalr	500(ra) # 376 <atoi>
 18a:	00001797          	auipc	a5,0x1
 18e:	96a7a323          	sw	a0,-1690(a5) # af0 <x>
    if(n<=0){
 192:	00092783          	lw	a5,0(s2)
 196:	02f05963          	blez	a5,1c8 <main+0x8e>
        fprintf(2,"Error: first argument should be positive. Aborting...\n");
        exit(1);
    }
    if(pipe(pipefd)<0){
 19a:	00001517          	auipc	a0,0x1
 19e:	95e50513          	addi	a0,a0,-1698 # af8 <pipefd>
 1a2:	00000097          	auipc	ra,0x0
 1a6:	2e4080e7          	jalr	740(ra) # 486 <pipe>
 1aa:	02054d63          	bltz	a0,1e4 <main+0xaa>
        fprintf(2,"Error in creating pipe. Aboritng...\n");
        exit(1);
    }
    fun(n);
 1ae:	00001517          	auipc	a0,0x1
 1b2:	94652503          	lw	a0,-1722(a0) # af4 <n>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	e4a080e7          	jalr	-438(ra) # 0 <fun>
    exit(0);
 1be:	4501                	li	a0,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	2b6080e7          	jalr	694(ra) # 476 <exit>
        fprintf(2,"Error: first argument should be positive. Aborting...\n");
 1c8:	00001597          	auipc	a1,0x1
 1cc:	8a858593          	addi	a1,a1,-1880 # a70 <malloc+0x18c>
 1d0:	4509                	li	a0,2
 1d2:	00000097          	auipc	ra,0x0
 1d6:	626080e7          	jalr	1574(ra) # 7f8 <fprintf>
        exit(1);
 1da:	4505                	li	a0,1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	29a080e7          	jalr	666(ra) # 476 <exit>
        fprintf(2,"Error in creating pipe. Aboritng...\n");
 1e4:	00001597          	auipc	a1,0x1
 1e8:	8c458593          	addi	a1,a1,-1852 # aa8 <malloc+0x1c4>
 1ec:	4509                	li	a0,2
 1ee:	00000097          	auipc	ra,0x0
 1f2:	60a080e7          	jalr	1546(ra) # 7f8 <fprintf>
        exit(1);
 1f6:	4505                	li	a0,1
 1f8:	00000097          	auipc	ra,0x0
 1fc:	27e080e7          	jalr	638(ra) # 476 <exit>

0000000000000200 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 206:	87aa                	mv	a5,a0
 208:	0585                	addi	a1,a1,1
 20a:	0785                	addi	a5,a5,1
 20c:	fff5c703          	lbu	a4,-1(a1)
 210:	fee78fa3          	sb	a4,-1(a5)
 214:	fb75                	bnez	a4,208 <strcpy+0x8>
    ;
  return os;
}
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret

000000000000021c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 222:	00054783          	lbu	a5,0(a0)
 226:	cb91                	beqz	a5,23a <strcmp+0x1e>
 228:	0005c703          	lbu	a4,0(a1)
 22c:	00f71763          	bne	a4,a5,23a <strcmp+0x1e>
    p++, q++;
 230:	0505                	addi	a0,a0,1
 232:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 234:	00054783          	lbu	a5,0(a0)
 238:	fbe5                	bnez	a5,228 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 23a:	0005c503          	lbu	a0,0(a1)
}
 23e:	40a7853b          	subw	a0,a5,a0
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret

0000000000000248 <strlen>:

uint
strlen(const char *s)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 24e:	00054783          	lbu	a5,0(a0)
 252:	cf91                	beqz	a5,26e <strlen+0x26>
 254:	0505                	addi	a0,a0,1
 256:	87aa                	mv	a5,a0
 258:	4685                	li	a3,1
 25a:	9e89                	subw	a3,a3,a0
 25c:	00f6853b          	addw	a0,a3,a5
 260:	0785                	addi	a5,a5,1
 262:	fff7c703          	lbu	a4,-1(a5)
 266:	fb7d                	bnez	a4,25c <strlen+0x14>
    ;
  return n;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
  for(n = 0; s[n]; n++)
 26e:	4501                	li	a0,0
 270:	bfe5                	j	268 <strlen+0x20>

0000000000000272 <memset>:

void*
memset(void *dst, int c, uint n)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 278:	ce09                	beqz	a2,292 <memset+0x20>
 27a:	87aa                	mv	a5,a0
 27c:	fff6071b          	addiw	a4,a2,-1
 280:	1702                	slli	a4,a4,0x20
 282:	9301                	srli	a4,a4,0x20
 284:	0705                	addi	a4,a4,1
 286:	972a                	add	a4,a4,a0
    cdst[i] = c;
 288:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 28c:	0785                	addi	a5,a5,1
 28e:	fee79de3          	bne	a5,a4,288 <memset+0x16>
  }
  return dst;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <strchr>:

char*
strchr(const char *s, char c)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	cb99                	beqz	a5,2b8 <strchr+0x20>
    if(*s == c)
 2a4:	00f58763          	beq	a1,a5,2b2 <strchr+0x1a>
  for(; *s; s++)
 2a8:	0505                	addi	a0,a0,1
 2aa:	00054783          	lbu	a5,0(a0)
 2ae:	fbfd                	bnez	a5,2a4 <strchr+0xc>
      return (char*)s;
  return 0;
 2b0:	4501                	li	a0,0
}
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
  return 0;
 2b8:	4501                	li	a0,0
 2ba:	bfe5                	j	2b2 <strchr+0x1a>

00000000000002bc <gets>:

char*
gets(char *buf, int max)
{
 2bc:	711d                	addi	sp,sp,-96
 2be:	ec86                	sd	ra,88(sp)
 2c0:	e8a2                	sd	s0,80(sp)
 2c2:	e4a6                	sd	s1,72(sp)
 2c4:	e0ca                	sd	s2,64(sp)
 2c6:	fc4e                	sd	s3,56(sp)
 2c8:	f852                	sd	s4,48(sp)
 2ca:	f456                	sd	s5,40(sp)
 2cc:	f05a                	sd	s6,32(sp)
 2ce:	ec5e                	sd	s7,24(sp)
 2d0:	1080                	addi	s0,sp,96
 2d2:	8baa                	mv	s7,a0
 2d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d6:	892a                	mv	s2,a0
 2d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2da:	4aa9                	li	s5,10
 2dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2de:	89a6                	mv	s3,s1
 2e0:	2485                	addiw	s1,s1,1
 2e2:	0344d863          	bge	s1,s4,312 <gets+0x56>
    cc = read(0, &c, 1);
 2e6:	4605                	li	a2,1
 2e8:	faf40593          	addi	a1,s0,-81
 2ec:	4501                	li	a0,0
 2ee:	00000097          	auipc	ra,0x0
 2f2:	1a0080e7          	jalr	416(ra) # 48e <read>
    if(cc < 1)
 2f6:	00a05e63          	blez	a0,312 <gets+0x56>
    buf[i++] = c;
 2fa:	faf44783          	lbu	a5,-81(s0)
 2fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 302:	01578763          	beq	a5,s5,310 <gets+0x54>
 306:	0905                	addi	s2,s2,1
 308:	fd679be3          	bne	a5,s6,2de <gets+0x22>
  for(i=0; i+1 < max; ){
 30c:	89a6                	mv	s3,s1
 30e:	a011                	j	312 <gets+0x56>
 310:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 312:	99de                	add	s3,s3,s7
 314:	00098023          	sb	zero,0(s3)
  return buf;
}
 318:	855e                	mv	a0,s7
 31a:	60e6                	ld	ra,88(sp)
 31c:	6446                	ld	s0,80(sp)
 31e:	64a6                	ld	s1,72(sp)
 320:	6906                	ld	s2,64(sp)
 322:	79e2                	ld	s3,56(sp)
 324:	7a42                	ld	s4,48(sp)
 326:	7aa2                	ld	s5,40(sp)
 328:	7b02                	ld	s6,32(sp)
 32a:	6be2                	ld	s7,24(sp)
 32c:	6125                	addi	sp,sp,96
 32e:	8082                	ret

0000000000000330 <stat>:

int
stat(const char *n, struct stat *st)
{
 330:	1101                	addi	sp,sp,-32
 332:	ec06                	sd	ra,24(sp)
 334:	e822                	sd	s0,16(sp)
 336:	e426                	sd	s1,8(sp)
 338:	e04a                	sd	s2,0(sp)
 33a:	1000                	addi	s0,sp,32
 33c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33e:	4581                	li	a1,0
 340:	00000097          	auipc	ra,0x0
 344:	176080e7          	jalr	374(ra) # 4b6 <open>
  if(fd < 0)
 348:	02054563          	bltz	a0,372 <stat+0x42>
 34c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 34e:	85ca                	mv	a1,s2
 350:	00000097          	auipc	ra,0x0
 354:	17e080e7          	jalr	382(ra) # 4ce <fstat>
 358:	892a                	mv	s2,a0
  close(fd);
 35a:	8526                	mv	a0,s1
 35c:	00000097          	auipc	ra,0x0
 360:	142080e7          	jalr	322(ra) # 49e <close>
  return r;
}
 364:	854a                	mv	a0,s2
 366:	60e2                	ld	ra,24(sp)
 368:	6442                	ld	s0,16(sp)
 36a:	64a2                	ld	s1,8(sp)
 36c:	6902                	ld	s2,0(sp)
 36e:	6105                	addi	sp,sp,32
 370:	8082                	ret
    return -1;
 372:	597d                	li	s2,-1
 374:	bfc5                	j	364 <stat+0x34>

0000000000000376 <atoi>:

int
atoi(const char *s)
{
 376:	1141                	addi	sp,sp,-16
 378:	e422                	sd	s0,8(sp)
 37a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 37c:	00054603          	lbu	a2,0(a0)
 380:	fd06079b          	addiw	a5,a2,-48
 384:	0ff7f793          	andi	a5,a5,255
 388:	4725                	li	a4,9
 38a:	02f76963          	bltu	a4,a5,3bc <atoi+0x46>
 38e:	86aa                	mv	a3,a0
  n = 0;
 390:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 392:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 394:	0685                	addi	a3,a3,1
 396:	0025179b          	slliw	a5,a0,0x2
 39a:	9fa9                	addw	a5,a5,a0
 39c:	0017979b          	slliw	a5,a5,0x1
 3a0:	9fb1                	addw	a5,a5,a2
 3a2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3a6:	0006c603          	lbu	a2,0(a3)
 3aa:	fd06071b          	addiw	a4,a2,-48
 3ae:	0ff77713          	andi	a4,a4,255
 3b2:	fee5f1e3          	bgeu	a1,a4,394 <atoi+0x1e>
  return n;
}
 3b6:	6422                	ld	s0,8(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  n = 0;
 3bc:	4501                	li	a0,0
 3be:	bfe5                	j	3b6 <atoi+0x40>

00000000000003c0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3c6:	02b57663          	bgeu	a0,a1,3f2 <memmove+0x32>
    while(n-- > 0)
 3ca:	02c05163          	blez	a2,3ec <memmove+0x2c>
 3ce:	fff6079b          	addiw	a5,a2,-1
 3d2:	1782                	slli	a5,a5,0x20
 3d4:	9381                	srli	a5,a5,0x20
 3d6:	0785                	addi	a5,a5,1
 3d8:	97aa                	add	a5,a5,a0
  dst = vdst;
 3da:	872a                	mv	a4,a0
      *dst++ = *src++;
 3dc:	0585                	addi	a1,a1,1
 3de:	0705                	addi	a4,a4,1
 3e0:	fff5c683          	lbu	a3,-1(a1)
 3e4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3e8:	fee79ae3          	bne	a5,a4,3dc <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ec:	6422                	ld	s0,8(sp)
 3ee:	0141                	addi	sp,sp,16
 3f0:	8082                	ret
    dst += n;
 3f2:	00c50733          	add	a4,a0,a2
    src += n;
 3f6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3f8:	fec05ae3          	blez	a2,3ec <memmove+0x2c>
 3fc:	fff6079b          	addiw	a5,a2,-1
 400:	1782                	slli	a5,a5,0x20
 402:	9381                	srli	a5,a5,0x20
 404:	fff7c793          	not	a5,a5
 408:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 40a:	15fd                	addi	a1,a1,-1
 40c:	177d                	addi	a4,a4,-1
 40e:	0005c683          	lbu	a3,0(a1)
 412:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 416:	fee79ae3          	bne	a5,a4,40a <memmove+0x4a>
 41a:	bfc9                	j	3ec <memmove+0x2c>

000000000000041c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 41c:	1141                	addi	sp,sp,-16
 41e:	e422                	sd	s0,8(sp)
 420:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 422:	ca05                	beqz	a2,452 <memcmp+0x36>
 424:	fff6069b          	addiw	a3,a2,-1
 428:	1682                	slli	a3,a3,0x20
 42a:	9281                	srli	a3,a3,0x20
 42c:	0685                	addi	a3,a3,1
 42e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 430:	00054783          	lbu	a5,0(a0)
 434:	0005c703          	lbu	a4,0(a1)
 438:	00e79863          	bne	a5,a4,448 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 43c:	0505                	addi	a0,a0,1
    p2++;
 43e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 440:	fed518e3          	bne	a0,a3,430 <memcmp+0x14>
  }
  return 0;
 444:	4501                	li	a0,0
 446:	a019                	j	44c <memcmp+0x30>
      return *p1 - *p2;
 448:	40e7853b          	subw	a0,a5,a4
}
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret
  return 0;
 452:	4501                	li	a0,0
 454:	bfe5                	j	44c <memcmp+0x30>

0000000000000456 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 456:	1141                	addi	sp,sp,-16
 458:	e406                	sd	ra,8(sp)
 45a:	e022                	sd	s0,0(sp)
 45c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 45e:	00000097          	auipc	ra,0x0
 462:	f62080e7          	jalr	-158(ra) # 3c0 <memmove>
}
 466:	60a2                	ld	ra,8(sp)
 468:	6402                	ld	s0,0(sp)
 46a:	0141                	addi	sp,sp,16
 46c:	8082                	ret

000000000000046e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 46e:	4885                	li	a7,1
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <exit>:
.global exit
exit:
 li a7, SYS_exit
 476:	4889                	li	a7,2
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <wait>:
.global wait
wait:
 li a7, SYS_wait
 47e:	488d                	li	a7,3
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 486:	4891                	li	a7,4
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <read>:
.global read
read:
 li a7, SYS_read
 48e:	4895                	li	a7,5
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <write>:
.global write
write:
 li a7, SYS_write
 496:	48c1                	li	a7,16
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <close>:
.global close
close:
 li a7, SYS_close
 49e:	48d5                	li	a7,21
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a6:	4899                	li	a7,6
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ae:	489d                	li	a7,7
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <open>:
.global open
open:
 li a7, SYS_open
 4b6:	48bd                	li	a7,15
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4be:	48c5                	li	a7,17
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c6:	48c9                	li	a7,18
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ce:	48a1                	li	a7,8
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <link>:
.global link
link:
 li a7, SYS_link
 4d6:	48cd                	li	a7,19
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4de:	48d1                	li	a7,20
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e6:	48a5                	li	a7,9
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ee:	48a9                	li	a7,10
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f6:	48ad                	li	a7,11
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4fe:	48b1                	li	a7,12
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 506:	48b5                	li	a7,13
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 50e:	48b9                	li	a7,14
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 516:	48d9                	li	a7,22
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <yield>:
.global yield
yield:
 li a7, SYS_yield
 51e:	48dd                	li	a7,23
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 526:	48e1                	li	a7,24
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 52e:	48e5                	li	a7,25
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 536:	48e9                	li	a7,26
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <ps>:
.global ps
ps:
 li a7, SYS_ps
 53e:	48ed                	li	a7,27
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 546:	48f1                	li	a7,28
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 54e:	1101                	addi	sp,sp,-32
 550:	ec06                	sd	ra,24(sp)
 552:	e822                	sd	s0,16(sp)
 554:	1000                	addi	s0,sp,32
 556:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 55a:	4605                	li	a2,1
 55c:	fef40593          	addi	a1,s0,-17
 560:	00000097          	auipc	ra,0x0
 564:	f36080e7          	jalr	-202(ra) # 496 <write>
}
 568:	60e2                	ld	ra,24(sp)
 56a:	6442                	ld	s0,16(sp)
 56c:	6105                	addi	sp,sp,32
 56e:	8082                	ret

0000000000000570 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 570:	7139                	addi	sp,sp,-64
 572:	fc06                	sd	ra,56(sp)
 574:	f822                	sd	s0,48(sp)
 576:	f426                	sd	s1,40(sp)
 578:	f04a                	sd	s2,32(sp)
 57a:	ec4e                	sd	s3,24(sp)
 57c:	0080                	addi	s0,sp,64
 57e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 580:	c299                	beqz	a3,586 <printint+0x16>
 582:	0805c863          	bltz	a1,612 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 586:	2581                	sext.w	a1,a1
  neg = 0;
 588:	4881                	li	a7,0
 58a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 58e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 590:	2601                	sext.w	a2,a2
 592:	00000517          	auipc	a0,0x0
 596:	54650513          	addi	a0,a0,1350 # ad8 <digits>
 59a:	883a                	mv	a6,a4
 59c:	2705                	addiw	a4,a4,1
 59e:	02c5f7bb          	remuw	a5,a1,a2
 5a2:	1782                	slli	a5,a5,0x20
 5a4:	9381                	srli	a5,a5,0x20
 5a6:	97aa                	add	a5,a5,a0
 5a8:	0007c783          	lbu	a5,0(a5)
 5ac:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5b0:	0005879b          	sext.w	a5,a1
 5b4:	02c5d5bb          	divuw	a1,a1,a2
 5b8:	0685                	addi	a3,a3,1
 5ba:	fec7f0e3          	bgeu	a5,a2,59a <printint+0x2a>
  if(neg)
 5be:	00088b63          	beqz	a7,5d4 <printint+0x64>
    buf[i++] = '-';
 5c2:	fd040793          	addi	a5,s0,-48
 5c6:	973e                	add	a4,a4,a5
 5c8:	02d00793          	li	a5,45
 5cc:	fef70823          	sb	a5,-16(a4)
 5d0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5d4:	02e05863          	blez	a4,604 <printint+0x94>
 5d8:	fc040793          	addi	a5,s0,-64
 5dc:	00e78933          	add	s2,a5,a4
 5e0:	fff78993          	addi	s3,a5,-1
 5e4:	99ba                	add	s3,s3,a4
 5e6:	377d                	addiw	a4,a4,-1
 5e8:	1702                	slli	a4,a4,0x20
 5ea:	9301                	srli	a4,a4,0x20
 5ec:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5f0:	fff94583          	lbu	a1,-1(s2)
 5f4:	8526                	mv	a0,s1
 5f6:	00000097          	auipc	ra,0x0
 5fa:	f58080e7          	jalr	-168(ra) # 54e <putc>
  while(--i >= 0)
 5fe:	197d                	addi	s2,s2,-1
 600:	ff3918e3          	bne	s2,s3,5f0 <printint+0x80>
}
 604:	70e2                	ld	ra,56(sp)
 606:	7442                	ld	s0,48(sp)
 608:	74a2                	ld	s1,40(sp)
 60a:	7902                	ld	s2,32(sp)
 60c:	69e2                	ld	s3,24(sp)
 60e:	6121                	addi	sp,sp,64
 610:	8082                	ret
    x = -xx;
 612:	40b005bb          	negw	a1,a1
    neg = 1;
 616:	4885                	li	a7,1
    x = -xx;
 618:	bf8d                	j	58a <printint+0x1a>

000000000000061a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 61a:	7119                	addi	sp,sp,-128
 61c:	fc86                	sd	ra,120(sp)
 61e:	f8a2                	sd	s0,112(sp)
 620:	f4a6                	sd	s1,104(sp)
 622:	f0ca                	sd	s2,96(sp)
 624:	ecce                	sd	s3,88(sp)
 626:	e8d2                	sd	s4,80(sp)
 628:	e4d6                	sd	s5,72(sp)
 62a:	e0da                	sd	s6,64(sp)
 62c:	fc5e                	sd	s7,56(sp)
 62e:	f862                	sd	s8,48(sp)
 630:	f466                	sd	s9,40(sp)
 632:	f06a                	sd	s10,32(sp)
 634:	ec6e                	sd	s11,24(sp)
 636:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 638:	0005c903          	lbu	s2,0(a1)
 63c:	18090f63          	beqz	s2,7da <vprintf+0x1c0>
 640:	8aaa                	mv	s5,a0
 642:	8b32                	mv	s6,a2
 644:	00158493          	addi	s1,a1,1
  state = 0;
 648:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 64a:	02500a13          	li	s4,37
      if(c == 'd'){
 64e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 652:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 656:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 65a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65e:	00000b97          	auipc	s7,0x0
 662:	47ab8b93          	addi	s7,s7,1146 # ad8 <digits>
 666:	a839                	j	684 <vprintf+0x6a>
        putc(fd, c);
 668:	85ca                	mv	a1,s2
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	ee2080e7          	jalr	-286(ra) # 54e <putc>
 674:	a019                	j	67a <vprintf+0x60>
    } else if(state == '%'){
 676:	01498f63          	beq	s3,s4,694 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 67a:	0485                	addi	s1,s1,1
 67c:	fff4c903          	lbu	s2,-1(s1)
 680:	14090d63          	beqz	s2,7da <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 684:	0009079b          	sext.w	a5,s2
    if(state == 0){
 688:	fe0997e3          	bnez	s3,676 <vprintf+0x5c>
      if(c == '%'){
 68c:	fd479ee3          	bne	a5,s4,668 <vprintf+0x4e>
        state = '%';
 690:	89be                	mv	s3,a5
 692:	b7e5                	j	67a <vprintf+0x60>
      if(c == 'd'){
 694:	05878063          	beq	a5,s8,6d4 <vprintf+0xba>
      } else if(c == 'l') {
 698:	05978c63          	beq	a5,s9,6f0 <vprintf+0xd6>
      } else if(c == 'x') {
 69c:	07a78863          	beq	a5,s10,70c <vprintf+0xf2>
      } else if(c == 'p') {
 6a0:	09b78463          	beq	a5,s11,728 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6a4:	07300713          	li	a4,115
 6a8:	0ce78663          	beq	a5,a4,774 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6ac:	06300713          	li	a4,99
 6b0:	0ee78e63          	beq	a5,a4,7ac <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6b4:	11478863          	beq	a5,s4,7c4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6b8:	85d2                	mv	a1,s4
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	e92080e7          	jalr	-366(ra) # 54e <putc>
        putc(fd, c);
 6c4:	85ca                	mv	a1,s2
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e86080e7          	jalr	-378(ra) # 54e <putc>
      }
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b765                	j	67a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6d4:	008b0913          	addi	s2,s6,8
 6d8:	4685                	li	a3,1
 6da:	4629                	li	a2,10
 6dc:	000b2583          	lw	a1,0(s6)
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	e8e080e7          	jalr	-370(ra) # 570 <printint>
 6ea:	8b4a                	mv	s6,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b771                	j	67a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f0:	008b0913          	addi	s2,s6,8
 6f4:	4681                	li	a3,0
 6f6:	4629                	li	a2,10
 6f8:	000b2583          	lw	a1,0(s6)
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e72080e7          	jalr	-398(ra) # 570 <printint>
 706:	8b4a                	mv	s6,s2
      state = 0;
 708:	4981                	li	s3,0
 70a:	bf85                	j	67a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 70c:	008b0913          	addi	s2,s6,8
 710:	4681                	li	a3,0
 712:	4641                	li	a2,16
 714:	000b2583          	lw	a1,0(s6)
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	e56080e7          	jalr	-426(ra) # 570 <printint>
 722:	8b4a                	mv	s6,s2
      state = 0;
 724:	4981                	li	s3,0
 726:	bf91                	j	67a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 728:	008b0793          	addi	a5,s6,8
 72c:	f8f43423          	sd	a5,-120(s0)
 730:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 734:	03000593          	li	a1,48
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	e14080e7          	jalr	-492(ra) # 54e <putc>
  putc(fd, 'x');
 742:	85ea                	mv	a1,s10
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	e08080e7          	jalr	-504(ra) # 54e <putc>
 74e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 750:	03c9d793          	srli	a5,s3,0x3c
 754:	97de                	add	a5,a5,s7
 756:	0007c583          	lbu	a1,0(a5)
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	df2080e7          	jalr	-526(ra) # 54e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 764:	0992                	slli	s3,s3,0x4
 766:	397d                	addiw	s2,s2,-1
 768:	fe0914e3          	bnez	s2,750 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 76c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 770:	4981                	li	s3,0
 772:	b721                	j	67a <vprintf+0x60>
        s = va_arg(ap, char*);
 774:	008b0993          	addi	s3,s6,8
 778:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 77c:	02090163          	beqz	s2,79e <vprintf+0x184>
        while(*s != 0){
 780:	00094583          	lbu	a1,0(s2)
 784:	c9a1                	beqz	a1,7d4 <vprintf+0x1ba>
          putc(fd, *s);
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	dc6080e7          	jalr	-570(ra) # 54e <putc>
          s++;
 790:	0905                	addi	s2,s2,1
        while(*s != 0){
 792:	00094583          	lbu	a1,0(s2)
 796:	f9e5                	bnez	a1,786 <vprintf+0x16c>
        s = va_arg(ap, char*);
 798:	8b4e                	mv	s6,s3
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bdf9                	j	67a <vprintf+0x60>
          s = "(null)";
 79e:	00000917          	auipc	s2,0x0
 7a2:	33290913          	addi	s2,s2,818 # ad0 <malloc+0x1ec>
        while(*s != 0){
 7a6:	02800593          	li	a1,40
 7aa:	bff1                	j	786 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7ac:	008b0913          	addi	s2,s6,8
 7b0:	000b4583          	lbu	a1,0(s6)
 7b4:	8556                	mv	a0,s5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	d98080e7          	jalr	-616(ra) # 54e <putc>
 7be:	8b4a                	mv	s6,s2
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	bd65                	j	67a <vprintf+0x60>
        putc(fd, c);
 7c4:	85d2                	mv	a1,s4
 7c6:	8556                	mv	a0,s5
 7c8:	00000097          	auipc	ra,0x0
 7cc:	d86080e7          	jalr	-634(ra) # 54e <putc>
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	b565                	j	67a <vprintf+0x60>
        s = va_arg(ap, char*);
 7d4:	8b4e                	mv	s6,s3
      state = 0;
 7d6:	4981                	li	s3,0
 7d8:	b54d                	j	67a <vprintf+0x60>
    }
  }
}
 7da:	70e6                	ld	ra,120(sp)
 7dc:	7446                	ld	s0,112(sp)
 7de:	74a6                	ld	s1,104(sp)
 7e0:	7906                	ld	s2,96(sp)
 7e2:	69e6                	ld	s3,88(sp)
 7e4:	6a46                	ld	s4,80(sp)
 7e6:	6aa6                	ld	s5,72(sp)
 7e8:	6b06                	ld	s6,64(sp)
 7ea:	7be2                	ld	s7,56(sp)
 7ec:	7c42                	ld	s8,48(sp)
 7ee:	7ca2                	ld	s9,40(sp)
 7f0:	7d02                	ld	s10,32(sp)
 7f2:	6de2                	ld	s11,24(sp)
 7f4:	6109                	addi	sp,sp,128
 7f6:	8082                	ret

00000000000007f8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7f8:	715d                	addi	sp,sp,-80
 7fa:	ec06                	sd	ra,24(sp)
 7fc:	e822                	sd	s0,16(sp)
 7fe:	1000                	addi	s0,sp,32
 800:	e010                	sd	a2,0(s0)
 802:	e414                	sd	a3,8(s0)
 804:	e818                	sd	a4,16(s0)
 806:	ec1c                	sd	a5,24(s0)
 808:	03043023          	sd	a6,32(s0)
 80c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 810:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 814:	8622                	mv	a2,s0
 816:	00000097          	auipc	ra,0x0
 81a:	e04080e7          	jalr	-508(ra) # 61a <vprintf>
}
 81e:	60e2                	ld	ra,24(sp)
 820:	6442                	ld	s0,16(sp)
 822:	6161                	addi	sp,sp,80
 824:	8082                	ret

0000000000000826 <printf>:

void
printf(const char *fmt, ...)
{
 826:	711d                	addi	sp,sp,-96
 828:	ec06                	sd	ra,24(sp)
 82a:	e822                	sd	s0,16(sp)
 82c:	1000                	addi	s0,sp,32
 82e:	e40c                	sd	a1,8(s0)
 830:	e810                	sd	a2,16(s0)
 832:	ec14                	sd	a3,24(s0)
 834:	f018                	sd	a4,32(s0)
 836:	f41c                	sd	a5,40(s0)
 838:	03043823          	sd	a6,48(s0)
 83c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 840:	00840613          	addi	a2,s0,8
 844:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 848:	85aa                	mv	a1,a0
 84a:	4505                	li	a0,1
 84c:	00000097          	auipc	ra,0x0
 850:	dce080e7          	jalr	-562(ra) # 61a <vprintf>
}
 854:	60e2                	ld	ra,24(sp)
 856:	6442                	ld	s0,16(sp)
 858:	6125                	addi	sp,sp,96
 85a:	8082                	ret

000000000000085c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 85c:	1141                	addi	sp,sp,-16
 85e:	e422                	sd	s0,8(sp)
 860:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 862:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 866:	00000797          	auipc	a5,0x0
 86a:	29a7b783          	ld	a5,666(a5) # b00 <freep>
 86e:	a805                	j	89e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 870:	4618                	lw	a4,8(a2)
 872:	9db9                	addw	a1,a1,a4
 874:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 878:	6398                	ld	a4,0(a5)
 87a:	6318                	ld	a4,0(a4)
 87c:	fee53823          	sd	a4,-16(a0)
 880:	a091                	j	8c4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 882:	ff852703          	lw	a4,-8(a0)
 886:	9e39                	addw	a2,a2,a4
 888:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 88a:	ff053703          	ld	a4,-16(a0)
 88e:	e398                	sd	a4,0(a5)
 890:	a099                	j	8d6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 892:	6398                	ld	a4,0(a5)
 894:	00e7e463          	bltu	a5,a4,89c <free+0x40>
 898:	00e6ea63          	bltu	a3,a4,8ac <free+0x50>
{
 89c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89e:	fed7fae3          	bgeu	a5,a3,892 <free+0x36>
 8a2:	6398                	ld	a4,0(a5)
 8a4:	00e6e463          	bltu	a3,a4,8ac <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a8:	fee7eae3          	bltu	a5,a4,89c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8ac:	ff852583          	lw	a1,-8(a0)
 8b0:	6390                	ld	a2,0(a5)
 8b2:	02059713          	slli	a4,a1,0x20
 8b6:	9301                	srli	a4,a4,0x20
 8b8:	0712                	slli	a4,a4,0x4
 8ba:	9736                	add	a4,a4,a3
 8bc:	fae60ae3          	beq	a2,a4,870 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c4:	4790                	lw	a2,8(a5)
 8c6:	02061713          	slli	a4,a2,0x20
 8ca:	9301                	srli	a4,a4,0x20
 8cc:	0712                	slli	a4,a4,0x4
 8ce:	973e                	add	a4,a4,a5
 8d0:	fae689e3          	beq	a3,a4,882 <free+0x26>
  } else
    p->s.ptr = bp;
 8d4:	e394                	sd	a3,0(a5)
  freep = p;
 8d6:	00000717          	auipc	a4,0x0
 8da:	22f73523          	sd	a5,554(a4) # b00 <freep>
}
 8de:	6422                	ld	s0,8(sp)
 8e0:	0141                	addi	sp,sp,16
 8e2:	8082                	ret

00000000000008e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e4:	7139                	addi	sp,sp,-64
 8e6:	fc06                	sd	ra,56(sp)
 8e8:	f822                	sd	s0,48(sp)
 8ea:	f426                	sd	s1,40(sp)
 8ec:	f04a                	sd	s2,32(sp)
 8ee:	ec4e                	sd	s3,24(sp)
 8f0:	e852                	sd	s4,16(sp)
 8f2:	e456                	sd	s5,8(sp)
 8f4:	e05a                	sd	s6,0(sp)
 8f6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f8:	02051493          	slli	s1,a0,0x20
 8fc:	9081                	srli	s1,s1,0x20
 8fe:	04bd                	addi	s1,s1,15
 900:	8091                	srli	s1,s1,0x4
 902:	0014899b          	addiw	s3,s1,1
 906:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 908:	00000517          	auipc	a0,0x0
 90c:	1f853503          	ld	a0,504(a0) # b00 <freep>
 910:	c515                	beqz	a0,93c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 912:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 914:	4798                	lw	a4,8(a5)
 916:	02977f63          	bgeu	a4,s1,954 <malloc+0x70>
 91a:	8a4e                	mv	s4,s3
 91c:	0009871b          	sext.w	a4,s3
 920:	6685                	lui	a3,0x1
 922:	00d77363          	bgeu	a4,a3,928 <malloc+0x44>
 926:	6a05                	lui	s4,0x1
 928:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 930:	00000917          	auipc	s2,0x0
 934:	1d090913          	addi	s2,s2,464 # b00 <freep>
  if(p == (char*)-1)
 938:	5afd                	li	s5,-1
 93a:	a88d                	j	9ac <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 93c:	00000797          	auipc	a5,0x0
 940:	1cc78793          	addi	a5,a5,460 # b08 <base>
 944:	00000717          	auipc	a4,0x0
 948:	1af73e23          	sd	a5,444(a4) # b00 <freep>
 94c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 94e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 952:	b7e1                	j	91a <malloc+0x36>
      if(p->s.size == nunits)
 954:	02e48b63          	beq	s1,a4,98a <malloc+0xa6>
        p->s.size -= nunits;
 958:	4137073b          	subw	a4,a4,s3
 95c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 95e:	1702                	slli	a4,a4,0x20
 960:	9301                	srli	a4,a4,0x20
 962:	0712                	slli	a4,a4,0x4
 964:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 966:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96a:	00000717          	auipc	a4,0x0
 96e:	18a73b23          	sd	a0,406(a4) # b00 <freep>
      return (void*)(p + 1);
 972:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 976:	70e2                	ld	ra,56(sp)
 978:	7442                	ld	s0,48(sp)
 97a:	74a2                	ld	s1,40(sp)
 97c:	7902                	ld	s2,32(sp)
 97e:	69e2                	ld	s3,24(sp)
 980:	6a42                	ld	s4,16(sp)
 982:	6aa2                	ld	s5,8(sp)
 984:	6b02                	ld	s6,0(sp)
 986:	6121                	addi	sp,sp,64
 988:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 98a:	6398                	ld	a4,0(a5)
 98c:	e118                	sd	a4,0(a0)
 98e:	bff1                	j	96a <malloc+0x86>
  hp->s.size = nu;
 990:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 994:	0541                	addi	a0,a0,16
 996:	00000097          	auipc	ra,0x0
 99a:	ec6080e7          	jalr	-314(ra) # 85c <free>
  return freep;
 99e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9a2:	d971                	beqz	a0,976 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a6:	4798                	lw	a4,8(a5)
 9a8:	fa9776e3          	bgeu	a4,s1,954 <malloc+0x70>
    if(p == freep)
 9ac:	00093703          	ld	a4,0(s2)
 9b0:	853e                	mv	a0,a5
 9b2:	fef719e3          	bne	a4,a5,9a4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9b6:	8552                	mv	a0,s4
 9b8:	00000097          	auipc	ra,0x0
 9bc:	b46080e7          	jalr	-1210(ra) # 4fe <sbrk>
  if(p == (char*)-1)
 9c0:	fd5518e3          	bne	a0,s5,990 <malloc+0xac>
        return 0;
 9c4:	4501                	li	a0,0
 9c6:	bf45                	j	976 <malloc+0x92>
