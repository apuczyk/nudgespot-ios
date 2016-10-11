//
//  BTActionOptions.m
//  Pods
//
//  Created by Nudgespot on 15/09/16.
//
//

#import "BTActionOptions.h"

@implementation BTActionOptions

@synthesize behavior, parameters, activationMode, authenticationRequired, destructive;

+ (BTActionOptions *) updateBehavior: (UIUserNotificationActionBehavior) behavior andParameters:(NSDictionary *) parameters andActivationMode:(UIUserNotificationActivationMode) activationMode andAuthenticationRequired:(BOOL) authenticationRequired andDestructive:(BOOL) destructive;
{
    
    BTActionOptions * options = [[BTActionOptions alloc] init];
    
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
        options.behavior = behavior;
        options.parameters = parameters;
    #endif
    
    options.activationMode = activationMode;
    options.authenticationRequired = authenticationRequired;
    options.destructive = destructive;
    
    return options;
}

@end
