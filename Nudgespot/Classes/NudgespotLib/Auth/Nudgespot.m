//
//  NudgespotCredentials.m
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "Nudgespot.h"

#import <Google/CloudMessaging.h>
#import "SubscriberClient.h"
#import "NudgespotNetworkManager.h"
#import "NudgespotVisitor.h"

#define Nudge [self sharedInstance]

static Nudgespot *sharedMyManager = nil;

@interface Nudgespot()

@property(nonatomic, strong) void (^anonymousHandler)(id response, NSError *error);

@end

@implementation Nudgespot

@synthesize registrationId;
@synthesize JavascriptAPIkey;
@synthesize RESTAPIkey;

+ (id)sharedInstance {
    @synchronized(self) {
        if(sharedMyManager == nil)
            sharedMyManager = [[super allocWithZone:NULL] init];
    }
    return sharedMyManager;
}


+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance] ;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (id)setJavascriptAPIkey:(NSString *)key andRESTAPIkey:(NSString *)token {
    
    [Nudge setJavascriptAPIkey:key];
    [Nudge setRESTAPIkey:token];
    [Nudge setRestUser:@"api"];
    
    return self;
}

+ (id) setEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    return [Nudge initWithEndpoint:endpointUrl andUID:uid registrationHandler:registeration];
}

+ (id) setWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;
{
    return [Nudge initWithUID:uid registrationHandler:registeration];
}

+ (id) setWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;
{
    return [Nudge initWithEndpoint:endpointUrl andSubscriber:currentSubscriber registrationHandler:registeration];
}

+ (id) setWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;
{
    return [Nudge initWithSubscriber:currentSubscriber registrationHandler:registeration];;
}

+ (void)runRegistrationInBackgroundWithToken:(NSData *)deviceToken registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    [self getOrWaitForDeviceTokenWithTime:100 withCompletion:^(id deviceToken, NSError *error) {
        
        // As Device Token not found then we don't need to register with GCM. We will only register GCM if we found Device Token..
        if (!error) {
            
            [self connectWithGCM];
            
            DLog(@"runRegistrationInBackgroundWithToken starts here");
            
            [self registerForNotifications:deviceToken registrationHandler:registeration];
        }
    }];
}


/**
 *  @brief Method which will use if we want to call it as anynomous users.
 *  @return Completion handler will give you response and error if any.
 */

+ (void) registerAnynomousUser: (void (^)(id response, NSError *error))completionBlock;
{
    [Nudge setIsAnonymousUser:YES];
    [Nudge setAnonymousHandler:completionBlock];
    
    [Nudge getAccountsSDKConfigCompletionHandler:^(id response, id error) {

        [self getOrWaitForDeviceTokenWithTime:100 withCompletion:^(id deviceToken, NSError *error) {
            
            if (!error) {
                
                [self runRegistrationInBackgroundWithToken:[Nudge deviceToken] registrationHandler:completionBlock];
            } else {
                [self sendAnonymousRegistrationToNudgespotWithToken:nil];
            }

        }];
    }];
}

+ (void)loadDeviceToken:(NSData *)deviceToken
{
    [Nudge   setIsRegisterForNotification:NO];
    [Nudge   setDeviceToken:deviceToken];
    [Nudge   setTheDelegate:Nudge];
}

#pragma mark - Helper Method to get App Info

/**
 * @return Application's version code from the Application Bundle.
 */

-(int) getAppVersion {
    
    @try {
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString *versionCode = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        
        return versionCode.intValue;
        
    }
    @catch (NSException *exception) {
        DLog(@"Exception:%@",exception);
    }
}


#pragma mark - Methods used to connect and disconnect from GCM Server

/**
 *  Connect to the GCM server to receive non-APNS notifications
 */

+ (void)connectWithGCM {
    
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        
        if (error) {
            
            DLog(@"Could not connect to GCM: %@", error.localizedDescription);
            
        } else {
            
            DLog(@"Connected to GCM");
        }
    }];
}

/**
 *  Disconnect with the GCM server to stop receiving non-APNS notifications
 */

