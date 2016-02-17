//
//  SubscriberContact.m
//  NudgespotiOS
//
//  Created by Poomalai on 04/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "SubscriberContact.h"

#import "NudgespotConstants.h"

@implementation SubscriberContact

@synthesize type;

@synthesize value;

@synthesize subscriptionStatus;

-(id)initwithType:(NSString *)contactType andValue:(NSString *)contactValue
{
    [self initwithType:contactType andValue:contactValue andSubscriptionStatus:@""];
    
    return self;
}

-(id)initwithType:(NSString *)contactType andValue:(NSString *)contactValue andSubscriptionStatus:(NSString *)status
{
    
    self.type = contactType;
    
    self.value = contactValue;
    
    self.subscriptionStatus = @"active";
    
    if (![status isEqualToString:@""] && status != nil) {
        self.subscriptionStatus = status;
    }
    
    return self;
}


-(SubscriberContact *)initWithJSON:(NSMutableDictionary *)responseDict
{
    NSString *contactType = [responseDict objectForKey:KEY_CONTACT_TYPE];
    
    NSString *contactValue = [responseDict objectForKey:KEY_CONTACT_VALUE];

    NSString *contactStatus = [responseDict objectForKey:KEY_CONTACT_SUBSCRIPTION_STATUS];

    [self initwithType:contactType andValue:contactValue andSubscriptionStatus:contactStatus];
    
    return self;
}


-(NSMutableDictionary *)toJSON {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    @try {
        
        if ([BasicUtils isNonEmpty:self.type]) {
            
            [dict setObject:self.type forKey:KEY_CONTACT_TYPE];
            
        }
        if ([BasicUtils isNonEmpty:self.value]) {
            
            [dict setObject:self.value forKey:KEY_CONTACT_VALUE];
            
        }
        if ([BasicUtils isNonEmpty:self.subscriptionStatus]) {
            
            [dict setObject:self.subscriptionStatus forKey:KEY_CONTACT_SUBSCRIPTION_STATUS];
            
        }
    }
     @catch (NSException *exception) {
         
         NSLog(@"Exception:%@",exception);
         
     }
    
    return dict;
}

@end
