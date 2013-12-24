//
//  OCMBorderFilter.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/18.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMBorderFilter.h"

NSString *const kOCMBorderShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
	 lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
	 lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
     lowp vec4 mixedColor = mix(textureColor, textureColor2, textureColor2.a);
     
	 gl_FragColor = vec4(mixedColor.rgb, 1.0);
 }
 );


@implementation OCMBorderFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kOCMBorderShaderString]))
    {
		return nil;
    }
    
    return self;
}

- (void)setBorderImage:(UIImage *)borderImage
{
    framePicture = [[GPUImagePicture alloc] initWithImage:borderImage];
    [framePicture addTarget:self atTextureLocation:1];
    [framePicture processImage];
}

- (UIImage *)borderImage
{
    return framePicture.imageFromCurrentlyProcessedOutput;
}

@end
