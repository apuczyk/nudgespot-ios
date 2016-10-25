//
//  SubscriberClient.m
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "SubscriberClient.h"

#import "NudgespotNetworkManager.h"

#import "Firebase.h"

@implementation SubscriberClient

@synthesize endpoint;

@synthesize subscriberUid;

@synthesize subscriber;

@synthesize client;

@synthesize credentialsPresent;

@synthesize activity;

@synthesize group;

-(id)init {
    
    if ([super init]) {
        
        self = [super init];
        
        self.endpoint = @"";
        self.gcmSenderID = nil;
        
        group = dispatch_group_create();
        
        [self configureFirebase];
        
    }
    
    return self;
}

-(id)initWithEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    self.endpoint = endpointUrl;
    
    return [self initWithUID:uid registrationHandler:registeration];
    
}


-(id) initWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    subscriber = [[NudgespotSubscriber alloc] init];
    
    subscriber.uid = uid;
    
    return [self initWithSubscriber:subscriber registrationHandler:registeration];
    
}


-(id) initWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    self.endpoint = endpointUrl;
    
    return [self initWithSubscriber:subscriber registrationHandler:registeration];
}

-(id) initWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *, NSError *))registeration {
    
    DLog(@"self.endpoint = %@",self.endpoint);
    
    [self checkEndPoints];
    
    self.registrationHandler = registeration;
    
    if (currentSubscriber != nil) {
        
        self.subscriberUid = currentSubscriber.uid;
        
        self.subscriber = currentSubscriber;
        
        // call the method on a background thread
        dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            
            // sendAnonymousIdentification method will send Notification to server so, that they will replace all anonymous users to uid and from there server can track.
            [self sendAnonymousIdentification];
            
            DLog(@"identifySubscriber starts here");
            
            // Identify subscriber will get user and if not found then it will create.
            
            [self identifySubscriberWithCompletion:^(NudgespotSubscriber *currentSubsciber, id error) {
                
                DLog(@"identifySubscriber ends here");
                
                if (currentSubscriber) {
                    
                    [Nudgespot gotSubscriber:currentSubsciber registrationHandler:self.registrationHandler];
                    
                } else {
                    self.registrationHandler(currentSubsciber, error);
                }
            }];
        });
    }
    
    return self;
}

- (id) initWithAnonymousUserWithRegistrationToken: (NSString *)registrationToken completionBlock :(void (^)(id response, id error))completionBlock;
{
    DLog(@"self.endpoint = %@",self.endpoint);
    
    [self checkEndPoints];
    
    NSString *isRegistered = [BasicUtils getUserDefaultsValueForKey:SHARED_PROP_IS_ANON_USER_EXISTS];
    
    if (isRegistered.length) {
        
        // Check if anonymousId token is same or not...
        NSString *visitorFcmToken = [BasicUtils getUserDefaultsValueForKey:CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID_ANON];
        
        if (![visitorFcmToken isEqualToString:[[FIRInstanceID instanceID] token]]) {
            
            NudgespotVisitor *visitor = [[NudgespotVisitor alloc] init];
            visitor.registrationToken = [[FIRInstanceID instanceID] token];
            [[Nudgespot sharedInstance] setVisitor:visitor];
            
            [self loginWithAnonymous:visitor completionBlock:completionBlock];
            
            DLog(@"Visitor FCM updated %@", visitor.toJSON);
            
        } else {
            
            if (completionBlock) {
                completionBlock ([NSString stringWithFormat:@"Vistor already exits %@", isRegistered], nil);
            }
        }
    } else {
        
        NudgespotVisitor *visitor = [[NudgespotVisitor alloc] init];
        visitor.registrationToken = registrationToken;
        
        [[Nudgespot sharedInstance] setVisitor:visitor];
        
        [self loginWithAnonymous:visitor completionBlock:completionBlock];
        
        DLog(@"Visitor Created %@", visitor.toJSON);
    }

    return self;
}

- (void) loginWithAnonymous: (NudgespotVisitor *) visitor completionBlock :(void (^)(id response, id error))completionBlock {
    
    [NudgespotNetworkManager loginWithAnonymousUser:visitor.toJSON success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        if (!operation.error) {
            
            [BasicUtils setUserDefaultsValue:visitor.anonymousId forKey:SHARED_PROP_IS_ANON_USER_EXISTS];
            [BasicUtils setUserDefaultsValue:visitor.registrationToken forKey:CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID_ANON];
        }
        
        if (completionBlock) {
            completionBlock(responseObject, operation.error);
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
        if (completionBlock) {
            completionBlock(operation.response, error);
        }
        
    }];
}

