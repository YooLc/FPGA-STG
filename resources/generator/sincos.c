#include <stdio.h>
#include <math.h>
#include <stdint.h>
int main()
{
    FILE *sin_txt = fopen("sin.coe", "w");
    fprintf(sin_txt, "; This is coe file for sin function\n");
    fprintf(sin_txt, "memory_initialization_radix=16;\n");
    fprintf(sin_txt, "memory_initialization_vector=\n");
    for (int i = 0; i < 360; i++) {
        uint16_t val = round(sin(i * 3.1415936 / 180.0) * 32767);
        fprintf(sin_txt, "%04X,\n", val);
    }
    for (int i = 360; i < 367; i++)
        fprintf(sin_txt, "0000,\n");
    fprintf(sin_txt, "0000;");
    fclose(sin_txt);

    FILE *cos_txt = fopen("cos.coe", "w");
    fprintf(cos_txt, "; This is coe file for cos function\n");
    fprintf(cos_txt, "memory_initialization_radix=16;\n");
    fprintf(cos_txt, "memory_initialization_vector=\n");
    for (int i = 0; i < 360; i++) {
        uint16_t val = round(cos(i * 3.1415936 / 180.0) * 32767);
        fprintf(cos_txt, "%04X,\n", val);
    }
    for (int i = 360; i < 367; i++)
        fprintf(cos_txt, "0000,\n");
    fprintf(cos_txt, "0000;");
    fclose(cos_txt);
    return 0;
}