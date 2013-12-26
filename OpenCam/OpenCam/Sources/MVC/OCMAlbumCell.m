//
//  OCMAlbumCell.m
//  OpenCam
//
//  Created by Jason Hsu on 11/5/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "OCMAlbumCell.h"
#import "OCMDefinitions.h"
#import "UIImage+OCMAdditions.h"

@implementation OCMAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.highlightedTextColor = [UIColor darkGrayColor];
        
        UIButton *accessoryButton = [[UIButton alloc] init];
        self.accessoryView = accessoryButton;
        [accessoryButton setImage:[UIImage imageWithName:@"ArrowRight"] forState:UIControlStateNormal];
        [accessoryButton sizeToFit];
    }
    return self;
}

+ (CGFloat)height
{
    return 75;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.textLabel.highlighted = highlighted;
    ((UIButton *)self.accessoryView).highlighted = highlighted;
    
    [super setHighlighted:highlighted animated:animated];
}

@end
