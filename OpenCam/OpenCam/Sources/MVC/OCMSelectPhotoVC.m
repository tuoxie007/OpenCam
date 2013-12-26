//
//  OCMSelectPhotoVC.m
//  OpenCam
//
//  Created by Jason Hsu on 11/5/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "OCMSelectPhotoVC.h"
#import "OCMAlbumsVC.h"
#import "OCMPhotosVC.h"
#import <ImageIO/ImageIO.h>
#import "OCMEditPhotoVC.h"
#import "UIImage+OCMAdditions.h"
#import "OCMDefinitions.h"
#import "OCMCameraViewController.h"

@interface OCMSelectPhotoVC () <UIScrollViewDelegate>

@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *nextButton;
@property (nonatomic, weak) UIScrollView *previewAreaView;
@property (nonatomic, weak) UIImageView *preview;
@property (nonatomic) BOOL sourceImageChanged;
@property (nonatomic) CGSize sourceImageSize;

@property (nonatomic, weak) UINavigationController *albumVC;

@end

@implementation OCMSelectPhotoVC

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(photoSelected:)
     name:OCMDidSelectPhotoNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(firstPhotoLoaded:)
     name:OCMDidLoadFirstPhotoNotification
     object:nil];
    
    self.view.backgroundColor = [UIColor colorWithWhite:38/255 alpha:1];
    
    UIView *selectPhotoView = [[UIView alloc] init];
    selectPhotoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:selectPhotoView];
    self.selectPhotoView = selectPhotoView;
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTop:)];
    [selectPhotoView addGestureRecognizer:tapGesture];
    
    UIButton *backButton = [[UIButton alloc] init];
    [selectPhotoView addSubview:backButton];
    self.backButton = backButton;
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageWithName:@"CameraSmall"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [selectPhotoView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = LocalStr(@"Crop");
    [titleLabel sizeToFit];
    
    UIButton *nextButton = [[UIButton alloc] init];
    [selectPhotoView addSubview:nextButton];
    self.nextButton = nextButton;
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setImage:[UIImage imageWithName:@"ArrowRight"] forState:UIControlStateNormal];
    [nextButton sizeToFit];
    
    UIImageView *preview = [[UIImageView alloc] init];
    self.preview = preview;
    self.sourceImage = self.sourceImage;
    
    UIScrollView *previewAreaView = [[UIScrollView alloc] init];
    [selectPhotoView addSubview:previewAreaView];
    self.previewAreaView = previewAreaView;
    previewAreaView.backgroundColor = [UIColor colorWithWhite:.1 alpha:1];
    previewAreaView.showsHorizontalScrollIndicator = NO;
    previewAreaView.showsVerticalScrollIndicator = NO;
    previewAreaView.size = ccs(self.view.width, self.view.width);
    previewAreaView.delegate = self;
    preview.size = previewAreaView.size;
    
    [previewAreaView addSubview:preview];
    
    selectPhotoView.size = ccs(previewAreaView.width, previewAreaView.bottom);
    
    UINavigationController *albumVC = [[UINavigationController alloc] init];
    self.albumVC = albumVC;
    [self addChildViewController:albumVC];
    [self.view insertSubview:albumVC.view belowSubview:selectPhotoView];
    
    OCMAlbumsVC *albumsVC = [[OCMAlbumsVC alloc] init];
    [albumVC pushViewController:albumsVC animated:NO];
    OCMPhotosVC *photosVC = [[OCMPhotosVC alloc] init];
    [albumVC pushViewController:photosVC animated:NO];
    
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    if (self.sourceImage && self.sourceImageChanged) {
        self.preview.leftTop = CGPointZero;
        self.previewAreaView.minimumZoomScale = 1;
        self.previewAreaView.maximumZoomScale = MAX(self.sourceImageSize.width, self.sourceImageSize.height) / self.preview.width;
        self.previewAreaView.zoomScale = self.previewAreaView.width / MIN(self.preview.width, self.preview.height);
    }
    self.sourceImageChanged = NO;
    
    if (!self.selectPhotoView.top) {
        float topHeight = 64;
        self.previewAreaView.top = topHeight;
        self.selectPhotoView.height = self.previewAreaView.bottom;
        self.backButton.center = ccp(topHeight/2, topHeight/2);
        self.titleLabel.center = ccp(self.view.width/2, topHeight/2);
        self.nextButton.center = ccp(self.view.width-topHeight/2, topHeight/2);
        
        self.albumVC.view.top = self.selectPhotoView.bottom;
        self.albumVC.view.height = self.view.height - self.selectPhotoView.bottom;
    }
    
    [super viewDidLayoutSubviews];
}

