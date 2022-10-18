#import "TerraFlutterRtPlugin.h"
#if __has_include(<terra_flutter_rt/terra_flutter_rt-Swift.h>)
#import <terra_flutter_rt/terra_flutter_rt-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "terra_flutter_rt-Swift.h"
#endif

@implementation TerraFlutterRtPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTerraFlutterRtPlugin registerWithRegistrar:registrar];
}
@end
