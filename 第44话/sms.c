#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define TRUE    1
#define MAXSTUS 10
#define MAXCMD  16              //最大命令长度
#define MAXNAME 32              //最大姓名长度
#define MAXDATA 1024            //最大数据长度
#define CODELEN 8               //学号长度

#define INSERT  1               //插入数据
#define SEARCH  2               //搜索数据
#define UPDATE  3               //修改数据
#define DELETE  4               //删除数据
#define SAVE    5               //保存数据
#define HELP    6               //帮助命令
#define SHOW    7               //显示数据
#define QUIT    0               //退出命令
#define ILLEGAL -1              //非法指令
#define ERROR   -2              //一般错误

typedef struct student
{
    unsigned int code;
    char name[MAXNAME];
}Student;

int getopcode(char* command);
int help();
int show();
int save(Student* stu, int index);
int insert(char* data, Student* stu);
int search(char* data);
int update(char* data);
int delete(char* data);

int main(int argc, char* argv[])
{
    int opcode = ILLEGAL;
    int index  = 0;
    char command[MAXCMD] = {0}; //用于接收命令
    char data[MAXDATA]  = {0};  //用于接收数据
    Student stus[MAXSTUS];
    Student* stu = stus;
    
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
            save(stu, index);
            continue;
        }
        scanf("%s", data);      //用于输入数据
        switch(opcode)
        {
            case INSERT: 
            {
                if(index == MAXSTUS - 1)
                {
                    save(stu, index);
                    index = 0;
                    stu = stus;
                }
                printf("Berfore insert code = %d, name = %s\n", stus[index].code, stus[index].name);
                insert(data, stu); 
                printf("After insert code = %d, name = %s\n", stus[index].code, stus[index].name);
                index++;
                stu++;
                break;    
            }
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
int save(Student* stu, int index)
{
    printf("Save\n");
    FILE* datafile = fopen("data.txt", "a");
    stu = stu - index;
    for(int i = 0; i < index; i++)
    {
        fprintf(datafile, "%d,", stu->code);
        fprintf(datafile, "%s\n", stu->name);
        stu++;
    }
    fclose(datafile);
    return 0;
}



int insert(char* data, Student* pstu)
{
    printf("Insert data %s\n", data);
    char acode[CODELEN] = {0};
    char aname[MAXNAME] = {0};
    int i = 0;
    for(i = 0; i < CODELEN; i++)
    {
        if(data[i] < '0' || data[i] > '9')
        {
            printf("Please check Input with code.\n");
            return ERROR;
        }
            
        acode[i] = data[i];
    }
    pstu->code = atoi(acode);
    
    if(data[i] != ',')
    {
        printf("Please check input with \','\n");
        return ERROR;
    }
    i++;
    while((data[i] >= 'a' && data[i] <= 'z') || (data[i] >= 'A' && data[i] <= 'Z'))
    {
        pstu->name[i-CODELEN - 1] = data[i];
        i++;
    }

    if(data[i] == '\0')
    {
        pstu->name[i-CODELEN] = data[i];
        return 0;
    }
    else
    {
        printf("Please check input with name.\n");
        return ERROR;
    }    
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