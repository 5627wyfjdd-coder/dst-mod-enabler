#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *DSTRoot(void){
    NSString *doc=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    return [doc stringByAppendingPathComponent:@"DoNotStarveTogether"];
}
static void Ensure(NSString *p){
    [[NSFileManager defaultManager] createDirectoryAtPath:p withIntermediateDirectories:YES attributes:nil error:nil];
}
__attribute__((constructor))
static void DSTInit(void){
    @autoreleasepool{
        NSString *root=DSTRoot();
        Ensure(root);
        Ensure([root stringByAppendingPathComponent:@"mods"]);
        NSString *enabled=[root stringByAppendingPathComponent:@"enabledmods.lua"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:enabled]){
            [@"return {}\\n" writeToFile:enabled atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSString *settings=[root stringByAppendingPathComponent:@"modsettings.lua"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:settings]){
            [@"return {}\\n" writeToFile:settings atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        NSLog(@"[DSTMods] mods folder ready");
    }
}
