#import <Foundation/Foundation.h>
#import <substrate.h>
#import <dlfcn.h>

static NSString *DSTRoot(void)
{
    NSString *doc = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory,
        NSUserDomainMask,
        YES
    ).firstObject;

    return [doc stringByAppendingPathComponent:@"DoNotStarveTogether"];
}

static NSString *DSTMods(void)
{
    return [DSTRoot() stringByAppendingPathComponent:@"mods"];
}

static void EnsureDir(NSString *path)
{
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:path]) {
        [fm createDirectoryAtPath:path
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
}

static void EnsureLua(NSString *path)
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        return;

    [@"return {}\n" writeToFile:path
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:nil];
}

extern "C"
const char *DST_GetModsPath()
{
    static NSString *path = nil;

    if (!path)
        path = DSTMods();

    return [path UTF8String];
}

__attribute__((constructor))
static void DSTModsInit()
{
    @autoreleasepool {

        EnsureDir(DSTRoot());
        EnsureDir(DSTMods());

        EnsureLua([DSTRoot() stringByAppendingPathComponent:@"enabledmods.lua"]);
        EnsureLua([DSTRoot() stringByAppendingPathComponent:@"modsettings.lua"]);

        NSLog(@"[DSTMods] %@", DSTMods());
    }
}

/* ========= 2.1.1 Hook（需要真实符号） ========= */

typedef int (*luaL_loadbufferx_t)(
    void *,
    const char *,
    size_t,
    const char *,
    const char *);

static luaL_loadbufferx_t orig_luaL_loadbufferx;

static int hook_luaL_loadbufferx(
    void *L,
    const char *buff,
    size_t sz,
    const char *name,
    const char *mode)
{
    /* 在这里可注入 modindex.lua */

    return orig_luaL_loadbufferx(L,buff,sz,name,mode);
}

%ctor
{
    void *handle = dlopen(NULL, RTLD_NOW);

    if (!handle)
        return;

    /* 这里必须根据2.1.1实际符号MSHookFunction */
}
