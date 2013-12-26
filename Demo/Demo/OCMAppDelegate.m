//
//  OCMAppDelegate.m
//  Demo
//
//  Created by Jason Hsu on 2013/12/24.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMAppDelegate.h"
#import "OCMViewController.h"

@implementation OCMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[OCMViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
