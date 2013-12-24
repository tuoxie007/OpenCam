//
//  OCMPhotosVC.h
//  OpenCam
//
//  Created by Jason Hsu on 11/5/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OCMDidSelectPhotoNotification @"OCMDidSelectPhotoNotification"
#define OCMDidLoadFirstPhotoNotification @"OCMDidLoadFirstPhotoNotification"
#define OCMDidTapPhotosTopViewNotification @"OCMDidTapPhotosTopViewNotification"

@protocol OCMPhotoCoverDelegate <NSObject>

- (void)touchMoved:(NSValue *)moved inView:(UIView *)view;
- (void)touchEnded:(NSValue *)moved inView:(UIView *)view;

@end

@interface OCMPhotoCover : UIView

@property (nonatomic) CGPoint touchBeginPosition;
@property (nonatomic, strong) id<OCMPhotoCoverDelegate> delegate; // strong delegate
@property (nonatomic) CGPoint lastMoved;

@end

@interface OCMPhotosVC : UICollectionViewController

@property (nonatomic, strong) NSURL *albumURL;
@property (nonatomic, copy) NSString *albumName;

@end
