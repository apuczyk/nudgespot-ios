//
//  NudgespotSubscriber.m
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "NudgespotSubscriber.h"

#import "NudgespotConstants.h"

@implementation NudgespotSubscriber

@synthesize uid;

@synthesize accountId;

@synthesize name;

@synthesize firstName;

@synthesize lastName;

@synthesize resourceLocation;

@synthesize signupTime;

@synthesize properties;

@synthesize subscriberContactList;



-(NudgespotSubscriber *) initWithJSON:(NSMutableDictionary *)subscriber {
    
    @try {
        
        if (subscriber != nil) {
            
            self.uid = [subscriber objectForKey:KEY_SUBSCRIBER_UID]? [subscriber objectForKey:KEY_SUBSCRIBER_UID] : @"";
            
            self.accountId = [subscriber objectForKey:KEY_SUBSCRIBER_ACCOUNTID]? [subscriber objectForKey:KEY_SUBSCRIBER_ACCOUNTID] : @"";

            self.name = [subscriber objectForKey:KEY_SUBSCRIBER_NAME]? [subscriber objectForKey:KEY_SUBSCRIBER_NAME] : @"";
            
            self.firstName = [subscriber objectForKey:KEY_FIRST_NAME]? [subscriber objectForKey:KEY_FIRST_NAME] : @"";
            
            self.lastName = [subscriber objectForKey:KEY_LAST_NAME]? [subscriber objectForKey:KEY_LAST_NAME] : @"";
            
            self.resourceLocation = [subscriber objectForKey:KEY_SUBSCRIBER_RES_URL]? [subscriber objectForKey:KEY_SUBSCRIBER_RES_URL] : @"";
            
            self.signupTime = [subscriber objectForKey:KEY_SIGNED_UP_AT]? [NSDate date] : [NSDate date];
            
            self.properties = [subscriber objectForKey:KEY_SUBSCRIBER_PROPERTIES]? [subscriber objectForKey:KEY_SUBSCRIBER_PROPERTIES] : nil;

            
            NSMutableArray *contacts = [subscriber objectForKey:KEY_CONTACT]? [subscriber objectForKey:KEY_CONTACT] : [[NSMutableArray alloc] init];
            
            self.subscriberContactList = [[NSMutableArray alloc] init];

            for(NSMutableDictionary *responseContact in contacts) {
                
                SubscriberContact *contact = [[SubscriberContact alloc] initWithJSON:responseContact];
                
                [self.subscriberContactList addObject:contact];
            }
        }
    }
    @catch (NSException *exception) {
        
        DLog(@"Exception:%@",exception);
        
    }
    return self;
}


-(BOOL) hasContact:(NSString *)type andValue:(NSString *)value {
    
    BOOL found = false;
    
    for(SubscriberContact *contact in self.subscriberContactList) {
        
        if ([contact.type isEqualToString:type] && [contact.value isEqualToString:value]) {
            
            found = true;
        }
    }
    return found;
}


-(void) unsubscribeAll {
    
    NSMutableArray *unsubscribes = [[NSMutableArray alloc] init];
    
    for (SubscriberContact *contact in self.subscriberContactList ) {
        
        SubscriberContact *currentContact = [[SubscriberContact alloc] initwithType:contact.type andValue:contact.value
                                                              andSubscriptionStatus:@"inactive"];
        
        [unsubscribes addObject:currentContact];
    }
    [self.subscriberContactList removeAllObjects];
    
    self.subscriberContactList = unsubscribes;
}


-(void) unsubscribeContact:(NSString *)type andValue:(NSString *)value {
    
    [self removeContact:type andValue:value]; // safety check in case the contact already exists
    
    SubscriberContact *contact = [[SubscriberContact alloc] initwithType:type andValue:value andSubscriptionStatus:@"inactive"];
    
    [self.subscriberContactList addObject:contact];
}


-(void) addContact:(NSString *)type andValue:(NSString *)value {
    
    [self removeContact:type andValue:value]; // safety check in case the contact already exists
    
    SubscriberContact *contact = [[SubscriberContact alloc] initwithType:type andValue:value];
    
    [self.subscriberContactList addObject:contact];
    
}


-(void) removeContact:(NSString *)type andValue:(NSString *)value {
    
    for(SubscriberContact *contact in self.subscriberContactList) {
        
        if ([contact.type isEqualToString:type] && [contact.value isEqualToString:value]) {
            
            [self.subscriberContactList removeObject:contact];
        }
    }
}


-(NSMutableDictionary *)toJSON {
    
    NSMutableDictionary *subscriberDict = [[NSMutableDictionary alloc] init];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    @try {
        
        if ([BasicUtils isNonEmpty:self.uid]) {
            
            [dict setObject:self.uid forKey:KEY_SUBSCRIBER_UID];
            
        }
        
        if ([BasicUtils isNonEmpty:self.firstName] && self.firstName != nil) {
            
            [dict setObject:self.firstName forKey:KEY_FIRST_NAME];
            
        }
        if ([BasicUtils isNonEmpty:self.lastName] && self.lastName != nil) {
            
            [dict setObject:self.lastName forKey:KEY_LAST_NAME];
            
        }
        if ([BasicUtils isNonEmpty:self.name] && self.name != nil) {
            
            [dict setObject:self.name forKey:KEY_SUBSCRIBER_NAME];
            
        }
        if (self.signupTime != nil) {
            
            [dict setObject:[BasicUtils getStringValueOfUTC:self.signupTime] forKey:KEY_SIGNED_UP_AT];
            
        }
        if (self.properties != nil) {
            
            [dict setObject:self.properties forKey:KEY_SUBSCRIBER_PROPERTIES];
            
        }
        if (self.subscriberContactList.count > 0) {
            
            NSMutableArray *contactArrayList = [[NSMutableArray alloc] init];
            
            for (SubscriberContact *contact in self.subscriberContactList) {
                
                [contactArrayList addObject:[contact toJSON]];
            }
            [dict setObject:contactArrayList forKey:KEY_CONTACT];
        }
        
        [subscriberDict setObject:dict forKey:KEY_SUBSCRIBER];
        
    }
    @catch (NSException *exception) {
        
        DLog(@"Exception:%@",exception);
        
    }
    return subscriberDict;
}



@end
