//
//  OCMCameraViewController.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/24.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OCMCameraViewControllerProtocal;

@interface OCMCameraViewController : UINavigationController

@property (nonatomic, strong) UIImage *photo;
@property (nonatomic) CGFloat maxWidth, maxHeight;
@property (nonatomic, weak) id<OCMCameraViewControllerProtocal, UINavigationControllerDelegate> delegate;

@end


@protocol OCMCameraViewControllerProtocal <NSObject>

- (void)cameraViewControllerDidFinish:(OCMCameraViewController *)cameraViewController;

@end

