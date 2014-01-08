//
//  OCMDefinitions.h
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/11.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#ifndef OpenCam_OCMDefinitions_h
#define OpenCam_OCMDefinitions_h

#import "HSUViewFrameHelpers.h"
#import "OpenCam.h"

#ifndef LocalStr
#define LocalStr(s) [OpenCam localizedString:s]
#endif

#ifndef rgb
#define rgb(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]
#endif

#ifndef bw
#define bw(w) [UIColor colorWithWhite:w/255.0f alpha:1]
#endif

#ifndef Screen4Inch
#define Screen4Inch ([[UIScreen mainScreen] bounds].size.height == 568)
#endif

#ifndef iPad
#define iPad ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#endif

#endif
