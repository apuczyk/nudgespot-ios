//
//  NudgespotCredentials.h
//  NudgespotiOS
//
//  Created by Poomalai on 05/07/15.
//  Copyright (c) 2015 Nudgespot. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NudgespotActivity.h"
#import "SubscriberContact.h"
#import "Nudgespot.h"
#import "NudgespotSubscriber.h"
#import "SubscriberClient.h"
#import "NudgespotActivity.h"
#import "BasicUtils.h"
#import "Reachability.h"
#import "SubscriberClient.h"

@interface Nudgespot : SubscriberClient <SubscriberClientDelegate>
{
    NSString *registrationId;
}

@property (nonatomic , retain) NSString *registrationId;
@property (nonatomic , assign) BOOL isRegisterForNotification;
@property (nonatomic , retain) NSMutableDictionary* registrationOptions;
@property (nonatomic , retain) NSData *deviceToken;
@property (nonatomic , retain) NSString *apiKey;
@property (nonatomic , retain) NSString *secretToken;

+ (id) sharedInstance;

+ (id)setApiKey:(NSString *)key andSecretToken:(NSString *)token;

+ (id) setEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

+ (id) setWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

+ (id) setWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

+ (id) setWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

+ (void)runRegistrationInBackgroundWithToken:(NSData *)deviceToken registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

#pragma mark - Helper Method to Device Token from Appdelegate

/**
 * @return Application's version code from the Application Bundle.
 */

+ (void) loadDeviceToken : (NSData *)deviceToken;


#pragma mark - Methods used to connect and disconnect from GCM Server

/**
 *  Connect to the GCM server to receive non-APNS notifications
 */

+ (void)connectWithGCM;

/**
 *  Disconnect with the GCM server to stop receiving non-APNS notifications
 */

+ (void)disconnectWithGCM;


#pragma mark - Method to clear local storage

/**
 * @ Delete the registration id from GCM Server and also clear the local data storage
 */


+ (void) clearRegistrationWithCompletion:(void (^)(id response, NSError *error))completionBlock;

#pragma mark - Registration Methods

/**
 * @ Actual registration for Notification starts here. To register for Notification in GCM Server and also stores the data in local data storage
 */

+ (BOOL) registerForNotifications:(NSData *)data registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 * Registers the application with GCM servers asynchronously.
 * <p/>
 * Stores the registration ID and the app version code in the application's shared preferences.
 */

+ (void)registerAndSendInBackground:(NSData *)deviceToken andRegisterAfresh:(BOOL)registerAfresh registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

#pragma mark - Methods to perform local storage

/**
 * Stores the subscriber UID in the application's {@code SharedPreferences}
 *
 * @param context application's context.
 * @param subuid  customer ID
 */

+ (void) storeSubscriberUid:(NSString *)subuid;

/**
 * Stores the registration ID and the app versionCode in the application's
 * {@code SharedPreferences}.
 *
 * @param context application's context.
 * @param regid   registration ID
 */

+ (void) storeRegistrationId:(NSString *)regid;


/**
 * Sends the registration ID to Nudgespot server over HTTP along with the user id.
 * So it can save the registration id for future communication using CCS
 */

+ (void) sendRegistrationToNudgespotWithRegistrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

#pragma mark - Unregistration Methods

/**
 * Sends un-registration to the Nudgespot server over HTTP to notify that this device has been un-registered for this user.
 */

+ (BOOL) sendUnregistrationToNudgespotWithCompletion:(void (^)(id response, NSError *error))completionBlock;


+ (NSMutableDictionary *)messageObjectToJSON:(NSString *) messageId andMode:(NSString *)mode;


#pragma mark - Notification receipt Acknowledgement Methods

/**
 * to acknowledge receipt of that message to the GCM connection server
 */

+ (void)acknowledgeGCMServer:(NSDictionary *)userInfo;


#pragma mark Navigate To Specific Screen Handler Methods

+(void) processNudgespotNotification:(NSDictionary *)userinfo;

+(void) sendNudgespotMessageEvent:(NSString *)messageId andEvent:(NSString *)event;


#pragma mark - Track Activities ..

/**
 *  @brief Method for track Acitvity.
 *  @param NudgespotActivity
 *  @return Completion handler will give you response and error if any.
 */

+ (void) trackActivity:(NudgespotActivity *) activity completion:(void (^)(id response, NSError *error))completionBlock;

@end