- (void)setSourceImage:(UIImage *)sourceImage
{
    if (!sourceImage) {
        return;
    }
    _sourceImage = sourceImage;
    self.preview.image = sourceImage;
    self.previewAreaView.zoomScale = 1;
    if (sourceImage.size.width > sourceImage.size.height) {
        self.preview.size = ccs(self.previewAreaView.width, self.previewAreaView.width*sourceImage.size.height/sourceImage.size.width);
    } else {
        self.preview.size = ccs(self.previewAreaView.height*sourceImage.size.width/sourceImage.size.height, self.previewAreaView.height);
    }
    self.sourceImageChanged = YES;
    [self.view setNeedsLayout];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.preview;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [UIView animateWithDuration:.2 animations:^{
        self.preview.leftTop = ccp(MAX(scrollView.width/2-view.width/2, 0), MAX(scrollView.height/2-view.height/2, 0));
    }];
}

- (void)photoSelected:(NSNotification *)notification
{
    ALAsset *asset = notification.object;
    self.selectedAsset = asset;
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    self.sourceImage = image;
    NSDictionary *metadata = asset.defaultRepresentation.metadata;
    CGFloat width = [[metadata valueForKey:(NSString *)kCGImagePropertyPixelWidth] floatValue];
    CGFloat height = [[metadata valueForKey:(NSString *)kCGImagePropertyPixelHeight] floatValue];
    self.sourceImageSize = ccs(width/[UIScreen mainScreen].scale, height/[UIScreen mainScreen].scale);
}

- (void)firstPhotoLoaded:(NSNotification *)notification
{
    if (!self.sourceImage) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:OCMDidSelectPhotoNotification
         object:notification.object
         userInfo:@{@"first": @YES}];
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)next
{
    ALAssetRepresentation *assetRepresentation = [self.selectedAsset defaultRepresentation];
    CGImageRef fullResImage = [assetRepresentation fullResolutionImage];
    NSString *adjustment = [[assetRepresentation metadata] objectForKey:@"AdjustmentXMP"];
    if (adjustment) {
        NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
        CIImage *image = [CIImage imageWithCGImage:fullResImage];
        
        NSError *error = nil;
        NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                     inputImageExtent:image.extent
                                                                error:&error];
        CIContext *context = [CIContext contextWithOptions:nil];
        if (filterArray && !error) {
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            fullResImage = [context createCGImage:image fromRect:[image extent]];
        }
    }
    UIImage *result = [UIImage imageWithCGImage:fullResImage
                                          scale:[assetRepresentation scale]
                                    orientation:(UIImageOrientation)[assetRepresentation orientation]];
    OCMCameraViewController *nav = (OCMCameraViewController *)self.navigationController;
    result = [result imageRotatedToUpWithMaxWidth:nav.maxWidth?:result.size.width maxHeight:nav.maxHeight?:result.size.height];
    CGPoint leftTop = ccp(self.previewAreaView.contentOffset.x / self.preview.width * result.size.width,
                          self.previewAreaView.contentOffset.y / self.preview.height * result.size.height);
    CGSize size = ccs(self.previewAreaView.width / self.preview.width * result.size.width,
                      self.previewAreaView.width / self.preview.width * result.size.width);
    CGRect cropRect = ccr(leftTop.x, leftTop.y, size.width, size.height);
    UIImage *croppedImage = [result subImageAtRect:cropRect];
    OCMEditPhotoVC *editPhotoVC = [[OCMEditPhotoVC alloc] initWithSourceImage:croppedImage];
    [self.navigationController pushViewController:editPhotoVC animated:YES];
}

- (void)tapTop:(UIGestureRecognizer *)tapGesture
{
    CGPoint location = [tapGesture locationInView:self.selectPhotoView];
    if (location.y < self.previewAreaView.top) {
        [[NSNotificationCenter defaultCenter] postNotificationName:OCMDidTapPhotosTopViewNotification object:nil];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
