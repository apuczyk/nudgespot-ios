//
//  UIAlertController+Alert.m
//  Task_Assignment
//
//  Created by Maheep Kaushal on 04/01/16.
//  Copyright (c) 2016 Nudgespot. All rights reserved.
//

#import "UIAlertController+Alert.h"

@implementation UIAlertController (Alert)

+(void)alertViewWithTitle :(NSString *)title withMessage : (NSString *)message withCancelTile: (NSString *)cancelTitle showOnView: (UIViewController *)controller ;
{
    UIAlertController *ctr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
    [ctr addAction:cancel];
    [controller presentViewController:ctr animated:YES completion:nil];
}

@end