+ (void)disconnectWithGCM {
    
    [[GCMService sharedInstance] disconnect];
}

#pragma mark - Method to clear local storage

/**
 * @ Delete the registration id from GCM Server and also clear the local data storage
 */

+ (void) clearRegistrationWithCompletion:(void (^)(id response, NSError *error))completionBlock {
    
    [[GGLInstanceID sharedInstance] deleteTokenWithAuthorizedEntity:[Nudge gcmSenderID] scope: kGGLInstanceIDScopeGCM handler:^(NSError *error) {
        
        if (!error) {
            
            [self sendUnregistrationToNudgespotWithCompletion:^(id response, NSError *error) {
                
                if (!error) {
                    
                    [BasicUtils removeUserDefaultsForKey:SHARED_PROP_REGISTRATION_SENT];
                    
                    [BasicUtils removeUserDefaultsForKey:SHARED_PROP_REGISTRATION_ID];
                    
                    [BasicUtils removeUserDefaultsForKey:SHARED_PROP_APP_VERSION];
                    
                    [BasicUtils removeUserDefaultsForKey:SHARED_PROP_SUBSCRIBER_UID];
                    
                    [BasicUtils removeUserDefaultsForKey:SHARED_PROP_ANON_ID ];
                    
                    [BasicUtils removeUserDefaultsForKey:SHARED_PROP_IS_ANON_USER_EXISTS];
                    
                    [Nudge clearSubscriber];
                    
                    DLog(@"Cleared all registration data on the application");
                }
                
                if (completionBlock) {
                    completionBlock (response, error);
                }
                
            }];
            
        }
    }];
}

#pragma mark - Methods to retrieve local storage

/**
 * Gets the current registration ID for application on GCM service, if there is one.
 * <p/>
 * If result is empty, the app needs to register.
 *
 * @return registration ID, or empty string if there is no existing registration ID.
 */
-(NSString *)getStoredRegistrationId {
    
    NSString *regid = [BasicUtils getUserDefaultsValueForKey:SHARED_PROP_REGISTRATION_ID];
    
    if ([regid isEqualToString:@""]) {
        
        DLog(@"Registration not found.");
        
        return @"";
        
    } else {
        
        DLog(@"Registration found: %@", regid);
        
    }
    
    // Check if app was updated; if so, it must clear the registration ID
    // since the existing regID is not guaranteed to work with the new app version.
    
    int registeredVersion = (int) [[NSUserDefaults standardUserDefaults] integerForKey:SHARED_PROP_APP_VERSION];
    
    int currentVersion = [self getAppVersion];
    
    if (registeredVersion != currentVersion) {
        
        DLog(@"App version changed from %d to %d. Need to re-register", registeredVersion, currentVersion);
        
        return @"";
        
    }
    
    return regid;
}


/**
 * Retrieves the stored subscriber UID for the application, if there is one
 *
 * @param context
 * @return customer ID, or empty string if there is none.
 */
+ (NSString *) getStoredSubscriberUid {
    
    NSString *subuid = [BasicUtils getUserDefaultsValueForKey:SHARED_PROP_SUBSCRIBER_UID];
    
    if ([subuid isEqualToString:@""]) {
        
        DLog(@"Subscriber UID not found.");
        
    } else {
        
        DLog(@"Subscriber UID found: %@", subuid);
        
    }
    
    return subuid;
}


#pragma mark - Methods to perform local storage

/**
 * Stores the subscriber UID in the application's {@code SharedPreferences}
 *
 * @param context application's context.
 * @param subuid  customer ID
 */
+ (void) storeSubscriberUid:(NSString *)subuid {
    
    [BasicUtils setUserDefaultsValue:subuid forKey:SHARED_PROP_SUBSCRIBER_UID];
    
}


/**
 * Stores the registration ID and the app versionCode in the application's
 * {@code SharedPreferences}.
 *
 * @param context application's context.
 * @param regid   registration ID
 */
