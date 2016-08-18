//
//  NSAppDelegate.m
//  Nudgespot
//
//  Created by Maheep Kaushal on 04/07/2016.
//  Copyright (c) 2016 Maheep Kaushal. All rights reserved.
//

#import "NSAppDelegate.h"
#import "NSViewController.h"

#import "Nudgespot.h"
#import "NudgeSpotConstants.h"
#import "STPopupController.h"

@interface BasicTheamViewController : UIViewController

@property(nonatomic, assign) CGSize contentSizeInPopup;
@property(nonatomic, assign) CGSize landscapeContentSizeInPopup;

@end

@implementation BasicTheamViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"Basic Theam ViewController";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnDidTap)];
        self.contentSizeInPopup = CGSizeMake(300, 400);
        self.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    }
    return self;
}

- (void)nextBtnDidTap {
    
    NSLog(@"I am tapped");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
}

@end

static NSUInteger badgeCount = 1;

NSString * const NotificationCategoryIdent1  = @"ACTIONABLE";
//NSString * const NotificationCategoryIdent2  = @"ACTIONABLE2";
NSString * const NotificationActionOneIdent = @"ACTION_ONE";
NSString * const NotificationActionTwoIdent = @"ACTION_TWO";

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
        
        [self registerForNotification];
    }
    // [END register_for_remote_notifications]
    // [START start_Fcm_service]
    
    [Nudgespot setJavascriptAPIkey:kJavascriptAPIkey andRESTAPIkey:kRESTAPIkey];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriberUid];
    
    if (!uid) {
        
        // Here we are creating Anonymous user again for tracking activites.
        [Nudgespot registerAnynomousUser:^(id response, NSError *error) {
            NSLog(@"%@ is response", response);
        }];
        
    } else {
        [Nudgespot setWithUID:uid registrationHandler:^(NSString *registrationToken, NSError *error) {
            NSLog(@"%@ is response ", registrationToken);
        }];
    }
    
    return YES;
    
}


- (void)registerForNotification {
    
    UIMutableUserNotificationAction *action1;
    action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
    [action1 setTitle:@"Action 1"];
    [action1 setIdentifier:NotificationActionOneIdent];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:@"Action 2"];
    [action2 setIdentifier:NotificationActionTwoIdent];
    [action2 setDestructive:NO];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory1;
    actionCategory1 = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory1 setIdentifier:NotificationCategoryIdent1];
    [actionCategory1 setActions:@[action1, action2]
                    forContext:UIUserNotificationActionContextDefault];
    
//    UIMutableUserNotificationCategory *actionCategory2;
//    actionCategory2 = [[UIMutableUserNotificationCategory alloc] init];
//    [actionCategory2 setIdentifier:NotificationCategoryIdent2];
//    [actionCategory2 setActions:@[action1, action2, action1, action2]
//                    forContext:UIUserNotificationActionContextDefault];
//    
    NSSet *categories = [NSSet setWithObjects:actionCategory1,  nil];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Connect to the Fcm server to receive non-APNS notifications
    
    badgeCount = 0;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    
    [Nudgespot  connectToFcm];
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    NSLog(@"Notification received: %@", userInfo);
    
    if ([identifier isEqualToString:NotificationActionOneIdent]) {
        
        NSLog(@"You chose action 1.");
    }
    else if ([identifier isEqualToString:NotificationActionTwoIdent]) {
        
        NSLog(@"You chose action 2.");
    }
    if (completionHandler) {
        
        completionHandler();
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    
    NSLog(@"Notification received: %@", userInfo);
    
    // Start Code for showing message..
    if ((application.applicationState == UIApplicationStateInactive)) {
    
        STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:[BasicTheamViewController new]];
        UINavigationController *nc = (UINavigationController*)self.window.rootViewController;
        
        if (nc != nil) {
            [popupController presentInViewController:nc];
        }
        
    }
    // End Code for message popup showing..
    
    
    badgeCount = badgeCount +1;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    
    [Nudgespot  acknowledgeFcmServer:userInfo];
    
    [Nudgespot  processNudgespotNotification:userInfo withApplication:application andWindow:self.window];
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


@end
