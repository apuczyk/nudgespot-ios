//
//  BasicUtils.h
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2016 Nudgespot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BasicUtils : NSObject
{
    
}

#pragma mark common helper Methods

+ (BOOL)isEmpty:(NSString *)string;

+ (BOOL)isNonEmpty:(NSString *)string;

+ (NSDate *)getDateFromString:(NSString *)dateString;

+ (NSString *)getStringValueOfUTC:(NSDate *)date;

+ (NSTimeZone *)getTimeZone;

+ (NSDate *)nowDate;

+ (NSString *)nowString;

+(NSString *)getEncodedString:(NSString *)uID;


#pragma mark HTTP Methods

+ (id)cleanJsonToObject:(id)data;

#pragma mark NSUserDefaults GET/SET/REMOVE Methods

+ (void) setUserDefaultsValue:(NSString *)value forKey:(NSString *)key;

+ (NSString *) getUserDefaultsValueForKey:(NSString *)key;

+ (void) removeUserDefaultsForKey:(NSString *)key;

#pragma mark Navigate To Specific Screen Handler Methods

+ (void)navigateToSpecificViewController:(NSDictionary *)userinfo andApplication:(UIApplication *)application andWindow:(UIWindow *)window;

@end
