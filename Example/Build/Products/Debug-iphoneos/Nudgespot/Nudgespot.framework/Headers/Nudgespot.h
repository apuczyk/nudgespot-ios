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
#import "SubscriberClient.h"

@interface Nudgespot : SubscriberClient

/**
 *  @brief This is check if its registered user or AnonymousUser.
 */

@property (nonatomic, assign) BOOL isAnonymousUser;

/**
 *  @brief registration id. This will use once we got registration token from Fcm, later will will store that local. so,
 *         that we don't have togetStoredSubscriberUid get registration token from Fcm.
 */

@property (nonatomic , retain) NSString *registrationId;

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
 *  @return completion handler will return Token from Fcm and error in case anyting missing.
 */

+ (id)setJavascriptAPIkey:(NSString *)key andRESTAPIkey:(NSString *)token;

/**
 *  @brief Method will register user with unique uid and pass endpointurl.
 *  @param pass unique uid and endpointurl.
 *  @return completion handler will return Token from Fcm and error in case anyting missing.
 */

+ (id) setEndpoint:(NSString *)endpointUrl andUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method will register user with unique uid.
 *  @param pass unique uid.
 *  @return completion handler will return Token from Fcm and error in case anyting missing.
 */

+ (id) setWithUID:(NSString *)uid registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registration;

/**
 *  @brief Method will register user with subscriber and pass endpointurl.
 *  @param pass subscriber object and endpointurl.
 *  @return completion handler will return Token from Fcm and error in case anyting missing.
 */

+ (id) setWithEndpoint:(NSString *)endpointUrl andSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method will register user with subscriber.
 *  @param pass subscriber object in that case.
 *  @return completion handler will return Token from Fcm and error in case anyting missing.
 */

+ (id) setWithSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method runs for getting Fcm registeration token.
 *  @param device token from appdelegate file.
 *  @return completion handler will return Token from Fcm and error in case anyting missing.
 */

+ (void)runRegistrationInBackground:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 *  @brief Method register Anonymous Visitor on Nudgespot and compare registerationToken with Fcm token if not match then update again on Nudgespot with same Anonymous id and if same then return Visitor.
 *  @return Completion handler will give you response and error if any.
 */

+ (void) registerAnonymousUser: (void (^)(id response, NSError *error))completionBlock;

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
 * @ Delete the registration id from Fcm Server and also clear the local data storage
 */


+ (void) clearRegistration:(void (^)(id response, NSError *error))completionBlock;

#pragma mark - Registration Methods

/**
 * @ Actual registration for Notification starts here. To register for Notification in Fcm Server and also stores the data in local data storage
 */

+ (BOOL) registerForNotifications:(void (^)(NSString *registrationToken, NSError *error))registeration;

/**
 * Registers the application with Fcm servers asynchronously.
 * <p/>
 * Stores the registration ID and the app version code in the application's shared preferences.
 */

+ (void)registerAndSendInBackgroundAndRegisterAfresh:(BOOL)registerAfresh registrationHandler:(void (^)(NSString *registrationToken, NSError *error))registeration;

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

+ (void) sendRegistrationToNudgespot:(void (^)(NSString *registrationToken, NSError *error))registeration;

#pragma mark - Unregistration Methods

/**
 * Sends un-registration to the Nudgespot server over HTTP to notify that this device has been un-registered for this user.
 */

+ (BOOL) sendUnregistrationToNudgespot:(void (^)(id response, NSError *error))completionBlock;


+ (NSMutableDictionary *)messageObjectToJSON:(NSString *) messageId andMode:(NSString *)mode;

#pragma mark - Got subscriber..


/**
 *  @brief this will called when we got subscriber.
 *  @param NudgespotSubscriber
 *  @return Completion handler will give you response and error if any.
 */

+ (void)gotSubscriber:(NudgespotSubscriber *)currentSubscriber registrationHandler:(void (^)(NSString *, NSError *))registeration;

#pragma mark - Notification receipt Acknowledgement Methods

/**
 * to acknowledge receipt of that message to the Fcm connection server
 */

+ (void)acknowledgeFcmServer:(NSDictionary *)userInfo;

#pragma mark Navigate To Specific Screen Handler Methods

+ (void) processNudgespotNotification:(NSDictionary *)userinfo withApplication: (UIApplication * )application andWindow:(UIWindow *)window;

+ (void) sendNudgespotMessageEvent:(NSString *)messageId andEvent:(NSString *)event;

/**
 *  @brief Method which will use in didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken and this will help you to get correct format payload from APNS Data. 
 *  @param Devicetoken as NSData and Type, Production or Development.
 *  @return No return.
 */

+ (void)setAPNSToken:(NSData *)deviceToken ofType:(NudgespotIDAPNSTokenType) type;

#pragma mark - Track Activities ..

/**
 *  @brief Method for track Acitvity.
 *  @param NudgespotActivity
 *  @return Completion handler will give you response and error if any.
 */

+ (void) trackActivity:(NudgespotActivity *) activity completion:(void (^)(id response, NSError *error))completionBlock;

@end
