//
//  AppDelegate.m
//  yt
//
//  Created by CalvinK19 on 7/13/25.
//  Copyright (c) 2025 calvink19. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "SettingsViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    ViewController *mainVC;
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        mainVC = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
        // settingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController_iPad" bundle:nil];
    } else {
        mainVC = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        // settingsVC = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    }
    
    mainVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Watch" image:nil tag:0];
    settingsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:nil tag:1];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[mainVC, settingsVC];
    
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
