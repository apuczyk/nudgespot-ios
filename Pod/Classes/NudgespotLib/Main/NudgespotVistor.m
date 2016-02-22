//
//  NudgespotVistor.m
//  Pods
//
//  Created by Maheep Kaushal on 22/02/16.
//
//

#import "NudgespotVistor.h"

@implementation NudgespotVistor


-(NudgespotVistor *)initWithJSON:(NSMutableDictionary *)responseDictionary {
    
    NSMutableDictionary *activityDictionary = [responseDictionary objectForKey:KEY_VISTOR];
    
    if (activityDictionary == nil) {
        
        activityDictionary = responseDictionary;
    }
    
    self.timestamp = [activityDictionary objectForKey:KEY_TIMESTAMP]? [activityDictionary objectForKey:KEY_TIMESTAMP] : [BasicUtils nowDate];
    
    self.properties = [activityDictionary objectForKey:KEY_VISTOR_PROPERTIES]? [activityDictionary objectForKey:KEY_VISTOR_PROPERTIES] : @"";
    
    self.uid = [self uniqueAppId];
    
    return self;
}

-(NSString*)uniqueAppId
{
    NSString *Appname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *strApplicationUUID = [SSKeychain passwordForService:Appname account:@"DeviceUniqueId"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:Appname account:@"DeviceUniqueId"];
        self.isRegistered = NO;
    }
    else {
        self.isRegistered = YES;
    }
    return strApplicationUUID;
}


-(NSMutableDictionary *)toJSON {
    
    NSMutableDictionary *activityDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if ([BasicUtils isNonEmpty:self.uid]) {
        
        @try {
            
            if ([BasicUtils isNonEmpty:self.uid] && self.uid != nil) {
                
                NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
                
                [userDict setObject:self.uid forKey:VISTER_UID];
                
                [dict setObject:userDict forKey:KEY_ACTIVITY_SUBSCRIBER];
                
            }
            
            if (self.timestamp != nil) {
                
                [dict setObject:[BasicUtils getStringValueOfUTC:self.timestamp] forKey:KEY_VISTOR_TIMESTAMP];
                
            }
            else {
                [dict setObject:[BasicUtils nowString] forKey:KEY_VISTOR_TIMESTAMP];
            }
            
            if (self.properties != nil) {
                
                [dict setObject:self.properties forKey:KEY_ACTIVITY_PROPERTIES];
                
            }
            
            [activityDict setObject:dict forKey:KEY_ACTIVITY];
            
        }
        @catch (NSException *exception) {
            
            DLog(@"Exception:%@",exception);
            
        }
    }
    return activityDict;
}

@end
