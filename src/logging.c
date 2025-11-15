#include "logging.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <dlfcn.h>
#include <string.h>

static FILE* g_xeno_log_file = NULL;
static int g_use_android_log = 0;
static void* g_liblog = NULL;

// Android log function pointer
typedef int (*android_log_print_fn)(int prio, const char* tag, const char* fmt, ...);
static android_log_print_fn android_log_func = NULL;

void xeno_logging_init(void) {
	// Try to load Android's liblog.so at runtime
	g_liblog = dlopen("liblog.so", RTLD_NOW);
	if (g_liblog) {
		android_log_func = (android_log_print_fn)dlsym(g_liblog, "__android_log_print");
		if (android_log_func) {
			g_use_android_log = 1;
			android_log_func(4, "XenoWrapper", "ExynosTools logging initialized (Android logcat mode)");
			return;
		}
	}
	
	// Fall back to file/stderr logging
	const char* path = getenv("EXYNOSTOOLS_LOG_PATH");
	if (path && *path) {
		FILE* f = fopen(path, "a");
		if (f) {
			g_xeno_log_file = f;
			setvbuf(g_xeno_log_file, NULL, _IOLBF, 0);
			fprintf(g_xeno_log_file, "[XenoWrapper][I] ExynosTools logging initialized (file mode: %s)\n", path);
			return;
		}
	}
	
	// Default to stderr
	fprintf(stderr, "[XenoWrapper][I] ExynosTools logging initialized (stderr mode)\n");
}

FILE* xeno_log_stream(void) {
	return g_xeno_log_file ? g_xeno_log_file : stderr;
}

void xeno_log_print(int level, const char* tag, const char* fmt, ...) {
	va_list args;
	va_start(args, fmt);
	
	if (g_use_android_log && android_log_func) {
		// Use Android logcat
		android_log_func(level, tag, fmt, args);
	} else {
		// Use fprintf
		FILE* out = xeno_log_stream();
		const char* level_str;
		switch (level) {
			case 3: level_str = "D"; break;
			case 4: level_str = "I"; break;
			case 5: level_str = "W"; break;
			case 6: level_str = "E"; break;
			default: level_str = "?"; break;
		}
		fprintf(out, "[%s][%s] ", tag, level_str);
		vfprintf(out, fmt, args);
		fprintf(out, "\n");
		fflush(out);
	}
	
	va_end(args);
}

