//
//  OCMPhotosVC.m
//  OpenCam
//
//  Created by Jason Hsu on 11/5/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "OCMPhotosVC.h"
#import "OCMPhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "OCMPhotosNavBar.h"
#import "OCMSelectPhotoVC.h"
#import "OCMDefinitions.h"

#define OCMPhotoCellIdentifier @"OCMPhotoCell"
#define OCMPhotoScrollTop 100
#define OCMPhotoNavHeight 80

@interface OCMPhotosCollectionView : UICollectionView

@property (nonatomic) CGFloat touchBeginY;
@property (nonatomic) CGFloat startOffsetTop;

@end


@implementation OCMPhotosCollectionView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    self.touchBeginY = point.y - self.contentOffset.y;
    
    return [super hitTest:point withEvent:event];
}

@end

@implementation OCMPhotoCover

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    self.touchBeginPosition = [touch locationInView:self.window];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self.window];
    CGPoint moved = CGPointMake(p.x - self.touchBeginPosition.x, p.y - self.touchBeginPosition.y);
    [self.delegate performSelector:@selector(touchMoved:inView:)
                        withObject:[NSValue valueWithCGPoint:moved]
                        withObject:self];
    self.lastMoved = moved;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:OCMDidTapPhotosTopViewNotification object:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView:self.window];
    CGPoint moved = CGPointMake(p.x - self.touchBeginPosition.x, p.y - self.touchBeginPosition.y);
    [self.delegate performSelector:@selector(touchEnded:inView:)
                        withObject:[NSValue valueWithCGPoint:moved]
                        withObject:self];
}

@end


@interface OCMPhotosVC () <UICollectionViewDelegateFlowLayout, OCMPhotoCoverDelegate>

@property (nonatomic, weak) OCMPhotosNavBar *navBar;
@property (nonatomic, weak) UIButton *albumBackButton;
@property (nonatomic, weak) UILabel *albumTitleLabel;
@property (nonatomic, weak) UICollectionView *albumView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLib;
@property (nonatomic, assign) NSInteger photoCount;
@property (nonatomic, strong) NSMutableArray *assets;
//@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic) CGPoint scrollBeginOffset;
@property (nonatomic) CGPoint scrollingOffset;
@property (nonatomic) BOOL touching;

@end

@implementation OCMPhotosVC

- (id)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = ccs(104, 104);
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 4;
    layout.headerReferenceSize = ccs(WinSize.width, OCMPhotoNavHeight);
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(tapTop)
     name:OCMDidTapPhotosTopViewNotification
     object:nil];
    
    self.view.clipsToBounds = NO;
    [self.navigationController setNavigationBarHidden:YES];
    
    self.collectionView = [[OCMPhotosCollectionView alloc] initWithFrame:self.collectionView.frame collectionViewLayout:self.collectionView.collectionViewLayout];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[OCMPhotoCell class] forCellWithReuseIdentifier:OCMPhotoCellIdentifier];
    [self.collectionView registerClass:[OCMPhotosNavBar class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"OCMPhotosNavigationBar"];
    
    self.assetsLib = [[ALAssetsLibrary alloc] init];
    self.assets = [NSMutableArray array];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    __weak typeof(self)weakSelf = self;
    if (self.albumURL) {
        [self.assetsLib groupForURL:self.albumURL resultBlock:^(ALAssetsGroup *group) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                weakSelf.photoCount = group.numberOfAssets;
                [weakSelf processAssetsGroup:group];
            }
        } failureBlock:^(NSError *error) {
            
        }];
    } else {
        [self.assetsLib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                NSString *albumnName = [group valueForProperty:ALAssetsGroupPropertyName];
                weakSelf.albumName = albumnName;
                weakSelf.titleLabel.text = albumnName;
                [weakSelf.titleLabel sizeToFit];
                
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                weakSelf.photoCount = group.numberOfAssets;
                [weakSelf processAssetsGroup:group];
            }
        } failureBlock:^(NSError *error) {
            
        }];
    }
    
    [super viewWillAppear:animated];
}

