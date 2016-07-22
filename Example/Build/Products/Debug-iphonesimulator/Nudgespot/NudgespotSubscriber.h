//
//  NudgespotSubscriber.h
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NudgespotSubscriber : NSObject
{
    NSString *uid;
    
    NSString *accountId;
    
    NSString *name;
    
    NSString *firstName;
    
    NSString *lastName;
    
    NSString *resourceLocation;
    
    NSDate *signupTime;
    
    NSMutableDictionary *properties;
    
    NSMutableArray *subscriberContactList;
}

@property (nonatomic , retain) NSString *uid;

@property (nonatomic , retain) NSString *accountId;

@property (nonatomic , retain) NSString *name;

@property (nonatomic , retain) NSString *firstName;

@property (nonatomic , retain) NSString *lastName;

@property (nonatomic , retain) NSString *resourceLocation;

@property (nonatomic , retain) NSDate *signupTime;

@property (nonatomic , retain) NSMutableDictionary *properties;

@property (nonatomic , retain) NSMutableArray *subscriberContactList;


-(NudgespotSubscriber *) initWithJSON:(NSMutableDictionary *)subscriber;

-(BOOL) hasContact:(NSString *)type andValue:(NSString *)value;

-(void) unsubscribeAll;

-(void) unsubscribeContact:(NSString *)type andValue:(NSString *)value;

-(void) addContact:(NSString *)type andValue:(NSString *)value;

-(void) removeContact:(NSString *)type andValue:(NSString *)value;

-(NSMutableDictionary *) toJSON;

@end
