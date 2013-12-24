//
//  OCMSelectPhotoVC.h
//  OpenCam
//
//  Created by Jason Hsu on 11/5/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface OCMSelectPhotoVC : UIViewController

@property (nonatomic, strong) ALAsset *selectedAsset;
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, weak) UIView *selectPhotoView;
@property (nonatomic, weak) UIView *selectViewCover;
@property (nonatomic) BOOL locked;
@property (nonatomic) BOOL fromBottom;
@property (nonatomic) BOOL animating;
@property (nonatomic, strong) UIViewController *photosVC;

@end