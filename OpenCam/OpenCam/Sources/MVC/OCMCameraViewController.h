//
//  OCMCameraViewController.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/24.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OCMCameraViewControllerDelegate;

@interface OCMCameraViewController : UINavigationController

@property (nonatomic, strong) UIImage *photo;
@property (nonatomic) CGFloat maxWidth, maxHeight;
@property (nonatomic, weak) id<OCMCameraViewControllerDelegate, UINavigationControllerDelegate> delegate;

@end


@protocol OCMCameraViewControllerDelegate <NSObject>

- (void)cameraViewControllerDidFinish:(OCMCameraViewController *)cameraViewController;

@end