+ (void) storeRegistrationId:(NSString *)regid {
    
    [BasicUtils setUserDefaultsValue:regid forKey:SHARED_PROP_REGISTRATION_ID];
    
    [Nudge setRegistrationId:regid];
    
    [[NSUserDefaults standardUserDefaults] setInteger:[Nudge getAppVersion] forKey:SHARED_PROP_APP_VERSION];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Registration Methods

/**
 * @ Actual registration for Notification starts here. To register for Notification in GCM Server and also stores the data in local data storage
 */

+ (BOOL) registerForNotifications:(NSData *)data registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    [Nudge setIsRegisterForNotification:YES];
    
    BOOL registerAfresh = false;
    
    NSString *subuid = [self getStoredSubscriberUid];
    NSString *registrationId =  [Nudge getStoredRegistrationId];
    
    [self gcmStartConfig];
    
    if ([Nudge isAnonymousUser] && registrationId.length == 0  && subuid.length == 0) { // Get GCM Registration Token for Anyonomous User
        
        [self gettingTokenFromGCM:[Nudge deviceToken]];
        
    }else if ([Nudge isAnonymousUser] && registrationId.length > 1 && subuid.length == 0) {
        
        [self sendAnonymousRegistrationToNudgespotWithToken:registrationId];
    }
    
    if ([BasicUtils isNonEmpty:[Nudge subscriberUid]]) {
        
        if (![[Nudge subscriberUid] isEqualToString:subuid]) {
            
            registerAfresh = true;
            
            [self storeSubscriberUid:[Nudge subscriberUid]]; // update the stored value with the new ID
        }
        
    } else {
        [Nudge setSubscriberUid:subuid]; // assign the stored value
    }
    
    if ([BasicUtils isNonEmpty:[Nudge subscriberUid]]) { // now when we have a subscriber uid, we attempt registration if not already done
        
        [Nudge setRegistrationId:registrationId];
        
        [self registerAndSendInBackground:data andRegisterAfresh:registerAfresh registrationHandler:registeration];
    }
    
    return YES;
}

/**
 * Registers the application with GCM servers asynchronously.
 * <p/>
 * Stores the registration ID and the app version code in the application's shared preferences.
 */
+ (void)registerAndSendInBackground:(NSData *)deviceToken andRegisterAfresh:(BOOL)registerAfresh registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;{
    
    if ([[Nudge registrationId] isEqualToString:@""] || registerAfresh) { // either no existing registration ID found or the customer is a new one in which case we re-register
        
        [self gettingTokenFromGCM:deviceToken];
        
    } else { // in case the registration is there but the registration failed last time, we try it again
        
        [self sendRegistrationToNudgespotWithRegistrationHandler:registeration];
        
    }
}

+ (void) gcmStartConfig {
    
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    
}

+ (void)gettingTokenFromGCM:(NSData *)deviceToken {
    
    [Nudge setRegistrationOptions:@{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                                    kGGLInstanceIDAPNSServerTypeSandboxOption:@NO}];
    
//    DLog(@"%@ is device token %@ is GCM Id", deviceToken, [Nudge gcmSenderID]);
    
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:[Nudge gcmSenderID]
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:[Nudge registrationOptions]
                                                      handler:^(NSString *token, NSError *error){
                                                          
                                                          DLog(@"GCM Registration token = %@",token);
                                                          DLog(@"GCM Registration error = %@",error);
                                                          
                                                          if (![token isEqualToString:@""] && token != nil) {
                                                              
                                                              [self storeRegistrationId:token];
                                                              [self sendAnonymousRegistrationToNudgespotWithToken:token];
                                                              [self sendRegistrationToNudgespotWithRegistrationHandler:[Nudge registrationHandler]];
                                                          }
                                                          
                                                      }];
    
}

#pragma mark - GCM When token Needs to Refresh <GGLInstanceIDDelegate>

- (void)onTokenRefresh
{
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    
    DLog(@"The GCM registration token needs to be changed.");
    
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:self.gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:^(NSString *token, NSError *error) {
                                                          
                                                          DLog(@"GCM Registration token Refresh = %@",token);
                                                          DLog(@"GCM Registration Refresh error = %@",error);
                                                          
                                                          if (![token isEqualToString:@""] && token != nil) {
                                                              
                                                              [Nudgespot storeRegistrationId:token];
                                                              
                                                              [Nudgespot sendRegistrationToNudgespotWithRegistrationHandler:self.registrationHandler];
                                                              [[Nudgespot sharedInstance] sendAnonymousRegistrationToNudgespotWithToken:token];
                                                          }
                                                      }];
    
}


