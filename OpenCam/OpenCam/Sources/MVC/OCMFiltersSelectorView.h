//
//  OCMFiltersSelectorView.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/10.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OCMMetaKeyBackgroundColor @"background_color"
#define OCMMetaKeyBackgroundColorSelected @"background_color_selected"
#define OCMMetaKeyTitle @"title"
#define OCMMetaKeyIconName @"icon_name"
#define OCMMetaKeyIconNameSelected @"icon_name_selected"
#define OCMMetaKeyType @"type"
#define OCMMetaKeyLevel @"level"
#define OCMMetaKeyLevelMin @"level_min"
#define OCMMetaKeyLevelMax @"level_max"
#define OCMMetaKeySelected @"selected"
#define OCMMetaKeyRotate @"rotate"
#define OCMMetaKeyFlip @"flip"

@protocol OCMFiltersSelectorViewDelegate <NSObject>

- (void)filterButtonTouched:(UIButton *)filterButton withMetadata:(NSDictionary *)metadata;

@end

@interface OCMFiltersSelectorView : UIScrollView

@property (nonatomic, weak) id<OCMFiltersSelectorViewDelegate, UIScrollViewDelegate> delegate;

- (instancetype)initWithButtonMetas:(NSArray *)buttonMetas;
- (void)reset;

@end