- (void)checkEndPoints {
    
    if ([self.endpoint isEqualToString:@""] || self.endpoint == nil) {
        
        self.endpoint = REST_API_ENDPOINT;
    }
    else {
        REST_API_ENDPOINT = self.endpoint;
    }
    
}

-(void) clearSubscriber {
    
    self.subscriber = nil;
    
    self.subscriberUid = @"";
}

-(BOOL) isSubscriberReady {
    return (self.subscriber != nil) && [BasicUtils isNonEmpty:self.subscriber.resourceLocation];
}


- (void)sendAnonymousIdentification {
    
    NSString * vistitorUid = [self getStoredAnonymousUid];
    
    if (!vistitorUid.length) {
        return;
    }
    
    NSString * poolId = [NSString string];
    
    NSLog(@"%@ is uid %@", self.subscriber.uid, [[Nudgespot sharedInstance] JavascriptAPIkey]);
    
    NSDictionary * message = @{KEY_SUBSCRIBER_UID : self.subscriber.uid, KEY_VISITOR_UID: vistitorUid, @"api_key": [[Nudgespot sharedInstance] JavascriptAPIkey]};
    
    [NudgespotNetworkManager identifyVisitorForAccount:message success:^(NSURLSessionDataTask *operation, id responseObject) {
        DLog(@"success %@", responseObject);
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        DLog(@"error %@", error);
    }];
    
}

#pragma mark Nudgespot Service Methods

-(void) identifySubscriber:(NudgespotSubscriber *)subscriber completion:(void (^)(NudgespotSubscriber *subscriber, id error))completionBlock {
    
    @try {
        
        if (subscriber == nil) {
            return;
        }
        
        NSMutableDictionary *postData =  [subscriber toJSON];
        
        [NudgespotNetworkManager identifySubscriberWithPostData:postData success:^(NSURLSessionDataTask *operation, id responseObject) {
            DLog(@"url = %@ identify json Response Object ::::::::::::::::::::: \n  = %@",operation.response.URL.absoluteString,  responseObject);
            
            NudgespotSubscriber *getSubscriber = [self convertDictionaryToModel:responseObject];
            
            if (completionBlock != nil) {
                completionBlock (getSubscriber, nil);
            }
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            DLog(@"%@ is failure \n %@", error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey], error);
            
            if (completionBlock != nil){
                completionBlock (nil, error);
            }
        }];
        
    }
    @catch (NSException *exception) {
        
        DLog(@"Exception:%@",exception);
        
    }
}


-(void) updateSubscriber:(NudgespotSubscriber *)currentSubscriber completion:(void (^)(NudgespotSubscriber *subscriber, id error))completionBlock {
    
    @try {
        
        if (currentSubscriber == nil) {
            return;
        }
        
        NSMutableDictionary *postData =  [currentSubscriber toJSON] ;
        
        [NudgespotNetworkManager updateSubscriberWithUrl:currentSubscriber.resourceLocation withPostData:postData success:^(NSURLSessionDataTask *operation, id responseObject) {
            
            DLog(@"url = %@ updateSubscriber %@ json Response Object ::::::::::::::::::::: \n  = %@",operation.response.URL.absoluteString, postData,  responseObject);
            
            NudgespotSubscriber *getSubscriber = [self convertDictionaryToModel:responseObject];
            
            if (completionBlock != nil) {
                completionBlock (getSubscriber, nil);
            }
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
           
            DLog(@"%@ is failure \n %@", error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey], error);
            
            if (completionBlock != nil){
                completionBlock (nil, error);
            }
        }];

    }
    @catch (NSException *exception) {
        
        DLog(@"Exception:%@",exception);
        
    }
}

-(void) identifySubscriberWithCompletion:(void (^)(NudgespotSubscriber *currentSubsciber, id error))completionBlock {
    
    if ([BasicUtils isNonEmpty:self.subscriberUid]) {
        
        [self identifySubscriber:self.subscriber completion:^(NudgespotSubscriber *subscriber, id error) {
            if (subscriber) {
                self.subscriber = subscriber;
                
                if (completionBlock != nil) {
                    completionBlock (subscriber, error);
                }
            }
        }];
    }
}