- (void)processAssetsGroup:(ALAssetsGroup *)group
{
    [self.assets removeAllObjects];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __weak typeof(self)weakSelf = self;
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.assets addObject:result];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.collectionView reloadData];
                });
            }
        }];
    });
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OCMPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:OCMPhotoCellIdentifier forIndexPath:indexPath];
    ALAsset *asset = self.assets[indexPath.item];
    cell.photoView.image = [UIImage imageWithCGImage:[asset thumbnail]];
    if (indexPath.item == 0) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:OCMDidLoadFirstPhotoNotification
         object:asset];
    }
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    if (selectPhotoVC.selectedAsset == asset) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    OCMPhotosNavBar *navBar = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                               withReuseIdentifier:@"OCMPhotosNavigationBar"
                                                                                      forIndexPath:indexPath];
    [navBar.backButton removeTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [navBar.backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = navBar.titleLabel;
    self.titleLabel.text = self.albumName;
    [self.titleLabel sizeToFit];
    
    self.navBar = navBar;
    
    return navBar;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = self.assets[indexPath.item];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:OCMDidSelectPhotoNotification
     object:asset
     userInfo:nil];
    [self haulDownSelectPhotoView];
    [self.collectionView reloadData];
}

- (void)backButtonTouched
{
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    selectPhotoVC.photosVC = self;
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)touchBeginY
{
    return ((OCMPhotosCollectionView *)self.collectionView).touchBeginY;
}

- (void)setHeaderHeight:(CGFloat)height
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.headerReferenceSize = ccs(layout.headerReferenceSize.width, height);
    [self.collectionView reloadData];
}

- (void)setToTopWithAnimation:(BOOL)animation
{
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    selectPhotoVC.locked = YES;
    if (animation) {
        [UIView animateWithDuration:.2 animations:^{
            selectPhotoVC.animating = YES;
            [self setSelectViewTop:OCMPhotoScrollTop - selectPhotoVC.selectPhotoView.height];
        } completion:^(BOOL finished) {
            selectPhotoVC.animating = NO;
            [self setHeaderHeight:OCMPhotoNavHeight];
            self.collectionView.contentOffset =
                ccp(0, self.collectionView.contentOffset.y - (selectPhotoVC.selectPhotoView.height-OCMPhotoScrollTop));
        }];
    } else {
        [self setSelectViewTop:OCMPhotoScrollTop - selectPhotoVC.selectPhotoView.height];
        [self setHeaderHeight:OCMPhotoNavHeight];
        self.collectionView.contentOffset =
            ccp(0, self.collectionView.contentOffset.y - (selectPhotoVC.selectPhotoView.height-OCMPhotoScrollTop));
    }
}

- (void)unSetToTop
{
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    selectPhotoVC.locked = NO;
    [self setHeaderHeight:selectPhotoVC.selectPhotoView.height + OCMPhotoNavHeight - OCMPhotoScrollTop];
    self.collectionView.contentOffset =
        ccp(0, self.collectionView.contentOffset.y + (selectPhotoVC.selectPhotoView.height-OCMPhotoScrollTop));
}

