//
//  AppDelegate.swift
//  Nudgespot
//
//  Created by Maheep Kaushal on 08/22/2016.
//  Copyright (c) 2016 Maheep Kaushal. All rights reserved.
//

import UIKit


@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {

    let kSubscriberUid = "SubscriberUid"
    
    let kJavascriptAPIkey = ""
    
    let kRESTAPIkey = ""
    
    var badgeCount = 0
    
    var window: UIWindow?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Register for remote notifications
        
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 {
            // Register for Push Notifications  for iOS 7.1 or earlier
            application.registerForRemoteNotificationTypes([.Alert, .Sound, .Badge])
        } else {
            let types:UIUserNotificationType = ([.Alert, .Sound, .Badge])
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        
        // Initialize Nudgespot
        
        Nudgespot.setJavascriptAPIkey(kJavascriptAPIkey, andRESTAPIkey: kRESTAPIkey)
        
        let uid = NSUserDefaults.standardUserDefaults().objectForKey(kSubscriberUid)
        
        if uid == nil {
            
            Nudgespot.registerAnonymousUser({ (response: AnyObject?, error: NSError?) in
                print(response)
            })
        } else {
            Nudgespot.setWithUID(uid! as! String, registrationHandler: { (response: String?, error: NSError?) in
                print(response)
            })
        }
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        badgeCount = 0
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
        
        Nudgespot.connectToFcm()
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print("Notification Received: \(userInfo)")
        
        badgeCount += 1
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = badgeCount
        
        Nudgespot.acknowledgeFcmServer(userInfo)
        
        Nudgespot.processNudgespotNotification(userInfo, withApplication: application, andWindow: window)
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        Nudgespot.setAPNSToken(deviceToken, ofType: .APNSTokenTypeSandbox)
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        Nudgespot.disconnectToFcm()
    }

}

