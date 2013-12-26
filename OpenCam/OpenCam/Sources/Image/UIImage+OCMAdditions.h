//
//  UIImage+OCMAdditions.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/10.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (OCMAdditions)

- (UIImage *)subImageAtRect:(CGRect)rect;
- (UIImage *)imageRotatedToUp;
- (UIImage *)imageRotatedToUpWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
- (CGFloat)largerSize; // max of width & height
- (CGFloat)aspectRatio; // width / height
- (UIImage *)stretchableImageFromCenter;
+ (UIImage *)imageWithName:(NSString *)imageName;

@end
