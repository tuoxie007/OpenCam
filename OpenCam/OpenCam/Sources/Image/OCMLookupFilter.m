//
//  OCMCoyoteFilter.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/12.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMLookupFilter.h"
#import "OCMGPUImageLookupFilter.h"
#import "OCMGPUImageWBLookupFilter.h"
#import "UIImage+OCMAdditions.h"

@implementation OCMLookupFilter

- (instancetype)initWithName:(NSString *)name isWhiteAndBlack:(BOOL)isWhiteAndBlack
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    UIImage *image = [UIImage imageWithName:[NSString stringWithFormat:@"lookup_%@", [name lowercaseString]]];
    
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    if (isWhiteAndBlack) {
        lookupFilter = [[OCMGPUImageWBLookupFilter alloc] init];
    } else {
        lookupFilter = [[OCMGPUImageLookupFilter alloc] init];
    }
    [self addFilter:lookupFilter];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    
    return self;
}

-(void)prepareForImageCapture {
    [lookupImageSource processImage];
    [super prepareForImageCapture];
}

#pragma mark -
#pragma mark Accessors
- (CGFloat)level
{
    return lookupFilter.level;
}

- (void)setLevel:(CGFloat)level
{
    lookupFilter.level = level;
    [lookupImageSource processImage];
}

- (NSArray *)targets
{
    return lookupFilter.targets;
}

@end