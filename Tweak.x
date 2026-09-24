#import <Foundation/Foundation.h>
#import <substrate.h>
#include <string.h>
#include <stdlib.h>

typedef struct lua_State lua_State;

static int (*orig_luaL_loadfile)(lua_State *L, const char *filename);
static int (*p_luaL_loadstring)(lua_State *L, const char *s);
static const char *(*p_lua_tostring)(lua_State *L, int idx);
static void (*p_lua_pop)(lua_State *L, int n);

static int my_luaL_loadfile(lua_State *L, const char *filename) {
    if (!orig_luaL_loadfile) return 0;
    int ret = orig_luaL_loadfile(L, filename);
    if (filename && strstr(filename, "servercreationscreen.lua")) {
        if (!p_lua_tostring) return ret;
        const char *source = p_lua_tostring(L, -1);
        if (source) {
            const char *target = "self.mods_enabled = IsNotConsole()";
            char *pos = strstr(source, target);
            if (pos) {
                if (!p_lua_pop || !p_luaL_loadstring) return ret;
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
                    p_lua_pop(L, 1);
                    ret = p_luaL_loadstring(L, new_source);
                    free(new_source);
                }
            }
        }
    }
    return ret;
}

%ctor {
    void *addr = MSFindSymbol(NULL, "_luaL_loadfile");
    if (!addr) addr = MSFindSymbol(NULL, "luaL_loadfile");
    if (addr) {
        MSHookFunction(addr, (void *)my_luaL_loadfile, (void **)&orig_luaL_loadfile);
    }
    
    p_luaL_loadstring = (int (*)(lua_State *, const char *))MSFindSymbol(NULL, "_luaL_loadstring");
    if (!p_luaL_loadstring) p_luaL_loadstring = (int (*)(lua_State *, const char *))MSFindSymbol(NULL, "luaL_loadstring");
    
    p_lua_tostring = (const char *(*)(lua_State *, int))MSFindSymbol(NULL, "_lua_tostring");
    if (!p_lua_tostring) p_lua_tostring = (const char *(*)(lua_State *, int))MSFindSymbol(NULL, "lua_tostring");
    
    p_lua_pop = (void (*)(lua_State *, int))MSFindSymbol(NULL, "_lua_pop");
    if (!p_lua_pop) p_lua_pop = (void (*)(lua_State *, int))MSFindSymbol(NULL, "lua_pop");
}
