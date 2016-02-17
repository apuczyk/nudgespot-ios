//
//  NSActivityViewController.m
//  NudgeSpotDemo
//
//  Created by Maheep Kaushal on 11/02/16.
//  Copyright (c) 2016 Nudgespot. All rights reserved.
//

#import "NSActivityViewController.h"
#import "NudgespotActivity.h"
#import "Nudgespot.h"
#import "NSAppDelegate.h"
#import "UIAlertController+Alert.h"

@interface NSActivityViewController()

@property(nonatomic, strong) NudgespotActivity *activity;

@property (weak, nonatomic) IBOutlet UITextField *orderNumber;
@property (weak, nonatomic) IBOutlet UITextField *orderAmount;
@property (weak, nonatomic) IBOutlet UITextField *courseName;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;

@end

@implementation NSActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailTitle.text = [NSString stringWithFormat:@"Hi %@", [[[Nudgespot sharedInstance] subscriber] uid]];
    
    self.navigationItem.hidesBackButton = YES;
}


- (IBAction)placeOrderPressed:(id)sender {
    
    if (!self.orderAmount.text.length || !self.orderNumber.text.length) {
        
        [UIAlertController alertViewWithTitle:@"Error!!" withMessage:@"Please enter Order Amount or Number" withCancelTile:@"ok" showOnView:self];
        return;
        
    }
    
    NSDictionary *dict = @{@"Order Amount":self.orderAmount.text,
                           @"Order Number":self.orderNumber.text
                           };
    
    _activity = [[NudgespotActivity alloc] initwithNudgespotActivity:@"purchased" andUID:[[[Nudgespot sharedInstance] subscriber] uid] andProperty:(NSMutableDictionary *)dict];
    
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
    
    _activity = [[NudgespotActivity alloc] initwithNudgespotActivity:@"purchased" andUID:[[[Nudgespot sharedInstance] subscriber] uid] andProperty:(NSMutableDictionary *)dict];
    
    [Nudgespot trackActivity:_activity completion:^(id response, NSError *error) {
        
        NSLog(@"%@ is response", response);
        
    }];
    
}


- (IBAction)logoutPressed:(id)sender {
    
    [Nudgespot  clearRegistrationWithCompletion:^(id response, NSError *error) {
        
        if (response) {
            
            NSLog(@"Logout success with response %@", response);
            [self.navigationController popViewControllerAnimated:YES];
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
