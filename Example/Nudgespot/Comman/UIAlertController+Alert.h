//
//  UIAlertController+Alert.h
//  Task_Assignment
//
//  Created by Maheep Kaushal on 04/01/16.
//  Copyright (c) 2016 Nudgespot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Alert)

+(void)alertViewWithTitle :(NSString *)title withMessage : (NSString *)message withCancelTile: (NSString *)cancelTitle showOnView: (UIViewController *)controller ;

@end