#pragma mark - GCM When token Needs to Refresh <SubscriberClientDelegate>

/**
 *  A Delegate method from SubscriberClientDelegate which will call once we have Subscriber.
 */

- (void)gotSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *, NSError *))registeration
{
    DLog(@"%@ is currentSubscriber", currentSubscriber);
    
    if (currentSubscriber) {
        [Nudgespot runRegistrationInBackgroundWithToken:self.deviceToken registrationHandler:registeration];
    }
}

/**
 * Sends the registration ID to Nudgespot server over HTTP along with for Anonymous user.
 * So it can save the registration id for future communication using CCS
 */

+ (void)sendAnonymousRegistrationToNudgespotWithToken: (NSString *)registrationToken {
    
    if (registrationToken) {
        [Nudge initWithAnynomousUserWithRegistrationToken:registrationToken completionBlock:[Nudge anonymousHandler]];
    }
}

/**
 * Sends the registration ID to Nudgespot server over HTTP along with the user id.
 * So it can save the registration id for future communication using CCS
 */
+ (void) sendRegistrationToNudgespotWithRegistrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration; {
    
    // Here we send the registration ID to Nudgespot servers so that messages can be sent to this device
 
    if ([Nudge isSubscriberReady]) {
        
        if (![[Nudge subscriber] hasContact:CONTACT_TYPE_IOS_GCM_REGISTRATION_ID andValue:[Nudge registrationId]]) {
            
            [[Nudge subscriber] addContact:CONTACT_TYPE_IOS_GCM_REGISTRATION_ID andValue:[Nudge registrationId]];
            
            [Nudge updateSubscriber:[Nudge subscriber] completion:^(NudgespotSubscriber *subscriber, id error) {
                if (subscriber) {
                    [Nudge setSubscriber:subscriber];
                }
                
                // Complete completion Block for initlize client
                if (registeration) {
                    registeration([Nudge registrationId], error);
                }
                
                DLog(@"Registration sent to Nudgespot: %@", [Nudge registrationId]);
            }];
            
        } else {
            
            // Complete Registeration Block for NudgespotClient
            if (registeration) {
                registeration([Nudge registrationId], nil);
            }
            
            DLog(@"Registration already exists in Nudgespot: %@", [Nudge registrationId]);
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:SHARED_PROP_REGISTRATION_SENT];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        
        // Subscriber was not ready, unable to register
        DLog(@"Unable to send registration to Nudgespot as subscriber was not created successfully.");
        
        // Complete Registeration Block Error for NudgespotClient
        if (registeration) {
            registeration(nil, [NSError errorWithDomain:@"Unable to send registration to Nudgespot as subscriber was not created successfully." code:400 userInfo:nil]);
        }
        
    }
}

#pragma mark - Unregistration Methods

/**
 * Sends un-registration to the Nudgespot server over HTTP to notify that this device has been un-registered for this user.
 */
+ (BOOL) sendUnregistrationToNudgespotWithCompletion:(void (^)(id response, NSError *error))completionBlock; {
    
    BOOL unregistered = false;
    
    // First send contact de-activation data to the server
    if ([Nudge isSubscriberReady]) {
        
        [[Nudge subscriber] removeContact:CONTACT_TYPE_IOS_GCM_REGISTRATION_ID andValue:[Nudge registrationId]];
        
        [Nudge updateSubscriber:[Nudge subscriber] completion:^(NudgespotSubscriber *subscriber, id error) {
            if (subscriber) {
                [Nudge setSubscriber:subscriber];
            }
            
            if (completionBlock) {
                completionBlock(subscriber, error);
            }
        }];
        
        unregistered = true;
    }
    return unregistered;
}