-(void) trackActivity:(NudgespotActivity *) currentActivity completion:(void (^)(id response, NSError *error))completionBlock {
    
    if ([self isSubscriberReady] || [[Nudgespot sharedInstance] isAnonymousUser]) {
        
        dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            
           __block NSString *message = @"";
            
            @try {
                
                if (currentActivity == nil) {
                    return;
                }
                
                NSMutableDictionary *postData = [currentActivity toJSON];
                
                [NudgespotNetworkManager createActivityWithPostData:postData success:^(NSURLSessionDataTask *operation, id responseObject) {
                    
                    DLog(@" url = %@ and postData = %@ and trackActivity json Response string ::::::::::::::::::::: \n  = %@",operation.response.URL.absoluteString, postData, responseObject);
                    
                    if ([responseObject objectForKey:KEY_ERROR] == nil) {
                        
                        activity = [[NudgespotActivity alloc] initWithJSON:responseObject];
                    }
                    else if ([responseObject objectForKey:KEY_ERROR] != nil) {
                        
                        message = [self getErrorMessage:[responseObject objectForKey:KEY_ERROR]];
                    }
                    
                    if (completionBlock) {
                        completionBlock (responseObject, operation.error);
                    }
                    
                } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                    DLog(@"%@ is error %@", operation.response, error);
                    
                    if (completionBlock) {
                        completionBlock (operation.response, error);
                    }
                }];
            
            }
            @catch (NSException *exception) {
                
                DLog(@"Exception:%@",exception);
                
            }
        });
        
    } else {
        
        // Subscriber was not ready, unable to register
        if (completionBlock) {
            completionBlock (nil, [NSError errorWithDomain:@"Unable to track activity to Nudgespot as subscriber was not created successfully." code:400 userInfo:nil]);
        }
        
        DLog(@"Unable to track activity to Nudgespot as subscriber was not created successfully.");
    }

}

-(NSString *) getErrorMessage:(NSMutableDictionary *)responseDictionary {
    
    NSString *message = @"";

    @try {
        
        if([responseDictionary isKindOfClass:[NSString class]]) {
            
            message = [NSString stringWithFormat:@"%@", responseDictionary];
            
            return message;
        }
        if ([responseDictionary objectForKey:KEY_ERROR_MESSAGE] != nil) {
            
            message = [responseDictionary objectForKey:KEY_ERROR_MESSAGE]? [responseDictionary objectForKey:KEY_ERROR_MESSAGE] : @"";
        }
    }
    @catch (NSException *exception) {
        
        DLog(@"Exception on getErrorMessage Method:%@",exception);
        
    }
    
    return message;
}


- (NudgespotSubscriber *) getSubscriber:(NSString *) uid WithCompletion:(void (^)(NudgespotSubscriber *currentSubsciber, id error))completionBlock {
    
    [NudgespotNetworkManager getSubscriberWithUid:uid success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        DLog(@"Subscriber response :%@",responseObject);
        
        NudgespotSubscriber *getSubscriber = [self convertDictionaryToModel:responseObject];
        
        if (completionBlock != nil) {
            completionBlock (getSubscriber, nil);
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        DLog(@"Exception message :%@",error);
        
        if (completionBlock != nil) {
            completionBlock (nil, error);
        }
    }];
}

-(NudgespotSubscriber *)convertDictionaryToModel:(NSMutableDictionary *)responseDictionary {
    
    NSString *message = @"";

    NudgespotSubscriber *curSubscriber = nil;

    if (responseDictionary != nil) {
                
        if ([responseDictionary objectForKey:KEY_ERROR] == nil) {
            
            curSubscriber = [[NudgespotSubscriber alloc] initWithJSON:responseDictionary];
            
            if ([BasicUtils isEmpty:curSubscriber.resourceLocation]) {
                
                DLog(@"Exception message :%@",curSubscriber.uid);
            }
            else if (![BasicUtils isEmpty:curSubscriber.uid] && ![BasicUtils isEmpty:curSubscriber.resourceLocation]) {
                
                subscriber = curSubscriber;
            }
            
            if ([BasicUtils isEmpty:curSubscriber.uid] || [BasicUtils isEmpty:curSubscriber.resourceLocation]) {
                
                curSubscriber = nil;
            }
            
        }
        else if ([responseDictionary objectForKey:KEY_ERROR] != nil) {
            
            message = [self getErrorMessage:[responseDictionary objectForKey:KEY_ERROR]];
            
            DLog(@"Exception message :%@",message);
        }
    }
    
    return curSubscriber;
}

