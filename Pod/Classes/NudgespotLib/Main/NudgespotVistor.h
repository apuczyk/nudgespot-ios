//
//  NudgespotVistor.h
//  Pods
//
//  Created by Maheep Kaushal on 22/02/16.
//
//

#import <Foundation/Foundation.h>

@interface NudgespotVistor : NSObject

@property (nonatomic , retain) NSString *uid;

@property (nonatomic , retain) NSDate *timestamp;

@property (nonatomic , retain) NSMutableDictionary *properties;

@property (nonatomic , assign) BOOL isRegistered;

-(NudgespotVistor *) initWithJSON:(NSMutableDictionary *)vistor;

-(NSMutableDictionary *) toJSON;

@end
