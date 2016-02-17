//
//  NSAppDelegate.m
//  Nudgespot
//
//  Created by Maheep Kaushal on 02/17/2016.
//  Copyright (c) 2016 Nudgespot. All rights reserved.
//

#import "NSAppDelegate.h"

#import "Nudgespot.h"
#import "NudgeSpotConstants.h"

static NSUInteger badgeCount = 1;

@interface NSAppDelegate()

@property (nonatomic, strong) NSData *deviceToken;

@end

@implementation NSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Override point for customization after application launch.
    // Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
    } else {
        // iOS 8 or later
        // [END_EXCLUDE]
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    // [END register_for_remote_notifications]
    // [START start_gcm_service]
    
    [Nudgespot  setApiKey:kApiKey andSecretToken:kApiSecretToken];
    
    return YES;
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Connect to the GCM server to receive non-APNS notifications
    
    badgeCount = 0;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    
    [Nudgespot  connectWithGCM];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    
    NSLog(@"Notification received: %@", userInfo);
    
    badgeCount = badgeCount +1;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    
    [Nudgespot   acknowledgeGCMServer:userInfo];
    
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%@ is device token", deviceToken);
    
    self.deviceToken = deviceToken;
    
    [Nudgespot   loadDeviceToken:deviceToken];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [Nudgespot   disconnectWithGCM];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}


@end
