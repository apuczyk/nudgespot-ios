//
//  NudgespotActivity.h
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NudgespotActivity : NSObject
{
    NSString *event;
    
    NSDate *timestamp;
    
    NSString *subscriberUid;
    
    NSMutableDictionary *properties;
}

@property (nonatomic , retain) NSString *event;

@property (nonatomic , retain) NSDate *timestamp;

@property (nonatomic , retain) NSString *subscriberUid;

@property (nonatomic , retain) NSMutableDictionary *properties;


-(NudgespotActivity *) initwithNudgespotActivity:(NSString *)currentevent andUID:(NSString *)uID;

-(NudgespotActivity *)initwithNudgespotActivity:(NSString *)currentevent andUID:(NSString *)uID andProperty:(NSMutableDictionary *)activityProperty ;

-(NudgespotActivity *)initwithNudgespotActivity:(NSString *)currentevent andTimestamp:(NSDate *)currentTimestamp andUID:(NSString *)uID andProperty:(NSMutableDictionary *)activityProperty;

-(NSMutableDictionary *)toJSON;

-(NudgespotActivity *)initWithJSON:(NSMutableDictionary *)responseDictionary;

@end
