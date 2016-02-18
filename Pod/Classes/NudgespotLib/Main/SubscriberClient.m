//
//  SubscriberClient.m
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "SubscriberClient.h"
#import "NudgespotSubscriber.h"
#import <Google/CloudMessaging.h>
#import "NudgespotNetworkManager.h"
#import "NudgespotSubscriber.h"
#import "NudgespotActivity.h"
#import "NudgespotConstants.h"

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
    }
    
    return self;
}

-(id)initWithEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    self.endpoint = endpointUrl;
    
    self = [self initWithUID:uid registrationHandler:registeration];
    
    return self;
}


-(id) initWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration{
    
    subscriber = [[NudgespotSubscriber alloc] init];
    
    subscriber.uid = uid;
    
    self = [self initWithSubscriber:subscriber registrationHandler:registeration];
    
    return self;
}


-(id) initWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    self.endpoint = endpointUrl;

    self = [self initWithSubscriber:subscriber registrationHandler:registeration];
    
    return self;
}

-(id) initWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *, NSError *))registeration {
    
    DLog(@"self.endpoint = %@",self.endpoint);
    
    if ([self.endpoint isEqualToString:@""] || self.endpoint == nil) {
        
        self.endpoint = REST_API_ENDPOINT;
    }
    
    self.registrationHandler = registeration;
    
    // initialize subscriber with GCM Client ..
    @try {
        [self initGCM];
    }
    @catch (NSException *exception) {
        DLog(@"%@ is exception", exception);
    }
    
    
    if (currentSubscriber != nil) {
        
        self.subscriberUid = currentSubscriber.uid;
        
        self.subscriber = currentSubscriber;
        
        group = dispatch_group_create();
        
        // call the method on a background thread
        dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
            
            DLog(@"getOrCreateSubscriber starts here");
            
            [self getOrCreateSubscriberWithCompletion:^(NudgespotSubscriber *currentSubsciber, id error) {
                
                DLog(@"getOrCreateSubscriber ends here");
                
                if (currentSubscriber) {
                    
                    if ([_theDelegate respondsToSelector:@selector(gotSubscriber:registrationHandler:)]) {
                        
                        DLog(@"%@ is regsi", registeration);
                        
                        [_theDelegate gotSubscriber:currentSubsciber registrationHandler:self.registrationHandler];
                    }
                }
            }];
            
        });
        
    }
    
    return self;
}

-(void) clearSubscriber {
    
    self.subscriber = nil;
    
    self.subscriberUid = @"";
}

-(BOOL) isSubscriberReady {
    return (self.subscriber != nil) && [BasicUtils isNonEmpty:self.subscriber.resourceLocation];
}


- (void) initGCM {
    
    // Configure the Google context: parses the GoogleService-Info.plist, and initializes
    // the services that have entries in the file
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    self.gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate = self;
    
}

#pragma mark Nudgespot Service Methods

-(void) createSubscriber:(NudgespotSubscriber *)currentSubscriber completion:(void (^)(NudgespotSubscriber *subscriber, id error))completionBlock {
    
    @try {
        
        if (currentSubscriber == nil) {
            return;
        }
        
        NSMutableDictionary *postData =  [currentSubscriber toJSON];
        
        [NudgespotNetworkManager createSubscriberWithPostData:postData success:^(NSURLSessionDataTask *operation, id responseObject)
        {
            DLog(@"url = %@ createSubscriber %@ json Response Object ::::::::::::::::::::: \n  = %@",operation.response.URL.absoluteString, postData,  responseObject);
            
            NudgespotSubscriber *getSubscriber = [self convertDictionaryToModel:responseObject];
            
            if (completionBlock != nil) {
                completionBlock (getSubscriber, nil);
            }

        } failure:^(NSURLSessionDataTask *operation, NSError *error)
        {
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

            DLog(@"%@ operation Status", operation.response);
            
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


-(void) getSubscriber:(NSString *)uID completion:(void (^)(NudgespotSubscriber *subsciber, id error))completionBlock {
    
    @try {
        
        NSString *encodedUID = [BasicUtils getEncodedString:uID];
        
        [NudgespotNetworkManager getSubscriberWithID:encodedUID success:^(NSURLSessionDataTask *operation, id responseObject) {
            
            DLog(@"url = %@ getSubscriber %@ json Response Object ::::::::::::::::::::: \n  = %@",operation.response.URL.absoluteString, encodedUID,  responseObject);
            
            DLog(@"%@ operation Status", operation);
            
            NudgespotSubscriber  *getSubsciber = [self convertDictionaryToModel:responseObject];
            
            if (completionBlock != nil){
                completionBlock (getSubsciber, nil);
            }
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            
            if (completionBlock != nil){
                completionBlock (nil, error);
            }
        }];
    }
    @catch (NSException *exception) {
        
        DLog(@"Exception:%@",exception);
    }
    
}


-(void) getOrCreateSubscriberWithCompletion:(void (^)(NudgespotSubscriber *currentSubsciber, id error))completionBlock {
    
    if ([BasicUtils isNonEmpty:self.subscriberUid]) {
        
        [self getSubscriber:self.subscriberUid completion:^(NudgespotSubscriber *theSubscriber, id error)
        {
            if (theSubscriber){
                
                self.subscriber = theSubscriber;
                if (completionBlock != nil) {
                    completionBlock (theSubscriber, error);
                }
            }
            else
            {
                [self createSubscriber:subscriber completion:^(NudgespotSubscriber *theSubscriber, id error) {
                    
                    if (theSubscriber) {
                        self.subscriber = theSubscriber;
                        
                        if (completionBlock != nil) {
                            completionBlock (theSubscriber, error);
                        }
                    }
                }];
            }
        }];
    }
}


-(void) trackActivity:(NudgespotActivity *) currentActivity completion:(void (^)(id response, NSError *error))completionBlock {
    
    if ([self isSubscriberReady]) {

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


@end
