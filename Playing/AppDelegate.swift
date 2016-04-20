//
//  AppDelegate.swift
//  Playing
//
//  Created by Daniel on 2/15/16.
//  Copyright © 2016 Notabela. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.tintColor = UIColor.yellowColor()
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        //create a nowPlayingViewController by copying MoviesNavigationController from storyboard
        let nowPlayingNavigationController = storyboard.instantiateViewControllerWithIdentifier("MoviesNavigationController") as! UINavigationController
        let nowPlayingViewController = nowPlayingNavigationController.topViewController as! MoviesViewController
        nowPlayingViewController.endpoint = "now_playing"
        nowPlayingNavigationController.tabBarItem.title = "Now Playing"
        nowPlayingNavigationController.tabBarItem.image = UIImage(named: "now_playing.png")
        
        //create a topRatedViewController by capturing MoviesNavigationController from storyboard
        let topRatedNavigationController = storyboard.instantiateViewControllerWithIdentifier("MoviesNavigationController") as! UINavigationController
        let topRatedViewController = topRatedNavigationController.topViewController as! MoviesViewController
        topRatedViewController.endpoint = "top_rated"
        topRatedNavigationController.tabBarItem.title = "Top Rated"
        topRatedNavigationController.tabBarItem.image = UIImage(named: "top_rated.png")
        
        //create a tab bar controller and embedded the two views in it
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController]
        
        //set tabBar as rootView controller
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        //customize Navigation bar and tab bar to be very transluscent
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().shadowImage = UIImage()
        let colorImage = UIImage.imageFromColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.8), frame: CGRectMake(0, 0, 340, 64))
        UINavigationBar.appearance().setBackgroundImage(colorImage, forBarMetrics: UIBarMetrics.Default)
        tabBarController.tabBar.backgroundImage = colorImage
        
        return true
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

//custom drawing
extension UIImage
{
    class func imageFromColor(color: UIColor, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        color.setFill()
        UIRectFill(frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

