//
//  BTUserAppNotification.h
//  Pods
//
//  Created by Nudgespot on 02/09/16.
//
//

#import <UIKit/UIKit.h>

#import "BTActionOptions.h"

@protocol BTUserAppNotificationDelegate <NSObject>

- (void)launchedFromNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void)launchedFromNotification:(NSDictionary *)notification actionIdentifier:(NSString *)identifier completionHandler:(void (^)())completionHandler;

- (void)receivedBackgroundNotification:(NSDictionary *)notification actionIdentifier:(NSString *)identifier completionHandler:(void (^)())completionHandler;

- (void)receivedBackgroundNotification:(NSDictionary *)notification actionIdentifier:(NSString *)identifier withResponse: (NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler;

@end

@interface BTUserAppNotification : NSObject

@property(nonatomic, strong) id <BTUserAppNotificationDelegate> btUserDelegate;

@property(nonatomic, strong) UIApplication* application;

+ (BTUserAppNotification *)sharedInstance;

+ (void)application: (UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

+ (void)application: (UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo withWindows: (UIWindow *)windows fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())handler;

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())handler;

// This is for iOS 10.
//+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
//
//+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler;


// Set Notification Categories from Boomtrain Default categories..

+ (void) setDefaultBTCategoryWith : (NSString *) notificationIdentifier andApplication: (UIApplication *)application;

+ (void) setAllDefaultBTCategory: (UIApplication *)application;

+ (void) updateRegistration : (UIApplication *)application withCategories: (NSSet *)categories;

+ (UIMutableUserNotificationAction *) createCustomActionWithTitle:(NSString *)title withIdentifier:(NSString *)identifier options:(BTActionOptions *)optionDic;

+ (void) createCustomCategoryWithIdentifier: (NSString *)identifier withActions:(NSArray *)actions withApplication:(UIApplication *) application;

@end
