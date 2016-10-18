//
//  NudgespotNetworkManager.h
//  Pods
//
//  Created by Maheep Kaushal on 05/02/16.
//
//

#import <AFNetworking/AFNetworking.h>

#define StringFormat(fmt, ...) [NSString stringWithFormat: fmt, ## __VA_ARGS__]

typedef void(^successCallback)(NSURLSessionDataTask *operation, id responseObject);
typedef void(^failureCallback)(NSURLSessionDataTask *operation, NSError *error);

@interface NudgespotNetworkManager : AFHTTPSessionManager

+ (NudgespotNetworkManager *)sharedInstance;

@end

#pragma mark - Helper methods for subscriber

@interface NudgespotNetworkManager (Subscriber)

+ (NSURLSessionDataTask *) getAccountsSDKConfigFile:(NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;

+ (NSURLSessionDataTask *) identifySubscriberWithPostData:(NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;

+ (NSURLSessionDataTask *) getSubscriberWithUid:(NSString *)uid success:(successCallback)success failure:(failureCallback)failure;

+ (NSURLSessionDataTask *) updateSubscriberWithUrl:(NSString *)urlString withPostData : (NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;

+ (NSURLSessionDataTask *) identifyVisitorForAccount:(NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;

+ (NSURLSessionDataTask *) deleteContactWithUrl:(NSString *)urlString success:(successCallback)success failure:(failureCallback)failure;


@end

#pragma mark - Helper methods for Nudgespot MessageEvents

@interface NudgespotNetworkManager (MessageEvents)

+ (NSURLSessionDataTask *)sendNudgespotMessageEventWithData:(NSMutableDictionary *) postData  success:(successCallback)success failure:(failureCallback)failure;

@end

#pragma mark - Helper methods for Activity or for Push Notifications..

@interface NudgespotNetworkManager (Activity)

+ (NSURLSessionDataTask *) createActivityWithPostData : (NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;

@end


#pragma mark - Helper methods for Anonymous User

@interface NudgespotNetworkManager (Anonymous)

+ (NSURLSessionDataTask *) loginWithAnonymousUser : (NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;

@end


