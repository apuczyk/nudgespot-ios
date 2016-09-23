//
//  NudgespotVisitor.h
//  Pods
//
//  Created by Maheep Kaushal on 22/02/16.
//
//

#import <Foundation/Foundation.h>

@interface NudgespotVisitor : NSObject

@property (nonatomic , retain) NSString *anonymousId;

@property (nonatomic , retain) NSString *registrationToken;

@property (nonatomic , retain) NSMutableDictionary *properties;

-(NSMutableDictionary *)toJSON;

-(NudgespotVisitor *)initWithJSON:(NSMutableDictionary *)responseDictionary;

@end
