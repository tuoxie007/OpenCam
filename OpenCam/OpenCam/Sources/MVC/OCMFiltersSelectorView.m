//
//  OCMFiltersSelectorView.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/10.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMFiltersSelectorView.h"
#import "OCMDefinitions.h"
#import "UIImage+OCMAdditions.h"

#define Size (Screen4Inch ? 92 : (iPad ? 96 : 55))

@interface OCMFiltersSelectorView ()

@property (nonatomic, strong) NSArray *buttonMetas;
@property (nonatomic, weak) UIButton *currentButton;

@end

@implementation OCMFiltersSelectorView

- (instancetype)initWithButtonMetas:(NSArray *)buttonMetas
{
    self = [super initWithFrame:ccr(0, 0, WinSize.width, Size)];
    if (self) {
        for (int i=0; i<buttonMetas.count; i++) {
            NSDictionary *buttonMeta = buttonMetas[i];
            UIColor *backgroundColor = buttonMeta[OCMMetaKeyBackgroundColor];
            NSString *title = LocalStr(buttonMeta[OCMMetaKeyTitle]);
            if ([buttonMeta[OCMMetaKeyType] hasSuffix:@"lookup"]) {
                title = nil;
            }
            NSString *iconName = buttonMeta[OCMMetaKeyIconName];
            NSString *iconNameSelected = buttonMeta[OCMMetaKeyIconNameSelected];
            
            UIButton *button = [[UIButton alloc] init];
            button.tag = i;
            [button addTarget:self action:@selector(filterButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            
            button.backgroundColor = backgroundColor;
            if (title.length) {
                [button setTitle:title forState:UIControlStateNormal];
            }
            if (iconName) {
                UIImage *icon = [UIImage imageWithName:iconName];
                if (!Screen4Inch) {
                    icon = [UIImage imageWithCGImage:icon.CGImage scale:icon.scale*92/55 orientation:UIImageOrientationUp];
                }
                [button setImage:icon forState:UIControlStateNormal];
            }
            if (iconNameSelected) {
                UIImage *icon = [UIImage imageWithName:iconNameSelected];
                if (!Screen4Inch) {
                    icon = [UIImage imageWithCGImage:icon.CGImage scale:icon.scale*sqrtf(92/55) orientation:UIImageOrientationUp];
                }
                [button setImage:icon forState:UIControlStateSelected];
            }
            
            button.frame = ccr(i*Size, 0, Size, Size);
            button.titleLabel.font = [UIFont boldSystemFontOfSize:Screen4Inch?14:10];
            
            CGSize titleSize;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            if ([title respondsToSelector:@selector(sizeWithAttributes:)]) {
                titleSize = [title sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
            } else {
                titleSize = [title sizeWithFont:button.titleLabel.font];
            }
#else
            titleSize = [title sizeWithFont:button.titleLabel.font];
#endif
            CGSize imageSize = [button imageForState:UIControlStateNormal].size;
            if (title.length) {
                button.imageEdgeInsets = edi(0, 0, titleSize.height+14, -titleSize.width);
            }
            if (iconName) {
                button.titleEdgeInsets = edi(button.height-(titleSize.height+14), -imageSize.width, 0, 0);
            }
            
            [self addSubview:button];
            
            if ([buttonMeta[OCMMetaKeySelected] boolValue]) {
                __weak typeof(self)weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf filterButtonTouched:button];
                });
            }
        }
        self.contentSize = ccs(buttonMetas.count * Size, Size);
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.buttonMetas = buttonMetas;
    }
    return self;
}

- (void)filterButtonTouched:(UIButton *)sender
{
    if (self.currentButton == sender) {
        return;
    }
    
    sender.selected = YES;
    sender.backgroundColor = self.buttonMetas[sender.tag][OCMMetaKeyBackgroundColorSelected];
    [self adjustEdgeInsetsForButton:sender forState:UIControlStateSelected];
    
    if (self.currentButton) {
        self.currentButton.selected = NO;
        self.currentButton.backgroundColor = self.buttonMetas[self.currentButton.tag][OCMMetaKeyBackgroundColor];
        [self adjustEdgeInsetsForButton:self.currentButton forState:UIControlStateNormal];
    }
    
    [self.delegate filterButtonTouched:sender withMetadata:self.buttonMetas[sender.tag]];
    
    self.currentButton = sender;
}

- (void)adjustEdgeInsetsForButton:(UIButton *)button forState:(UIControlState)state
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    CGSize titleSize;
    if ([[button titleForState:state] respondsToSelector:@selector(sizeWithAttributes:)]) {
        titleSize = [[button titleForState:state] sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    } else {
        titleSize = [[button titleForState:state] sizeWithFont:button.titleLabel.font];
    }
#else
    CGSize titleSize = [[button titleForState:state] sizeWithFont:button.titleLabel.font];
#endif
    CGSize imageSize = [button imageForState:state].size;
    if ([button titleForState:state].length) {
        button.imageEdgeInsets = edi(0, 0, titleSize.height+14, -titleSize.width);
    }
    if ([button imageForState:state]) {
        button.titleEdgeInsets = edi(button.height-(titleSize.height+14), -imageSize.width, 0, 0);
    }
}

- (void)reset
{
    self.currentButton.selected = NO;
    self.currentButton.backgroundColor = self.buttonMetas[self.currentButton.tag][OCMMetaKeyBackgroundColor];
    self.currentButton = nil;
}

@end
