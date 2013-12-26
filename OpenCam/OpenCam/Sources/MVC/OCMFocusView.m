//
//  OCMFocusView.m
//  OpenCam
//
//  Created by Jason Hsu on 11/3/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "OCMFocusView.h"
#import "OCMDefinitions.h"
#import "UIImage+OCMAdditions.h"

@interface OCMFocusView ()

@property (nonatomic, strong) UIImage *crossImage;
@property (nonatomic, assign) float boundWidth;
@property (nonatomic, assign) float addBoundWidth;

@end

@implementation OCMFocusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:.025 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.boundWidth == 0) {
        self.boundWidth = 3;
    }
    
    if (!self.crossImage) {
        self.crossImage = [UIImage imageWithName:@"Focus"];
    }
    
    CGSize crossImageSize = self.crossImage.size;
    
    [self.crossImage drawInRect:ccr(rect.size.width/2-crossImageSize.width/2,
                                    rect.size.height/2-crossImageSize.height/2,
                                    crossImageSize.width,
                                    crossImageSize.height)];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextSetLineWidth(context, 3);
    
    CGContextAddEllipseInRect(context, ccr(self.boundWidth,
                                           self.boundWidth,
                                           rect.size.width-self.boundWidth*2,
                                           rect.size.height-self.boundWidth*2));
    CGContextStrokePath(context);
    
    if (self.boundWidth >= 8) {
        self.addBoundWidth = -.5;
    } else if (self.boundWidth <= 3) {
        self.addBoundWidth = .5;
    }
    self.boundWidth += self.addBoundWidth;
}

@end
