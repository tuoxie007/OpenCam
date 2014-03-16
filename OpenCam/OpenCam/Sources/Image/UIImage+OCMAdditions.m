//
//  UIImage+OCMAdditions.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/10.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "UIImage+OCMAdditions.h"
#import "OCMDefinitions.h"

@implementation UIImage (OCMAdditions)

- (UIImage *)subImageAtRect:(CGRect)rect
{
    rect = ccr(rect.origin.x*self.scale, rect.origin.y*self.scale, rect.size.width*self.scale, rect.size.height*self.scale);
    if (rect.size.width >= self.size.width && rect.size.height >= self.size.height) {
        return self;
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage* subImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return subImage;
}

- (UIImage*)scaleToWidth:(CGFloat)width force:(BOOL)force
{
    if (!force && width >= self.size.width) {
        return self;
    }
    CGSize newSize;
    newSize.width = width;
    newSize.height = self.size.height/self.size.width*newSize.width;
    
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, floorf(newSize.width)+1, floorf(newSize.height)+1)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage*)scaleToHeight:(CGFloat)height force:(BOOL)force
{
    if (!force && height >= self.size.height) {
        return self;
    }
    CGSize newSize;
    newSize.height = height;
    newSize.width = self.size.width/self.size.height*newSize.height;
    
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, floorf(newSize.width)+1, floorf(newSize.height)+1)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)imageRotatedToUp
{
    CGFloat maxSide = MAX(self.size.width, self.size.height);
    return [self imageRotatedToUpWithMaxWidth:maxSide maxHeight:maxSide];
}

- (UIImage *)imageRotatedToUpWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    if (self.imageOrientation == UIImageOrientationUp && self.size.width <= maxWidth && self.size.height <= maxHeight) {
        return self;
    }
    
    CGImageRef imgRef = self.CGImage;
    if (imgRef == NULL) {
        return [self imageRotatedToUpWithCIImageWithMaxWidth:maxWidth maxHeight:maxHeight];
    }
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    if (maxWidth == 0) {
        maxWidth = width;
    }
    if (maxHeight == 0) {
        maxHeight = height;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > maxWidth || height > maxHeight) {
        CGFloat ratio = width/height;
        if (ratio > maxWidth / maxHeight) {
            bounds.size.width = maxWidth;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxHeight;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage *)imageRotatedToUpWithCIImageWithMaxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGSize imageSize = self.CIImage.extent.size;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    return [UIImage imageWithCIImage:[self.CIImage imageByApplyingTransform:transform]];
}

- (CGFloat)largerSize
{
    return MAX(self.size.width, self.size.height);
}

- (CGFloat)aspectRatio
{
    return self.size.width / self.size.height;
}

- (UIImage *)stretchableImageFromCenter
{
    return [self stretchableImageWithLeftCapWidth:self.size.width/2 topCapHeight:self.size.height/2];
}

+ (UIImage *)imageWithName:(NSString *)imageName
{
    UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"OpenCam.bundle/Contents/Resources/%@", imageName]];
    if (img) {
        return img;
    }
    img = [UIImage imageNamed:[NSString stringWithFormat:@"OpenCam.bundle/Contents/Resources/icon_%@", imageName]];
    if (img) {
        return img;
    }
    return [UIImage imageNamed:imageName];
}

@end