/**
 * Retrieves the stored Visitor for the application, if there is one
 *
 * @param context
 * @return Visitor Anonymous id, or empty string if there is none.
 */
- (NSString *) getStoredAnonymousUid {
    
    NSString *anon_id = [BasicUtils getUserDefaultsValueForKey:SHARED_PROP_ANON_ID];
    
    if ([anon_id isEqualToString:@""]) {
        
        DLog(@"Visitor anonymous not found.");
        
    } else {
        
        DLog(@"Visitor anonymous found: %@", anon_id);
        
    }
    
    return anon_id;
}

- (void) removeContact:(NSString *)type andValue: (NSString *) value completion:(void (^)(id response, NSError *error))completionBlock; {
    
    if([[Nudgespot sharedInstance] isSubscriberReady]) {
        
        NSString *url = [self.subscriber contactLocation:type andValue:value];
        
        if(url != nil) {
            
            [NudgespotNetworkManager deleteContactWithUrl:url success:^(NSURLSessionDataTask *operation, id responseObject) {
                DLog(@"Deleted Contact %@", responseObject);
                
                if (completionBlock) {
                    completionBlock(responseObject, nil);
                }
                
                [self getSubscriber:self.subscriberUid WithCompletion:^(NudgespotSubscriber *currentSubsciber, id error) {
                    if (error == nil) {
                        self.subscriber = currentSubsciber;
                    }
                }];
                
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                DLog(@"Failure in deleting contact with Error: %@", error.description);
                
                if (completionBlock) {
                    completionBlock(nil, error);
                }
            }];;
        }
    }
    
}

#pragma mark - Fcm integration..

- (void) getFcmTokenCompletion:(void (^)(id token, id error))completionBlock; {
    
    @try {
        
        if ([[FIRInstanceID instanceID] token]) {
            if (completionBlock) {
                [self connectToFcmWithCompletion:^(id token, id error) {
                    completionBlock(token, error);
                }];
            }
        } else {
            self.completionBlock =  ^(id token, id error) {
                
                if (completionBlock) {
                    completionBlock(token, error);
                }
            };
        }
        
    }@catch (NSException *exception) {
        DLog(@"Exception = %@", exception);
    }
    
}

- (void) configureFirebase {
    
    @try {
        
        [FIRApp configure];
        
        self.gcmSenderID = [[FIROptions defaultOptions] GCMSenderID];
        
        // Add observer for InstanceID token refresh callback.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:) name:kFIRInstanceIDTokenRefreshNotification object:nil];

    } @catch (NSException *exception) {
        DLog(@"Exception = %@", exception);
    }
    
}

// [START refresh_token]
- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    DLog(@"InstanceID Refresh token: %@", refreshedToken);
    
    if (refreshedToken != nil) {
        // Connect to FCM since connection may have failed when attempted before having a token.
        [self connectToFcmWithCompletion:self.completionBlock];
        
        // Save FCM TOKEN...
        [BasicUtils setUserDefaultsValue:CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID forKey:refreshedToken];
    }
    
    // noOfTimestokenRefreshCalled:- in case its may not get refreshedToken and stop after some time.
    
    static int noOfTimestokenRefreshCalled = 1;
    
    if (noOfTimestokenRefreshCalled >= 15) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFIRInstanceIDTokenRefreshNotification object:nil];
    }
    
    noOfTimestokenRefreshCalled += 1;
    
}
// [END refresh_token]


// [START connect_to_fcm]
- (void)connectToFcmWithCompletion:(void (^)(id token, id error)) completionBlock {
    
    @try {
        [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
            
            if (completionBlock != nil) {
                completionBlock([[FIRInstanceID instanceID] token], error);
            }
            
            DLog(@"%@ is token, %@ is error", [[FIRInstanceID instanceID] token], error);
        }];
    } @catch (NSException *exception) {
        DLog(@"Exception %@", exception.description);
    }
    
}
// [END connect_to_fcm]

- (void)setAPNSToken:(NSData *)deviceToken ofType:(NudgespotIDAPNSTokenType) type {
    
    
    switch (type) {
        case NudgespotAPNSTokenTypeSandbox:
            [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
            break;
        case NudgespotAPNSTokenTypeProd:
            [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeProd];
            break;
        default:
            [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeUnknown];
            break;
    }
}

- (void)disconnectToFcm {
    
    [[FIRMessaging messaging] disconnect];
    DLog(@"Disconnected from FCM");
}

@end
