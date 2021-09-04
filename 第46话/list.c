#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAXNAME 32              //最大姓名长度
#define GPERROR -1
#define SUCESS  0

typedef struct student
{
    unsigned int code;
    char name[MAXNAME];
    struct student *next;
}Student;

typedef struct stulist
{
    Student *head;
    int count;
}StuList;

Student *createStudent()
{
    Student *stu = (Student *)malloc(sizeof(Student));
    if(stu != NULL)
    {
        stu->code = 0;
        memset(stu->name, 0, MAXNAME);
        stu->next = NULL;
        return stu;
    }
    return NULL;
}
int main(int argc, char* argv[])
{
    StuList stul;
    Student* stu;
    stul.head = createStudent();
    if(stul.head == NULL)
        return GPERROR;
    stul.count = 1;
    stu = stul.head;
    scanf("%d,%s", &stu->code, stu->name);
    stu->next = createStudent();
    if(stu->next == NULL)
        return GPERROR;
    stul.count++;
    stu = stu->next;
    scanf("%d,%s", &stu->code, stu->name);
    stu = stul.head;
    FILE* datafile = fopen("data.txt", "a");
    for(int i = 0; i < stul.count; i++)
    {
        printf("StuList[%d]`s code is %d, name is %s\n", i, stu->code, stu->name);
        fprintf(datafile, "%d,%s\n", stu->code, stu->name);
        stu = stu->next;
    }
    fclose(datafile);
    return SUCESS;
} 