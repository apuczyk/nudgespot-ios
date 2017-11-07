//
//  BTUserAppNotification.m
//  Pods
//
//  Created by Nudgespot on 02/09/16.
//
//

#import "BTUserAppNotification.h"

static BTUserAppNotification *sharedManager = nil;

@implementation BTUserAppNotification

+ (BTUserAppNotification *)sharedInstance {
    @synchronized(self) {
        if(sharedManager == nil)
            sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}


+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance] ;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}


+ (void)application: (UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings; {
    
    DLog(@"%@ is application and %@ is notificationSettings", application, notificationSettings);
    
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo withWindows: (UIWindow *)windows fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler; {
    
    [Nudgespot acknowledgeFcmServer:userInfo];
    
    [Nudgespot processNudgespotNotification:userInfo withApplication:application andWindow:windows];
    
    DLog(@"%@ is delegate", [[self sharedInstance] btUserDelegate]);
    
    if ([[[self sharedInstance] btUserDelegate]  respondsToSelector:@selector(launchedFromNotification:fetchCompletionHandler:)]) {
        
        [[[self sharedInstance] btUserDelegate] launchedFromNotification:userInfo fetchCompletionHandler:completionHandler];
    }

}

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())handler; {
    
    switch (application.applicationState) {
            
        case UIApplicationStateActive: // In Active State
            break;
        case UIApplicationStateInactive: // In InActive State
            
            if ([[[self sharedInstance] btUserDelegate] respondsToSelector:@selector(launchedFromNotification:actionIdentifier:completionHandler:)]) {
                [[[self sharedInstance] btUserDelegate] launchedFromNotification:userInfo actionIdentifier:identifier completionHandler:handler];
            }
            
            break;
            
        case UIApplicationStateBackground: // In BackGround State
            
            if ([[[self sharedInstance] btUserDelegate] respondsToSelector:@selector(receivedBackgroundNotification:actionIdentifier:completionHandler:)]) {
                [[[self sharedInstance] btUserDelegate] receivedBackgroundNotification:userInfo actionIdentifier:identifier completionHandler:handler];
            }
            
            break;
        default:
            break;
    }
    
}

+ (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())handler; {
    
    if ([[[self sharedInstance] btUserDelegate] respondsToSelector:@selector(receivedBackgroundNotification:actionIdentifier:withResponse:completionHandler:)]) {
        
        [[[self sharedInstance] btUserDelegate] receivedBackgroundNotification:userInfo actionIdentifier:identifier withResponse:responseInfo completionHandler:handler];
    }
    
}

//
//+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler; {
//    
//}
//
//+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler; {
//    
//}


// Set Notification Categories from Boomtrain Default categories..

+ (void) setDefaultBTCategoryWith : (NSString *) notificationIdentifier andApplication: (UIApplication *)application; {
    
    NSDictionary * userCategories = [self getUserCategoryDictionary];
    
    if (userCategories != nil) {
        
        NSMutableSet *categorySet = [[NSMutableSet alloc] init];
        
        UIMutableUserNotificationCategory * actionCategory = [self getCategoriesFrom:notificationIdentifier fromDictionary:userCategories];
        [categorySet addObject:actionCategory];
        
        [self updateRegistration:application withCategories:categorySet];
    }
}

+ (void) setAllDefaultBTCategory: (UIApplication *)application; {
    
    NSSet *allCategoriesSet = [self getAllDefaultBTCategory];
    
    [self updateRegistration:application withCategories:allCategoriesSet];
}

+ (NSMutableSet*) getAllDefaultBTCategory {
    
    NSDictionary * userCategories = [self getUserCategoryDictionary];
    
    if (userCategories != nil) {
        
        NSMutableSet *allSet = [[NSMutableSet alloc] init];
        
        for (NSString * category in userCategories.allKeys) {
            
            UIMutableUserNotificationCategory * actionCategory = [self getCategoriesFrom:category fromDictionary:userCategories];
            [allSet addObject:actionCategory];
        }
        
        return allSet;
    }
    
    return nil;
}

+ (void) createCustomCategoryWithIdentifier: (NSString *)identifier withActions:(NSArray *)actions withApplication:(UIApplication *) application;
{
    
    [[self sharedInstance] setApplication:application];
    
    NSString const * NotificationCategoryIdent = identifier ;
    
    UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier: NotificationCategoryIdent];
    [actionCategory setActions:actions
                    forContext:UIUserNotificationActionContextDefault];
    
    NSMutableSet *allCategoriesSet = [self getAllDefaultBTCategory];
    
    [allCategoriesSet addObject:actionCategory];
    
    [self updateRegistration:application withCategories:allCategoriesSet];

}

+ (UIMutableUserNotificationAction *) createCustomActionWithTitle:(NSString *)title withIdentifier:(NSString *)identifier options:(BTActionOptions *)optionDic;
{
    
    UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
    action.behavior = optionDic.behavior;
    action.activationMode = optionDic.activationMode;
    action.parameters = optionDic.parameters;
    action.authenticationRequired = optionDic.authenticationRequired;
    action.destructive = optionDic.destructive;
    [action setTitle:title];
    [action setIdentifier:identifier];
    
    return action;
}


+ (void) updateRegistration : (UIApplication *)application withCategories: (NSSet *)categories {
    
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
}

+ (UIMutableUserNotificationCategory *) getCategoriesFrom : (NSString *)notificationCategory fromDictionary: (NSDictionary *) userCategory {
    
    if ([userCategory objectForKey:notificationCategory]) {
        
        NSArray *userCategories = [userCategory objectForKey:notificationCategory];
        NSMutableArray *actions = [NSMutableArray array];
        
        if (userCategories != nil) {
            
            for (NSDictionary *dictionary in userCategories) {
                
                UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
                
                if ([dictionary[@"foreground"] boolValue] == true) {
                    [action setActivationMode:UIUserNotificationActivationModeForeground];
                } else {
                    [action setActivationMode:UIUserNotificationActivationModeBackground];
                }
                
                if ([dictionary[@"defaultBehavior"] boolValue] == true) {
                    [action setBehavior:UIUserNotificationActionBehaviorDefault];
                } else {
                    [action setBehavior:UIUserNotificationActionBehaviorTextInput];
                }
                
                [action setTitle:dictionary[@"title"]];
                [action setIdentifier:dictionary[@"identifier"]];
                [action setDestructive:NO];
                [action setAuthenticationRequired:[dictionary[@"authenticationRequired"] boolValue]];
                
                [actions addObject:action];
            }
        }
        
        NSString const * NotificationCategoryIdent = notificationCategory ;
        
        UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
        [actionCategory setIdentifier: NotificationCategoryIdent];
        [actionCategory setActions:actions
                        forContext:UIUserNotificationActionContextDefault];
        
        return actionCategory;
    }
    
    return nil;
}

+ (NSDictionary *) getUserCategoryDictionary {
    
    NSBundle *bundle = [NSBundle bundleForClass:self.classForCoder];
    NSURL *bundleUrl = [bundle URLForResource:@"Nudgespot" withExtension:@"bundle"];
    
    if (bundleUrl != nil) {
        
        NSString *filePath = [[NSBundle bundleWithURL:bundleUrl] pathForResource:@"BTNotificationCategories" ofType:@"plist"];
        NSDictionary *userCategory = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        return userCategory;
    }
    
    return nil;
}

@end
