//
//  AppDelegate.m
//  RottenTomatoes
//
//  Created by Chris Mamuad on 2/6/15.
//  Copyright (c) 2015 Chris Mamuad. All rights reserved.
//

#import "AppDelegate.h"
#import "MoviesViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MoviesViewController *mvc = [[MoviesViewController alloc] initWithMovieType:@"BoxOffice"];
    UINavigationController *nmvc = [[UINavigationController alloc] initWithRootViewController: mvc];
   
    nmvc.tabBarItem.title = @"Box Office";
    nmvc.tabBarItem.image = [UIImage imageNamed:@"films"];
    
    MoviesViewController *mvcdvd = [[MoviesViewController alloc] initWithMovieType:@"DVD"];
    UINavigationController *nmvcdvd = [[UINavigationController alloc] initWithRootViewController: mvcdvd];
 
    nmvcdvd.tabBarItem.title = @"DVD";
    nmvcdvd.tabBarItem.image = [UIImage imageNamed:@"television"];
    // Configure the tab bar controller with the two navigation controllers
    
    nmvc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    nmvc.navigationBar.barTintColor = [UIColor colorWithRed:0.0f green:0.0f blue:90.0f/255.0f alpha:0.5];
 
    [nmvc.navigationBar setTranslucent:YES];
    
    nmvcdvd.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    nmvcdvd.navigationBar.barTintColor = [UIColor colorWithRed:0.0f green:0.0f blue:90.0f/255.0f alpha:0.5];
    nmvcdvd.navigationBar.alpha = 0.4;
    [nmvcdvd.navigationBar setTranslucent:YES];
    
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor colorWithRed:0.0f green:0.0f blue:90.0f/255.0f alpha:0.5];
    
    tabBarController.viewControllers = @[nmvc, nmvcdvd];

    
    
    
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    
    
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
