//
//  OCMCameraViewController.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/24.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMCameraViewController.h"

@interface OCMCameraViewController ()

@end

@implementation OCMCameraViewController

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [super viewWillAppear:animated];
}
    
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
