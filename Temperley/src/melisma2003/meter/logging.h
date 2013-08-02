#include "zlog.h"

extern zlog_category_t *control_cat;
extern zlog_category_t *value_cat;

extern const int CONFIG_ISSUE;
extern const int CATEGORY_ISSUE;

//set up logging and make logging categories available
int start_log();

//call whenever program exits
int complete_log();
