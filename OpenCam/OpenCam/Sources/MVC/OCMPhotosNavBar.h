//
//  OCMPhotosNavigationBar.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/4.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCMPhotosNavBar : UICollectionReusableView

@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *selectPhotoView;

@end
