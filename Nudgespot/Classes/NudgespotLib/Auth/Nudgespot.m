//
//  NudgespotCredentials.m
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import "Nudgespot.h"

#import "Firebase.h"

#import "NudgespotNetworkManager.h"

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

/**
 *  @brief Method which will use in didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
 *  @param Devicetoken as NSData and Type, Production or Development.
 *  @return No return.
 */

+ (void)setAPNSToken:(NSData *)deviceToken ofType:(NudgespotIDAPNSTokenType) type {
    [Nudge setAPNSToken:deviceToken ofType:type];
}

/**
 *  @brief Method will initialize Nudgespot Client.
 *  @param pass api key from Nudgespot account settings and secrettoken from Nudgespot account settings.
 *  @return completion handler will return Token from Fcm and error in case anyting missing.
 */

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

+ (void) runRegistrationInBackground:(void (^)(NSString *, NSError *))registeration {
    
    [Nudge getFcmTokenCompletion:^(id token, id error) {
        
        DLog(@"runRegistrationInBackgroundWithToken starts here");
        
        [self registerForNotifications:registeration];
    }];
}


/**
 *  @brief Method which will use if we want to call it as Anonymous users.
 *  @return Completion handler will give you response and error if any.
 */

+ (void) registerAnonymousUser: (void (^)(id response, NSError *error))completionBlock;
{
    [Nudge setIsAnonymousUser:YES];
    [Nudge setAnonymousHandler:completionBlock];
    
    [Nudge getFcmTokenCompletion:^(id token, id error) {
        if (token) {
            [self runRegistrationInBackground:completionBlock];
        }
    }];
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

#pragma mark - Methods used to connect and disconnect from Fcm Server

/**
 *  Connect to the Fcm server to receive non-APNS notifications
 */

+ (void)connectToFcm {
    [Nudge connectToFcmWithCompletion:^(id token, id error) {
        if (!error) {
            DLog(@"Connected to Fcm.");
        } else {
            DLog(@"Unable to connect to FCM. %@", error);
        }
    }];
    
}

/**
 *  Disconnect with the Fcm server to stop receiving non-APNS notifications
 */

+ (void)disconnectToFcm {
    
    [Nudge disconnectToFcm];
    DLog(@"Disconnected from FCM");
}

#pragma mark - Method to clear local storage

/**
 * @ Delete the registration id from Fcm Server and also clear the local data storage
 */

+ (void) clearRegistration:(void (^)(id, NSError *))completionBlock {
    
    DLog(@"%@ is Fcm sender id", [Nudge gcmSenderID]);
    
    [[FIRInstanceID instanceID] deleteTokenWithAuthorizedEntity:[Nudge gcmSenderID] scope:kFIRInstanceIDTokenRefreshNotification handler:^(NSError * _Nullable error) {
      
        if (!error) {
            
            // Clear Notificaiton...
            
            [self sendUnregistrationToNudgespot:^(id response, NSError *error) {
                
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
 * Gets the current registration ID for application on Fcm service, if there is one.
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
 * @ Actual registration for Notification starts here. To register for Notification in Fcm Server and also stores the data in local data storage
 */

+ (BOOL) registerForNotifications:(void (^)(NSString *, NSError *))registeration {
    
    BOOL registerAfresh = false;
    
    NSString *subuid = [self getStoredSubscriberUid];
    NSString *registrationId =  [Nudge getStoredRegistrationId];
    
    if ([Nudge isAnonymousUser] && registrationId.length == 0  && subuid.length == 0) { // Get Fcm Registration Token for Anyonomous User
        
        [self gettingTokenFromFcm];
        
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
        
        [self registerAndSendInBackgroundAndRegisterAfresh:registerAfresh registrationHandler:registeration];
    }
    
    return YES;
}

/**
 * Registers the application with Fcm servers asynchronously.
 * <p/>
 * Stores the registration ID and the app version code in the application's shared preferences.
 */
+ (void)registerAndSendInBackgroundAndRegisterAfresh:(BOOL)registerAfresh registrationHandler:(void (^)(NSString *, NSError *))registeration {
    
    if ([[Nudge registrationId] isEqualToString:@""] || registerAfresh) { // either no existing registration ID found or the customer is a new one in which case we re-register
        
        [self gettingTokenFromFcm];
        
    } else { // in case the registration is there but the registration failed last time, we try it again
        
        [self sendRegistrationToNudgespot:registeration];
        
    }
}

+ (void)gettingTokenFromFcm {
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    
    [self storeRegistrationId:refreshedToken];
    [self sendAnonymousRegistrationToNudgespotWithToken:refreshedToken];
    [self sendRegistrationToNudgespot:[Nudge registrationHandler]];
}

+ (void)gotSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *, NSError *))registeration
{
    DLog(@"%@ is currentSubscriber", currentSubscriber);
    
    if (currentSubscriber) {
        
        [Nudgespot  runRegistrationInBackground:registeration];
    }
}

/**
 * Sends the registration ID to Nudgespot server over HTTP along with for Anonymous user.
 * So it can save the registration id for future communication using CCS
 */

+ (void)sendAnonymousRegistrationToNudgespotWithToken: (NSString *)registrationToken {
    
    if (registrationToken) {
        [Nudge initWithAnonymousUserWithRegistrationToken:registrationToken completionBlock:[Nudge anonymousHandler]];
    }
}

/**
 * Sends the registration ID to Nudgespot server over HTTP along with the user id.
 * So it can save the registration id for future communication using CCS
 */
+ (void) sendRegistrationToNudgespot:(void (^)(NSString *, NSError *))registeration {
    
    // Here we send the registration ID to Nudgespot servers so that messages can be sent to this device
    
    if ([Nudge isSubscriberReady]) {
        
        if (![[Nudge subscriber] hasContact:CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID andValue:[[FIRInstanceID instanceID] token]] ) {
            
            [[Nudge subscriber] updateContact:CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID FromValue:[Nudge registrationId] toValue:[[FIRInstanceID instanceID] token]];
            
            [Nudge updateSubscriber:[Nudge subscriber] completion:^(NudgespotSubscriber *subscriber, id error) {
                if (subscriber) {
                    [Nudge setSubscriber:subscriber];
                }
                
                // Complete completion Block for initlize client
                if (registeration != nil) {
                    registeration([[FIRInstanceID instanceID] token], error);
                }
                
                DLog(@"Registration sent to Nudgespot: %@", [[FIRInstanceID instanceID] token]);
                
                // Update Registration Id ..
                [self storeRegistrationId:[[FIRInstanceID instanceID] token]];
            }];
            
        } else {
            // Complete Registeration Block for NudgespotClient
            if (registeration) {
                registeration([[FIRInstanceID instanceID] token], nil);
            }
            
            DLog(@"Registration already exists in Nudgespot: %@", [[FIRInstanceID instanceID] token]);
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
+ (BOOL) sendUnregistrationToNudgespot:(void (^)(id, NSError *))completionBlock {
    
    BOOL unregistered = false;
    
    // First send contact de-activation data to the server
    if ([Nudge isSubscriberReady]) {
        
        [[Nudge subscriber] removeContact:CONTACT_TYPE_IOS_Fcm_REGISTRATION_ID andValue:[Nudge registrationId]];
        
        [Nudge updateSubscriber:[Nudge subscriber] completion:^(NudgespotSubscriber *subscriber, id error) {
            if (subscriber) {
                [Nudge setSubscriber:subscriber];
            }
            
            if (completionBlock) {
                completionBlock(subscriber, error);
            }
        }];
        
        unregistered = true;
    } else {
        if (completionBlock) {
            completionBlock(nil, [NSError errorWithDomain:@"Subscriber is not ready yet." code:1001 userInfo:nil]);
        }
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

#pragma mark - Notification receipt Acknowledgement Methods

/**
 * to acknowledge receipt of that message to the Fcm connection server
 */

+ (void)acknowledgeFcmServer:(NSDictionary *)userInfo {
    
    DLog(@"%@ is object", [FIRMessaging messaging]);
    
    [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
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
