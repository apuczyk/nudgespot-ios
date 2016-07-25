//
//  SubscriberClient.m
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "SubscriberClient.h"

#import "NudgespotNetworkManager.h"

#import <Firebase/Firebase.h>

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
    }
    
    return self;
}

-(id)initWithEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    self.endpoint = endpointUrl;
    
    return [self initWithUID:uid registrationHandler:registeration];
    
}


-(id) initWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration{
    
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
            
            [self getAccountsSDKConfigCompletionHandler:^(id response, id error) {
                
                // sendAnonymousIdentification method will send Notification to server so, that they will replace all anonymous users to uid and from there server can track.
                [self sendAnonymousIdentification];
                
                DLog(@"identifySubscriber starts here");
                
                // GetOrCreateSubscriber will get user and if not found then it will create.
                
                [self identifySubscriberWithCompletion:^(NudgespotSubscriber *currentSubsciber, id error) {
                    
                    DLog(@"identifySubscriber ends here");
                    
                    if (currentSubscriber) {
                        if ([_theDelegate respondsToSelector:@selector(gotSubscriber:registrationHandler:)]) {
                            [_theDelegate gotSubscriber:currentSubsciber registrationHandler:self.registrationHandler];
                        }
                    }
                }];
            }];
            
        });
    }
    
    return self;
}

- (id) initWithAnynomousUserWithRegistrationToken: (NSString *)registrationToken completionBlock :(void (^)(id response, id error))completionBlock;
{
    DLog(@"self.endpoint = %@",self.endpoint);
    
    [self checkEndPoints];
    
    NudgespotVisitor *visitor = [[NudgespotVisitor alloc] init];
    visitor.registrationToken = registrationToken;
    
    [[Nudgespot sharedInstance] setVisitor:visitor];
    
    NSString *isRegistered = [BasicUtils getUserDefaultsValueForKey:SHARED_PROP_IS_ANON_USER_EXISTS];
    
    if (!isRegistered.length) {
        
        [NudgespotNetworkManager loginWithAnynomousUser:visitor.toJSON success:^(NSURLSessionDataTask *operation, id responseObject) {
            
            if (!operation.error) {
                
                [BasicUtils setUserDefaultsValue:visitor.anonymousId forKey:SHARED_PROP_IS_ANON_USER_EXISTS];
            }
            
            if (completionBlock) {
                completionBlock(responseObject, operation.error);
            }
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            
            if (completionBlock) {
                completionBlock(operation.response, error);
            }
            
        }];
    } else {
        
        if (completionBlock) {
            completionBlock (@"Vistor already exits", nil);
        }
    }
    
    return self;
}

- (void)checkEndPoints {
    
    if ([self.endpoint isEqualToString:@""] || self.endpoint == nil) {
        
        self.endpoint = REST_API_ENDPOINT;
    }
    else {
        REST_API_ENDPOINT = self.endpoint;
    }
    
}

- (void) getAccountsSDKConfigCompletionHandler :(void (^)(id response, id error))completionBlock
{
    [NudgespotNetworkManager getAccountsSDKConfigFile:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        NSLog(@"%@ is response object", responseObject);
        
        NSDictionary * json_Data = responseObject;
        
        if (json_Data.count > 1) {
            
            [BasicUtils setUserDefaultsValue:[NSString stringWithFormat:@"%@",[json_Data objectForKey:@"gcm_sender_id"]] forKey:GCM_SENDER_ID];
            [BasicUtils setUserDefaultsValue:[json_Data objectForKey:@"sns_anon_identification_topic"] forKey:SNS_ANON_IDENTIFICATION_TOPIC];
            [BasicUtils setUserDefaultsValue:[json_Data objectForKey:@"identity_pool_id"] forKey:IDENTITY_POOL_ID];
            
            [self configureFirebase];
            
            if (completionBlock) {
                completionBlock(responseObject, nil);
            }
        }
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
        NSLog(@"%@ is error ", error.description);
        
        if (error) {
            
            [BasicUtils removeUserDefaultsForKey:GCM_SENDER_ID];
            [BasicUtils removeUserDefaultsForKey:SNS_ANON_IDENTIFICATION_TOPIC];
            [BasicUtils removeUserDefaultsForKey:IDENTITY_POOL_ID];
            
        }
        
        if (completionBlock) {
            completionBlock(nil, error);
        }
    }];
    
}

-(void) clearSubscriber {
    
    self.subscriber = nil;
    
    self.subscriberUid = @"";
}

-(BOOL) isSubscriberReady {
    return (self.subscriber != nil) && [BasicUtils isNonEmpty:self.subscriber.resourceLocation];
}


- (void) configureFirebase {
    
    self.gcmSenderID = [BasicUtils getUserDefaultsValueForKey:GCM_SENDER_ID];
    
    [FIRApp configure];
}

- (void)sendAnonymousIdentification {
    
    NSString * vistitorUid = [self getStoredAnonymousUid];
    
    if (!vistitorUid.length) {
        return;
    }
    
    NSString * poolId = [NSString string];
    
    if ([BasicUtils getUserDefaultsValueForKey:IDENTITY_POOL_ID]) {
        poolId = [BasicUtils getUserDefaultsValueForKey:IDENTITY_POOL_ID];
    }
    
    NSDictionary * message = @{KEY_SUBSCRIBER_UID : subscriber.uid,
                               KEY_VISITOR_UID: vistitorUid,
                               @"api_key": [[Nudgespot sharedInstance] JavascriptAPIkey]};
    
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
            DLog(@"url = %@ identify %@ json Response Object ::::::::::::::::::::: \n  = %@",operation.response.URL.absoluteString, postData,  responseObject);
            
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


-(void) updateSubscriber:(NudgespotSubscriber *)currentSubscriber completion:(void (^)(NudgespotSubscriber *subscriber, id error))completionBlock{
    
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
                
                NSDictionary *postData = [currentActivity toJSON];
                
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



@end
