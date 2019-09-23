//
//  AppDelegate.swift
//  CollapsingProfileController
//
//  Created by GreenChiu on 2019/9/23.
//  Copyright © 2019 GreenChiu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let aWindow = UIWindow()
        aWindow.rootViewController = UINavigationController(rootViewController: ViewController())
        aWindow.makeKeyAndVisible()
        window = aWindow
        return true
    }
}

