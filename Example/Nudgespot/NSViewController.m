//
//  NSViewController.h
//  Nudgespot
//
//  Created by Maheep Kaushal on 02/17/2016.
//  Copyright (c) 2016 Nudgespot. All rights reserved.
//

#import "NSViewController.h"

#import "NSAppDelegate.h"
#import "NudgeSpotConstants.h"
#import "Nudgespot.h"
#import "UIAlertController+Alert.h"
#import "NSActivityViewController.h"

@interface NSViewController () <UITextFieldDelegate>

@property (nonatomic, strong) Nudgespot *client;
@property (weak, nonatomic) IBOutlet UITextField *uid;

@end

@implementation NSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)loginPressed:(id)sender
{
    if (!self.uid.text.length)
    {
        [UIAlertController alertViewWithTitle:@"Error!!" withMessage:@"Please enter uid" withCancelTile:@"ok" showOnView:self];
        return;
    }
    
    [Nudgespot setWithUID:self.uid.text registrationHandler:^(NSString *registrationToken, NSError *error) {
        
        if (registrationToken) {
            
            NSActivityViewController *activityViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ActivityViewController"];
            [self.navigationController pushViewController:activityViewController animated:YES];
        }
        else{
            
            [UIAlertController alertViewWithTitle:@"Error!!" withMessage:[NSString stringWithFormat:@"%@", error.description] withCancelTile:@"ok" showOnView:self];
        }
        
    }];
    
}


@end
