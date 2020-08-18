//
//  ViewController.m
//  MMBeautyKitDemo
//
//  Created by sunfei on 2019/12/25.
//  Copyright © 2019 sunfei. All rights reserved.
//

#import "ViewController.h"
#import "MMCameraViewController.h"
#import "MMVideoAssetsCollectionViewController.h"
@import Photos;

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *items;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = @[@"相机"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MMViewControllerCell"];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0:
        {
        MMCameraViewController *vc = [[MMCameraViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
        
        void (^pushVC)(void) = ^{
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 1;
            layout.minimumInteritemSpacing = 1;
            layout.itemSize = CGSizeMake(80, 80);
            MMVideoAssetsCollectionViewController *vc = [[MMVideoAssetsCollectionViewController alloc] initWithCollectionViewLayout:layout];
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        void (^showAlert)(void) = ^{
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"申请相册权限" message:@"请在setting页面打开相册权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:okAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        };
        
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PHAuthorizationStatusAuthorized) {
                        pushVC();
                    } else {
                        showAlert();
                    }
                });
            }];
        } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            pushVC();
        } else {
            showAlert();
        }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MMViewControllerCell" forIndexPath:indexPath];
    cell.textLabel.text = self.items[indexPath.row];
    return cell;
}

@end
