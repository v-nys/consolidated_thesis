#include "logging.h"

zlog_category_t *control_cat;
zlog_category_t *value_cat;

int start_log() {
    const int CONFIG_ISSUE = -1;
    const int CATEGORY_ISSUE = -2;
    int rc;
    rc = zlog_init("logging.conf");
    if (rc) {
        return CONFIG_ISSUE; 
    }
    control_cat = zlog_get_category("control_flow");
    value_cat = zlog_get_category("values");
    if (!control_cat || !value_cat) {
        printf("get cat fail\n");
        zlog_fini();
        return CATEGORY_ISSUE;
    }
    zlog_info(control_cat, "Initialized logger.");
    return 0;
}

int complete_log() {
    zlog_fini();
    return 0;
}
