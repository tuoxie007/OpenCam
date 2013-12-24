//
//  OCMBorderFilter.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/18.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface OCMBorderFilter : GPUImageTwoInputFilter
{
    GPUImagePicture *framePicture;
}

@property (nonatomic, readwrite) UIImage *borderImage;

@end
