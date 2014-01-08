//
//  OCMEditPhotoVC.m
//  OpenCam
//
//  Created by Jason Hsu on 2013/12/10.
//  Copyright (c) 2013年 Jason Hsu. All rights reserved.
//

#import "OCMEditPhotoVC.h"
#import <GPUImage/GPUImage.h>
#import "OCMFiltersSelectorView.h"
#import "OCMLookupFilter.h"
#import "OCMFilterLevelControl.h"
#import "OCMBorderFilter.h"
#import "OCMVignetteFilter.h"
#import "OCMTransformControl.h"
#import "OCMSharePhotoVC.h"
#import "OCMDefinitions.h"
#import "OCMCameraViewController.h"
#import "UIImage+OCMAdditions.h"

#define CategoryPanelSize (Screen4Inch ? 92 : (iPad ? 96 : 55))
#define TemperatureDefaultValue 5000.0
#define BorderCount 22

@interface OCMEditPhotoVC () <OCMFiltersSelectorViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *sourceImage;

@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *nextButton;

@property (nonatomic, weak) GPUImageView *preview;

@property (nonatomic, weak) UIView *categoryPanel;
@property (nonatomic, weak) UIButton *undoButton;
@property (nonatomic, weak) UIButton *colorFilterButton;
@property (nonatomic, weak) UIButton *wbFilterButton;
@property (nonatomic, weak) UIButton *adjustButton;
@property (nonatomic, weak) UIButton *redoButton;
@property (nonatomic, strong) NSArray *categoryButtons;

@property (nonatomic, weak) OCMFiltersSelectorView *filterSelectorView;
@property (nonatomic, weak) OCMFilterLevelControl *levelControl;
@property (nonatomic, weak) OCMTransformControl *transformControl;
@property (nonatomic, weak) OCMFiltersSelectorView *subFilterSelectorView;

@property (nonatomic, strong) GPUImagePicture *inputPicture;

@property (nonatomic, strong) NSMutableArray *filterSettings;
@property (nonatomic, strong) NSMutableArray *rejectedFilterSettings;
@property (nonatomic) BOOL editingFilter;

@end

@implementation OCMEditPhotoVC

