//
//  ViewController.swift
//  Nudgespot
//
//  Created by Maheep Kaushal on 08/22/2016.
//  Copyright (c) 2016 Maheep Kaushal. All rights reserved.
//

import UIKit


extension String {
    
    var length : Int {
        return characters.count
    }
}

class ViewController: UIViewController {

    var activity = NudgespotActivity()
    
    @IBOutlet weak var orderNumber: UITextField!
    @IBOutlet weak var courseName: UITextField!
    @IBOutlet weak var orderAmount: UITextField!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var loginOrLogout: UIButton!
    @IBOutlet weak var uid: UITextField!
    
    @IBAction func placeOrderPressed(sender: UIButton) {
        
        if self.orderAmount.text?.length < 1 || self.orderNumber.text?.length < 1 {
            
            UIAlertController.alertViewWithTitle("Error!!", withMessage:"Please enter Order Amount or Number", withCancelTile: "ok", showOnView: self)
            return
        }
        
        let dict : NSMutableDictionary = ["Order Amount":self.orderAmount.text!,
            "Order Number":self.orderNumber.text!]
        
        self.activity = NudgespotActivity().initwithNudgespotActivity("purchased", andProperty: dict)
        
        Nudgespot.trackActivity(self.activity) { (response: AnyObject?, error: NSError?) in
            print("\(response), is response")
        }
    }
    
    @IBAction func enrolCoursePressed(sender: UIButton) {
        
        if self.courseName.text?.length < 1 {
            
            UIAlertController.alertViewWithTitle("Error!!", withMessage:"Please enter Course Name", withCancelTile: "ok", showOnView: self)
            return
        }
        
        let dict : NSMutableDictionary = ["Course Name":self.courseName.text!,
            "Course Duration":"1 year",
            "Course Fee":"$10,000"]
        
        self.activity = NudgespotActivity().initwithNudgespotActivity("enroll_course", andProperty: dict)
        
        Nudgespot.trackActivity(self.activity) { (response: AnyObject?, error: NSError?) in
            print("\(response), is response")
        }
        
    }
    
    @IBAction func loginPressed(sender: UIButton) {
        
        if self.uid.text?.length < 1 {
            
            UIAlertController.alertViewWithTitle("Error!!", withMessage: "Please enter uid", withCancelTile: "ok", showOnView: self)
            return
        }
        
        if sender.currentTitle == "LOGIN" {
            
            sender.enabled = false
            
            self.activityView.startAnimating()
            
            Nudgespot.setWithUID(self.uid.text!, registrationHandler: { (registrationToken, error) in
                
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    sender.enabled = true
                    self.activityView.stopAnimating()
                    sender.setTitle("LOGOUT", forState: .Normal)
                })
                
                NSUserDefaults.standardUserDefaults().setObject(self.uid.text!, forKey: "SubscriberUid")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                print("Registration Found \(registrationToken)")
            })
            
        } else {
            
            sender.enabled = false
            self.logoutPressed(sender)

        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let uidText = NSUserDefaults.standardUserDefaults().objectForKey("SubscriberUid")
        
        if uidText != nil {
            
            if uidText?.length > 1 {
                
                print(uidText!)
                
                self.uid.text = uidText! as? String
                self.loginOrLogout.setTitle("LOGOUT", forState: .Normal)
            }
        }
        
    }
    
    func logoutPressed(sender: UIButton) -> Void {
        
        self.activityView.startAnimating()
        
        Nudgespot.clearRegistration { (response: AnyObject?, error: NSError?) in
            
            if response != nil {
                
                NSUserDefaults.standardUserDefaults().removeObjectForKey("SubscriberUid")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                // Here we are creating Anonymous user again for tracking activites.
                
                Nudgespot.registerAnonymousUser({ (response: AnyObject?, error: NSError?) in
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        sender.enabled = true
                        self.activityView.stopAnimating()
                        sender.setTitle("LOGIN", forState: .Normal)
                    })
                    
                    print("\(response) is response")
                })
                
                // Clear Textfield ..
                
                self.uid.text = ""
                
                print("Logout success with response = \(response)")
                
            } else {
                self.activityView.stopAnimating()
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
}

