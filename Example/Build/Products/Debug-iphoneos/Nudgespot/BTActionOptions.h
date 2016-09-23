//
//  BTActionOptions.h
//  Pods
//
//  Created by Nudgespot on 15/09/16.
//
//

#import <Foundation/Foundation.h>

@interface BTActionOptions : NSObject


/**
 *  @brief The behavior of this action when the user activates it.
 */

@property (nonatomic, assign) UIUserNotificationActionBehavior behavior NS_AVAILABLE_IOS(9_0);

/**
 *  @brief Parameters that can be used by some types of actions.
 */

@property (nonatomic, copy) NSDictionary *parameters NS_AVAILABLE_IOS(9_0);

/**
 *  @brief How the application should be activated in response to the action.
 */

@property (nonatomic, assign) UIUserNotificationActivationMode activationMode;

/**
 *  @brief Whether this action is secure and should require unlocking before being performed. If the activation mode is UIUserNotificationActivationModeForeground, then the action is considered secure and this property is ignored.
 */

@property (nonatomic, assign, getter=isAuthenticationRequired) BOOL authenticationRequired;

/**
 *  @brief Whether this action should be indicated as destructive when displayed.
 */

@property (nonatomic, assign, getter=isDestructive) BOOL destructive;

+ (BTActionOptions *) updateBehavior: (UIUserNotificationActionBehavior) behavior andParameters:(NSDictionary *) parameters andActivationMode:(UIUserNotificationActivationMode) activationMode andAuthenticationRequired:(BOOL) authenticationRequired andDestructive:(BOOL) destructive;

@end
