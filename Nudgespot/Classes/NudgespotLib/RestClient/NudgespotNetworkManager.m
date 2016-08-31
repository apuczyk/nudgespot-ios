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
        
        self.requestSerializer.HTTPShouldHandleCookies = false ;
        
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:[[Nudgespot sharedInstance] restUser] password:[[Nudgespot sharedInstance] RESTAPIkey]];
        
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
        _sharedManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
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

+ (NSURLSessionDataTask *) updateSubscriberWithUrl:(NSString *)urlString withPostData : (NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;
{
    DLog(@"updateSubscriber %@ request serviceUrl ::::::::::::::::::::: \n  = %@",postData, urlString);
    
    return [NudgeRestInstance PUT:urlString parameters:postData success:success failure:failure];
}

+ (NSURLSessionDataTask *) identifySubscriberWithPostData:(NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure; {
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@",SUBSCRIBER_IDENTIFY];
    
    DLog(@"SUBSCRIBER IDENTIFY search path %@ ::::::::::::::::::::: \n request Url %@%@", requestUrl, [[[self manager] baseURL]absoluteString],SUBSCRIBER_IDENTIFY);
    
    return [NudgeRestInstance POST:SUBSCRIBER_IDENTIFY parameters:postData progress:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *) identifyVisitorForAccount:(NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure; {
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@",VISITOR_IDENTIFY];
    
    DLog(@"VISITOR IDENTIFY For an account %@ ::::::::::::::::::::: \n request Url %@%@", requestUrl, [[[self manager] baseURL]absoluteString], VISITOR_IDENTIFY);
    
    return [NudgeRestInstance POST:requestUrl parameters:postData progress:nil success:success failure:failure];
}


@end


#pragma mark - Helper methods for Nudgespot MessageEvents

@implementation NudgespotNetworkManager (MessageEvents)

+ (NSURLSessionDataTask *)sendNudgespotMessageEventWithData:(NSMutableDictionary *) postData  success:(successCallback)success failure:(failureCallback)failure {

    NudgespotNetworkManager * manager = [[NudgespotNetworkManager manager] initWithBaseURL:nil];
    
    DLog(@"message %@ request serviceUrl ::::::::::::::::::::: \n  = %@%@",postData, [[manager baseURL]absoluteString],TRACK_API_ENDPOINT);
    
    return [manager POST:TRACK_API_ENDPOINT parameters:postData progress:nil success:success failure:failure];

}

@end

#pragma mark - Helper methods for Activity or for Push Notifications..

@implementation NudgespotNetworkManager (Activity)

+ (NSURLSessionDataTask *) createActivityWithPostData : (NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure {
    
    DLog(@"createActivity %@ request serviceUrl ::::::::::::::::::::: \n  = %@%@",postData, [[[self manager] baseURL]absoluteString], ACTIVITY_CREATE_PATH);
    
    return [NudgeRestInstance POST:ACTIVITY_CREATE_PATH parameters:postData progress:nil success:success failure:failure];
}

@end


#pragma mark - Helper methods for Anonymous User

@implementation NudgespotNetworkManager (Anonymous)

+ (NSURLSessionDataTask *) loginWithAnonymousUser : (NSMutableDictionary *)postData success:(successCallback)success failure:(failureCallback)failure;
{
    DLog(@"login with Anonymous %@ request serviceUrl ::::::::::::::::::::: \n  = %@%@",postData, [[[self manager] baseURL]absoluteString], VISITOR_REGISTRATION);
    
    return [NudgeRestInstance POST:VISITOR_REGISTRATION parameters:postData progress:nil success:success failure:failure];
}

@end