- (instancetype)initWithSourceImage:(UIImage *)sourceImage
{
    self = [super init];
    if (self) {
        self.sourceImage = sourceImage;
        self.filterSettings = [NSMutableArray array];
        self.rejectedFilterSettings = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
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
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = LocalStr(@"Edit");
    [titleLabel sizeToFit];
    
    UIButton *nextButton = [[UIButton alloc] init];
    [self.view addSubview:nextButton];
    self.nextButton = nextButton;
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setImage:[UIImage imageWithName:@"ArrowRight"] forState:UIControlStateNormal];
    [nextButton sizeToFit];
    
    GPUImageView *preview = [[GPUImageView alloc] init];
    [self.view addSubview:preview];
    self.preview = preview;
    preview.size = ccs(self.view.width, self.view.width);
    
    UIView *categoryPanel = [[UIView alloc] init];
    self.categoryPanel = categoryPanel;
    [self.view addSubview:categoryPanel];
    
    UIButton *undoButton = [[UIButton alloc] init];
    self.undoButton = undoButton;
    [categoryPanel addSubview:undoButton];
    [undoButton setImage:[UIImage imageWithName:@"Undo"] forState:UIControlStateNormal];
    [undoButton sizeToFit];
    undoButton.enabled = NO;
    [undoButton addTarget:self action:@selector(undoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *colorFilterButtton = [[UIButton alloc] init];
    self.colorFilterButton = colorFilterButtton;
    [categoryPanel addSubview:colorFilterButtton];
    [colorFilterButtton setImage:[UIImage imageWithName:@"CategoryColor"] forState:UIControlStateNormal];
    [colorFilterButtton sizeToFit];
    colorFilterButtton.highlighted = YES;
    [colorFilterButtton addTarget:self action:@selector(colorFilterButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *wbFilterButton = [[UIButton alloc] init];
    self.wbFilterButton = wbFilterButton;
    [categoryPanel addSubview:wbFilterButton];
    [wbFilterButton setImage:[UIImage imageWithName:@"CategoryBlackAndWhite"] forState:UIControlStateNormal];
    [wbFilterButton sizeToFit];
    wbFilterButton.highlighted = YES;
    [wbFilterButton addTarget:self action:@selector(wbFilterButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *adjustButton = [[UIButton alloc] init];
    self.adjustButton = adjustButton;
    [categoryPanel addSubview:adjustButton];
    [adjustButton setImage:[UIImage imageWithName:@"Adjust"] forState:UIControlStateNormal];
    [adjustButton sizeToFit];
    adjustButton.highlighted = YES;
    [adjustButton addTarget:self action:@selector(adjustButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *redoButtton = [[UIButton alloc] init];
    self.redoButton = redoButtton;
    [categoryPanel addSubview:redoButtton];
    [redoButtton setImage:[UIImage imageWithName:@"Redo"] forState:UIControlStateNormal];
    [redoButtton sizeToFit];
    redoButtton.enabled = NO;
    [redoButtton addTarget:self action:@selector(redoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    self.categoryButtons = @[self.colorFilterButton, self.wbFilterButton, self.adjustButton];
    
    [self colorFilterButtonTouched:self.colorFilterButton];
    
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews
{
    CGFloat topHeight = 64;
    self.preview.top = topHeight;
    if (!Screen4Inch) {
        if (!iPad) {
            self.preview.top -= 14;
        }
    }
    self.backButton.center = ccp(topHeight/2, topHeight/2);
    self.titleLabel.center = ccp(self.view.width/2, topHeight/2);
    self.nextButton.center = ccp(self.view.width-topHeight/2, topHeight/2);
    
    self.categoryPanel.frame = ccr(0, self.preview.bottom, self.view.width, CategoryPanelSize);
    
    CGFloat buttonSize = 50;
    CGFloat left = (self.view.width - buttonSize * 5) / 6;
    CGFloat baseline = CategoryPanelSize/2;
    self.undoButton.leftCenter = ccp(left, baseline);
    self.colorFilterButton.leftCenter = ccp(self.undoButton.right + left, baseline);
    self.wbFilterButton.leftCenter = ccp(self.colorFilterButton.right + left, baseline);
    self.adjustButton.leftCenter = ccp(self.wbFilterButton.right + left, baseline);
    self.redoButton.leftCenter = ccp(self.adjustButton.right + left, baseline);
    
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:self.sourceImage];
    [picture addTarget:self.preview atTextureLocation:0];
    [picture processImage];
    self.inputPicture = picture;
    
    if (self.presentingViewController) {
        [self.nextButton setImage:[UIImage imageWithName:@"Tick"] forState:UIControlStateNormal];
        [self.nextButton sizeToFit];
    }
    
    [super viewWillAppear:animated];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)next
{
    GPUImageOutput *filter = self.inputPicture;
    while (filter.targets) {
        if (filter.targets[0] == self.preview) {
            break;
        }
        filter = filter.targets[0];
    }
    UIImage *photo;
    if (filter == self.inputPicture) {
        photo = self.sourceImage;
    } else {
        photo = filter.imageFromCurrentlyProcessedOutput;
    }
    
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
        OCMCameraViewController *nav = (OCMCameraViewController *)self.navigationController;
        nav.photo = photo;
        [nav.delegate cameraViewControllerDidFinish:nav];
    } else {
        OCMSharePhotoVC *shareVC = [[OCMSharePhotoVC alloc] init];
        if (filter == self.inputPicture) {
            shareVC.photo = photo;
        } else {
            shareVC.photo = photo;
        }
        [self.navigationController pushViewController:shareVC animated:YES];
    }
}

- (void)undoButtonTouched
{
    self.redoButton.enabled = YES;
    
    [self.rejectedFilterSettings addObject:self.filterSettings.lastObject];
    [self.filterSettings removeLastObject];
    
    [self refreshFilters];
    
    self.levelControl.hidden = YES;
    self.transformControl.hidden = YES;
    self.categoryPanel.hidden = NO;
    [self.filterSelectorView reset];
    
    self.undoButton.enabled = self.filterSettings.count > 0;
}

- (void)redoButtonTouched
{
    self.undoButton.enabled = YES;
    
    [self.filterSettings addObject:self.rejectedFilterSettings.lastObject];
    [self.rejectedFilterSettings removeLastObject];
    
    [self refreshFilters];
    
    self.redoButton.enabled = self.rejectedFilterSettings.count > 0;
}

- (void)colorFilterButtonTouched:(UIButton *)sender
{
    NSArray *infos = @[@[@"Coyote", rgb(158, 75, 76)],
                       @[@"Maple", rgb(203, 76, 84)],
                       @[@"Bandit", rgb(227, 77, 80)],
                       @[@"Mason", rgb(205, 149, 130)],
                       @[@"Clay", rgb(194, 95, 71)],
                       @[@"Zest", rgb(232, 107, 70)],
                       @[@"Zion", rgb(196, 120, 71)],
                       @[@"Flint", rgb(141, 104, 70)],
                       @[@"Wheat", rgb(213, 169, 87)],
                       @[@"Marko", rgb(231, 184, 114)],
                       @[@"Alda", rgb(248, 208, 117)],
                       @[@"Finch", rgb(181, 197, 115)],
                       @[@"Fern", rgb(67, 81, 48)],
                       @[@"Moss", rgb(90, 113, 78)],
                       @[@"Kudzu", rgb(54, 102, 80)],
                       @[@"Oliver", rgb(94, 154, 136)],
                       @[@"Siren", rgb(116, 169, 147)],
                       @[@"Burst", rgb(106, 195, 180)],
                       @[@"Super", rgb(139, 196, 200)],
                       @[@"Light", rgb(158, 216, 218)],
                       @[@"Pear", rgb(103, 181, 197)],
                       @[@"Lake", rgb(96, 164, 204)],
                       @[@"Waltz", rgb(125, 97, 139)],
                       @[@"Hanke", rgb(206, 111, 166)],
                       @[@"Dust", rgb(199, 122, 146)]];
    [self colorFiltersButtonTouched:sender simpleInfos:infos isWhiteAndBlack:NO];
}

- (void)wbFilterButtonTouched:(UIButton *)sender
{
    NSArray *infos = @[@[@"Coal", bw(69)],
                       @[@"Kings", bw(80)],
                       @[@"Fossil", bw(89)],
                       @[@"Shark", bw(59)],
                       @[@"Premiere", bw(40)],
                       @[@"Milk", bw(80)],
                       @[@"Smong", bw(105)],
                       @[@"Wilfred", bw(50)],
                       @[@"Verona", bw(35)]];
    [self colorFiltersButtonTouched:sender simpleInfos:infos isWhiteAndBlack:YES];
}

- (void)adjustButtonTouched:(UIButton *)sender
{
    NSArray *simpleInfos = @[@[@"Exposure",    @(-0.7),  @0.7,   @0.0],
                             @[@"Brightness",  @(-0.1),  @0.1,    @0.0],
                             @[@"Contrast",    @0.8,     @1.2,    @1.0],
                             @[@"Transform",   @0.0,     @1.0,    @0.0],
                             @[@"Fade",        @0.0,     @1.0,    @0.0],
                             @[@"Highlights",  @0.0,     @1.0,    @0.0],
                             @[@"Sharpen",     @(0.0),   @0.5,    @0.0],
                             @[@"Blur",        @0.0,     @2.0,    @0.0],
                             @[@"Saturation",  @0.0,     @2.0,    @1.0],
                             @[@"Vignette",    @0.0,     @1.0,    @0.0],
                             @[@"Temperature", @4000.0,  @6000.0, @TemperatureDefaultValue],
                             @[@"Orange Fix",  @0.0,     @1.0,    @0.0],
                             @[@"Green Fix",   @0.0,     @1.0,    @0.0],
                             @[@"Borders",     @0.0,     @1.0,    @0.0]
                             ];
    // Grain, Clarity
    [self iconFiltersButtonTouched:sender simpleInfos:simpleInfos type:@"adjust"];
}

- (void)colorFiltersButtonTouched:(UIButton *)sender simpleInfos:(NSArray *)simpleInfos isWhiteAndBlack:(BOOL)isWhiteAndBlack
{
    if (!sender.highlighted) {
        return;
    }
    
    [self.filterSelectorView removeFromSuperview];
    
    for (UIButton *button in self.categoryButtons) {
        button.highlighted = (button != sender);
    }
    
    NSMutableArray *metas = [NSMutableArray array];
    
    for (NSArray *info in simpleInfos) {
        NSDictionary *meta = @{OCMMetaKeyType: isWhiteAndBlack ? @"wblookup" : @"lookup",
                               OCMMetaKeyTitle: info[0],
                               OCMMetaKeyBackgroundColor: info[1],
                               OCMMetaKeyBackgroundColorSelected: bw(20),
                               OCMMetaKeyIconNameSelected: @"Heart",
                               OCMMetaKeyLevelMin: @0,
                               OCMMetaKeyLevelMax: @1,
                               OCMMetaKeyLevel: @(1.0)};
        [metas addObject:meta];
    }
    OCMFiltersSelectorView *filterSelectorView = [[OCMFiltersSelectorView alloc] initWithButtonMetas:metas];
    self.filterSelectorView = filterSelectorView;
    [self.view addSubview:filterSelectorView];
    filterSelectorView.delegate = self;
    filterSelectorView.bottom = self.view.height;
}

- (void)iconFiltersButtonTouched:(UIButton *)sender simpleInfos:(NSArray *)simpleInfos type:(NSString *)type
{
    if (!sender.highlighted) {
        return;
    }
    
    [self.filterSelectorView removeFromSuperview];
    
    for (UIButton *button in self.categoryButtons) {
        button.highlighted = (button != sender);
    }
    
    NSMutableArray *metas = [NSMutableArray array];
    
    for (NSArray *simpleInfo in simpleInfos) {
        NSDictionary *meta = @{OCMMetaKeyType: type,
                               OCMMetaKeyTitle: simpleInfo[0],
                               OCMMetaKeyBackgroundColor: rgb(219, 41, 61),
                               OCMMetaKeyBackgroundColorSelected: rgb(161, 18, 51),
                               OCMMetaKeyIconName: [simpleInfo[0] stringByReplacingOccurrencesOfString:@" " withString:@""],
                               OCMMetaKeyLevelMin: simpleInfo[1],
                               OCMMetaKeyLevelMax: simpleInfo[2],
                               OCMMetaKeyLevel: simpleInfo[3]};
        [metas addObject:meta];
    }
    OCMFiltersSelectorView *filterSelectorView = [[OCMFiltersSelectorView alloc] initWithButtonMetas:metas];
    self.filterSelectorView = filterSelectorView;
    [self.view addSubview:filterSelectorView];
    filterSelectorView.delegate = self;
    filterSelectorView.bottom = self.view.height;
}

- (void)filterButtonTouched:(UIButton *)filterButton withMetadata:(NSDictionary *)metadata
{
    // remove last editing filter settings
    if (self.editingFilter) {
        [self.filterSettings removeLastObject];
    }
    
    // add new filter settings
    NSMutableDictionary *curMeta = metadata.mutableCopy;
    [self.filterSettings addObject:curMeta];
    
    // specify deal 3 types of filter
    NSString *name = metadata[OCMMetaKeyTitle];
    if ([name isEqualToString:@"Fade"] || [name isEqualToString:@"Orange Fix"] || [name isEqualToString:@"Green Fix"]) {
        curMeta[OCMMetaKeyType] = @"lookup";
        curMeta[OCMMetaKeyTitle] = [name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
    
    // reset filters
    [self refreshFilters];
    
    if (self.levelControl) {
        self.levelControl.hidden = NO;
        self.levelControl.levelSlider.minimumValue = [metadata[OCMMetaKeyLevelMin] floatValue];
        self.levelControl.levelSlider.maximumValue = [metadata[OCMMetaKeyLevelMax] floatValue];
        self.levelControl.levelSlider.value = [metadata[OCMMetaKeyLevel] floatValue];
        self.levelControl.levelSlider.hidden = NO;
    } else {
        OCMFilterLevelControl *levelControl = [[OCMFilterLevelControl alloc] initWithFrame:ccr(0, self.preview.bottom, self.view.width, self.filterSelectorView.top-self.preview.bottom)];
        self.levelControl = levelControl;
        [self.view addSubview:levelControl];
        levelControl.levelSlider.minimumValue = [metadata[OCMMetaKeyLevelMin] floatValue];
        levelControl.levelSlider.maximumValue = [metadata[OCMMetaKeyLevelMax] floatValue];
        levelControl.levelSlider.value = [metadata[OCMMetaKeyLevel] floatValue];
        [levelControl.levelSlider addTarget:self action:@selector(levelChanged:) forControlEvents:UIControlEventValueChanged];
        [levelControl.closeButton addTarget:self action:@selector(levelClosed:) forControlEvents:UIControlEventTouchUpInside];
        [levelControl.applyButton addTarget:self action:@selector(levelApplied:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.transformControl removeFromSuperview];
    if ([name isEqualToString:@"Borders"]) {
        NSMutableArray *metas = [NSMutableArray array];
        for (int i=1; i<=BorderCount; i++) {
            NSDictionary *meta = @{OCMMetaKeyType: @"border",
                                   OCMMetaKeyBackgroundColor: bw(34),
                                   OCMMetaKeyBackgroundColorSelected: bw(24),
                                   OCMMetaKeyIconName: [NSString stringWithFormat:@"border_%02d", i],
                                   OCMMetaKeySelected: @(i==1)};
            [metas addObject:meta];
        }
        OCMFiltersSelectorView *borderSelectorView = [[OCMFiltersSelectorView alloc] initWithButtonMetas:metas];
        [self.view addSubview:borderSelectorView];
        self.subFilterSelectorView = borderSelectorView;
        borderSelectorView.top = self.filterSelectorView.top;
        borderSelectorView.delegate = self;
        self.filterSelectorView.hidden = YES;
        
        self.levelControl.levelSlider.hidden = YES;
    } else if ([name isEqualToString:@"Transform"]) {
        self.levelControl.levelSlider.hidden = YES;
        
        OCMTransformControl *transformControl = [[OCMTransformControl alloc] initWithFrame:ccr(0, self.preview.bottom, self.view.width, self.filterSelectorView.top - self.preview.bottom)];
        self.transformControl = transformControl;
        [self.view addSubview:transformControl];
        [self.transformControl.closeButton addTarget:self action:@selector(levelClosed:) forControlEvents:UIControlEventTouchUpInside];
        [self.transformControl.applyButton addTarget:self action:@selector(levelApplied:) forControlEvents:UIControlEventTouchUpInside];
        [self.transformControl.rotateButton addTarget:self action:@selector(transformRotated:) forControlEvents:UIControlEventTouchUpInside];
        [self.transformControl.flipXButton addTarget:self action:@selector(transformFlipX:) forControlEvents:UIControlEventTouchUpInside];
        [self.transformControl.flipYButton addTarget:self action:@selector(tranformFlipY:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.categoryPanel.hidden = YES;
    self.editingFilter = YES;
}

- (void)levelChanged:(UISlider *)levelSlider
{
    CGFloat level = [self.filterSettings.lastObject[OCMMetaKeyLevel] floatValue];
    if (levelSlider.value - level > 0.05 * (levelSlider.maximumValue - levelSlider.minimumValue) ||
        level - levelSlider.value > 0.05 * (levelSlider.maximumValue - levelSlider.minimumValue) ||
        levelSlider.value == levelSlider.maximumValue ||
        levelSlider.value == levelSlider.minimumValue) {
        
        self.filterSettings.lastObject[OCMMetaKeyLevel] = @(levelSlider.value);
        [self refreshFilters];
    }
}

- (void)levelClosed:(UIButton *)closeLevelButton
{
    [self.filterSettings removeLastObject];
    [self refreshFilters];
    
    self.levelControl.hidden = YES;
    self.transformControl.hidden = YES;
    self.categoryPanel.hidden = NO;
    [self.filterSelectorView reset];
    self.filterSelectorView.hidden = NO;
    self.levelControl.levelSlider.hidden = NO;
    self.subFilterSelectorView.hidden = YES;
    self.editingFilter = NO;
}

- (void)levelApplied:(UIButton *)applyLevelButton
{
    [self.rejectedFilterSettings removeAllObjects];
    
    self.levelControl.hidden = YES;
    self.transformControl.hidden = YES;
    self.categoryPanel.hidden = NO;
    [self.filterSelectorView reset];
    self.filterSelectorView.hidden = NO;
    self.levelControl.levelSlider.hidden = NO;
    self.subFilterSelectorView.hidden = YES;
    self.undoButton.enabled = YES;
    self.redoButton.enabled = NO;
    self.editingFilter = NO;
}

- (void)transformRotated:(UIButton *)rotatedButton
{
    NSMutableDictionary *meta = self.filterSettings.lastObject;
    if ([meta[OCMMetaKeyTitle] isEqualToString:@"Transform"]) {
        meta[OCMMetaKeyRotate] = @([meta[OCMMetaKeyRotate] floatValue] + 0.5);
    } else {
        NSMutableDictionary *meta = [NSMutableDictionary dictionary];
        meta[OCMMetaKeyType] = @"adjust";
        meta[OCMMetaKeyTitle] = @"Transform";
        meta[OCMMetaKeyRotate] = @(0.5);
        [self.filterSettings addObject:meta];
    }
    [self refreshFilters];
}

- (void)transformFlipX:(UIButton *)flipXButton
{
    NSMutableDictionary *meta = self.filterSettings.lastObject;
    if ([meta[OCMMetaKeyTitle] isEqualToString:@"Transform"]) {
        [self.filterSettings removeLastObject];
    } else {
        NSMutableDictionary *meta = [NSMutableDictionary dictionary];
        meta[OCMMetaKeyType] = @"adjust";
        meta[OCMMetaKeyTitle] = @"Transform";
        meta[OCMMetaKeyFlip] = @"x";
        [self.filterSettings addObject:meta];
    }
    [self refreshFilters];
}

- (void)tranformFlipY:(UIButton *)flipYButton
{
    NSMutableDictionary *meta = self.filterSettings.lastObject;
    if ([meta[OCMMetaKeyTitle] isEqualToString:@"Transform"]) {
        [self.filterSettings removeLastObject];
    } else {
        NSMutableDictionary *meta = [NSMutableDictionary dictionary];
        meta[OCMMetaKeyType] = @"adjust";
        meta[OCMMetaKeyTitle] = @"Transform";
        meta[OCMMetaKeyFlip] = @"y";
        [self.filterSettings addObject:meta];
    }
    [self refreshFilters];
}

- (void)refreshFilters
{
    [self.inputPicture removeAllTargets];
    
    NSMutableArray *filters = [NSMutableArray array];
    [filters addObject:self.inputPicture];
    for (NSDictionary *filterSetting in self.filterSettings) {
        GPUImageOutput<GPUImageInput> *filter = [self createFilterBySettings:filterSetting];
        if (filter) {
            [filters addObject:filter];
        }
    }
    [filters addObject:self.preview];
    
    for (int i=0; i<filters.count-1; i++) {
        GPUImageOutput *filter1 = filters[i];
        id<GPUImageInput> filter2 = filters[i+1];
        [filter1 addTarget:filter2 atTextureLocation:0];
    }
    [self.inputPicture processImage];
}

- (GPUImageOutput<GPUImageInput> *)createFilterBySettings:(NSDictionary *)filterSetting
{
    NSString *type = filterSetting[OCMMetaKeyType];
    NSString *name = filterSetting[OCMMetaKeyTitle];
    
    NSNumber *levelNum = filterSetting[OCMMetaKeyLevel];
    if ([type isEqualToString:@"lookup"]) {
        OCMLookupFilter *filter = [[OCMLookupFilter alloc] initWithName:name isWhiteAndBlack:NO];
        filter.level = [levelNum floatValue];
        return filter;
    } else if ([type isEqualToString:@"wblookup"]) {
        OCMLookupFilter *filter = [[OCMLookupFilter alloc] initWithName:name isWhiteAndBlack:YES];
        filter.level = [levelNum floatValue];
        return filter;
    } else if ([type isEqualToString:@"adjust"]) {
        if ([name isEqualToString:@"Exposure"]) {
            GPUImageExposureFilter *filter = [[GPUImageExposureFilter alloc] init];
            filter.exposure = [levelNum floatValue];
            return filter;
        } else if ([name isEqualToString:@"Brightness"]) {
            GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
            filter.brightness = [levelNum floatValue];
            return filter;
        } else if ([name isEqualToString:@"Contrast"]) {
            GPUImageContrastFilter *filter = [[GPUImageContrastFilter alloc] init];
            filter.contrast = [levelNum floatValue];
            return filter;
        } else if ([name isEqualToString:@"Highlights"]) {
            GPUImageHighlightShadowFilter *filter = [[GPUImageHighlightShadowFilter alloc] init];
            filter.highlights = 1 - [levelNum floatValue];
            return filter;
        } else if ([name isEqualToString:@"Grain"]) {
        } else if ([name isEqualToString:@"Sharpen"]) {
            GPUImageSharpenFilter *filter = [[GPUImageSharpenFilter alloc] init];
            filter.sharpness = [levelNum floatValue];
            return filter;
        } else if ([name isEqualToString:@"Blur"]) {
            GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
            filter.blurRadiusInPixels = [levelNum floatValue];
            return filter;
        } else if ([name isEqualToString:@"Saturation"]) {
            GPUImageSaturationFilter *filter = [[GPUImageSaturationFilter alloc] init];
            filter.saturation = [levelNum floatValue];
            return filter;
        } else if ([name isEqualToString:@"Temperature"]) {
            GPUImageWhiteBalanceFilter *filter = [[GPUImageWhiteBalanceFilter alloc] init];
            float temperature = [levelNum floatValue];
            if (temperature > TemperatureDefaultValue) {
                filter.temperature = (temperature - TemperatureDefaultValue) * 4 + TemperatureDefaultValue;
            } else {
                filter.temperature = temperature;
            }
            return filter;
        } else if ([name isEqualToString:@"Clarity"]) {
        } else if ([name isEqualToString:@"Vignette"]) {
            OCMVignetteFilter *filter = [[OCMVignetteFilter alloc] init];
            float level = [levelNum floatValue]; // 0 ~ 1
            filter.vignetteStart = 0.1;
            filter.vignetteEnd = 0.75;
            filter.vignetteLevel = level * .3;
            return filter;
        } else if ([name isEqualToString:@"Transform"]) {
            GPUImageTransformFilter *filter = [[GPUImageTransformFilter alloc] init];
            float degree = [filterSetting[OCMMetaKeyRotate] floatValue];
            NSString *flip = filterSetting[OCMMetaKeyFlip];
            CGAffineTransform transform = CGAffineTransformMakeRotation(degree * M_PI);
            if ([flip isEqualToString:@"x"]) {
                filter.affineTransform = CGAffineTransformScale(transform, 1, -1);
            } else if ([flip isEqualToString:@"y"]) {
                filter.affineTransform = CGAffineTransformScale(transform, -1, 1);
            } else {
                filter.affineTransform = transform;
            }
            return filter;
        }
    } else if ([type isEqualToString:@"border"]) {
        OCMBorderFilter *filter = [[OCMBorderFilter alloc] init];
        NSString *borderImageName = filterSetting[OCMMetaKeyIconName];
        filter.borderImage = [UIImage imageWithName:borderImageName];
        return filter;
    }
    return nil;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
