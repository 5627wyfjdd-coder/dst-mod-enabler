#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *GetRoot(void)
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
    static NSString *mods=nil;

    if(!mods){

        mods=[GetRoot() stringByAppendingPathComponent:@"mods"];

        [[NSFileManager defaultManager]
            createDirectoryAtPath:mods
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }

    return [mods UTF8String];
}

extern "C"
int DST_CreateModsFolder(void)
{
    DST_GetModsPath();
    return 1;
}

__attribute__((constructor))
static void DSTModsInit(void)
{
    @autoreleasepool{

        DST_CreateModsFolder();

        NSString *root=GetRoot();

        NSString *enabled=[root stringByAppendingPathComponent:@"enabledmods.lua"];

        if(![[NSFileManager defaultManager] fileExistsAtPath:enabled]){

            [@"return {}\n" writeToFile:enabled
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:nil];
        }

        NSString *setting=[root stringByAppendingPathComponent:@"modsettings.lua"];

        if(![[NSFileManager defaultManager] fileExistsAtPath:setting]){

            [@"return {}\n" writeToFile:setting
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:nil];
        }

        NSLog(@"[DSTMods] Framework Loaded");
    }
}
