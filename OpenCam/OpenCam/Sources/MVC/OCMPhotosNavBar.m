//
//  OCMPhotosNavigationBar.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/4.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMPhotosNavBar.h"
#import "OCMDefinitions.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
#import <QuartzCore/QuartzCore.h>
#endif
#import "UIImage+OCMAdditions.h"

@implementation OCMPhotosNavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *backButton = [[UIButton alloc] init];
        self.backButton = backButton;
        [self addSubview:backButton];
        backButton.layer.cornerRadius = 3;
        backButton.clipsToBounds = YES;
        backButton.backgroundColor = [UIColor colorWithWhite:1 alpha:.1];
        [backButton setImage:[UIImage imageWithName:@"ArrowLeft"] forState:UIControlStateNormal];
        [backButton sizeToFit];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        self.titleLabel = titleLabel;
        [self addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [titleLabel sizeToFit];
        
        self.backButton.size = ccs(50, 50);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backButton.leftCenter = ccp(15, self.height - 40);
    self.titleLabel.center = ccp(self.width/2, self.height - 40);
}

@end
