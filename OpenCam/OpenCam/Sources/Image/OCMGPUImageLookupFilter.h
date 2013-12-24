//
//  OCMGPUImageLookupFilter.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/12.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface OCMGPUImageLookupFilter : GPUImageLookupFilter
{
    GLint levelUniform;
    CGFloat _level;
}

@property(readwrite, nonatomic) CGFloat level;

@end