- (void)setSelectViewTop:(CGFloat)top
{
    // 越往上去，不透明度越大
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    selectPhotoVC.selectPhotoView.top = top;
    CGFloat targetTop = OCMPhotoScrollTop - selectPhotoVC.selectPhotoView.height;
    CGFloat distance = selectPhotoVC.selectPhotoView.top - targetTop;
    selectPhotoVC.selectViewCover.alpha = (1 - distance / selectPhotoVC.selectPhotoView.height) * 210/255.0f;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 开始拖动的时候，记录下触发位置
    self.scrollBeginOffset = scrollView.contentOffset;
    self.touching = YES;
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    selectPhotoVC.fromBottom = !selectPhotoVC.locked;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrollView.delegate = nil;
    CGFloat scrolled = scrollView.contentOffset.y - self.scrollBeginOffset.y;
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    if (selectPhotoVC.locked && selectPhotoVC.fromBottom) {
        scrolled += selectPhotoVC.selectPhotoView.height - OCMPhotoScrollTop;
    }
    if (self.touching &&
        !selectPhotoVC.locked &&
        ((OCMPhotosCollectionView *)scrollView).touchBeginY &&
        scrolled > self.touchBeginY &&
        self.navigationController.view.top != OCMPhotoScrollTop) {
        // 当向上拉动到触发点的时候
        [self setHeaderHeight:selectPhotoVC.selectPhotoView.height+OCMPhotoNavHeight-OCMPhotoScrollTop];
        self.navigationController.view.top = OCMPhotoScrollTop;
        self.navigationController.view.height = selectPhotoVC.view.height - OCMPhotoScrollTop;
        
        OCMPhotoCover *selectViewCover = [[OCMPhotoCover alloc] initWithFrame:selectPhotoVC.selectPhotoView.bounds];
        selectPhotoVC.selectViewCover = selectViewCover;
        [selectPhotoVC.selectPhotoView addSubview:selectViewCover];
        selectViewCover.backgroundColor = [UIColor colorWithWhite:1/7.0f alpha:1];
        selectViewCover.alpha = 0;
        selectViewCover.delegate = self;
    }
    if (self.touching && scrolled > self.touchBeginY && selectPhotoVC.fromBottom) {
        if (scrolled - self.touchBeginY < selectPhotoVC.selectPhotoView.height - OCMPhotoScrollTop) {
            if (!selectPhotoVC.locked) {
                [self setSelectViewTop:self.touchBeginY - scrolled];
            } else if (!selectPhotoVC.animating) {
                [self unSetToTop];
            }
        } else if (!selectPhotoVC.locked) {
            [self setToTopWithAnimation:NO];
        }
    } else if (self.touching) {
        if (self.navigationController.view.top == OCMPhotoScrollTop &&
            !selectPhotoVC.locked) {
            [selectPhotoVC.selectViewCover removeFromSuperview];
            [self setSelectViewTop:0];
            [selectPhotoVC.view setNeedsLayout];
            [self setHeaderHeight:OCMPhotoNavHeight];
            scrollView.contentOffset =
                ccp(0, scrollView.contentOffset.y - (selectPhotoVC.selectPhotoView.height-OCMPhotoScrollTop));
        }
    }
    scrollView.delegate = self;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    CGFloat scrolled = scrollView.contentOffset.y - self.scrollBeginOffset.y;
    if (self.touching && !selectPhotoVC.locked) {
        if (scrolled > self.touchBeginY) {
            if (velocity.y > 0) {
                if (selectPhotoVC.selectPhotoView.top > OCMPhotoScrollTop - selectPhotoVC.selectPhotoView.height) {
                    [self setToTopWithAnimation:YES];
                }
            } else {
                [UIView animateWithDuration:.2 animations:^{
                    [self setSelectViewTop:0];
                } completion:^(BOOL finished) {
                    [selectPhotoVC.selectViewCover removeFromSuperview];
                    [self setHeaderHeight:OCMPhotoNavHeight];
                    [selectPhotoVC.view setNeedsLayout];
                    scrollView.contentOffset =
                        ccp(0, scrollView.contentOffset.y - (selectPhotoVC.selectPhotoView.height-OCMPhotoScrollTop));
                }];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.touching = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)touchMoved:(NSValue *)moved inView:(UIView *)view
{
    if (moved.CGPointValue.y < 0) {
        return;
    }
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    OCMPhotosCollectionView *collectionView = (OCMPhotosCollectionView *)self.collectionView;
    if (OCMPhotoScrollTop - selectPhotoVC.selectPhotoView.height + moved.CGPointValue.y <= 0) {
        if (collectionView.startOffsetTop == 0) {
            collectionView.startOffsetTop = collectionView.contentOffset.y;
        }
        if (selectPhotoVC.selectPhotoView.top == 0) {
            self.navigationController.view.top = OCMPhotoScrollTop;
            self.navigationController.view.height = selectPhotoVC.view.height - OCMPhotoScrollTop;
            selectPhotoVC.locked = YES;
        }
        [self setSelectViewTop:OCMPhotoScrollTop - selectPhotoVC.selectPhotoView.height + moved.CGPointValue.y];
        collectionView.contentOffset = ccp(collectionView.contentOffset.x, collectionView.startOffsetTop - moved.CGPointValue.y);
    } else if (selectPhotoVC.locked) {
        selectPhotoVC.locked = NO;
        [self setSelectViewTop:0];
        [selectPhotoVC.view setNeedsLayout];
        collectionView.contentOffset = ccp(collectionView.contentOffset.x, collectionView.startOffsetTop - moved.CGPointValue.y + selectPhotoVC.selectPhotoView.height - OCMPhotoScrollTop);
    } else {
        collectionView.contentOffset = ccp(collectionView.contentOffset.x, collectionView.startOffsetTop - moved.CGPointValue.y + selectPhotoVC.selectPhotoView.height - OCMPhotoScrollTop);
    }
}

- (void)touchEnded:(NSValue *)moved inView:(OCMPhotoCover *)view
{
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    OCMPhotosCollectionView *collectionView = (OCMPhotosCollectionView *)self.collectionView;
    if (selectPhotoVC.selectPhotoView.top == 0) { // 已经放下来了
        [selectPhotoVC.selectViewCover removeFromSuperview];
        collectionView.startOffsetTop = 0;
    } else if (selectPhotoVC.selectPhotoView.top <= OCMPhotoScrollTop - selectPhotoVC.selectPhotoView.height) { // 还在顶上
        if (moved.CGPointValue.y > -5) { // 轻点
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        } else {
            collectionView.startOffsetTop = 0;
        }
    } else { // 还在半空中
        if (moved.CGPointValue.y > view.lastMoved.y) { // 向下仍
            [UIView animateWithDuration:.2 animations:^{
                [self setSelectViewTop:0];
                selectPhotoVC.locked = NO;
            } completion:^(BOOL finished) {
                [selectPhotoVC.selectViewCover removeFromSuperview];
                [selectPhotoVC.view setNeedsLayout];
                collectionView.contentOffset = ccp(collectionView.contentOffset.x, collectionView.startOffsetTop - moved.CGPointValue.y + selectPhotoVC.selectPhotoView.height - OCMPhotoScrollTop);
                collectionView.startOffsetTop = 0;
            }];
        } else { // 向上仍
            [UIView animateWithDuration:.2 animations:^{
                [self setSelectViewTop:OCMPhotoScrollTop - selectPhotoVC.selectPhotoView.height];
            }];
            collectionView.startOffsetTop = 0;
        }
    }
}

- (void)haulDownSelectPhotoView
{
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    OCMPhotosCollectionView *collectionView = (OCMPhotosCollectionView *)self.collectionView;
    if (selectPhotoVC.selectPhotoView.top < 0) {
        [UIView animateWithDuration:.2 animations:^{
            [self setSelectViewTop:0];
            selectPhotoVC.locked = NO;
            [selectPhotoVC.selectViewCover removeFromSuperview];
            [selectPhotoVC.view setNeedsLayout];
            collectionView.startOffsetTop = 0;
        } completion:^(BOOL finished) {
            [self photoSelected];
        }];
    }
}

- (void)photoSelected
{
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    NSInteger row = [self.assets indexOfObject:selectPhotoVC.selectedAsset];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

- (void)tapTop
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

@end
