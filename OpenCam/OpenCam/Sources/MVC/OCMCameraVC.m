//
//  OCMCameraVC.m
//  OpenCam
//
//  Created by Jason Hsu on 11/3/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "OCMCameraVC.h"
#import <GPUImage/GPUImage.h>
#import "OCMFocusView.h"
#import "OCMSelectPhotoVC.h"
#import "OCMDefinitions.h"
#import "OCMCameraViewController.h"
#import "UIImage+OCMAdditions.h"

@interface OCMCameraVC ()

@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, weak) GPUImageView *preview;
@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UIButton *toggleFlashButton;
@property (nonatomic, weak) UIButton *rotateCameraButton;
@property (nonatomic, weak) UIButton *settingsButton;
@property (nonatomic, weak) UIButton *cameraButton;
@property (nonatomic, weak) UIButton *cameraRollButton;
@property (nonatomic, weak) OCMFocusView *focusView;

@property (nonatomic, assign) BOOL waitingForFocus;

@end

@implementation OCMCameraVC

- (void)dealloc
{
    AVCaptureDevice *device = self.camera.inputCamera;
    [device removeObserver:self forKeyPath:@"adjustingFocus"];
    [device removeObserver:self forKeyPath:@"adjustingExposure"];
    [device removeObserver:self forKeyPath:@"adjustingWhiteBalance"];
    [self.camera stopCameraCapture];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor blackColor];
    
    GPUImageView *preview = [[GPUImageView alloc] init];
    self.preview = preview;
    [self.view addSubview:preview];
    preview.size = ccs(self.view.width, self.view.width * 4 / 3);
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focus:)];
    [preview addGestureRecognizer:tapGesture];
    
    UIButton *closeButton = [[UIButton alloc] init];
    self.closeButton = closeButton;
    [self.view addSubview:closeButton];
    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageWithName:@"Cross"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    closeButton.hidden = YES;
    
    UIButton *toggleFlashButton = [[UIButton alloc] init];
    self.toggleFlashButton = toggleFlashButton;
    [self.view addSubview:toggleFlashButton];
    [toggleFlashButton addTarget:self action:@selector(toggleFlash) forControlEvents:UIControlEventTouchUpInside];
    [toggleFlashButton setImage:[UIImage imageWithName:@"FlashOff"] forState:UIControlStateNormal];
    [toggleFlashButton setImage:[UIImage imageWithName:@"FlashOn"] forState:UIControlStateSelected];
    [toggleFlashButton sizeToFit];
    toggleFlashButton.hidden = YES;
    
    UIButton *rotateCameraButton = [[UIButton alloc] init];
    self.rotateCameraButton = rotateCameraButton;
    [self.view addSubview:rotateCameraButton];
    [rotateCameraButton addTarget:self action:@selector(rotateCamera) forControlEvents:UIControlEventTouchUpInside];
    [rotateCameraButton setImage:[UIImage imageWithName:@"RotateCamera"] forState:UIControlStateNormal];
    [rotateCameraButton sizeToFit];
    rotateCameraButton.hidden = YES;
    
    UIButton *settingsButton = [[UIButton alloc] init];
    self.settingsButton = settingsButton;
    [self.view addSubview:settingsButton];
    [settingsButton setImage:[UIImage imageWithName:@"Settings"] forState:UIControlStateNormal];
    [settingsButton sizeToFit];
    
    UIButton *captureButton = [[UIButton alloc] init];
    self.cameraButton = captureButton;
    [self.view addSubview:captureButton];
    [captureButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [captureButton setImage:[UIImage imageWithName:@"Camera"] forState:UIControlStateNormal];
    [captureButton sizeToFit];
    
    UIButton *cameraRollButton = [[UIButton alloc] init];
    self.cameraRollButton = cameraRollButton;
    [self.view addSubview:cameraRollButton];
    [cameraRollButton addTarget:self action:@selector(cameraRoll) forControlEvents:UIControlEventTouchUpInside];
    [cameraRollButton setImage:[UIImage imageWithName:@"CameraRoll"] forState:UIControlStateNormal];
    [cameraRollButton sizeToFit];
    
    // Setup Camera
    AVCaptureDevicePosition defaultPosition = AVCaptureDevicePositionFront;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            defaultPosition = AVCaptureDevicePositionBack;
        }
    }
    if (devices.count == 0) {
//        @throw [[NSException alloc] init];
    } else if (devices.count == 1) {
        rotateCameraButton.hidden = YES;
    }
    GPUImageStillCamera *camera = [[GPUImageStillCamera alloc]
                                   initWithSessionPreset:AVCaptureSessionPreset640x480
                                   cameraPosition:defaultPosition];
    self.camera = camera;
    camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    AVCaptureDevice *device = camera.inputCamera;
    if ([device lockForConfiguration:nil]) {
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        }
        if ([device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            device.flashMode = AVCaptureFlashModeOff;
        }
        [device unlockForConfiguration];
    }
    [device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
    [device addObserver:self forKeyPath:@"adjustingWhiteBalance" options:NSKeyValueObservingOptionNew context:nil];
    
    GPUImageFilter *noneFilter = [[GPUImageFilter alloc] init];
    [camera addTarget:noneFilter];
    [noneFilter addTarget:preview];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.camera startCameraCapture];
    [self.camera resumeCameraCapture];
    
    if (self.presentingViewController) {
        self.closeButton.hidden = NO;
    }
    if (self.camera.inputCamera.hasFlash) {
        self.toggleFlashButton.hidden = NO;
    }
    if ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 1) {
        self.rotateCameraButton.hidden = NO;
    }
    
    [self.view setNeedsLayout];
    
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    float topHeight = 64;
    if (Screen4Inch) {
        self.preview.top = topHeight;
    } else {
        self.preview.top = 0;
    }
    float bottomHeight = self.view.height - self.preview.bottom;
    self.closeButton.center = ccp(topHeight/2, topHeight/2);
    if (self.closeButton.hidden) {
        self.toggleFlashButton.center = ccp(topHeight/2, topHeight/2);
    } else {
        self.toggleFlashButton.center = ccp(self.view.width-topHeight*1.5, topHeight/2);
    }
    self.rotateCameraButton.center = ccp(self.view.width-topHeight/2, self.toggleFlashButton.center.y);
    self.settingsButton.center = ccp(bottomHeight/2, self.view.height-bottomHeight/2);
    if (self.settingsButton.bottom > self.view.height) {
        self.settingsButton.bottom = self.view.height;
    }
    if (self.settingsButton.left < 0) {
        self.settingsButton.left = 0;
    }
    self.cameraButton.center = ccp(self.view.width/2, self.settingsButton.center.y);
    self.cameraRollButton.center = ccp(self.view.width-bottomHeight/2, self.cameraButton.center.y);
    if (self.cameraRollButton.right > self.view.width) {
        self.cameraRollButton.right = self.view.width;
    }
    
    [super viewDidLayoutSubviews];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.camera pauseCameraCapture];
    
    [super viewDidDisappear:animated];
}

