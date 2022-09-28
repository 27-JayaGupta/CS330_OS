
user/_pinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/procstat.h"
#include "user/user.h"

int
main(void)
{
   0:	7159                	addi	sp,sp,-112
   2:	f486                	sd	ra,104(sp)
   4:	f0a2                	sd	s0,96(sp)
   6:	eca6                	sd	s1,88(sp)
   8:	1880                	addi	s0,sp,112
  struct procstat pstat;

  int x = fork();
   a:	00000097          	auipc	ra,0x0
   e:	41e080e7          	jalr	1054(ra) # 428 <fork>
  if (x < 0) {
  12:	0e054563          	bltz	a0,fc <main+0xfc>
  16:	84aa                	mv	s1,a0
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  18:	12a05463          	blez	a0,140 <main+0x140>
     sleep(2);
  1c:	4509                	li	a0,2
  1e:	00000097          	auipc	ra,0x0
  22:	4a2080e7          	jalr	1186(ra) # 4c0 <sleep>
     fprintf(1, "%d: Parent.\n", getpid());
  26:	00000097          	auipc	ra,0x0
  2a:	48a080e7          	jalr	1162(ra) # 4b0 <getpid>
  2e:	862a                	mv	a2,a0
  30:	00001597          	auipc	a1,0x1
  34:	97858593          	addi	a1,a1,-1672 # 9a8 <malloc+0x10a>
  38:	4505                	li	a0,1
  3a:	00000097          	auipc	ra,0x0
  3e:	778080e7          	jalr	1912(ra) # 7b2 <fprintf>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
  42:	fa840593          	addi	a1,s0,-88
  46:	557d                	li	a0,-1
  48:	00000097          	auipc	ra,0x0
  4c:	4b8080e7          	jalr	1208(ra) # 500 <pinfo>
  50:	0c054463          	bltz	a0,118 <main+0x118>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n",
  54:	fd843783          	ld	a5,-40(s0)
  58:	e43e                	sd	a5,8(sp)
  5a:	fd042783          	lw	a5,-48(s0)
  5e:	e03e                	sd	a5,0(sp)
  60:	fcc42883          	lw	a7,-52(s0)
  64:	fc842803          	lw	a6,-56(s0)
  68:	fb840793          	addi	a5,s0,-72
  6c:	fb040713          	addi	a4,s0,-80
  70:	fac42683          	lw	a3,-84(s0)
  74:	fa842603          	lw	a2,-88(s0)
  78:	00001597          	auipc	a1,0x1
  7c:	95858593          	addi	a1,a1,-1704 # 9d0 <malloc+0x132>
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	730080e7          	jalr	1840(ra) # 7b2 <fprintf>
         pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
     if (pinfo(x, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
  8a:	fa840593          	addi	a1,s0,-88
  8e:	8526                	mv	a0,s1
  90:	00000097          	auipc	ra,0x0
  94:	470080e7          	jalr	1136(ra) # 500 <pinfo>
  98:	08054a63          	bltz	a0,12c <main+0x12c>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n",
  9c:	fd843783          	ld	a5,-40(s0)
  a0:	e43e                	sd	a5,8(sp)
  a2:	fd042783          	lw	a5,-48(s0)
  a6:	e03e                	sd	a5,0(sp)
  a8:	fcc42883          	lw	a7,-52(s0)
  ac:	fc842803          	lw	a6,-56(s0)
  b0:	fb840793          	addi	a5,s0,-72
  b4:	fb040713          	addi	a4,s0,-80
  b8:	fac42683          	lw	a3,-84(s0)
  bc:	fa842603          	lw	a2,-88(s0)
  c0:	00001597          	auipc	a1,0x1
  c4:	96058593          	addi	a1,a1,-1696 # a20 <malloc+0x182>
  c8:	4505                	li	a0,1
  ca:	00000097          	auipc	ra,0x0
  ce:	6e8080e7          	jalr	1768(ra) # 7b2 <fprintf>
         pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
     fprintf(1, "Return value of waitpid=%d\n", waitpid(x, 0));
  d2:	4581                	li	a1,0
  d4:	8526                	mv	a0,s1
  d6:	00000097          	auipc	ra,0x0
  da:	41a080e7          	jalr	1050(ra) # 4f0 <waitpid>
  de:	862a                	mv	a2,a0
  e0:	00001597          	auipc	a1,0x1
  e4:	99058593          	addi	a1,a1,-1648 # a70 <malloc+0x1d2>
  e8:	4505                	li	a0,1
  ea:	00000097          	auipc	ra,0x0
  ee:	6c8080e7          	jalr	1736(ra) # 7b2 <fprintf>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n",
         pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
  }

  exit(0);
  f2:	4501                	li	a0,0
  f4:	00000097          	auipc	ra,0x0
  f8:	33c080e7          	jalr	828(ra) # 430 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
  fc:	00001597          	auipc	a1,0x1
 100:	88c58593          	addi	a1,a1,-1908 # 988 <malloc+0xea>
 104:	4509                	li	a0,2
 106:	00000097          	auipc	ra,0x0
 10a:	6ac080e7          	jalr	1708(ra) # 7b2 <fprintf>
     exit(0);
 10e:	4501                	li	a0,0
 110:	00000097          	auipc	ra,0x0
 114:	320080e7          	jalr	800(ra) # 430 <exit>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 118:	00001597          	auipc	a1,0x1
 11c:	8a058593          	addi	a1,a1,-1888 # 9b8 <malloc+0x11a>
 120:	4505                	li	a0,1
 122:	00000097          	auipc	ra,0x0
 126:	690080e7          	jalr	1680(ra) # 7b2 <fprintf>
 12a:	b785                	j	8a <main+0x8a>
     if (pinfo(x, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 12c:	00001597          	auipc	a1,0x1
 130:	88c58593          	addi	a1,a1,-1908 # 9b8 <malloc+0x11a>
 134:	4505                	li	a0,1
 136:	00000097          	auipc	ra,0x0
 13a:	67c080e7          	jalr	1660(ra) # 7b2 <fprintf>
 13e:	bf51                	j	d2 <main+0xd2>
     fprintf(1, "%d: Child.\n", getpid());
 140:	00000097          	auipc	ra,0x0
 144:	370080e7          	jalr	880(ra) # 4b0 <getpid>
 148:	862a                	mv	a2,a0
 14a:	00001597          	auipc	a1,0x1
 14e:	94658593          	addi	a1,a1,-1722 # a90 <malloc+0x1f2>
 152:	4505                	li	a0,1
 154:	00000097          	auipc	ra,0x0
 158:	65e080e7          	jalr	1630(ra) # 7b2 <fprintf>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 15c:	fa840593          	addi	a1,s0,-88
 160:	557d                	li	a0,-1
 162:	00000097          	auipc	ra,0x0
 166:	39e080e7          	jalr	926(ra) # 500 <pinfo>
 16a:	02054e63          	bltz	a0,1a6 <main+0x1a6>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n",
 16e:	fd843783          	ld	a5,-40(s0)
 172:	e43e                	sd	a5,8(sp)
 174:	fd042783          	lw	a5,-48(s0)
 178:	e03e                	sd	a5,0(sp)
 17a:	fcc42883          	lw	a7,-52(s0)
 17e:	fc842803          	lw	a6,-56(s0)
 182:	fb840793          	addi	a5,s0,-72
 186:	fb040713          	addi	a4,s0,-80
 18a:	fac42683          	lw	a3,-84(s0)
 18e:	fa842603          	lw	a2,-88(s0)
 192:	00001597          	auipc	a1,0x1
 196:	88e58593          	addi	a1,a1,-1906 # a20 <malloc+0x182>
 19a:	4505                	li	a0,1
 19c:	00000097          	auipc	ra,0x0
 1a0:	616080e7          	jalr	1558(ra) # 7b2 <fprintf>
 1a4:	b7b9                	j	f2 <main+0xf2>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 1a6:	00001597          	auipc	a1,0x1
 1aa:	81258593          	addi	a1,a1,-2030 # 9b8 <malloc+0x11a>
 1ae:	4505                	li	a0,1
 1b0:	00000097          	auipc	ra,0x0
 1b4:	602080e7          	jalr	1538(ra) # 7b2 <fprintf>
 1b8:	bf2d                	j	f2 <main+0xf2>

00000000000001ba <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c0:	87aa                	mv	a5,a0
 1c2:	0585                	addi	a1,a1,1
 1c4:	0785                	addi	a5,a5,1
 1c6:	fff5c703          	lbu	a4,-1(a1)
 1ca:	fee78fa3          	sb	a4,-1(a5)
 1ce:	fb75                	bnez	a4,1c2 <strcpy+0x8>
    ;
  return os;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret

00000000000001d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	cb91                	beqz	a5,1f4 <strcmp+0x1e>
 1e2:	0005c703          	lbu	a4,0(a1)
 1e6:	00f71763          	bne	a4,a5,1f4 <strcmp+0x1e>
    p++, q++;
 1ea:	0505                	addi	a0,a0,1
 1ec:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	fbe5                	bnez	a5,1e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1f4:	0005c503          	lbu	a0,0(a1)
}
 1f8:	40a7853b          	subw	a0,a5,a0
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret

0000000000000202 <strlen>:

uint
strlen(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 208:	00054783          	lbu	a5,0(a0)
 20c:	cf91                	beqz	a5,228 <strlen+0x26>
 20e:	0505                	addi	a0,a0,1
 210:	87aa                	mv	a5,a0
 212:	4685                	li	a3,1
 214:	9e89                	subw	a3,a3,a0
 216:	00f6853b          	addw	a0,a3,a5
 21a:	0785                	addi	a5,a5,1
 21c:	fff7c703          	lbu	a4,-1(a5)
 220:	fb7d                	bnez	a4,216 <strlen+0x14>
    ;
  return n;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
  for(n = 0; s[n]; n++)
 228:	4501                	li	a0,0
 22a:	bfe5                	j	222 <strlen+0x20>

000000000000022c <memset>:

void*
memset(void *dst, int c, uint n)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 232:	ce09                	beqz	a2,24c <memset+0x20>
 234:	87aa                	mv	a5,a0
 236:	fff6071b          	addiw	a4,a2,-1
 23a:	1702                	slli	a4,a4,0x20
 23c:	9301                	srli	a4,a4,0x20
 23e:	0705                	addi	a4,a4,1
 240:	972a                	add	a4,a4,a0
    cdst[i] = c;
 242:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 246:	0785                	addi	a5,a5,1
 248:	fee79de3          	bne	a5,a4,242 <memset+0x16>
  }
  return dst;
}
 24c:	6422                	ld	s0,8(sp)
 24e:	0141                	addi	sp,sp,16
 250:	8082                	ret

0000000000000252 <strchr>:

char*
strchr(const char *s, char c)
{
 252:	1141                	addi	sp,sp,-16
 254:	e422                	sd	s0,8(sp)
 256:	0800                	addi	s0,sp,16
  for(; *s; s++)
 258:	00054783          	lbu	a5,0(a0)
 25c:	cb99                	beqz	a5,272 <strchr+0x20>
    if(*s == c)
 25e:	00f58763          	beq	a1,a5,26c <strchr+0x1a>
  for(; *s; s++)
 262:	0505                	addi	a0,a0,1
 264:	00054783          	lbu	a5,0(a0)
 268:	fbfd                	bnez	a5,25e <strchr+0xc>
      return (char*)s;
  return 0;
 26a:	4501                	li	a0,0
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  return 0;
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <strchr+0x1a>

0000000000000276 <gets>:

char*
gets(char *buf, int max)
{
 276:	711d                	addi	sp,sp,-96
 278:	ec86                	sd	ra,88(sp)
 27a:	e8a2                	sd	s0,80(sp)
 27c:	e4a6                	sd	s1,72(sp)
 27e:	e0ca                	sd	s2,64(sp)
 280:	fc4e                	sd	s3,56(sp)
 282:	f852                	sd	s4,48(sp)
 284:	f456                	sd	s5,40(sp)
 286:	f05a                	sd	s6,32(sp)
 288:	ec5e                	sd	s7,24(sp)
 28a:	1080                	addi	s0,sp,96
 28c:	8baa                	mv	s7,a0
 28e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 290:	892a                	mv	s2,a0
 292:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 294:	4aa9                	li	s5,10
 296:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 298:	89a6                	mv	s3,s1
 29a:	2485                	addiw	s1,s1,1
 29c:	0344d863          	bge	s1,s4,2cc <gets+0x56>
    cc = read(0, &c, 1);
 2a0:	4605                	li	a2,1
 2a2:	faf40593          	addi	a1,s0,-81
 2a6:	4501                	li	a0,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	1a0080e7          	jalr	416(ra) # 448 <read>
    if(cc < 1)
 2b0:	00a05e63          	blez	a0,2cc <gets+0x56>
    buf[i++] = c;
 2b4:	faf44783          	lbu	a5,-81(s0)
 2b8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2bc:	01578763          	beq	a5,s5,2ca <gets+0x54>
 2c0:	0905                	addi	s2,s2,1
 2c2:	fd679be3          	bne	a5,s6,298 <gets+0x22>
  for(i=0; i+1 < max; ){
 2c6:	89a6                	mv	s3,s1
 2c8:	a011                	j	2cc <gets+0x56>
 2ca:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2cc:	99de                	add	s3,s3,s7
 2ce:	00098023          	sb	zero,0(s3)
  return buf;
}
 2d2:	855e                	mv	a0,s7
 2d4:	60e6                	ld	ra,88(sp)
 2d6:	6446                	ld	s0,80(sp)
 2d8:	64a6                	ld	s1,72(sp)
 2da:	6906                	ld	s2,64(sp)
 2dc:	79e2                	ld	s3,56(sp)
 2de:	7a42                	ld	s4,48(sp)
 2e0:	7aa2                	ld	s5,40(sp)
 2e2:	7b02                	ld	s6,32(sp)
 2e4:	6be2                	ld	s7,24(sp)
 2e6:	6125                	addi	sp,sp,96
 2e8:	8082                	ret

00000000000002ea <stat>:

int
stat(const char *n, struct stat *st)
{
 2ea:	1101                	addi	sp,sp,-32
 2ec:	ec06                	sd	ra,24(sp)
 2ee:	e822                	sd	s0,16(sp)
 2f0:	e426                	sd	s1,8(sp)
 2f2:	e04a                	sd	s2,0(sp)
 2f4:	1000                	addi	s0,sp,32
 2f6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f8:	4581                	li	a1,0
 2fa:	00000097          	auipc	ra,0x0
 2fe:	176080e7          	jalr	374(ra) # 470 <open>
  if(fd < 0)
 302:	02054563          	bltz	a0,32c <stat+0x42>
 306:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 308:	85ca                	mv	a1,s2
 30a:	00000097          	auipc	ra,0x0
 30e:	17e080e7          	jalr	382(ra) # 488 <fstat>
 312:	892a                	mv	s2,a0
  close(fd);
 314:	8526                	mv	a0,s1
 316:	00000097          	auipc	ra,0x0
 31a:	142080e7          	jalr	322(ra) # 458 <close>
  return r;
}
 31e:	854a                	mv	a0,s2
 320:	60e2                	ld	ra,24(sp)
 322:	6442                	ld	s0,16(sp)
 324:	64a2                	ld	s1,8(sp)
 326:	6902                	ld	s2,0(sp)
 328:	6105                	addi	sp,sp,32
 32a:	8082                	ret
    return -1;
 32c:	597d                	li	s2,-1
 32e:	bfc5                	j	31e <stat+0x34>

0000000000000330 <atoi>:

int
atoi(const char *s)
{
 330:	1141                	addi	sp,sp,-16
 332:	e422                	sd	s0,8(sp)
 334:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 336:	00054603          	lbu	a2,0(a0)
 33a:	fd06079b          	addiw	a5,a2,-48
 33e:	0ff7f793          	andi	a5,a5,255
 342:	4725                	li	a4,9
 344:	02f76963          	bltu	a4,a5,376 <atoi+0x46>
 348:	86aa                	mv	a3,a0
  n = 0;
 34a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 34c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 34e:	0685                	addi	a3,a3,1
 350:	0025179b          	slliw	a5,a0,0x2
 354:	9fa9                	addw	a5,a5,a0
 356:	0017979b          	slliw	a5,a5,0x1
 35a:	9fb1                	addw	a5,a5,a2
 35c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 360:	0006c603          	lbu	a2,0(a3)
 364:	fd06071b          	addiw	a4,a2,-48
 368:	0ff77713          	andi	a4,a4,255
 36c:	fee5f1e3          	bgeu	a1,a4,34e <atoi+0x1e>
  return n;
}
 370:	6422                	ld	s0,8(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret
  n = 0;
 376:	4501                	li	a0,0
 378:	bfe5                	j	370 <atoi+0x40>

000000000000037a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 37a:	1141                	addi	sp,sp,-16
 37c:	e422                	sd	s0,8(sp)
 37e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 380:	02b57663          	bgeu	a0,a1,3ac <memmove+0x32>
    while(n-- > 0)
 384:	02c05163          	blez	a2,3a6 <memmove+0x2c>
 388:	fff6079b          	addiw	a5,a2,-1
 38c:	1782                	slli	a5,a5,0x20
 38e:	9381                	srli	a5,a5,0x20
 390:	0785                	addi	a5,a5,1
 392:	97aa                	add	a5,a5,a0
  dst = vdst;
 394:	872a                	mv	a4,a0
      *dst++ = *src++;
 396:	0585                	addi	a1,a1,1
 398:	0705                	addi	a4,a4,1
 39a:	fff5c683          	lbu	a3,-1(a1)
 39e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a2:	fee79ae3          	bne	a5,a4,396 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3a6:	6422                	ld	s0,8(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
    dst += n;
 3ac:	00c50733          	add	a4,a0,a2
    src += n;
 3b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3b2:	fec05ae3          	blez	a2,3a6 <memmove+0x2c>
 3b6:	fff6079b          	addiw	a5,a2,-1
 3ba:	1782                	slli	a5,a5,0x20
 3bc:	9381                	srli	a5,a5,0x20
 3be:	fff7c793          	not	a5,a5
 3c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3c4:	15fd                	addi	a1,a1,-1
 3c6:	177d                	addi	a4,a4,-1
 3c8:	0005c683          	lbu	a3,0(a1)
 3cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d0:	fee79ae3          	bne	a5,a4,3c4 <memmove+0x4a>
 3d4:	bfc9                	j	3a6 <memmove+0x2c>

00000000000003d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e422                	sd	s0,8(sp)
 3da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3dc:	ca05                	beqz	a2,40c <memcmp+0x36>
 3de:	fff6069b          	addiw	a3,a2,-1
 3e2:	1682                	slli	a3,a3,0x20
 3e4:	9281                	srli	a3,a3,0x20
 3e6:	0685                	addi	a3,a3,1
 3e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ea:	00054783          	lbu	a5,0(a0)
 3ee:	0005c703          	lbu	a4,0(a1)
 3f2:	00e79863          	bne	a5,a4,402 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3f6:	0505                	addi	a0,a0,1
    p2++;
 3f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3fa:	fed518e3          	bne	a0,a3,3ea <memcmp+0x14>
  }
  return 0;
 3fe:	4501                	li	a0,0
 400:	a019                	j	406 <memcmp+0x30>
      return *p1 - *p2;
 402:	40e7853b          	subw	a0,a5,a4
}
 406:	6422                	ld	s0,8(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret
  return 0;
 40c:	4501                	li	a0,0
 40e:	bfe5                	j	406 <memcmp+0x30>

0000000000000410 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 410:	1141                	addi	sp,sp,-16
 412:	e406                	sd	ra,8(sp)
 414:	e022                	sd	s0,0(sp)
 416:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 418:	00000097          	auipc	ra,0x0
 41c:	f62080e7          	jalr	-158(ra) # 37a <memmove>
}
 420:	60a2                	ld	ra,8(sp)
 422:	6402                	ld	s0,0(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret

0000000000000428 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 428:	4885                	li	a7,1
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <exit>:
.global exit
exit:
 li a7, SYS_exit
 430:	4889                	li	a7,2
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <wait>:
.global wait
wait:
 li a7, SYS_wait
 438:	488d                	li	a7,3
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 440:	4891                	li	a7,4
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <read>:
.global read
read:
 li a7, SYS_read
 448:	4895                	li	a7,5
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <write>:
.global write
write:
 li a7, SYS_write
 450:	48c1                	li	a7,16
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <close>:
.global close
close:
 li a7, SYS_close
 458:	48d5                	li	a7,21
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <kill>:
.global kill
kill:
 li a7, SYS_kill
 460:	4899                	li	a7,6
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <exec>:
.global exec
exec:
 li a7, SYS_exec
 468:	489d                	li	a7,7
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <open>:
.global open
open:
 li a7, SYS_open
 470:	48bd                	li	a7,15
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 478:	48c5                	li	a7,17
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 480:	48c9                	li	a7,18
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 488:	48a1                	li	a7,8
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <link>:
.global link
link:
 li a7, SYS_link
 490:	48cd                	li	a7,19
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 498:	48d1                	li	a7,20
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a0:	48a5                	li	a7,9
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4a8:	48a9                	li	a7,10
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b0:	48ad                	li	a7,11
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4b8:	48b1                	li	a7,12
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4c0:	48b5                	li	a7,13
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4c8:	48b9                	li	a7,14
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4d0:	48d9                	li	a7,22
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <yield>:
.global yield
yield:
 li a7, SYS_yield
 4d8:	48dd                	li	a7,23
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 4e0:	48e1                	li	a7,24
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 4e8:	48e5                	li	a7,25
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 4f0:	48e9                	li	a7,26
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <ps>:
.global ps
ps:
 li a7, SYS_ps
 4f8:	48ed                	li	a7,27
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 500:	48f1                	li	a7,28
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 508:	1101                	addi	sp,sp,-32
 50a:	ec06                	sd	ra,24(sp)
 50c:	e822                	sd	s0,16(sp)
 50e:	1000                	addi	s0,sp,32
 510:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 514:	4605                	li	a2,1
 516:	fef40593          	addi	a1,s0,-17
 51a:	00000097          	auipc	ra,0x0
 51e:	f36080e7          	jalr	-202(ra) # 450 <write>
}
 522:	60e2                	ld	ra,24(sp)
 524:	6442                	ld	s0,16(sp)
 526:	6105                	addi	sp,sp,32
 528:	8082                	ret

000000000000052a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 52a:	7139                	addi	sp,sp,-64
 52c:	fc06                	sd	ra,56(sp)
 52e:	f822                	sd	s0,48(sp)
 530:	f426                	sd	s1,40(sp)
 532:	f04a                	sd	s2,32(sp)
 534:	ec4e                	sd	s3,24(sp)
 536:	0080                	addi	s0,sp,64
 538:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 53a:	c299                	beqz	a3,540 <printint+0x16>
 53c:	0805c863          	bltz	a1,5cc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 540:	2581                	sext.w	a1,a1
  neg = 0;
 542:	4881                	li	a7,0
 544:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 548:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 54a:	2601                	sext.w	a2,a2
 54c:	00000517          	auipc	a0,0x0
 550:	55c50513          	addi	a0,a0,1372 # aa8 <digits>
 554:	883a                	mv	a6,a4
 556:	2705                	addiw	a4,a4,1
 558:	02c5f7bb          	remuw	a5,a1,a2
 55c:	1782                	slli	a5,a5,0x20
 55e:	9381                	srli	a5,a5,0x20
 560:	97aa                	add	a5,a5,a0
 562:	0007c783          	lbu	a5,0(a5)
 566:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 56a:	0005879b          	sext.w	a5,a1
 56e:	02c5d5bb          	divuw	a1,a1,a2
 572:	0685                	addi	a3,a3,1
 574:	fec7f0e3          	bgeu	a5,a2,554 <printint+0x2a>
  if(neg)
 578:	00088b63          	beqz	a7,58e <printint+0x64>
    buf[i++] = '-';
 57c:	fd040793          	addi	a5,s0,-48
 580:	973e                	add	a4,a4,a5
 582:	02d00793          	li	a5,45
 586:	fef70823          	sb	a5,-16(a4)
 58a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 58e:	02e05863          	blez	a4,5be <printint+0x94>
 592:	fc040793          	addi	a5,s0,-64
 596:	00e78933          	add	s2,a5,a4
 59a:	fff78993          	addi	s3,a5,-1
 59e:	99ba                	add	s3,s3,a4
 5a0:	377d                	addiw	a4,a4,-1
 5a2:	1702                	slli	a4,a4,0x20
 5a4:	9301                	srli	a4,a4,0x20
 5a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5aa:	fff94583          	lbu	a1,-1(s2)
 5ae:	8526                	mv	a0,s1
 5b0:	00000097          	auipc	ra,0x0
 5b4:	f58080e7          	jalr	-168(ra) # 508 <putc>
  while(--i >= 0)
 5b8:	197d                	addi	s2,s2,-1
 5ba:	ff3918e3          	bne	s2,s3,5aa <printint+0x80>
}
 5be:	70e2                	ld	ra,56(sp)
 5c0:	7442                	ld	s0,48(sp)
 5c2:	74a2                	ld	s1,40(sp)
 5c4:	7902                	ld	s2,32(sp)
 5c6:	69e2                	ld	s3,24(sp)
 5c8:	6121                	addi	sp,sp,64
 5ca:	8082                	ret
    x = -xx;
 5cc:	40b005bb          	negw	a1,a1
    neg = 1;
 5d0:	4885                	li	a7,1
    x = -xx;
 5d2:	bf8d                	j	544 <printint+0x1a>

00000000000005d4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d4:	7119                	addi	sp,sp,-128
 5d6:	fc86                	sd	ra,120(sp)
 5d8:	f8a2                	sd	s0,112(sp)
 5da:	f4a6                	sd	s1,104(sp)
 5dc:	f0ca                	sd	s2,96(sp)
 5de:	ecce                	sd	s3,88(sp)
 5e0:	e8d2                	sd	s4,80(sp)
 5e2:	e4d6                	sd	s5,72(sp)
 5e4:	e0da                	sd	s6,64(sp)
 5e6:	fc5e                	sd	s7,56(sp)
 5e8:	f862                	sd	s8,48(sp)
 5ea:	f466                	sd	s9,40(sp)
 5ec:	f06a                	sd	s10,32(sp)
 5ee:	ec6e                	sd	s11,24(sp)
 5f0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f2:	0005c903          	lbu	s2,0(a1)
 5f6:	18090f63          	beqz	s2,794 <vprintf+0x1c0>
 5fa:	8aaa                	mv	s5,a0
 5fc:	8b32                	mv	s6,a2
 5fe:	00158493          	addi	s1,a1,1
  state = 0;
 602:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 604:	02500a13          	li	s4,37
      if(c == 'd'){
 608:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 60c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 610:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 614:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 618:	00000b97          	auipc	s7,0x0
 61c:	490b8b93          	addi	s7,s7,1168 # aa8 <digits>
 620:	a839                	j	63e <vprintf+0x6a>
        putc(fd, c);
 622:	85ca                	mv	a1,s2
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	ee2080e7          	jalr	-286(ra) # 508 <putc>
 62e:	a019                	j	634 <vprintf+0x60>
    } else if(state == '%'){
 630:	01498f63          	beq	s3,s4,64e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 634:	0485                	addi	s1,s1,1
 636:	fff4c903          	lbu	s2,-1(s1)
 63a:	14090d63          	beqz	s2,794 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 63e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 642:	fe0997e3          	bnez	s3,630 <vprintf+0x5c>
      if(c == '%'){
 646:	fd479ee3          	bne	a5,s4,622 <vprintf+0x4e>
        state = '%';
 64a:	89be                	mv	s3,a5
 64c:	b7e5                	j	634 <vprintf+0x60>
      if(c == 'd'){
 64e:	05878063          	beq	a5,s8,68e <vprintf+0xba>
      } else if(c == 'l') {
 652:	05978c63          	beq	a5,s9,6aa <vprintf+0xd6>
      } else if(c == 'x') {
 656:	07a78863          	beq	a5,s10,6c6 <vprintf+0xf2>
      } else if(c == 'p') {
 65a:	09b78463          	beq	a5,s11,6e2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 65e:	07300713          	li	a4,115
 662:	0ce78663          	beq	a5,a4,72e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 666:	06300713          	li	a4,99
 66a:	0ee78e63          	beq	a5,a4,766 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 66e:	11478863          	beq	a5,s4,77e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 672:	85d2                	mv	a1,s4
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e92080e7          	jalr	-366(ra) # 508 <putc>
        putc(fd, c);
 67e:	85ca                	mv	a1,s2
 680:	8556                	mv	a0,s5
 682:	00000097          	auipc	ra,0x0
 686:	e86080e7          	jalr	-378(ra) # 508 <putc>
      }
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b765                	j	634 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 68e:	008b0913          	addi	s2,s6,8
 692:	4685                	li	a3,1
 694:	4629                	li	a2,10
 696:	000b2583          	lw	a1,0(s6)
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	e8e080e7          	jalr	-370(ra) # 52a <printint>
 6a4:	8b4a                	mv	s6,s2
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	b771                	j	634 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6aa:	008b0913          	addi	s2,s6,8
 6ae:	4681                	li	a3,0
 6b0:	4629                	li	a2,10
 6b2:	000b2583          	lw	a1,0(s6)
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	e72080e7          	jalr	-398(ra) # 52a <printint>
 6c0:	8b4a                	mv	s6,s2
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bf85                	j	634 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6c6:	008b0913          	addi	s2,s6,8
 6ca:	4681                	li	a3,0
 6cc:	4641                	li	a2,16
 6ce:	000b2583          	lw	a1,0(s6)
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	e56080e7          	jalr	-426(ra) # 52a <printint>
 6dc:	8b4a                	mv	s6,s2
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bf91                	j	634 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6e2:	008b0793          	addi	a5,s6,8
 6e6:	f8f43423          	sd	a5,-120(s0)
 6ea:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ee:	03000593          	li	a1,48
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	e14080e7          	jalr	-492(ra) # 508 <putc>
  putc(fd, 'x');
 6fc:	85ea                	mv	a1,s10
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	e08080e7          	jalr	-504(ra) # 508 <putc>
 708:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 70a:	03c9d793          	srli	a5,s3,0x3c
 70e:	97de                	add	a5,a5,s7
 710:	0007c583          	lbu	a1,0(a5)
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	df2080e7          	jalr	-526(ra) # 508 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71e:	0992                	slli	s3,s3,0x4
 720:	397d                	addiw	s2,s2,-1
 722:	fe0914e3          	bnez	s2,70a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 726:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b721                	j	634 <vprintf+0x60>
        s = va_arg(ap, char*);
 72e:	008b0993          	addi	s3,s6,8
 732:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 736:	02090163          	beqz	s2,758 <vprintf+0x184>
        while(*s != 0){
 73a:	00094583          	lbu	a1,0(s2)
 73e:	c9a1                	beqz	a1,78e <vprintf+0x1ba>
          putc(fd, *s);
 740:	8556                	mv	a0,s5
 742:	00000097          	auipc	ra,0x0
 746:	dc6080e7          	jalr	-570(ra) # 508 <putc>
          s++;
 74a:	0905                	addi	s2,s2,1
        while(*s != 0){
 74c:	00094583          	lbu	a1,0(s2)
 750:	f9e5                	bnez	a1,740 <vprintf+0x16c>
        s = va_arg(ap, char*);
 752:	8b4e                	mv	s6,s3
      state = 0;
 754:	4981                	li	s3,0
 756:	bdf9                	j	634 <vprintf+0x60>
          s = "(null)";
 758:	00000917          	auipc	s2,0x0
 75c:	34890913          	addi	s2,s2,840 # aa0 <malloc+0x202>
        while(*s != 0){
 760:	02800593          	li	a1,40
 764:	bff1                	j	740 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 766:	008b0913          	addi	s2,s6,8
 76a:	000b4583          	lbu	a1,0(s6)
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	d98080e7          	jalr	-616(ra) # 508 <putc>
 778:	8b4a                	mv	s6,s2
      state = 0;
 77a:	4981                	li	s3,0
 77c:	bd65                	j	634 <vprintf+0x60>
        putc(fd, c);
 77e:	85d2                	mv	a1,s4
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	d86080e7          	jalr	-634(ra) # 508 <putc>
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b565                	j	634 <vprintf+0x60>
        s = va_arg(ap, char*);
 78e:	8b4e                	mv	s6,s3
      state = 0;
 790:	4981                	li	s3,0
 792:	b54d                	j	634 <vprintf+0x60>
    }
  }
}
 794:	70e6                	ld	ra,120(sp)
 796:	7446                	ld	s0,112(sp)
 798:	74a6                	ld	s1,104(sp)
 79a:	7906                	ld	s2,96(sp)
 79c:	69e6                	ld	s3,88(sp)
 79e:	6a46                	ld	s4,80(sp)
 7a0:	6aa6                	ld	s5,72(sp)
 7a2:	6b06                	ld	s6,64(sp)
 7a4:	7be2                	ld	s7,56(sp)
 7a6:	7c42                	ld	s8,48(sp)
 7a8:	7ca2                	ld	s9,40(sp)
 7aa:	7d02                	ld	s10,32(sp)
 7ac:	6de2                	ld	s11,24(sp)
 7ae:	6109                	addi	sp,sp,128
 7b0:	8082                	ret

00000000000007b2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b2:	715d                	addi	sp,sp,-80
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	1000                	addi	s0,sp,32
 7ba:	e010                	sd	a2,0(s0)
 7bc:	e414                	sd	a3,8(s0)
 7be:	e818                	sd	a4,16(s0)
 7c0:	ec1c                	sd	a5,24(s0)
 7c2:	03043023          	sd	a6,32(s0)
 7c6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ca:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ce:	8622                	mv	a2,s0
 7d0:	00000097          	auipc	ra,0x0
 7d4:	e04080e7          	jalr	-508(ra) # 5d4 <vprintf>
}
 7d8:	60e2                	ld	ra,24(sp)
 7da:	6442                	ld	s0,16(sp)
 7dc:	6161                	addi	sp,sp,80
 7de:	8082                	ret

00000000000007e0 <printf>:

void
printf(const char *fmt, ...)
{
 7e0:	711d                	addi	sp,sp,-96
 7e2:	ec06                	sd	ra,24(sp)
 7e4:	e822                	sd	s0,16(sp)
 7e6:	1000                	addi	s0,sp,32
 7e8:	e40c                	sd	a1,8(s0)
 7ea:	e810                	sd	a2,16(s0)
 7ec:	ec14                	sd	a3,24(s0)
 7ee:	f018                	sd	a4,32(s0)
 7f0:	f41c                	sd	a5,40(s0)
 7f2:	03043823          	sd	a6,48(s0)
 7f6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	00840613          	addi	a2,s0,8
 7fe:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 802:	85aa                	mv	a1,a0
 804:	4505                	li	a0,1
 806:	00000097          	auipc	ra,0x0
 80a:	dce080e7          	jalr	-562(ra) # 5d4 <vprintf>
}
 80e:	60e2                	ld	ra,24(sp)
 810:	6442                	ld	s0,16(sp)
 812:	6125                	addi	sp,sp,96
 814:	8082                	ret

0000000000000816 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 816:	1141                	addi	sp,sp,-16
 818:	e422                	sd	s0,8(sp)
 81a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 820:	00000797          	auipc	a5,0x0
 824:	2a07b783          	ld	a5,672(a5) # ac0 <freep>
 828:	a805                	j	858 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 82a:	4618                	lw	a4,8(a2)
 82c:	9db9                	addw	a1,a1,a4
 82e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 832:	6398                	ld	a4,0(a5)
 834:	6318                	ld	a4,0(a4)
 836:	fee53823          	sd	a4,-16(a0)
 83a:	a091                	j	87e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 83c:	ff852703          	lw	a4,-8(a0)
 840:	9e39                	addw	a2,a2,a4
 842:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 844:	ff053703          	ld	a4,-16(a0)
 848:	e398                	sd	a4,0(a5)
 84a:	a099                	j	890 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 84c:	6398                	ld	a4,0(a5)
 84e:	00e7e463          	bltu	a5,a4,856 <free+0x40>
 852:	00e6ea63          	bltu	a3,a4,866 <free+0x50>
{
 856:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 858:	fed7fae3          	bgeu	a5,a3,84c <free+0x36>
 85c:	6398                	ld	a4,0(a5)
 85e:	00e6e463          	bltu	a3,a4,866 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 862:	fee7eae3          	bltu	a5,a4,856 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 866:	ff852583          	lw	a1,-8(a0)
 86a:	6390                	ld	a2,0(a5)
 86c:	02059713          	slli	a4,a1,0x20
 870:	9301                	srli	a4,a4,0x20
 872:	0712                	slli	a4,a4,0x4
 874:	9736                	add	a4,a4,a3
 876:	fae60ae3          	beq	a2,a4,82a <free+0x14>
    bp->s.ptr = p->s.ptr;
 87a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 87e:	4790                	lw	a2,8(a5)
 880:	02061713          	slli	a4,a2,0x20
 884:	9301                	srli	a4,a4,0x20
 886:	0712                	slli	a4,a4,0x4
 888:	973e                	add	a4,a4,a5
 88a:	fae689e3          	beq	a3,a4,83c <free+0x26>
  } else
    p->s.ptr = bp;
 88e:	e394                	sd	a3,0(a5)
  freep = p;
 890:	00000717          	auipc	a4,0x0
 894:	22f73823          	sd	a5,560(a4) # ac0 <freep>
}
 898:	6422                	ld	s0,8(sp)
 89a:	0141                	addi	sp,sp,16
 89c:	8082                	ret

000000000000089e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 89e:	7139                	addi	sp,sp,-64
 8a0:	fc06                	sd	ra,56(sp)
 8a2:	f822                	sd	s0,48(sp)
 8a4:	f426                	sd	s1,40(sp)
 8a6:	f04a                	sd	s2,32(sp)
 8a8:	ec4e                	sd	s3,24(sp)
 8aa:	e852                	sd	s4,16(sp)
 8ac:	e456                	sd	s5,8(sp)
 8ae:	e05a                	sd	s6,0(sp)
 8b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b2:	02051493          	slli	s1,a0,0x20
 8b6:	9081                	srli	s1,s1,0x20
 8b8:	04bd                	addi	s1,s1,15
 8ba:	8091                	srli	s1,s1,0x4
 8bc:	0014899b          	addiw	s3,s1,1
 8c0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c2:	00000517          	auipc	a0,0x0
 8c6:	1fe53503          	ld	a0,510(a0) # ac0 <freep>
 8ca:	c515                	beqz	a0,8f6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ce:	4798                	lw	a4,8(a5)
 8d0:	02977f63          	bgeu	a4,s1,90e <malloc+0x70>
 8d4:	8a4e                	mv	s4,s3
 8d6:	0009871b          	sext.w	a4,s3
 8da:	6685                	lui	a3,0x1
 8dc:	00d77363          	bgeu	a4,a3,8e2 <malloc+0x44>
 8e0:	6a05                	lui	s4,0x1
 8e2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8e6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ea:	00000917          	auipc	s2,0x0
 8ee:	1d690913          	addi	s2,s2,470 # ac0 <freep>
  if(p == (char*)-1)
 8f2:	5afd                	li	s5,-1
 8f4:	a88d                	j	966 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8f6:	00000797          	auipc	a5,0x0
 8fa:	1d278793          	addi	a5,a5,466 # ac8 <base>
 8fe:	00000717          	auipc	a4,0x0
 902:	1cf73123          	sd	a5,450(a4) # ac0 <freep>
 906:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 908:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 90c:	b7e1                	j	8d4 <malloc+0x36>
      if(p->s.size == nunits)
 90e:	02e48b63          	beq	s1,a4,944 <malloc+0xa6>
        p->s.size -= nunits;
 912:	4137073b          	subw	a4,a4,s3
 916:	c798                	sw	a4,8(a5)
        p += p->s.size;
 918:	1702                	slli	a4,a4,0x20
 91a:	9301                	srli	a4,a4,0x20
 91c:	0712                	slli	a4,a4,0x4
 91e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 920:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 924:	00000717          	auipc	a4,0x0
 928:	18a73e23          	sd	a0,412(a4) # ac0 <freep>
      return (void*)(p + 1);
 92c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 930:	70e2                	ld	ra,56(sp)
 932:	7442                	ld	s0,48(sp)
 934:	74a2                	ld	s1,40(sp)
 936:	7902                	ld	s2,32(sp)
 938:	69e2                	ld	s3,24(sp)
 93a:	6a42                	ld	s4,16(sp)
 93c:	6aa2                	ld	s5,8(sp)
 93e:	6b02                	ld	s6,0(sp)
 940:	6121                	addi	sp,sp,64
 942:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 944:	6398                	ld	a4,0(a5)
 946:	e118                	sd	a4,0(a0)
 948:	bff1                	j	924 <malloc+0x86>
  hp->s.size = nu;
 94a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 94e:	0541                	addi	a0,a0,16
 950:	00000097          	auipc	ra,0x0
 954:	ec6080e7          	jalr	-314(ra) # 816 <free>
  return freep;
 958:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 95c:	d971                	beqz	a0,930 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 960:	4798                	lw	a4,8(a5)
 962:	fa9776e3          	bgeu	a4,s1,90e <malloc+0x70>
    if(p == freep)
 966:	00093703          	ld	a4,0(s2)
 96a:	853e                	mv	a0,a5
 96c:	fef719e3          	bne	a4,a5,95e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 970:	8552                	mv	a0,s4
 972:	00000097          	auipc	ra,0x0
 976:	b46080e7          	jalr	-1210(ra) # 4b8 <sbrk>
  if(p == (char*)-1)
 97a:	fd5518e3          	bne	a0,s5,94a <malloc+0xac>
        return 0;
 97e:	4501                	li	a0,0
 980:	bf45                	j	930 <malloc+0x92>
