//
//  OCMPhotoCell.m
//  OpenCam
//
//  Created by Jason Hsu on 11/5/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "OCMPhotoCell.h"
#import "OCMDefinitions.h"
#import "UIImage+OCMAdditions.h"

@implementation OCMPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *photoView = [[UIImageView alloc] init];
        [self.contentView addSubview:photoView];
        photoView.contentMode = UIViewContentModeScaleToFill;
        photoView.frame = self.bounds;
        self.photoView = photoView;
        
        UIView *selectionView = [[UIView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:selectionView];
        self.selectionView = selectionView;
        selectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
        
        UIImageView *tickView = [[UIImageView alloc] init];
        [self.selectionView addSubview:tickView];
        tickView.image = [UIImage imageWithName:@"CircleTick"];
        [tickView sizeToFit];
        tickView.center = selectionView.boundsCenter;
        
        selectionView.hidden = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.selectionView.hidden = !selected;
}

@end
