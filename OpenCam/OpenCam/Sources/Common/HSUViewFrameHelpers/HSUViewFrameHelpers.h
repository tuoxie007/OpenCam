//
//  UIView+Addition.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/24/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ccr(x, y, w, h) CGRectMake(floorf(x), floorf(y), floorf(w), floorf(h))
#define ccp(x, y) CGPointMake(floorf(x), floorf(y))
#define ccs(w, h) CGSizeMake(floorf(w), floorf(h))
#define edi(top, left, bottom, right) UIEdgeInsetsMake(floorf(top), floorf(left), floorf(bottom), floorf(right))

#define WinSize [UIScreen mainScreen].bounds.size

@interface UIView (HSUFrameHelpers)

@property (nonatomic, readwrite) CGFloat left, right, top, bottom, width, height;
@property (nonatomic, readwrite) CGPoint topCenter, bottomCenter, leftCenter, rightCenter;
@property (nonatomic, readwrite) CGPoint leftTop, leftBottom, rightTop, rightBottom;
@property (nonatomic, readonly) CGPoint boundsCenter;
@property (nonatomic, readwrite) CGSize size;
@property (nonatomic, readonly) CGFloat largerSize; // max of width & height
@property (nonatomic, readonly) CGFloat aspectRatio; // width / height


- (NSString *)frameStr;

@end
