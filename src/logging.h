#pragma once

#include <stdio.h>
#include <stdlib.h>

// Runtime detection of Android logcat - works even on cross-compiled binaries
void xeno_logging_init(void);
FILE* xeno_log_stream(void);
void xeno_log_print(int level, const char* tag, const char* fmt, ...);

static inline int xeno_log_enabled_debug(void) {
    const char* e = getenv("EXYNOSTOOLS_DEBUG");
    return e && *e == '1';
}

// Log levels matching Android
#define XENO_LOG_INFO  4
#define XENO_LOG_WARN  5
#define XENO_LOG_ERROR 6
#define XENO_LOG_DEBUG 3

#define XENO_LOGI(fmt, ...) xeno_log_print(XENO_LOG_INFO, "XenoWrapper", fmt, ##__VA_ARGS__)
#define XENO_LOGW(fmt, ...) xeno_log_print(XENO_LOG_WARN, "XenoWrapper", fmt, ##__VA_ARGS__)
#define XENO_LOGE(fmt, ...) xeno_log_print(XENO_LOG_ERROR, "XenoWrapper", fmt, ##__VA_ARGS__)
#define XENO_LOGD(fmt, ...) do { if (xeno_log_enabled_debug()) xeno_log_print(XENO_LOG_DEBUG, "XenoWrapper", fmt, ##__VA_ARGS__); } while(0)

