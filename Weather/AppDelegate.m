//
//  AppDelegate.m
//  Weather
//
//  Created by Ludvik Polak on 26.10.14.
//  Copyright (c) 2014 com.ludvikpolak. All rights reserved.
//

#import "AppDelegate.h"
#import "WeatherDataObject.h"
#import "TodayViewController.h"
#import "ForecastViewController.h"
#import "SettingsViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

UINavigationController * CreateNavigationController(UIViewController * Controller){
    
    UINavigationController *navController = nil;
    
    if(Controller){
        navController = [[UINavigationController alloc] initWithRootViewController:Controller];
    }
    else{
        navController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
    }
    
    UIFont * font = [UIFont fontWithName:@"ProximaNova-Semibold" size:18.0];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0],
                                                            NSFontAttributeName: font                                                            }];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];

    return navController;
}

-(UITabBarController*)CreateTabBar{
    
    // definition of tabBarController
    UITabBarController * tabBar = [[UITabBarController alloc] init];
    
    UIFont * font = [UIFont fontWithName:@"ProximaNova-Semibold" size:10.0];
    NSDictionary *normalState = @{
                                  NSForegroundColorAttributeName : [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0],
                                  NSFontAttributeName : font
                                  };
    
    NSDictionary *normalTextState = @{
                                      NSForegroundColorAttributeName : [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0]
                                  };
    NSDictionary *selectedTextState = @{
                                      NSForegroundColorAttributeName : [UIColor colorWithRed:0x2f/255.0 green:0x91/255.0 blue:0xff/255.0 alpha:1.0]
                                      };
    
    [[UITabBarItem appearance] setTitleTextAttributes:normalState forState:UIControlStateNormal];
    
    UINavigationController * nav = nil;
    
    // TodayViewController
    nav = CreateNavigationController([[TodayViewController alloc] initWithNibName:@"TodayViewController" bundle:nil]);
    nav.tabBarItem.title = NSLocalizedString(@"Today", @"Today");
    [nav.tabBarItem setImage:[[UIImage imageNamed:@"TodayNormal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav.tabBarItem setSelectedImage:[[UIImage imageNamed:@"TodaySelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav.tabBarItem setTitleTextAttributes:normalTextState forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:selectedTextState forState:UIControlStateHighlighted];
    [tabBar addChildViewController:nav];
    
    // ForecastViewController
    nav = CreateNavigationController([[ForecastViewController alloc] initWithNibName:@"ForecastViewController" bundle:nil]);
    nav.tabBarItem.title = NSLocalizedString(@"Forecast", @"Forecast");
    [nav.tabBarItem setImage:[[UIImage imageNamed:@"ForecastNormal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav.tabBarItem setSelectedImage:[[UIImage imageNamed:@"ForecastSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav.tabBarItem setTitleTextAttributes:normalTextState forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:selectedTextState forState:UIControlStateHighlighted];
    [tabBar addChildViewController:nav];
    
    // SettingsViewController
    nav = CreateNavigationController([[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil]);
    nav.tabBarItem.title = NSLocalizedString(@"Settings", @"Settings");
    [nav.tabBarItem setImage:[[UIImage imageNamed:@"SettingsNormal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav.tabBarItem setSelectedImage:[[UIImage imageNamed:@"SettingsSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav.tabBarItem setTitleTextAttributes:normalTextState forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:selectedTextState forState:UIControlStateHighlighted];
    [tabBar addChildViewController:nav];
    
    return tabBar;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.tabBar = [self CreateTabBar];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:self.tabBar];
    [self.window makeKeyAndVisible];
    
    [[WeatherDataObject Shared] RefreshData];
    [[WeatherDataObject Shared] UpdateWeatherForAllLocations];
    
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