+ (void) processNudgespotNotification:(NSDictionary *)userinfo withApplication: (UIApplication * )application andWindow:(UIWindow *)window {
    
    NSString *messageId = [userinfo objectForKey:@"message_uid"];
    
    if (messageId != nil) {
        
        if (application.applicationState == UIApplicationStateBackground) {
            [self sendNudgespotMessageEvent:messageId andEvent:@"delivered"];
        } else if (application.applicationState == UIApplicationStateInactive) {
            [BasicUtils navigateToSpecificViewController:userinfo andApplication:application andWindow:window];
        }
        
    }
    
}


+ (void)sendNudgespotMessageEvent:(NSString *)messageId andEvent:(NSString *)event {
    
    DLog(@"Sending the message %@ event",event);
    
    @try {
        
        if (!messageId.length) {
            return;
        }
        
        NSMutableDictionary *postDic = [self messageObjectToJSON:messageId andMode:event];
        
        [NudgespotNetworkManager sendNudgespotMessageEventWithData:postDic success:^(NSURLSessionDataTask *operation, id responseObject) {
            
            DLog(@"message %@ json Response Object ::::::::::::::::::::: \n  = %@ %@ %@", postDic, responseObject, operation.originalRequest.URL.absoluteString, operation.currentRequest.URL.absoluteString);
            
            [Nudge setSubscriber:[Nudge convertDictionaryToModel:responseObject]];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            
            DLog(@"%@ is failure \n %@", error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey], error);
        }];
        
    }
    @catch (NSException *exception) {
        
        DLog(@"Exception:%@",exception);
        
    }
    
}

+ (NSMutableDictionary *)messageObjectToJSON:(NSString *) messageId andMode:(NSString *)event {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    @try {
        
        int timestamp = [[NSDate date] timeIntervalSince1970];
        
        if ([BasicUtils isNonEmpty:messageId]) {
            
            [dict setObject:messageId forKey:KEY_MESSAGEID];
        }
        
        if ([BasicUtils isNonEmpty:event]) {
            
            [dict setObject:event forKey:KEY_EVENT];
            
            [dict setObject:[NSString stringWithFormat:@"%d",timestamp] forKey:KEY_TIMESTAMP];
        }
        
    }
    @catch (NSException *exception) {
        
        DLog(@"Exception:%@",exception);
        
    }
    
    return dict;
}

+ (void)getOrWaitForDeviceTokenWithTime:(NSTimeInterval)timeInterval withCompletion : (void (^)(id deviceToken, NSError * error)) completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Here we are waiting if our device token not found...
        NSTimeInterval sleep = 0.01;
        
        while (sleep < timeInterval && ![Nudge deviceToken]) { // we build an exponential wait time for about one minute else give up and wait for the next initialization
            
            DLog(@"%@ is deviceToken and %@ is GCM Sender ID", [Nudge deviceToken], [Nudge gcmSenderID]);
            
            @try {
                DLog(@"Sleeping for %lf seconds", sleep);
                [NSThread sleepForTimeInterval:sleep];
            }
            @catch (NSException *exception) {
                DLog(@"Exception:%@",exception);
            }
            @finally {
                sleep = sleep * 2;
            }
        }
        
        if ([Nudge deviceToken]) {
            if (completionBlock) {
                completionBlock ([Nudge deviceToken ], nil);
            }
        }
        else {
            if(completionBlock) {
                completionBlock (nil, [NSError errorWithDomain:@"Device token not found" code:1001 userInfo:nil]);
            }
        }
    });
    
}

#pragma mark - Notification receipt Acknowledgement Methods

/**
 * to acknowledge receipt of that message to the GCM connection server
 */

+ (void)acknowledgeGCMServer:(NSDictionary *)userInfo {
    
    NSLog(@"%@ is object", [GCMService sharedInstance]);
    
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
}

#pragma mark - Track Activities ..

/**
 *  @brief Method for track Acitvity.
 *  @param NudgespotActivity
 *  @return Completion handler will give you response and error if any.
 */

+ (void) trackActivity:(NudgespotActivity *) activity completion:(void (^)(id response, NSError *error))completionBlock;
{
    return [Nudge trackActivity:activity completion:completionBlock];
}


@end
