//
//  AppDelegate.swift
//  PredixMobileReferenceApp
//
//  Created by Johns, Andy (GE Corporate) on 8/10/15.
//  Copyright © 2015 GE. All rights reserved.
//

import UIKit
import PredixMobileSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authenticationViewController : UIViewController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        #if DEBUG
            if NSProcessInfo.processInfo().environment["XCInjectBundle"] != nil {
                // Exit if we're running unit tests...
                PGSDKLogger.debug("Detected running functional unit tests, not starting normal services or running normal UI processes")
                return true
            }
        #endif
        
        // Pre-load configuration. This will load any Settings bundles into NSUserDefaults and set default logging levels
        PredixMobilityConfiguration.loadConfiguration()
        
        // Add optional and custom services to the system if required
        //PredixMobilityConfiguration.additionalBootServicesToRegister = [OpenURLService.self]

        // create the PredixMobilityManager object. This object coordinates the application state, interacts with the various services, and holds closures called during authentication.
        
        let vc : ViewController = self.window?.rootViewController as! ViewController
        unowned let unownedSelf = self
        let pmm = PredixMobilityManager(packageWindow: vc, presentAuthentication: { (packageWindow) -> (PredixAppWindowProtocol) in
            
            // for this example we're using a new instance of the primary view controller to host the authentication pages.
            let authVC = vc.storyboard!.instantiateViewControllerWithIdentifier("ViewController") as! ViewController
            authVC.isAuthenticationView = true
            unownedSelf.authenticationViewController = authVC
            unownedSelf.window?.rootViewController!.presentViewController(authVC, animated: true, completion: nil)
            return authVC as PredixAppWindowProtocol
            
            }, dismissAuthentication: { (authenticationWindow) -> () in
                
                if let authVC = unownedSelf.authenticationViewController
                {
                    unownedSelf.authenticationViewController = nil
                    authVC.dismissViewControllerAnimated(true, completion: nil)
                }

        })

        // logging our current running environment
        PGSDKLogger.debug("Started app with launchOptions: \(launchOptions)")
        
        let processInfo = NSProcessInfo.processInfo()
        let device = UIDevice.currentDevice()
        let bundle = NSBundle.mainBundle()
        let id : String = bundle.bundleIdentifier ?? ""

        PGSDKLogger.info("Running Environment:\n     locale: \(NSLocale.currentLocale().localeIdentifier)\n     device model:\(device.model)\n     device system name:\(device.systemName)\n     device system version:\(device.systemVersion)\n     device vendor identifier:\(device.identifierForVendor!.UUIDString)\n     iOS Version: \(processInfo.operatingSystemVersionString)\n     app bundle id: \(id)\n     app build version: \(bundle.objectForInfoDictionaryKey("CFBundleShortVersionString") ?? "")\n     app version: \(bundle.objectForInfoDictionaryKey(kCFBundleVersionKey as String) ?? "")")
        
        if TARGET_IPHONE_SIMULATOR == 1
        {
            //This will help you find where the build lives when running in the simulator
            PGSDKLogger.info("Simulator build running from:\n \(NSBundle.mainBundle().bundlePath)")
            let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory,.UserDomainMask,true).first!
            PGSDKLogger.info("Simulator Application Support dir is here:\n \(applicationSupportDirectory))")
        }
        
        if let launchOptions = launchOptions, notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification
        {
            PGSDKLogger.debug("Startup with local notification")
            PGSDKLogger.trace("Startup local notification info: \(notification.userInfo)")
            PredixMobilityManager.sharedInstance.application(application, didReceiveLocalNotification: notification)
        }
        
        if let launchOptions = launchOptions, userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject]
        {
            PGSDKLogger.debug("Startup with remote notification")
            PGSDKLogger.trace("Startup remote notification info: \(userInfo)")
            PredixMobilityManager.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
        }

        // start the application. This will spin up the PredixMobile environment and call the Boot service to start the application.
        pmm.startApp()
        
        self.setupRemoteNotifications()
        
        return true
    }

    // Registers for Remote (Push) Notifications.
    func setupRemoteNotifications()
    {
        self.setupUserNotificationSettings()
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    // sets up the User Notification Settings, if those settings haven't already been setup.
    func setupUserNotificationSettings()
    {
        // get the current settings
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if settings == nil || settings!.categories == nil || settings!.categories!.isEmpty || settings!.types.isEmpty
        {
            // ensure the current settings have what we're expecting. If not, add what we want
            let action = UIMutableUserNotificationAction()
            action.activationMode = .Foreground
            
            let actionCategory = UIMutableUserNotificationCategory()
            actionCategory.setActions([action], forContext: UIUserNotificationActionContext.Default)
            
            let categorySet = Set<UIMutableUserNotificationCategory>(arrayLiteral: actionCategory)
            
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound] , categories: categorySet)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }

    
    //MARK: Application Delegate Handlers to pass handling to PredixMobilityManager
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        PredixMobilityManager.sharedInstance.applicationWillResignActive(application)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        PredixMobilityManager.sharedInstance.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        PredixMobilityManager.sharedInstance.applicationWillEnterForeground(application)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        #if DEBUG
            if NSProcessInfo.processInfo().environment["XCInjectBundle"] != nil {
                // Exit if we're running unit tests...
                PGSDKLogger.debug("Detected running functional unit tests, not starting normal services or running normal UI processes")
                return
            }
        #endif
        
        PredixMobilityManager.sharedInstance.applicationDidBecomeActive(application)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PredixMobilityManager.sharedInstance.applicationWillTerminate(application)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        PredixMobilityManager.sharedInstance.application(application, didReceiveLocalNotification: notification)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PredixMobilityManager.sharedInstance.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PredixMobilityManager.sharedInstance.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        PredixMobilityManager.sharedInstance.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }


}


