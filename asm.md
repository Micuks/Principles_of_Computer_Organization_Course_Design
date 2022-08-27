# 汇编代码

## 原始指令

|    汇编    |        功能        | IR7~4 | IR3~2  | IR1~0  |
| :--------: | :----------------: | :---: | :----: | :----: |
| ADD Rd,Rs  |     Rd<-Rd+Rs      | 0001  |   Rd   |   Rs   |
| SUB Rd,Rs  |     Rd<-Rd-Rs      | 0010  |   Rd   |   Rs   |
| AND Rd,Rs  |   Rd<-Rd and Rs    | 0011  |   Rd   |   Rs   |
| INC Rd,Rs  |      Rd<-Rd+1      | 0100  |   Rd   |   XX   |
| LD Rd,[Rs] |      Rd<-[Rs]      | 0101  |   Rd   |   Rs   |
| ST Rs,[Rd] |      Rs->[Rd]      | 0110  |   Rd   |   Rs   |
| JC offset  | 若C则 PC<-@+offset | 0111  | offset | offset |
| JZ offset  | 若Z则 PC<-@+offset | 1000  | offset | offset |
|  JMP [Rd]  |      PC<-[Rd]      | 1001  |   Rd   |   XX   |
|    STOP    |      暂停运行      | 1110  |   XX   |   XX   |

*上表中@为当前PC值*

## 拓展指令

|   汇编    |   功能   | IR7~4 | IR3~2 | IR1~0 |
| :-------: | :------: | :---: | :---: | :---: |
|    NOP    |    无    | 0000  |  XX   |  XX   |
|  OUT Rs   | DBUS<-Rs | 1010  |  XX   |  Rs   |
| OR Rd,Rs |  Rd<-Rd or Rs   | 1011 | Rd | Rs |
| CMP Rd,Rs |  Rd-Rs   | 1100 | Rd | Rs |
| MOV Rd,Rs | Rd<-Rs | 1101 | Rd | Rs |



## 汇编代码

### 比较寄存器R0 R1

```
CMP R0,R1
JZ 1H
JMP [R2]
ST R2,[R3]
STOP
```

程序功能为：若R0,R1相等则将R3的值放入以R2为地址的内存处。

初始时R0,R1放待比较的两个数字，R2放4H。

