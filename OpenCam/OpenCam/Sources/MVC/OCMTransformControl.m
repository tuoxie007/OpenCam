//
//  OCMTransformControl.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/20.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMTransformControl.h"
#import "UIImage+OCMAdditions.h"
#import "OCMDefinitions.h"

@implementation OCMTransformControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *closeButton = [[UIButton alloc] init];
        self.closeButton = closeButton;
        [self addSubview:closeButton];
        [closeButton setImage:[UIImage imageWithName:@"Cross"] forState:UIControlStateNormal];
        [closeButton sizeToFit];
        
        UIButton *applyButton = [[UIButton alloc] init];
        self.applyButton = applyButton;
        [self addSubview:applyButton];
        [applyButton setImage:[UIImage imageWithName:@"Tick"] forState:UIControlStateNormal];
        [applyButton sizeToFit];
        
        UIButton *rotateButton = [[UIButton alloc] init];
        self.rotateButton = rotateButton;
        [self addSubview:rotateButton];
        [rotateButton setImage:[UIImage imageWithName:@"Rotate"] forState:UIControlStateNormal];
        [rotateButton sizeToFit];
        
        UIButton *flipYButton = [[UIButton alloc] init];
        self.flipYButton = flipYButton;
        [self addSubview:flipYButton];
        [flipYButton setImage:[UIImage imageWithName:@"FlipY"] forState:UIControlStateNormal];
        [flipYButton sizeToFit];
        
        UIButton *flipXButton = [[UIButton alloc] init];
        self.flipXButton = flipXButton;
        [self addSubview:flipXButton];
        [flipXButton setImage:[UIImage imageWithName:@"FlipX"] forState:UIControlStateNormal];
        [flipXButton sizeToFit];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat paddingLeft = 39;
    CGFloat distance = (self.width - paddingLeft * 2) / 4;
    CGFloat baseline = self.height / 2;
    self.closeButton.center = ccp(paddingLeft, baseline);
    self.rotateButton.center = ccp(paddingLeft + distance, baseline);
    self.flipYButton.center = ccp(paddingLeft + distance * 2, baseline);
    self.flipXButton.center = ccp(paddingLeft + distance * 3, baseline);
    self.applyButton.center = ccp(paddingLeft + distance * 4, baseline);
    
    [super layoutSubviews];
}

@end
