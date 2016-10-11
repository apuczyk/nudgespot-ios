//
//  NSActivityViewController.m
//  Nudgespot
//
//  Created by Maheep Kaushal on 11/02/16.
//  Copyright (c) 2016 Nudgespot. All rights reserved.
//

#import "NSViewController.h"
#import "NudgespotActivity.h"
#import "Nudgespot.h"
#import "NSAppDelegate.h"
#import "UIAlertController+Alert.h"
#import "NudgespotVisitor.h"
#import "NudgeSpotConstants.h"

@interface NSViewController()

@property(nonatomic, strong) NudgespotActivity *activity;

@property (weak, nonatomic) IBOutlet UITextField *orderNumber;
@property (weak, nonatomic) IBOutlet UITextField *orderAmount;
@property (weak, nonatomic) IBOutlet UITextField *courseName;
@property (weak, nonatomic) IBOutlet UITextField *uid;
@property (weak, nonatomic) IBOutlet UIButton *loginOrLogout;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation NSViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSString *uidText = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriberUid];
    
    if (uidText) {
        
        if (uidText.length > 1) {
            [self.uid setText:uidText];
            [self.loginOrLogout setTitle:@"LOGOUT" forState:UIControlStateNormal];
        }
        
    }
    
}

- (IBAction)loginPressed:(UIButton *)sender
{
    if (!self.uid.text.length)
    {
        [UIAlertController alertViewWithTitle:@"Error!!" withMessage:@"Please enter uid" withCancelTile:@"ok" showOnView:self];
        return;
    }
    
    if ([sender.currentTitle isEqualToString:@"LOGIN"]) {
        
        [sender setEnabled:NO];
        
        [self.activityIndicatorView startAnimating];
        
        __weak NSViewController *weak = self;
        
        [Nudgespot setWithUID:self.uid.text registrationHandler:^(NSString *registrationToken, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setEnabled:YES];
                [weak.activityIndicatorView stopAnimating];
                [sender setTitle:@"LOGOUT" forState:UIControlStateNormal];
            });
            
            [[NSUserDefaults standardUserDefaults] setObject:self.uid.text forKey:kSubscriberUid];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"Registration Found %@ and error %@", registrationToken, error);
            
        }];
    }
    else {
        
        [sender setEnabled:NO];
        [self logoutPressed:sender];
        
    }
    
}

- (IBAction)placeOrderPressed:(id)sender {
    
    if (!self.orderAmount.text.length || !self.orderNumber.text.length) {
        
        [UIAlertController alertViewWithTitle:@"Error!!" withMessage:@"Please enter Order Amount or Number" withCancelTile:@"ok" showOnView:self];
        return;
        
    }
    
    NSDictionary *dict = @{@"Order Amount":self.orderAmount.text,
                           @"Order Number":self.orderNumber.text
                           };
    
    _activity = [[NudgespotActivity alloc] initwithNudgespotActivity:@"purchased" andProperty:(NSMutableDictionary *)dict];
    
    [Nudgespot trackActivity:_activity completion:^(id response, NSError *error) {
        
        NSLog(@"%@ is response", response);
    }];
    
}


- (IBAction)enrollCoursePressed:(id)sender {
    
    if (!self.courseName.text.length) {
        
        [UIAlertController alertViewWithTitle:@"Error!!" withMessage:@"Please enter Course Name" withCancelTile:@"ok" showOnView:self];
        return;
        
    }
    
    NSDictionary *dict = @{@"Course Name":self.courseName.text,
                           @"Course Duration":@"1 year",
                           @"Course Fee":@"$10,000"
                           };
    
    _activity = [[NudgespotActivity alloc] initwithNudgespotActivity:@"enroll_course" andProperty:(NSMutableDictionary *)dict];
    
    [Nudgespot trackActivity:_activity completion:^(id response, NSError *error) {
        
        NSLog(@"%@ is response", response);
    }];
    
}


- (void)logoutPressed:(id)sender {
    
    [self.activityIndicatorView startAnimating];
    
    __weak NSViewController *weak = self;
    
    [Nudgespot clearRegistration:^(id response, NSError *error) {
        if (response) {
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubscriberUid];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Here we are creating Anonymous user again for tracking activites.
            
            [Nudgespot registerAnonymousUser:^(id response, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sender setEnabled:YES];
                    [weak.activityIndicatorView stopAnimating];
                    [sender setTitle:@"LOGIN" forState:UIControlStateNormal];
                    
                });
                
                NSLog(@"%@ is response", response);
            }];
            
            // Clear TextField ..
            self.uid.text = @"";
            
            NSLog(@"Logout success with response %@", response);
        } else {
            [weak.activityIndicatorView stopAnimating];
        }
    }];
    
}


#pragma mark - TextField Delegates..

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
