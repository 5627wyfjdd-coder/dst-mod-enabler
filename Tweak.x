#import <Foundation/Foundation.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

static void MakeDir(NSString *path) {
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

static void InstallMod(void) {
    // Fixed path requested by the user.
    NSString *root =
        @"/var/mobile/Containers/Data/Application/"
         "C763CDBC-2A29-45A7-93D8-4CA2139A08F6/"
         "Documents/DoNotStarveTogether";

    NSString *mods = [root stringByAppendingPathComponent:@"mods"];
    NSString *mod  = [mods stringByAppendingPathComponent:@"Ice Backpack"];

    MakeDir(root);
    MakeDir(mods);
    MakeDir(mod);

    // Resources are bundled with the dylib.
    NSBundle *bundle = [NSBundle bundleForClass:[NSObject class]];
    NSString *resourceRoot = [[NSBundle mainBundle] resourcePath];

    // For a Theos dylib/tweak, resources are installed under the tweak's
    // bundle directory.  Prefer the executable's adjacent Resources path.
    NSString *candidate = [[NSBundle bundleWithPath:
        [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DSTModLoader.bundle"]]
        resourcePath];

    if (candidate) resourceRoot = candidate;

    NSArray<NSString *> *files = @[
        @"modicon.tex",
        @"modicon.xml",
        @"modinfo.lua",
        @"modmain.lua"
    ];

    NSFileManager *fm = [NSFileManager defaultManager];

    for (NSString *file in files) {
        NSString *src = [resourceRoot stringByAppendingPathComponent:
                         [@"Ice Backpack" stringByAppendingPathComponent:file]];
        NSString *dst = [mod stringByAppendingPathComponent:file];

        if ([fm fileExistsAtPath:src]) {
            [fm removeItemAtPath:dst error:nil];
            [fm copyItemAtPath:src toPath:dst error:nil];
        }
    }
}

__attribute__((constructor))
static void DSTModLoaderInit(void) {
    @autoreleasepool {
        InstallMod();
    }
}

