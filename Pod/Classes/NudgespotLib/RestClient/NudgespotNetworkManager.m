//
//  NudgespotNetworkManager.m
//  Pods
//
//  Created by Maheep Kaushal on 05/02/16.
//
//

#import "NudgespotNetworkManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "NudgespotConstants.h"

#define NudgeRestInstance [self sharedInstance]

@implementation NudgespotNetworkManager

+ (instancetype)manager
{
    return [[self alloc] initWithBaseURL:[NSURL URLWithString:REST_API_ENDPOINT]];
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self)
    {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:[[Nudgespot sharedInstance] apiKey] password:[[Nudgespot sharedInstance] secretToken]];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.requestSerializer setValue: @"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"Nudgespot::iOS::RestClient" forHTTPHeaderField:@"User-Agent"];
        [self.requestSerializer setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    }
    
    return self;
}

#pragma mark - Shared Manager
+ (NudgespotNetworkManager *)sharedInstance;
{
    static NudgespotNetworkManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [NudgespotNetworkManager manager];
    });
    
    return _sharedManager;
}

#pragma mark - Load
+ (void)load
{
#if PRINT_VERBOSE_INFORMATION
    [AFNetworkActivityLogger sharedLogger].level = AFLoggerLevelDebug;
    [[AFNetworkActivityLogger sharedLogger] startLogging];
#endif
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
}

@end

#pragma mark - Helper methods for subscriber

@implementation NudgespotNetworkManager (Subscriber)

+ (NSURLSessionDataTask *) createSubscriberWithPostData:(NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;
{
    DLog(@"createSubscriber %@ request serviceUrl ::::::::::::::::::::: \n  = %@%@",postData, [[[self manager] baseURL]absoluteString],SUBSCRIBER_CREATE_PATH);
    
    return [NudgeRestInstance POST:SUBSCRIBER_CREATE_PATH parameters:postData progress:nil success:success failure:failure];

}

+ (NSURLSessionDataTask *) updateSubscriberWithUrl:(NSString *)urlString withPostData : (NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;
{
    DLog(@"updateSubscriber %@ request serviceUrl ::::::::::::::::::::: \n  = %@",postData, urlString);
    
    return [NudgeRestInstance PUT:urlString parameters:postData success:success failure:failure];
}

+ (NSURLSessionDataTask *) getSubscriberWithID:(NSString *)uid success:(successCallback)success failure:(failureCallback)failure;
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",SUBSCRIBER_FIND_PATH, uid];
    
    DLog(@"getSubscriber search path %@ ::::::::::::::::::::: \n request Url %@%@", requestUrl, [[[self manager] baseURL]absoluteString],SUBSCRIBER_FIND_PATH);
    
    return [NudgeRestInstance GET:requestUrl parameters:nil progress:nil success:success failure:failure];
}

@end


#pragma mark - Helper methods for Nudgespot MessageEvents

@implementation NudgespotNetworkManager (MessageEvents)

+ (NSURLSessionDataTask *)sendNudgespotMessageEventWithData:(NSMutableDictionary *) postData  success:(successCallback)success failure:(failureCallback)failure {
    
    DLog(@"message %@ request serviceUrl ::::::::::::::::::::: \n  = %@%@",postData, [[[self manager] baseURL]absoluteString],TRACK_API_ENDPOINT);
    
    return [NudgeRestInstance POST:TRACK_API_ENDPOINT parameters:postData progress:nil success:success failure:failure];

}

@end

#pragma mark - Helper methods for Activity or for Push Notifications..

@implementation NudgespotNetworkManager (Activity)

+ (NSURLSessionDataTask *) createActivityWithPostData : (NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure {
    
    DLog(@"createActivity %@ request serviceUrl ::::::::::::::::::::: \n  = %@%@",postData, [[[self manager] baseURL]absoluteString], ACTIVITY_CREATE_PATH);
    
    return [NudgeRestInstance POST:ACTIVITY_CREATE_PATH parameters:postData progress:nil success:success failure:failure];
}

@end


