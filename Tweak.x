#import <Foundation/Foundation.h>
#import <substrate.h>
#include <string.h>
#include <stdlib.h>

typedef struct lua_State lua_State;
extern int luaL_loadstring(lua_State *L, const char *s);
extern const char *lua_tostring(lua_State *L, int idx);
extern void lua_pop(lua_State *L, int n);

static int (*orig_luaL_loadfile)(lua_State *L, const char *filename);

static int my_luaL_loadfile(lua_State *L, const char *filename) {
    int ret = orig_luaL_loadfile(L, filename);
    if (filename && strstr(filename, "servercreationscreen.lua")) {
        const char *source = lua_tostring(L, -1);
        if (source) {
            const char *target = "self.mods_enabled = IsNotConsole()";
            char *pos = strstr(source, target);
            if (pos) {
                const char *replacement = "self.mods_enabled = true";
                size_t prefix_len = pos - source;
                size_t target_len = strlen(target);
                size_t repl_len = strlen(replacement);
                size_t suffix_len = strlen(pos + target_len);
                size_t new_len = prefix_len + repl_len + suffix_len + 1;
                char *new_source = malloc(new_len);
                if (new_source) {
                    memcpy(new_source, source, prefix_len);
                    memcpy(new_source + prefix_len, replacement, repl_len);
                    memcpy(new_source + prefix_len + repl_len, pos + target_len, suffix_len);
                    new_source[new_len - 1] = '\0';
                    lua_pop(L, 1);
                    ret = luaL_loadstring(L, new_source);
                    free(new_source);
                }
            }
        }
    }
    return ret;
}

%ctor {
    void *addr = MSFindSymbol(NULL, "_luaL_loadfile");
    if (addr) {
        MSHookFunction(addr, (void *)my_luaL_loadfile, (void **)&orig_luaL_loadfile);
    }
}
