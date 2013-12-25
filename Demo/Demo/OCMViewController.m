//
//  OCMViewController.m
//  Demo
//
//  Created by Jason Hsu on 2013/12/24.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMViewController.h"
#import <OpenCam/OpenCam.h>

@interface OCMViewController () <OCMCameraViewControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIImageView *preview;

@end

@implementation OCMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *cameraButton = [[UIButton alloc] init];
    [self.view addSubview:cameraButton];
    [cameraButton setTitle:@"Start Camera" forState:UIControlStateNormal];
    [cameraButton sizeToFit];
    cameraButton.center = self.view.center;
    [cameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(startCamera) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *preview = [[UIImageView alloc] init];
    self.preview = preview;
    [self.view addSubview:preview];
    preview.size = ccs(self.view.width, self.view.width);
    preview.center = self.view.center;
    preview.contentMode = UIViewContentModeScaleAspectFit;
    
    preview.top = (self.view.height - preview.height - cameraButton.height - 30) / 2;
    cameraButton.bottom = self.view.height - preview.top;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)startCamera
{
    OCMCameraViewController *camVC = [OpenCam cameraViewController];
    camVC.delegate = self;
    camVC.maxWidth = 1000;
    [self presentViewController:camVC animated:YES completion:nil];
}

- (void)cameraViewControllerDidFinish:(OCMCameraViewController *)cameraViewController
{
    self.preview.image = cameraViewController.photo;
}

@end
