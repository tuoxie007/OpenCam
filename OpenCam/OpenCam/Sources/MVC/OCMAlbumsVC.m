//
//  OCMAlbumsVC.m
//  OpenCam
//
//  Created by Jason Hsu on 11/5/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "OCMAlbumsVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "OCMAlbumCell.h"
#import "OCMPhotosVC.h"
#import "OCMSelectPhotoVC.h"
#import "OCMDefinitions.h"

@interface OCMAlbumsVC ()

//@property (nonatomic, strong) ALAssetsLibrary *assetsLib;
@property (nonatomic, strong) NSMutableArray *albumNames;
@property (nonatomic, strong) NSMutableArray *groupURLs;

@end

@implementation OCMAlbumsVC

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.tableView registerClass:[OCMAlbumCell class] forCellReuseIdentifier:@"OCMAlbumCell"];
    self.tableView.backgroundColor = [UIColor colorWithWhite:20/255.0f alpha:1];
    self.tableView.separatorColor = [UIColor colorWithWhite:40/255.0f alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.albumNames = [NSMutableArray array];
    self.groupURLs = [NSMutableArray array];
    
    ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
    //self.assetsLib = assetsLib;
    __weak typeof(self)weakSelf = self;
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSURL *groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
            [weakSelf.groupURLs addObject:groupURL];
            NSString *albumnName = [group valueForProperty:ALAssetsGroupPropertyName];
            [weakSelf.albumNames addObject:albumnName];
            [weakSelf.tableView reloadData];
        } else {
            weakSelf.groupURLs = [[[weakSelf.groupURLs reverseObjectEnumerator] allObjects] mutableCopy];
            weakSelf.albumNames = [[[weakSelf.albumNames reverseObjectEnumerator] allObjects] mutableCopy];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Load Photo Albums Failed");
    }];
    
    [super viewWillAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albumNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OCMAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OCMAlbumCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.albumNames.count > indexPath.row) {
        NSString *albumName = self.albumNames[indexPath.row];
        cell.textLabel.text = albumName;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [OCMAlbumCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *albumnName = self.albumNames[indexPath.row];
    NSURL *albumnURL = self.groupURLs[indexPath.row];
    OCMSelectPhotoVC *selectPhotoVC = (OCMSelectPhotoVC *)self.navigationController.parentViewController;
    OCMPhotosVC *photosVC = (OCMPhotosVC *)((OCMPhotoCover *)selectPhotoVC.selectViewCover).delegate;
    if (photosVC == nil) {
        photosVC = [[OCMPhotosVC alloc] init];
    }
    photosVC.albumName = albumnName;
    photosVC.albumURL = albumnURL;
    [self.navigationController pushViewController:photosVC animated:YES];
}

@end
