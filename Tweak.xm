#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>

typedef struct lua_State lua_State;

extern "C" {
    int lua_pushstring(lua_State *L,const char *s);
    void lua_pushcclosure(lua_State *L,int (*fn)(lua_State *),int n);
    void lua_setglobal(lua_State *L,const char *name);
}

static NSString *DSTRoot()
{
    NSString *doc =
    NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory,
        NSUserDomainMask,
        YES
    ).firstObject;

    return [doc stringByAppendingPathComponent:
            @"DoNotStarveTogether"];
}

static NSString *DSTMods()
{
    return [DSTRoot()
            stringByAppendingPathComponent:@"mods"];
}

extern "C"
const char *DST_GetModsPath()
{
    static NSString *path=nil;

    if(path==nil)
        path=DSTMods();

    return [path UTF8String];
}

static int Lua_DST_GetModsPath(lua_State *L)
{
    lua_pushstring(L,DST_GetModsPath());
    return 1;
}

extern "C"
void DST_RegisterLua(lua_State *L)
{
    lua_pushcclosure(L,Lua_DST_GetModsPath,0);
    lua_setglobal(L,"DST_GetModsPath");
}

extern "C"
int DST_CreateModsFolder()
{
    NSFileManager *fm=[NSFileManager defaultManager];

    NSString *root=DSTRoot();
    NSString *mods=DSTMods();

    [fm createDirectoryAtPath:mods
  withIntermediateDirectories:YES
                   attributes:nil
                        error:nil];

    NSString *enabled =
    [root stringByAppendingPathComponent:
     @"enabledmods.lua"];

    if(![fm fileExistsAtPath:enabled])
    {
        [@"return {}\n"
         writeToFile:enabled
         atomically:YES
         encoding:NSUTF8StringEncoding
         error:nil];
    }

    NSString *setting =
    [root stringByAppendingPathComponent:
     @"modsettings.lua"];

    if(![fm fileExistsAtPath:setting])
    {
        [@"return {}\n"
         writeToFile:setting
         atomically:YES
         encoding:NSUTF8StringEncoding
         error:nil];
    }

    return 1;
}

__attribute__((constructor))
static void DSTModsInit()
{
    @autoreleasepool
    {
        DST_CreateModsFolder();

        NSLog(@"[DSTMods] Loaded");
        NSLog(@"[DSTMods] %s",
              DST_GetModsPath());
    }
}
