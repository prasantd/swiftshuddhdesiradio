//
//  AppDelegate.swift
//  Shuddh Desi Radio
//
//  Created by AtlantaLoaner2 on 6/11/19.
//  Copyright © 2019 Shuddh Desi Radio. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var imgSponsorsArr: [UIImage]?
    var drawerController: MMDrawerController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Connection is active")
        }
        catch {
            print("Unexpected error: \(error).")
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        buildNavigationDrawer()
     
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func buildNavigationDrawer(){
        let mainStoryBoard:UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
        
        let mainPage:SDRTabBarController = mainStoryBoard.instantiateViewController(withIdentifier: "SDRTabBarController") as! SDRTabBarController
        
        let leftSideMenu:LeftViewController = mainStoryBoard.instantiateViewController(withIdentifier: "LeftSideViewController") as! LeftViewController
        
        let leftSideMenuNav = UINavigationController(rootViewController:leftSideMenu)
        
        drawerController = MMDrawerController(center: mainPage, leftDrawerViewController: leftSideMenuNav)
        
        drawerController!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView
        drawerController!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.panningCenterView
        
        // Assign MMDrawerController to our window's root ViewController
        window?.rootViewController = drawerController

    }
}

