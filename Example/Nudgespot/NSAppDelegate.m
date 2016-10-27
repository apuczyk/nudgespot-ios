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


#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif


static NSUInteger badgeCount = 1;

@implementation NSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
#pragma clang diagnostic pop
    } else {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError * _Nullable error) {
             }
             ];
            
            // For iOS 10 display notification (sent via APNS)
            [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
            // For iOS 10 data message (sent via FCM)
            [[FIRMessaging messaging] setRemoteMessageDelegate:self];
#endif
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }
    
    
    // Initialize Nudgespot
    
    [Nudgespot setJavascriptAPIkey:kJavascriptAPIkey andRESTAPIkey:kRESTAPIkey];
    
    [BTUserAppNotification setAllDefaultBTCategory:application];
    
//    BTActionOptions *custom1 = [BTActionOptions updateBehavior:(UIUserNotificationActionBehavior) andParameters:(NSDictionary *) andActivationMode:(UIUserNotificationActivationMode) andAuthenticationRequired:(BOOL) andDestructive:(BOOL)];
//    [BTUserAppNotification createCustomCategoryWithIdentifier:@"Actionalble" withActions:@[custom1] withApplication:application];
    
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
    
    [Nudgespot setAPNSToken:deviceToken ofType:NudgespotAPNSTokenTypeSandbox];
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


// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Print message ID.
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
    // Print full message.
    NSLog(@"%@", userInfo);
}

// Receive data message on iOS 10 devices.
//- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
//    // Print full message
//    NSLog(@"%@", [remoteMessage appData]);
//}
#endif
// [END ios_10_message_handling]

@end
