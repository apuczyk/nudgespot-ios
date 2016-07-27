//
//  NudgespotVistor.m
//  Pods
//
//  Created by Maheep Kaushal on 22/02/16.
//
//

#import "NudgespotVisitor.h"

@implementation NudgespotVisitor

- (id)init {
    
    if (self = [super init]) {
        
        self.anonymousId = [self uniqueAppId];
        
        /*properties will implement later*/
    }
    
    return self;
}

-(NSString*)uniqueAppId
{
    
    NSString *strApplicationUUID = [BasicUtils getUserDefaultsValueForKey:SHARED_PROP_ANON_ID];
    
    if (!strApplicationUUID.length) {
        
        strApplicationUUID = [[[NSUUID UUID] UUIDString] lowercaseString];
        
        [BasicUtils setUserDefaultsValue:strApplicationUUID forKey:SHARED_PROP_ANON_ID];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return strApplicationUUID;
}


-(NudgespotVisitor *)initWithJSON:(NSMutableDictionary *)responseDictionary;
{
    NSMutableDictionary *visitorDictionary = [responseDictionary objectForKey:KEY_VISITOR];
    
    if (visitorDictionary == nil) {
        
        visitorDictionary = responseDictionary;
    }
    
    self.anonymousId = [visitorDictionary objectForKey:KEY_VISITOR_UID]? [visitorDictionary objectForKey:KEY_VISITOR_UID] : @"";
    
    self.registrationToken = [[visitorDictionary objectForKey:KEY_VISITOR_DEVICE_INFO] objectForKey:CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID]? [[visitorDictionary objectForKey:KEY_VISITOR_DEVICE_INFO] objectForKey:CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID] : @"";
    
    self.properties = [visitorDictionary objectForKey:KEY_VISITOR_PROPERTIES]? [visitorDictionary objectForKey:KEY_VISITOR_PROPERTIES] : @{};
    
    return self;
    
}

-(NSMutableDictionary *)toJSON {
    
    NSMutableDictionary *vistorDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    @try {
        
        if ([BasicUtils isNonEmpty:self.anonymousId]) {
            
            [dict setObject:self.anonymousId forKey:KEY_VISITOR_UID];
        }
        
        if ([BasicUtils isNonEmpty:self.registrationToken]) {
            
            NSMutableDictionary *deviceInfo = @{CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID : self.registrationToken,
                                                KEY_VISITOR_TYPE  : KEY_VISITOR_TYPE_iOS};
            
            [dict setObject:deviceInfo forKey:KEY_VISITOR_DEVICE_INFO];
        }
        
        if (self.properties == nil) {
            self.properties = [[NSMutableDictionary alloc] init];
        }else{
            self.properties = [[NSMutableDictionary alloc] initWithDictionary:self.properties];
        }
        
        [self.properties setObject:@"Y" forKey:iOS_USER];
        [dict setObject:self.properties forKey:KEY_VISITOR_PROPERTIES];
        
        [vistorDict setObject:dict forKey:KEY_VISITOR];
        
    }
    @catch (NSException *exception) {
        
        DLog(@"Exception:%@",exception);
    }
    
    return vistorDict;
}

@end
