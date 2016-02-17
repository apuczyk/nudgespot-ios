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

#define Nudge [self sharedInstance]

@implementation Nudgespot

@synthesize registrationId;
@synthesize apiKey;
@synthesize secretToken;

+ (id)sharedInstance {
    
    static Nudgespot *sharedCredentials = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedCredentials = [[self alloc] init];
    });
    
    return sharedCredentials;
}

+ (id)setApiKey:(NSString *)key andSecretToken:(NSString *)token {
    
    [Nudge setApiKey:key];
    [Nudge setSecretToken:token];
    
    return self;
}

- (id)init {
    
    if (self = [super init]) {
        
    }
    return self;
}


+ (id) setEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    [Nudge initWithEndpoint:endpointUrl andUID:uid registrationHandler:registeration];
    
    return self;
}

+ (id) setWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;
{
    [Nudge initWithUID:uid registrationHandler:registeration];
    
    return self;
}

+ (id) setWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;
{
    [Nudge initWithEndpoint:endpointUrl andSubscriber:currentSubscriber registrationHandler:registeration];
    
    return self;
    
}

+ (id) setWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;
{
    [Nudge initWithSubscriber:currentSubscriber registrationHandler:registeration];
    
    return self;
}

+ (void)runRegistrationInBackgroundWithToken:(NSData *)deviceToken registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration {
    
    if (deviceToken) {
        [self loadDeviceToken:deviceToken];
    }else{
        NSLog(@"Error: Device Token Not Found!!");
        return;
    }
    
    [self  connectWithGCM];
    
    NSLog(@"runRegistrationInBackgroundWithToken starts here");
    
    [self registerForNotifications:[Nudge deviceToken] registrationHandler:registeration];
    
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
        NSLog(@"Exception:%@",exception);
    }
}


#pragma mark - Methods used to connect and disconnect from GCM Server

/**
 *  Connect to the GCM server to receive non-APNS notifications
 */

+ (void)connectWithGCM {
    
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        
        if (error) {
            
            NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
            
        } else {
            
            NSLog(@"Connected to GCM");
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
            
            [self sendUnregistrationToNudgespotWithCompletion:completionBlock];
            
            [BasicUtils removeUserDefaultsForKey:SHARED_PROP_REGISTRATION_SENT];
            
            [BasicUtils removeUserDefaultsForKey:SHARED_PROP_REGISTRATION_ID];
            
            [BasicUtils removeUserDefaultsForKey:SHARED_PROP_APP_VERSION];
            
            [BasicUtils removeUserDefaultsForKey:SHARED_PROP_SUBSCRIBER_UID];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"Cleared all registration data on the application");
            
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
        
        NSLog(@"Registration not found.");
        
        return @"";
        
    } else {
        
        NSLog(@"Registration found: %@", regid);
        
    }
    
    // Check if app was updated; if so, it must clear the registration ID
    // since the existing regID is not guaranteed to work with the new app version.
    
    int registeredVersion = (int) [[NSUserDefaults standardUserDefaults] integerForKey:SHARED_PROP_APP_VERSION];
    
    int currentVersion = [self getAppVersion];
    
    if (registeredVersion != currentVersion) {
        
        NSLog(@"App version changed from %d to %d. Need to re-register", registeredVersion, currentVersion);
        
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
-(NSString *) getStoredSubscriberUid {
    
    NSString *subuid = [BasicUtils getUserDefaultsValueForKey:SHARED_PROP_SUBSCRIBER_UID];
    
    if ([subuid isEqualToString:@""]) {
        
        NSLog(@"Subscriber UID not found.");
        
    } else {
        
        NSLog(@"Subscriber UID found: %@", subuid);
        
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
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    
    BOOL ready = false;
    
    if (data == nil)
        return ready;
    
    BOOL registerAfresh = false;
    
    NSString *subuid = [Nudge getStoredSubscriberUid];
    
    if ([BasicUtils isNonEmpty:[Nudge subscriberUid]]) {
        
        if (![[Nudge subscriberUid] isEqualToString:subuid]) {
            
            registerAfresh = true;
            
            [self storeSubscriberUid:[Nudge subscriberUid]]; // update the stored value with the new ID
        }
        
    } else {
        [Nudge setSubscriberUid:subuid]; // assign the stored value
    }
    
    if ([BasicUtils isNonEmpty:[Nudge subscriberUid]]) { // now when we have a subscriber uid, we attempt registration if not already done
        
        [Nudge setRegistrationId:[Nudge getStoredRegistrationId]];
        
        [self registerAndSendInBackground:data andRegisterAfresh:registerAfresh registrationHandler:registeration];
        
        ready = true;
    }
    
    return ready;
}

/**
 * Registers the application with GCM servers asynchronously.
 * <p/>
 * Stores the registration ID and the app version code in the application's shared preferences.
 */
+ (void)registerAndSendInBackground:(NSData *)deviceToken andRegisterAfresh:(BOOL)registerAfresh registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;{
    
    [self gcmStartConfig];
    
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
                                    kGGLInstanceIDAPNSServerTypeSandboxOption:@"YES"}];
    
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:[Nudge gcmSenderID]
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:[Nudge registrationOptions]
                                                      handler:^(NSString *token, NSError *error){
                                                          
                                                          NSLog(@"GCM Registration token = %@",token);
                                                          NSLog(@"GCM Registration error = %@",error);
                                                          
                                                          if (![token isEqualToString:@""] && token != nil) {
                                                              
                                                              [self storeRegistrationId:token];
                                                              
                                                              [self sendRegistrationToNudgespotWithRegistrationHandler:[Nudge registrationHandler]];
                                                          }
                                                      }];
    
}

