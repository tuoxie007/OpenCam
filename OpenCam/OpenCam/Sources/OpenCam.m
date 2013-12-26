//
//  OpenCam.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/24.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OpenCam.h"
#import "OCMCameraVC.h"
#import "OCMCameraViewController.h"

@implementation OpenCam

+ (NSString *)localizedString:(NSString *)key
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"OpenCam" ofType:@"bundle"];
    NSBundle *bundle = [[NSBundle alloc] initWithPath:bundlePath];
    NSString *value = [bundle localizedStringForKey:key value:@"" table:nil];
    return value;
}

+ (OCMCameraViewController *)cameraViewController
{
    OCMCameraVC *cameraVC = [[OCMCameraVC alloc] init];
    OCMCameraViewController *nav = [[OCMCameraViewController alloc] initWithRootViewController:cameraVC];
    return nav;
}

@end
