//
//  SubscriberContact.h
//  NudgespotiOS
//
//  Created by Poomalai on 04/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubscriberContact : NSObject
{
    NSString *type;
    
    NSString *value;
    
    NSString *subscriptionStatus;
}

@property (nonatomic , retain) NSString *type;

@property (nonatomic , retain) NSString *value;

@property (nonatomic , retain) NSString *subscriptionStatus;

-(id) initwithType:(NSString *)contactType andValue:(NSString *)contactValue;

-(id) initwithType:(NSString *)contactType andValue:(NSString *)contactValue andSubscriptionStatus:(NSString *)status;

-(SubscriberContact *) initWithJSON:(NSMutableDictionary *)responseDict;

-(NSMutableDictionary *) toJSON;

@end
