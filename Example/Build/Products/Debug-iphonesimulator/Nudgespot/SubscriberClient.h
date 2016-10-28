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
@class Nudgespot;

typedef NS_ENUM(NSInteger, NudgespotIDAPNSTokenType) {
    /// Unknown token type.
    NudgespotAPNSTokenTypeUnknown = 0,
    /// Sandbox token type.
    NudgespotAPNSTokenTypeSandbox,
    /// Production token type.
    NudgespotAPNSTokenTypeProd,
};



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

@property (nonatomic , retain) NSString *gcmSenderID;

@property(nonatomic, strong) void (^registrationHandler) (NSString *registrationToken, NSError *error);

@property(nonatomic, strong) void (^completionBlock)(id token, id error);

@property BOOL credentialsPresent;


-(id)initWithEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

-(id) initWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

-(id) initWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

-(id) initWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

- (id) initWithAnonymousUserWithRegistrationToken: (NSString *)registrationToken completionBlock :(void (^)(id response, id error))completionBlock;

-(void) clearSubscriber;

-(BOOL) isSubscriberReady;

#pragma mark Nudgespot Service Methods

-(void) identifySubscriber:(NudgespotSubscriber *)subscriber completion:(void (^)(NudgespotSubscriber *subscriber, id error))completionBlock;

-(void) updateSubscriber:(NudgespotSubscriber *)currentSubscriber completion:(void (^)(NudgespotSubscriber *subscriber, id error))completionBlock;

-(void) trackActivity:(NudgespotActivity *) currentActivity completion:(void (^)(id response, NSError *error))completionBlock;

-(NSString *) getErrorMessage:(NSMutableDictionary *)responseDictionary;

-(NudgespotSubscriber *)convertDictionaryToModel:(NSMutableDictionary *)responseDictionary;

- (void)setAPNSToken:(NSData *)deviceToken ofType:(NudgespotIDAPNSTokenType) type;

- (void) removeContact:(NSString *)type andValue: (NSString *) value completion:(void (^)(id response, NSError *error))completionBlock;

/**
 * Retrieves the stored subscriber UID for the application, if there is one
 *
 * @param context
 * @return customer ID, or empty string if there is none.
 */
- (NSString *) getStoredSubscriberUid;

- (NudgespotSubscriber *) getSubscriber:(NSString *) uid WithCompletion:(void (^)(NudgespotSubscriber *currentSubsciber, id error))completionBlock;

- (void) getFcmTokenCompletion:(void (^)(id token, id error))completionBlock;

#pragma mark - Fcm integration.

- (void)connectToFcmWithCompletion:(void (^)(id token, id error)) completionBlock ;

- (void) disconnectToFcm;

@end
