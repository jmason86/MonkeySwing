//
//  AppDelegate.m
//  MonkeySwing
//
//  Created by James Paul Mason on 1/1/14.
//  Copyright (c) 2014 James Paul Mason. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup the persistent data structure in NSUserDefaults
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultScores = [NSArray array];
    NSArray *levels = [NSArray array];
    for (int i = 1; i <= 20 ; i++ ) { // To change the number of levels, just change the max value of i
        defaultScores = [defaultScores arrayByAddingObject:[NSNumber numberWithInt:0]];
        levels = [levels arrayByAddingObject:[NSString stringWithFormat:@"%@%i", @"Level", i]];
    }
    NSDictionary *defaults = [NSDictionary dictionaryWithObjects:defaultScores forKeys:levels];
    [standardDefaults registerDefaults:defaults];
    [standardDefaults synchronize];
    
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
