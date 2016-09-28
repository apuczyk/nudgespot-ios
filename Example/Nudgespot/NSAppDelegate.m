//
//  NSAppDelegate.m
//  Nudgespot
//
//  Created by Maheep Kaushal on 04/07/2016.
//  Copyright (c) 2016 Maheep Kaushal. All rights reserved.
//

#import "NSAppDelegate.h"
#import "NSViewController.h"

#import "NudgespotSDK.h"
#import "NudgeSpotConstants.h"

static NSUInteger badgeCount = 1;

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
        
        UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                        UIUserNotificationTypeSound|
                                        UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types
                                                     categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    // [END register_for_remote_notifications]
    // [START start_Fcm_service]
        
    // Initialize Nudgespot
    
    [Nudgespot setJavascriptAPIkey:kJavascriptAPIkey andRESTAPIkey:kRESTAPIkey];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriberUid];
    
    if (!uid) {
        
        // Here we are creating Anonymous user again for tracking activites.
        
        [Nudgespot registerAnonymousUser:^(id response, NSError *error) {
            NSLog(@"%@ is response", response);
        }];
        
    } else {
        [Nudgespot setWithUID:uid registrationHandler:^(NSString *registrationToken, NSError *error) {
            NSLog(@"%@ is response ", registrationToken);
        }];
    }
    
    return YES;
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Connect to the Nudgetspot server to receive notifications
    
    badgeCount = 0;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    
    [Nudgespot  connectToFcm];
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
    
    [Nudgespot acknowledgeFcmServer:userInfo];
    
    [Nudgespot processNudgespotNotification:userInfo withApplication:application andWindow:self.window];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%@ is device token", deviceToken);
    
    [Nudgespot setAPNSToken:deviceToken ofType:NudgespotAPNSTokenTypeProd];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [Nudgespot disconnectToFcm];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}


@end
