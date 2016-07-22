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
        
    NSMutableDictionary *properties;
}

@property (nonatomic , retain) NSString *event;

@property (nonatomic , retain) NSDate *timestamp;

@property (nonatomic , retain) NSMutableDictionary *properties;


-(NudgespotActivity *) initwithNudgespotActivity:(NSString *)currentevent;

-(NudgespotActivity *)initwithNudgespotActivity:(NSString *)currentevent andProperty:(NSMutableDictionary *)activityProperty ;

-(NudgespotActivity *)initwithNudgespotActivity:(NSString *)currentevent andTimestamp:(NSDate *)currentTimestamp andProperty:(NSMutableDictionary *)activityProperty;

-(NSMutableDictionary *)toJSON;

-(NudgespotActivity *)initWithJSON:(NSMutableDictionary *)responseDictionary;

@end
