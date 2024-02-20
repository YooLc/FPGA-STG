#include <stdio.h>
int main()
{
    FILE *desc = fopen("desc.txt", "r");
    FILE *coe = fopen("desc.coe", "w");

    int depth = 256;

    fprintf(coe, "; Resource description file for danmaku game\n");
    fprintf(coe, "; This .COE file specifies the contents for a ROM of depth=%d, and width=64.\n", depth);
    fprintf(coe, "memory_initialization_radix=16;\n");
    fprintf(coe, "memory_initialization_vector=\n");

    int item_count = 0;
    while (!feof(desc)) {
        int x, y, w, h;
        fscanf(desc, "%d %d %d %d\n", &x, &y, &w, &h);
        fprintf(coe, "%04X%04X%04X%04X", x, y, w, h);
        if (item_count != depth - 1)
            fprintf(coe, ",\n");
        else
            fprintf(coe, ";\n");
        item_count++;
    }

    for (int i = item_count; i < depth; i++) {
        fprintf(coe, "0000000000000000");
        if (i != depth - 1)
            fprintf(coe, ",\n");
        else
            fprintf(coe, ";\n");
    }
    return 0;
}