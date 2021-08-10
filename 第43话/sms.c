#include <stdio.h>
#include <string.h>

#define TRUE    1
#define MAXCMD  16              //最大命令长度
#define MAXDATA 1024            //最大数据长度

#define INSERT  1               //插入数据
#define SEARCH  2               //搜索数据
#define UPDATE  3               //修改数据
#define DELETE  4               //删除数据
#define SAVE    5               //保存数据
#define HELP    6               //帮助命令
#define SHOW    7               //显示数据
#define QUIT    0               //退出命令
#define ILLEGAL -1              //非法指令

int getopcode(char* command);
int help();
int show();
int save();
int insert(char* data);
int search(char* data);
int update(char* data);
int delete(char* data);

int main(int argc, char* argv[])
{
    int opcode = ILLEGAL;
    char command[MAXCMD] = {0}; //用于接收命令
    char data[MAXDATA]  = {0};  //用于接收数据
    
    while(TRUE)                 //无限循环
    {
        printf("sms>");         //输出提示符
        scanf("%s", command);   //输入命令
        opcode = getopcode(command);    //获取opcde
        if(opcode == ILLEGAL)
        {
            printf("Unsupported command!\n");
            continue;
        }
        if(opcode == QUIT)
        {
            printf("Bye!\n");
            return 0;
        }
        if(opcode == HELP)
        {
            help();
            continue;
        }
        if(opcode == SHOW)
        {
            show();
            continue;
        }
        if(opcode == SAVE)
        {
            save();
            continue;
        }
        scanf("%s", data);      //用于输入数据
        switch(opcode)
        {
            case INSERT: insert(data); break;
            case SEARCH: search(data); break;
            case UPDATE: update(data); break;
            case DELETE: delete(data); break;
        }
    }
    return 0;
}

int getopcode(char* command)
{
    int opcode = ILLEGAL;               //默认指令非法
    if(strcmp(command, "insert") == 0)  //command与"insert"比较
        opcode = INSERT;                //结果为0则两字符串相同
    if(strcmp(command, "search") == 0)
        opcode = SEARCH;
    if(strcmp(command, "update") == 0)
        opcode = UPDATE;
    if(strcmp(command, "delete") == 0)
        opcode = DELETE;
    if(strcmp(command, "save") == 0)
        opcode = SAVE;
    if(strcmp(command, "help") == 0)
        opcode = HELP;
    if(strcmp(command, "quit") == 0)
        opcode = QUIT;
    if(strcmp(command, "show") == 0)
        opcode = SHOW;
    return opcode;
}
int help()
{
    printf("Help\n");
    return 0;
}
int show()
{
    printf("Show\n");
    return 0;
}
int save()
{
    printf("Save\n");
    return 0;
}
int insert(char* data)
{
    printf("Insert data %s\n", data);
    return 0;
}
int search(char* data)
{
    printf("Search data %s\n", data);
    return 0;
}
int update(char* data)
{
    printf("Update data %s\n", data);
    return 0;
}
int delete(char* data)
{
    printf("Delete data %s\n", data);
    return 0;
}