- (void)toggleFlash
{
    NSError *error = nil;
    if ([self.camera.inputCamera lockForConfiguration:&error]) {
        if (self.toggleFlashButton.selected) {
            self.camera.inputCamera.flashMode = AVCaptureFlashModeOff;
            self.toggleFlashButton.selected = NO;
        } else {
            self.camera.inputCamera.flashMode = AVCaptureFlashModeOn;
            self.toggleFlashButton.selected = YES;
        }
    }
}

- (void)rotateCamera
{
    [self.camera rotateCamera];
}

- (void)capture
{
    [self.camera pauseCameraCapture];
    __weak typeof(self)weakSelf = self;
    [self.camera capturePhotoAsImageProcessedUpToFilter:self.camera.targets.lastObject
                                  withCompletionHandler:^(UIImage *processedImage, NSError *error)
    {
        UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil);
        [weakSelf.camera resumeCameraCapture];
    }];
}

- (void)cameraRoll
{
    OCMSelectPhotoVC *selectPhotoVC = [[OCMSelectPhotoVC alloc] init];
    [self.navigationController pushViewController:selectPhotoVC animated:YES];
}

- (void)focus:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:self.preview];
    CGPoint landPoint = CGPointMake(tapPoint.y/self.preview.height, 1 - tapPoint.x/self.preview.width);
    
    AVCaptureDevice *device = self.camera.inputCamera;
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported]) {
            self.waitingForFocus = YES;
            device.focusPointOfInterest = landPoint;
        }
        if ([device isExposurePointOfInterestSupported]) {
            self.waitingForFocus = YES;
            device.exposurePointOfInterest = landPoint;
        }
        if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            device.focusMode = AVCaptureFocusModeAutoFocus;
        }
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        [device unlockForConfiguration];
    }
    
    [self.focusView removeFromSuperview];
    OCMFocusView *focusView = [[OCMFocusView alloc] initWithFrame:ccr(0, 0, 85, 85)];
    [self.preview addSubview:focusView];
    focusView.center = tapPoint;
    self.focusView = focusView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.camera.inputCamera) {
        if ([keyPath isEqualToString:@"adjustingFocus"] ||
            [keyPath isEqualToString:@"adjustingExposure"] ||
            [keyPath isEqualToString:@"adjustingWhiteBalance"]) {
            
            if (!self.camera.inputCamera.adjustingFocus &&
                !self.camera.inputCamera.adjustingExposure &&
                !self.camera.inputCamera.adjustingWhiteBalance) {
                
                if (self.waitingForFocus) {
                    self.waitingForFocus = NO;
                } else {
                    [self.focusView removeFromSuperview];
                }
            }
        }
    }
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
    OCMCameraViewController *nav = (OCMCameraViewController *)self.navigationController;
    nav.photo = nil;
    [nav.delegate cameraViewControllerDidFinish:nav];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