#pragma mark - GCM When token Needs to Refresh <GGLInstanceIDDelegate>

- (void)onTokenRefresh
{
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    
    NSLog(@"The GCM registration token needs to be changed.");
    
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:self.gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:^(NSString *token, NSError *error) {
                                                          
                                                          NSLog(@"GCM Registration token Refresh = %@",token);
                                                          NSLog(@"GCM Registration Refresh error = %@",error);
                                                          
                                                          if (![token isEqualToString:@""] && token != nil) {
                                                              
                                                              [Nudgespot storeRegistrationId:token];
                                                              [Nudgespot sendRegistrationToNudgespotWithRegistrationHandler:self.registrationHandler];
                                                          }
                                                      }];
    
}


#pragma mark - GCM When token Needs to Refresh <SubscriberClientDelegate>

/**
 *  A Delegate method from SubscriberClientDelegate which will call once we have Subscriber.
 */

- (void)gotSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *, NSError *))registeration
{
    NSLog(@"%@ is notification", currentSubscriber);
    
    if (currentSubscriber) {
        [Nudgespot runRegistrationInBackgroundWithToken:self.deviceToken registrationHandler:registeration];
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
                    NSLog(@"%@ is reg", registeration);
                    registeration([Nudge registrationId], error);
                }
                
                NSLog(@"Registration sent to Nudgespot: %@", [Nudge registrationId]);
            }];
            
        } else {
            
            // Complete Registeration Block for NudgespotClient
            if (registeration) {
                registeration([Nudge registrationId], nil);
            }
            
            NSLog(@"Registration already exists in Nudgespot: %@", [Nudge registrationId]);
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:SHARED_PROP_REGISTRATION_SENT];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        
        // Subscriber was not ready, unable to register
        NSLog(@"Unable to send registration to Nudgespot as subscriber was not created successfully.");
        
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


+ (void) processNudgespotNotification:(NSDictionary *)userinfo {
    
    NSString *messageId = [userinfo objectForKey:@"message_uid"];
    
    if (messageId != nil) {
        
        [self sendNudgespotMessageEvent:messageId andEvent:@"delivered"];
        
        [self sendNudgespotMessageEvent:messageId andEvent:@"opened"];
    }
}

+ (void)sendNudgespotMessageEvent:(NSString *)messageId andEvent:(NSString *)event {
    
    NSLog(@"Sending the message %@ event",event);
    
    @try {
        
        if (!messageId.length) {
            return;
        }
        
        NSMutableDictionary *postDic = [self messageObjectToJSON:messageId andMode:event];
        
        __weak typeof (Nudge) weakSelf = self;
        
        [NudgespotNetworkManager sendNudgespotMessageEventWithData:postDic success:^(NSURLSessionDataTask *operation, id responseObject) {
            
            NSLog(@"message %@ json Response Object ::::::::::::::::::::: \n  = %@", postDic, responseObject);
            
            [weakSelf setSubscriber:[Nudge convertDictionaryToModel:responseObject]];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            
            NSLog(@"%@ is failure \n %@", error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey], error);
        }];
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"Exception:%@",exception);
        
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
        
        NSLog(@"Exception:%@",exception);
        
    }
    
    return dict;
}


#pragma mark - Notification receipt Acknowledgement Methods

/**
 * to acknowledge receipt of that message to the GCM connection server
 */

+ (void)acknowledgeGCMServer:(NSDictionary *)userInfo {
    
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
}

#pragma mark - Track Activities ..

/**
 * to acknowledge receipt of that message to the GCM connection server
 */

+ (void) trackActivity:(NudgespotActivity *) activity completion:(void (^)(id response, NSError *error))completionBlock;
{
    return [Nudge trackActivity:activity completion:completionBlock];
}


@end
