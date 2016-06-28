//
//  SubscriberClient.h
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NudgespotSubscriber;
@class NudgespotActivity;
@class NudgespotVisitor;

@protocol SubscriberClientDelegate <NSObject>

- (void) gotSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

@end


@interface SubscriberClient : NSObject
{
    NSString *endpoint;
    
    NSString *subscriberCreateUrl;
    
    NSString *subscriberFindUrl;
    
    NSString *activityCreateUrl;
    
    NSString *subscriberUid;
    
    NudgespotSubscriber *subscriber;
    
    NudgespotActivity *activity;
    
}

@property (nonatomic , retain) dispatch_group_t group;

@property (nonatomic , retain) NSString *endpoint;

@property (nonatomic , retain) NSString *subscriberUid;

@property (nonatomic , retain) NudgespotSubscriber *subscriber;

@property (nonatomic , retain) NudgespotVisitor *visitor;

@property (nonatomic , retain) NudgespotActivity *activity;

@property (nonatomic , retain) SubscriberClient *client;

@property (nonatomic , assign) id<SubscriberClientDelegate> theDelegate;

@property (nonatomic , retain) NSString *gcmSenderID;

@property(nonatomic, strong) void (^registrationHandler) (NSString *registrationToken, NSError *error);

@property BOOL credentialsPresent;


-(id)initWithEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

-(id) initWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

-(id) initWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

-(id) initWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

- (id) initWithAnynomousUserWithRegistrationToken: (NSString *)registrationToken completionBlock :(void (^)(id response, id error))completionBlock;

-(void) clearSubscriber;

-(BOOL) isSubscriberReady;

#pragma mark Nudgespot Service Methods

- (void) getAccountsSDKConfigCompletionHandler :(void (^)(id response, id error))completionBlock;

-(void) identifySubscriber:(NudgespotSubscriber *)subscriber completion:(void (^)(NudgespotSubscriber *subscriber, id error))completionBlock;

-(void) updateSubscriber:(NudgespotSubscriber *)currentSubscriber completion:(void (^)(NudgespotSubscriber *subscriber, id error))completionBlock;

-(void) trackActivity:(NudgespotActivity *) currentActivity completion:(void (^)(id response, NSError *error))completionBlock;

-(NSString *) getErrorMessage:(NSMutableDictionary *)responseDictionary;

-(NudgespotSubscriber *)convertDictionaryToModel:(NSMutableDictionary *)responseDictionary;


/**
 * Retrieves the stored subscriber UID for the application, if there is one
 *
 * @param context
 * @return customer ID, or empty string if there is none.
 */
- (NSString *) getStoredSubscriberUid;


@end
