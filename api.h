#define SIZE_MAX   0x10000
struct list_head * append_int (struct list_head * head, int num, ...);
struct list_head * append_double (struct list_head *head, int num, ...);

struct list_head {
    union data {
        int *i;
        double *f;
        char *c;
        char **s;
        struct list_node *p;
    } data;
    int length;
    int size;
};
