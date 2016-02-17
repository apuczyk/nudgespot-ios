//
//  BasicUtils.m
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "BasicUtils.h"

#import "NudgespotConstants.h"

@implementation BasicUtils


#pragma mark common helper Methods

+ (BOOL)isEmpty:(NSString *)string {
    
    return ([string isKindOfClass:[NSNull class]] || string == nil);
    
}


+ (BOOL)isNonEmpty:(NSString *)string {
    
    return (![string isKindOfClass:[NSNull class]] && string != nil );
    
}


+ (NSDate *)getDateFromString:(NSString *)dateString {
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeZone:[self getTimeZone]];
    
    [formatter setDateFormat:[self getDateFormat]];
    
    NSDate * date = [formatter dateFromString:dateString];
    
    return date;
}


+ (NSString *)getStringValueOfUTC:(NSDate *)date {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeZone:[self getTimeZone]];
    
    [dateFormatter setDateFormat:[self getDateFormat]];
    
    NSString* dateTimeInIsoFormatForZuluTimeZone = [dateFormatter stringFromDate:date];
    
    return dateTimeInIsoFormatForZuluTimeZone;
}

+ (NSTimeZone *)getTimeZone {
    
    return [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
}


+ (NSString *)getDateFormat {
    
    return CURRENT_DATEFORMAT;
    
}


+ (NSString *)nowString {
    
    return [self getStringValueOfUTC:[NSDate date]];
    
}


+ (NSDate *)nowDate {
    
    return [NSDate date];
    
}


+(NSString *)getEncodedString:(NSString *)uID {
    
    
    
    NSString *encodedUID = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                 NULL,
                                                                                                 (CFStringRef)uID,
                                                                                                 NULL,
                                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                                 kCFStringEncodingUTF8));
    
    NSLog(@"encoded = %@",encodedUID);
    
    return encodedUID;
}

#pragma mark HTTP Methods

//Cleans the null values and replaces with ""
+ (id)cleanJsonToObject:(id)theJSONData {
    
    NSError* error;
    id jsonObject;

    if (theJSONData == (id)[NSNull null]){
        
        return [[NSObject alloc] init];
    }
    if (theJSONData == nil){
        
        return [[NSObject alloc] init];
    }

    if ([theJSONData isKindOfClass:[NSData class]]){
        
        jsonObject = [NSJSONSerialization JSONObjectWithData:theJSONData options:NSJSONReadingMutableLeaves error:&error];
    } else {
        
        jsonObject = theJSONData;
    }
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *array = [jsonObject mutableCopy];
        
        int arrayCount = (int)[array count];
        
        for (int i = arrayCount-1; i >= 0; i--) {
            
            id a = array[i];
            
            if (a == (id)[NSNull null]){
                
                [array removeObjectAtIndex:i];
            } else {
                
                array[i] = [self cleanJsonToObject:a];
            }
        }
        
        return array;
    } else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *dictionary = [jsonObject mutableCopy];
        
        for(NSString *key in [dictionary allKeys]) {
            
            id d = dictionary[key];
            
            if (d == (id)[NSNull null]){
                
                dictionary[key] = @"";
            } else {
                
                dictionary[key] = [self cleanJsonToObject:d];
            }
        }
        
        return dictionary;
        
    } else {
        
        return jsonObject;
    }
}


+(BOOL)isNetworkReachable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    if ([reachability isReachable])
    {
        return YES;
    }
    else {
        return NO;
    }
}


+(BOOL)checkReachability {
    
    BOOL isReachable = NO;
    
    for (int i=0 ;i < 3; ++i )
    {
        isReachable = [self isNetworkReachable];
        
        if (isReachable)
        {
            break;
        }
    }
    return isReachable;
}


#pragma mark NSUserDefaults GET/SET/REMOVE Methods

+ (void)setUserDefaultsValue:(NSString *)value forKey:(NSString *)key {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![value isEqualToString:@""]) {
        
        [userDefaults setObject:value forKey:key];
    }
    
}


+ (NSString *)getUserDefaultsValueForKey:(NSString *)key {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:key] != nil) {
        
        return [userDefaults objectForKey:key];
    }
    return @"";
}


+ (void)removeUserDefaultsForKey:(NSString *)key {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:key] != nil) {
        
        [userDefaults removeObjectForKey:key];
    }
    
}

#pragma mark Navigate To Specific Screen Handler Methods

+ (void)navigateToSpecificViewController:(NSDictionary *)userinfo andApplication:(UIApplication *)application andWindow:(UIWindow *)window {
    
    NSString *messageId = [userinfo objectForKey:@"message_uid"];

    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        if ([userinfo objectForKey:@"aps"] == nil) {
            return;
        }
        
        NSDictionary *aps = [userinfo objectForKey:@"aps"];
        
        NSDictionary *alert = [aps objectForKey:@"alert"];
        
        NSLog(@"Notification received: %@", [alert objectForKey:@"title"]);
        
        NSLog(@"launch_activity name: %@", [alert objectForKey:@"launch_activity"]);
        
        UINavigationController *nc = (UINavigationController*)window.rootViewController;
        
        if (userinfo) {
            
            UIViewController *vc = [nc.storyboard instantiateViewControllerWithIdentifier:[alert objectForKey:@"launch_activity"]];
            
            [nc pushViewController:vc animated:NO];
            
        }
    }
    
    NSLog(@"messageId = %@",messageId);
    
    if (messageId != nil) {
        // call the method on a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            
            [Nudgespot processNudgespotNotification:userinfo];
            
        });
    }
    
}

@end
