#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern "C" const char *DST_GetModsPath(void)
{
    static NSString *path = nil;

    if (!path) {
        NSString *doc = NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory,
            NSUserDomainMask,
            YES
        ).firstObject;

        path = [doc stringByAppendingPathComponent:
                @"DoNotStarveTogether/mods"];

        [[NSFileManager defaultManager]
            createDirectoryAtPath:path
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }

    return [path UTF8String];
}

__attribute__((constructor))
static void DSTModsInit(void)
{
    DST_GetModsPath();
    NSLog(@"[DSTMods] Framework Loaded");
}
