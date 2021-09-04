#include <stdio.h>
#include <linux/input.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <unistd.h>
#define DEV_PATH "/dev/input/event20"   //difference is possible
#define L 1
#define R 2
#define U 3
#define D 4
int main()
{
    int event_file = 0;
    int keynum = 0;
    struct input_event event_in;

    while(1)
    {   
        if(event_file <= 0)
        {
            event_file = open(DEV_PATH, O_RDONLY);
            continue;
        }
        
        if (read(event_file, &event_in, sizeof(event_in)) != sizeof(event_in))
        {
            continue;
        }

        if (event_in.type == EV_ABS)
        {
            if (event_in.code == 16)
            {
                if (event_in.value == -1)
                {
                    printf("方向 左左 按下\n");
                    keynum = L;
                }

                if (event_in.value == 0 && keynum == L)
                {
                    printf("方向 左左 抬起\n");
                }

                if (event_in.value == 1)
                {
                    printf("方向 右右 按下\n");
                    keynum = R;
                }

                if (event_in.value == 0 && keynum == R)
                {
                    printf("方向 右右 抬起\n");
                }
            }

            if (event_in.code == 17)
            {
                if (event_in.value == -1)
                {
                    printf("方向 上上 按下\n");
                    keynum = U;
                }

                if (event_in.value == 0 && keynum == U)
                {
                    printf("方向 上上 抬起\n");
                }

                if (event_in.value == 1)
                {
                    printf("方向 下下 按下\n");
                    keynum = D;
                }

                if (event_in.value == 0 && keynum == D)
                {
                    printf("方向 上上 抬起\n");
                }
            }

        }

    }
    return 0;
}