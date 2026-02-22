#define _GNU_SOURCE

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <config.h>
#include <map.h>
#include <wofi_api.h>

struct mode;
struct widget;

struct node {
	struct widget* widget;
	struct wl_list link;
};

static struct mode* current_mode;
static struct wl_list widgets;

static const char* VIEW_LABEL = "view";
static const char* VIEW_PREFIX = "__wofi_view__\t";

static void launch_viewer(const char* image_path);

static void trim_newline(char* line) {
	size_t len = strlen(line);
	while(len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) {
		line[len - 1] = '\0';
		--len;
	}
}

static bool is_image_entry(const char* entry) {
	return strstr(entry, "[[ binary data ") != NULL;
}

static bool run_stdin_command(const char* command, const char* input) {
	FILE* pipe = popen(command, "w");
	if(pipe == NULL) {
		return false;
	}

	if(fputs(input, pipe) == EOF || fputc('\n', pipe) == EOF) {
		pclose(pipe);
		return false;
	}

	return pclose(pipe) == 0;
}

static void debug_log_exec(const char* cmd) {
	FILE* f = fopen("/tmp/wofi-cliphist-debug.log", "a");
	if(f == NULL) {
		return;
	}
	const char* secondary = getenv("WOFI_ACTION_SECONDARY");
	fprintf(
		f,
		"exec cmd=[%s] is_view=%d secondary=%s\n",
		cmd,
		strncmp(cmd, VIEW_PREFIX, strlen(VIEW_PREFIX)) == 0 ? 1 : 0,
		secondary == NULL ? "NULL" : secondary
	);
	fclose(f);
}

static void enqueue_widget(const char* entry) {
	struct node* node = calloc(1, sizeof(struct node));
	if(node == NULL) {
		return;
	}

	if(is_image_entry(entry)) {
		char* text[2];
		char* actions[2];
		size_t view_action_len = strlen(VIEW_PREFIX) + strlen(entry) + 1;
		char* view_action = malloc(view_action_len);
		if(view_action == NULL) {
			free(node);
			return;
		}

		text[0] = (char*) entry;
		text[1] = (char*) VIEW_LABEL;
		actions[0] = (char*) entry;
		snprintf(view_action, view_action_len, "%s%s", VIEW_PREFIX, entry);
		actions[1] = view_action;

		node->widget = wofi_create_widget(current_mode, text, (char*) entry, actions, 2);
		free(view_action);
	} else {
		char* text[1];
		char* actions[1];
		text[0] = (char*) entry;
		actions[0] = (char*) entry;
		node->widget = wofi_create_widget(current_mode, text, (char*) entry, actions, 1);
	}

	if(node->widget == NULL) {
		free(node);
		return;
	}

	wl_list_insert(&widgets, &node->link);
}

static bool decode_entry_to_file(const char* entry, const char* output_path) {
	char command[512];
	snprintf(command, sizeof(command), "cliphist decode > %s", output_path);
	return run_stdin_command(command, entry);
}

static void preview_image_entry(const char* entry) {
	char temp_path[] = "/tmp/wofi-cliphist-image-XXXXXX";
	int fd = mkstemp(temp_path);
	if(fd < 0) {
		return;
	}

	close(fd);
	if(decode_entry_to_file(entry, temp_path)) {
		launch_viewer(temp_path);
	} else {
		unlink(temp_path);
	}
}

static void launch_viewer(const char* image_path) {
	pid_t pid = fork();
	if(pid != 0) {
		return;
	}

	execlp(
		"sh",
		"sh",
		"-c",
		"mpv --title='cliphist-view' --force-window=immediate --keep-open=yes --image-display-duration=inf \"$1\"; rm -f \"$1\"",
		"sh",
		image_path,
		(char*) NULL
	);

	_exit(127);
}

void init(struct mode* mode, struct map* config) {
	(void) config;
	current_mode = mode;
	wl_list_init(&widgets);

	FILE* list = popen("cliphist list", "r");
	if(list == NULL) {
		return;
	}

	char* line = NULL;
	size_t size = 0;
	while(getline(&line, &size, list) != -1) {
		trim_newline(line);
		if(line[0] == '\0') {
			continue;
		}
		enqueue_widget(line);
	}

	free(line);
	pclose(list);
}

struct widget* get_widget(void) {
	struct node* node;
	struct node* tmp;
	wl_list_for_each_reverse_safe(node, tmp, &widgets, link) {
		struct widget* widget = node->widget;
		wl_list_remove(&node->link);
		free(node);
		return widget;
	}
	return NULL;
}

void exec(const char* cmd) {
	if(cmd == NULL || *cmd == '\0') {
		wofi_exit(1);
		return;
	}

	debug_log_exec(cmd);

	size_t prefix_len = strlen(VIEW_PREFIX);
	if(strncmp(cmd, VIEW_PREFIX, prefix_len) == 0) {
		const char* secondary = getenv("WOFI_ACTION_SECONDARY");
		if(secondary != NULL && strcmp(secondary, "1") == 0) {
			const char* entry = cmd + prefix_len;
			preview_image_entry(entry);
		}
	} else {
		run_stdin_command("cliphist decode | wl-copy", cmd);
	}

	wofi_exit(0);
}

bool no_entry(void) {
	return true;
}
