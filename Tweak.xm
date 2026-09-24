#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *DSTRoot(void)
{
    NSString *doc = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory,
        NSUserDomainMask,
        YES
    ).firstObject;

    return [doc stringByAppendingPathComponent:@"DoNotStarveTogether"];
}

extern "C"
const char *DST_GetModsPath(void)
{
    static NSString *mods = nil;

    if (!mods) {
        mods = [[DSTRoot() stringByAppendingPathComponent:@"mods"] copy];
    }

    return [mods UTF8String];
}

extern "C"
int DST_CreateModsFolder(void)
{
    NSFileManager *fm = [NSFileManager defaultManager];

    NSString *modsPath = [NSString stringWithUTF8String:DST_GetModsPath()];

    [fm createDirectoryAtPath:modsPath
  withIntermediateDirectories:YES
                   attributes:nil
                        error:nil];

    NSString *enabled =
        [DSTRoot() stringByAppendingPathComponent:@"enabledmods.lua"];

    if (![fm fileExistsAtPath:enabled]) {
        [@"return {}\n" writeToFile:enabled
                         atomically:YES
                           encoding:NSUTF8StringEncoding
                              error:nil];
    }

    NSString *setting =
        [DSTRoot() stringByAppendingPathComponent:@"modsettings.lua"];

    if (![fm fileExistsAtPath:setting]) {
        [@"return {}\n" writeToFile:setting
                         atomically:YES
                           encoding:NSUTF8StringEncoding
                              error:nil];
    }

    return 1;
}

__attribute__((constructor))
static void DSTModsInit(void)
{
    @autoreleasepool {
        DST_CreateModsFolder();
        NSLog(@"[DSTMods] Framework Loaded");
    }
}
