//
//  OCMSharePhotoVC.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/21.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMSharePhotoVC.h"
#import "OCMDefinitions.h"
#import "UIImage+OCMAdditions.h"

@interface OCMSharePhotoVC ()

@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *preview;
@property (nonatomic, weak) UIButton *copiURLButton;
@property (nonatomic, weak) UIButton *saveButton;
@property (nonatomic, weak) UIButton *cameraButton;
@property (nonatomic, weak) UIButton *cameraRollButton;
@property (nonatomic, weak) UIActivityIndicatorView *spinner;


@end

@implementation OCMSharePhotoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *backButton = [[UIButton alloc] init];
    [self.view addSubview:backButton];
    self.backButton = backButton;
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageWithName:@"ArrowLeft"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = LocalStr(@"Save & Share");
    [titleLabel sizeToFit];
    
    UIImageView *preview = [[UIImageView alloc] initWithImage:self.photo];
    self.preview = preview;
    [self.view addSubview:preview];
    preview.size = ccs(self.view.width, self.view.width);
    preview.contentMode = UIViewContentModeScaleAspectFit;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] init];
    self.spinner = spinner;
    [self.view addSubview:spinner];
    
    UIButton *copyURLButton = [[UIButton alloc] init];
    self.copiURLButton = copyURLButton;
    [self.view addSubview:copyURLButton];
    [copyURLButton setTitle:LocalStr(@"Sending to Sina Weibo") forState:UIControlStateDisabled];
    [copyURLButton setTitle:LocalStr(@"Copy Image URL") forState:UIControlStateNormal];
    [copyURLButton addTarget:self action:@selector(shareButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    copyURLButton.enabled = NO;
    [copyURLButton sizeToFit];
    copyURLButton.hidden = YES;
    
    UIButton *saveButton = [[UIButton alloc] init];
    self.saveButton = saveButton;
    [self.view addSubview:saveButton];
    [saveButton setTitle:LocalStr(@"Save") forState:UIControlStateNormal];
    [saveButton setTitle:LocalStr(@"Saved") forState:UIControlStateDisabled];
    saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    saveButton.backgroundColor = rgb(226, 66, 80);
    [saveButton addTarget:self action:@selector(saveButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cameraButton = [[UIButton alloc] init];
    self.cameraButton = cameraButton;
    [self.view addSubview:cameraButton];
    [cameraButton setImage:[UIImage imageWithName:@"Camera"] forState:UIControlStateNormal];
    cameraButton.backgroundColor = bw(45);
    [cameraButton addTarget:self action:@selector(cameraButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cameraRollButton = [[UIButton alloc] init];
    self.cameraRollButton = cameraRollButton;
    [self.view addSubview:cameraRollButton];
    [cameraRollButton setImage:[UIImage imageWithName:@"CameraRoll"] forState:UIControlStateNormal];
    cameraRollButton.backgroundColor = bw(45);
    [cameraRollButton addTarget:self action:@selector(cameraRollButtonTouched) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self.spinner startAnimating];
}

- (void)viewDidLayoutSubviews
{
    CGFloat topHeight = 64;
    self.preview.top = topHeight;
    self.backButton.center = ccp(topHeight/2, topHeight/2);
    self.titleLabel.center = ccp(self.view.width/2, topHeight/2);
    
    CGFloat buttonHeight = (self.view.height - topHeight - self.preview.height) / (Screen4Inch ? 2 : 1);
    
    self.copiURLButton.center = ccp(self.view.width/2 + self.spinner.width/2 + 5, self.preview.bottom+buttonHeight/2);
    self.spinner.leftCenter = ccp(self.copiURLButton.left-self.spinner.width-10, self.copiURLButton.center.y);
    
    self.saveButton.frame = ccr(0, self.view.height-buttonHeight, self.view.width/3, buttonHeight);
    self.cameraButton.frame = ccr(self.saveButton.right, self.view.height-buttonHeight, self.view.width/3, buttonHeight);
    self.cameraRollButton.frame = ccr(self.cameraButton.right, self.view.height-buttonHeight, self.view.width/3, buttonHeight);
    
    [super viewDidLayoutSubviews];
}

- (void)weiboSent
{
    [self.spinner stopAnimating];
    self.copiURLButton.enabled = YES;
    [self.copiURLButton sizeToFit];
}

- (void)shareButtonTouched
{
    
}

- (void)saveButtonTouched
{
    UIImageWriteToSavedPhotosAlbum(self.photo, nil, nil, nil);
    self.saveButton.enabled = NO;
    self.saveButton.backgroundColor = bw(45);
}

- (void)cameraButtonTouched
{
    UIViewController *cameraVC = self.navigationController.viewControllers[0];
    self.navigationController.viewControllers = @[self.navigationController.viewControllers.lastObject];
    [self.navigationController pushViewController:cameraVC animated:YES];
    self.navigationController.viewControllers = @[cameraVC];
}

- (void)cameraRollButtonTouched
{
    UIViewController *cameraRollVC = self.navigationController.viewControllers[1];
    self.navigationController.viewControllers = @[self.navigationController.viewControllers.lastObject];
    [self.navigationController pushViewController:cameraRollVC animated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
