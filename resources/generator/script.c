#include <stdio.h>
int main()
{
    FILE *script = fopen("script.txt", "r");
    FILE *coe = fopen("script.coe", "w");

    int depth = 4096;

    fprintf(coe, "; Script file for danmaku game\n");
    fprintf(coe, "; This .COE file specifies the contents for a ROM of depth=%d, and width=104.\n", depth);
    fprintf(coe, "memory_initialization_radix=16;\n");
    fprintf(coe, "memory_initialization_vector=\n");

    int item_count = 0;
    while (!feof(script)) {
        int frame, base_x, base_y, deg, rho, vdeg, vrho, res_id;
        fscanf(script, "%d %d %d %d %d %d %d %d\n", &frame, &base_x, &base_y, &deg, &rho, &vdeg, &vrho, &res_id);
        fprintf(coe, "%04X%04X%04X%04X%04X%02X%02X%02X", frame, base_x, base_y, deg, rho, vdeg, vrho, res_id);
        if (item_count != depth - 1)
            fprintf(coe, ",\n");
        else
            fprintf(coe, ";\n");
        item_count++;
    }

    for (int i = item_count; i < depth; i++) {
        fprintf(coe, "00000000000000000000000000");
        if (i != depth - 1)
            fprintf(coe, ",\n");
        else
            fprintf(coe, ";\n");
    }
    return 0;
}