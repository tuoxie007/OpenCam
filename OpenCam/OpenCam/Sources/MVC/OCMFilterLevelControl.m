//
//  OCMFilterLevelControl.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/12.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMFilterLevelControl.h"
#import "UIImage+OCMAdditions.h"
#import "OCMDefinitions.h"

@implementation OCMFilterLevelControl

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
        
        UISlider *levelSlider = [[UISlider alloc] init];
        self.levelSlider = levelSlider;
        [self addSubview:levelSlider];
        [levelSlider setMinimumTrackImage:[[UIImage imageWithName:@"SliderMinimumTrack"] stretchableImageFromCenter]
                                 forState:UIControlStateNormal];
        [levelSlider setMaximumTrackImage:[[UIImage imageWithName:@"SliderMaximumTrack"] stretchableImageFromCenter]
                                 forState:UIControlStateNormal];
        [levelSlider setThumbImage:[UIImage imageWithName:@"SliderThumb"] forState:UIControlStateNormal];
        [levelSlider sizeToFit];
        levelSlider.value = 1;
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat paddingLeft = 39;
    self.closeButton.center = ccp(paddingLeft, self.height/2);
    self.applyButton.center = ccp(self.width-paddingLeft, self.height/2);
    self.levelSlider.width = self.width - paddingLeft * 4;
    self.levelSlider.center = self.boundsCenter;
    
    [super layoutSubviews];
}

@end
