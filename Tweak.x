#import <Foundation/Foundation.h>
#import <substrate.h>
#include <string.h>

typedef struct lua_State lua_State;

static int (*orig_luaL_loadfile)(lua_State *L, const char *filename);

static int my_luaL_loadfile(lua_State *L, const char *filename) {
    if (filename && strstr(filename, "servercreationscreen.lua")) {
        NSString *path = [NSString stringWithUTF8String:filename];
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        if (content && !error) {
            NSString *target = @"self.mods_enabled = IsNotConsole()";
            NSString *replacement = @"self.mods_enabled = true";
            
            if ([content containsString:target]) {
                NSString *modified = [content stringByReplacingOccurrencesOfString:target withString:replacement];
                
                NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"servercreationscreen_modified.lua"];
                [modified writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                
                if (!error) {
                    return orig_luaL_loadfile(L, [tempPath UTF8String]);
                }
            }
        }
    }
    return orig_luaL_loadfile(L, filename);
}

%ctor {
    void *addr = MSFindSymbol(NULL, "_luaL_loadfile");
    if (!addr) addr = MSFindSymbol(NULL, "luaL_loadfile");
    if (addr) {
        MSHookFunction(addr, (void *)my_luaL_loadfile, (void **)&orig_luaL_loadfile);
    }
}
