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
#import <Firebase/Firebase.h>

@interface Nudgespot : SubscriberClient <SubscriberClientDelegate>

/**
 *  @brief This is check if its registered user or AnonymousUser.
 */

@property (nonatomic, assign) BOOL isAnonymousUser;

/**
 *  @brief registration id. This will use once we got registration token from GCM, later will will store that local. so, 
 *         that we don't have togetStoredSubscriberUid get registration token from GCM.
 */

@property (nonatomic , retain) NSString *registrationId;

/**
 *  @brief check if Registeration is done successfully or not.
 */

@property (nonatomic , assign) BOOL isRegisterForNotification;

/**
 *  @brief registration options for GCM.
 */

@property (nonatomic , retain) NSDictionary* registrationOptions;

/**
 *  @brief device token from appdelegate file, which requires to register GCM.
 */

@property (nonatomic , retain) NSData *deviceToken;

/**
 *  @brief api key from Nudgespot account settings.
 */

@property (nonatomic , retain) NSString *JavascriptAPIkey;

/**
 *  @brief api key from Nudgespot account settings.
 */

@property (nonatomic , retain) NSString *restUser;

/**
 *  @brief secret token from Nudgespot account settings.
 */

@property (nonatomic , retain) NSString *RESTAPIkey;

/**
 *  @brief sharedInstance which will work as singleton.
 */

+ (id) sharedInstance;

/**
 *  @brief Method will initialize Nudgespot Client.
 *  @param pass api key from Nudgespot account settings and secrettoken from Nudgespot account settings.
 *  @return completion handler will return Token from GCM and error in case anyting missing.
 */

+ (id)setJavascriptAPIkey:(NSString *)key andRESTAPIkey:(NSString *)token;

/**
 *  @brief Method will register user with unique uid and pass endpointurl.
 *  @param pass unique uid and endpointurl.
 *  @return completion handler will return Token from GCM and error in case anyting missing.
 */

+ (id) setEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method will register user with unique uid.
 *  @param pass unique uid.
 *  @return completion handler will return Token from GCM and error in case anyting missing.
 */

+ (id) setWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method will register user with subscriber and pass endpointurl.
 *  @param pass subscriber object and endpointurl.
 *  @return completion handler will return Token from GCM and error in case anyting missing.
 */

+ (id) setWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method will register user with subscriber.
 *  @param pass subscriber object in that case.
 *  @return completion handler will return Token from GCM and error in case anyting missing.
 */

+ (id) setWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method runs for getting GCM registeration token.
 *  @param device token from appdelegate file.
 *  @return completion handler will return Token from GCM and error in case anyting missing.
 */

+ (void)runRegistrationInBackgroundWithToken:(NSData *)deviceToken registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method which will use if we want to call it as anynomous users.
 *  @return Completion handler will give you response and error if any.
 */

+ (void) registerAnynomousUser: (void (^)(id response, NSError *error))completionBlock;

#pragma mark - Helper Method to Device Token from Appdelegate

/**
 *  @brief Method for loading Device token to Nudgespot.
 *  @param pass device token from appdelegate file.
 *  @return Application's version code from the Application Bundle.
 */

+ (void) loadDeviceToken : (NSData *)deviceToken;


#pragma mark - Methods used to connect and disconnect from Fcm Server

/**
 *  Connect to the Fcm server to receive non-APNS notifications
 */

+ (void)connectToFcm;

/**
 *  Disconnect with the Fcm server to stop receiving non-APNS notifications
 */

+ (void)disconnectToFcm;


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
 * Retrieves the stored Visitor for the application, if there is one
 *
 * @param context
 * @return Visitor Anonymous id, or empty string if there is none.
 */
+ (NSString *) getStoredAnonymousUid;


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
 * to acknowledge receipt of that message to the Fcm connection server
 */

+ (void)acknowledgeFcmServer:(NSDictionary *)userInfo;

#pragma mark Navigate To Specific Screen Handler Methods

+ (void) processNudgespotNotification:(NSDictionary *)userinfo withApplication: (UIApplication * )application andWindow:(UIWindow *)window;

+ (void) sendNudgespotMessageEvent:(NSString *)messageId andEvent:(NSString *)event;


#pragma mark - Track Activities ..

/**
 *  @brief Method for track Acitvity.
 *  @param NudgespotActivity
 *  @return Completion handler will give you response and error if any.
 */

+ (void) trackActivity:(NudgespotActivity *) activity completion:(void (^)(id response, NSError *error))completionBlock;

@end
