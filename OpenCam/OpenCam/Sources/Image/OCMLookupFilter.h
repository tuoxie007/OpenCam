//
//  OCMCoyoteFilter.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/12.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@class OCMGPUImageLookupFilter;
@interface OCMLookupFilter : GPUImageFilterGroup
{
    GPUImagePicture *lookupImageSource;
    OCMGPUImageLookupFilter *lookupFilter;
}

@property (nonatomic, readwrite) CGFloat level;

- (instancetype)initWithName:(NSString *)name isWhiteAndBlack:(BOOL)isWhiteAndBlack;

@end
