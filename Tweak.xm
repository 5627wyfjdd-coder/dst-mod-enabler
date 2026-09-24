#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static void CreateMods(void)
{
    NSString *doc = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory,
        NSUserDomainMask,
        YES
    ).firstObject;

    NSString *root = [doc stringByAppendingPathComponent:@"DoNotStarveTogether"];
    NSString *mods = [root stringByAppendingPathComponent:@"mods"];

    NSFileManager *fm = [NSFileManager defaultManager];

    [fm createDirectoryAtPath:mods
  withIntermediateDirectories:YES
                   attributes:nil
                        error:nil];

    NSString *enabled = [root stringByAppendingPathComponent:@"enabledmods.lua"];
    if (![fm fileExistsAtPath:enabled]) {
        [@"return {}\n" writeToFile:enabled atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }

    NSString *settings = [root stringByAppendingPathComponent:@"modsettings.lua"];
    if (![fm fileExistsAtPath:settings]) {
        [@"return {}\n" writeToFile:settings atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

%hook UIApplication

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    %orig;
    CreateMods();
}

%end

%ctor
{
    @autoreleasepool {
        NSLog(@"[DSTMods] Loaded");
    }
}
