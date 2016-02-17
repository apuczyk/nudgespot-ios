//
//  NudgespotActivity.m
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "NudgespotActivity.h"

@implementation NudgespotActivity

@synthesize event;

@synthesize timestamp;

@synthesize subscriberUid;

@synthesize properties;


-(NudgespotActivity *)initwithNudgespotActivity:(NSString *)currentevent andUID:(NSString *)uID {
    
    [self initwithNudgespotActivity:currentevent andTimestamp:[BasicUtils nowDate] andUID:uID andProperty:nil];
    
    return self;
}

-(NudgespotActivity *)initwithNudgespotActivity:(NSString *)currentevent andUID:(NSString *)uID andProperty:(NSMutableDictionary *)activityProperty {
    
    [self initwithNudgespotActivity:currentevent andTimestamp:[BasicUtils nowDate] andUID:uID andProperty:activityProperty];
    
    return self;
}

-(NudgespotActivity *)initwithNudgespotActivity:(NSString *)currentevent andTimestamp:(NSDate *)currentTimestamp andUID:(NSString *)uID andProperty:(NSMutableDictionary *)activityProperty {
    
    self.event = currentevent;

    self.timestamp = currentTimestamp;
    
    self.subscriberUid = uID;
    
    self.properties = activityProperty;
    
    return self;
}


-(NudgespotActivity *)initWithJSON:(NSMutableDictionary *)responseDictionary {
    
    NSMutableDictionary *activityDictionary = [responseDictionary objectForKey:KEY_ACTIVITY];

    if (activityDictionary == nil) {
        
        activityDictionary = responseDictionary;
    }
    
    
    self.event = [activityDictionary objectForKey:KEY_ACTIVITY_NAME]? [activityDictionary objectForKey:KEY_ACTIVITY_NAME] : @"";
    
    NSMutableDictionary *subscriber = [activityDictionary objectForKey:KEY_ACTIVITY_SUBSCRIBER];
    
    if (subscriber != nil) {
        
        self.subscriberUid = [subscriber objectForKey:KEY_SUBSCRIBER_UID]? [subscriber objectForKey:KEY_SUBSCRIBER_UID] : @"";

    }
    
    self.timestamp = [activityDictionary objectForKey:KEY_ACTIVITY_TIMESTAMP]? [activityDictionary objectForKey:KEY_ACTIVITY_TIMESTAMP] : [BasicUtils nowDate];
    
    self.properties = [activityDictionary objectForKey:KEY_ACTIVITY_PROPERTIES]? [activityDictionary objectForKey:KEY_ACTIVITY_PROPERTIES] : @"";

    return self;
}


-(NSMutableDictionary *)toJSON {
    
    NSMutableDictionary *activityDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    if ([BasicUtils isNonEmpty:self.event]) {
        
        @try {
            
            if ([BasicUtils isNonEmpty:self.event] && self.event != nil) {
                
                [dict setObject:self.event forKey:KEY_ACTIVITY_NAME];
                
            }

            if ([BasicUtils isNonEmpty:self.subscriberUid] && self.subscriberUid != nil) {
                
                NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];

                [userDict setObject:self.subscriberUid forKey:KEY_SUBSCRIBER_UID];
                
                [dict setObject:userDict forKey:KEY_ACTIVITY_SUBSCRIBER];
                
            }

            if (self.timestamp != nil) {
                
                [dict setObject:[BasicUtils getStringValueOfUTC:self.timestamp] forKey:KEY_ACTIVITY_TIMESTAMP];
                
            }
            else {
                [dict setObject:[BasicUtils nowString] forKey:KEY_ACTIVITY_TIMESTAMP];
            }
            
            if (self.properties != nil) {
                
                [dict setObject:self.properties forKey:KEY_ACTIVITY_PROPERTIES];
                
            }

            [activityDict setObject:dict forKey:KEY_ACTIVITY];
            
        }
        @catch (NSException *exception) {
            
            NSLog(@"Exception:%@",exception);
            
        }
    }
    return activityDict;
}

@end
