//
//  OpenCam.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/24.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMDefinitions.h"
#import "OCMCameraViewController.h"

@interface OpenCam : NSObject

+ (OCMCameraViewController *)cameraViewController;
+ (NSString *)localizedString:(NSString *)key;

@end
