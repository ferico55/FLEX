//
//  CameraCollectionViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "CameraCollectionViewController.h"
#import "CameraCollectionCell.h"
#import "CameraCropViewController.h"

@interface ALAssetsLibrary (TkpdCategory)

+ (ALAssetsLibrary *)defaultAssetsLibrary;

@end

@implementation ALAssetsLibrary (TkpdCategory)

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}


@end

@interface CameraCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate, CameraCropViewControllerDelegate>
{
    BOOL _isnodata;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property(nonatomic, strong) NSMutableArray *assets;

@end

@implementation CameraCollectionViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _assets = [NSMutableArray new];
    
    //[_collectionview registerClass:[CameraCollectionCell class] forCellWithReuseIdentifier:@"CameraCollectionCellIdentifier"];
    [_collectionview registerNib:[UINib nibWithNibName:@"CameraCollectionCell" bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:@"CameraCollectionCellIdentifier"];
    
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    if (!self.assets) {
        _assets = [[NSMutableArray alloc] init];
    } else {
        [_assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [_assets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
    //_assets = [@[] mutableCopy];
    //__block NSMutableArray *tmpAssets = [@[] mutableCopy];
    //// 1
    //ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary defaultAssetsLibrary];
    //// 2
    //[assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    //    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
    //        if(result)
    //        {
    //            // 3
    //            [tmpAssets addObject:result];
    //        }
    //    }];
    //    
    //    // 4
    //    //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    //    //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
    //    _assets = tmpAssets;
    //    
    //    // 5
    //    [_collectionview reloadData];
    //} failureBlock:^(NSError *error) {
    //    NSLog(@"Error loading images %@", error);
    //}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CameraCollectionCellIdentifier" forIndexPath:indexPath];
    //
    //ALAsset *asset = self.assets[indexPath.row];
    ////cell.asset = asset;
    //cell.backgroundColor = [UIColor redColor];
    //
    //return cell;
    
    UICollectionViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = @"CameraCollectionCellIdentifier";

		cell = (CameraCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
		if (cell == nil) {
			//cell = [CameraCollectionCell newcell];
			//((CameraCollectionCell*)cell).delegate = self;
		}
        
        // load the asset for this cell
        ALAsset *asset = _assets[indexPath.row];
        
        // apply the image to the cell
        ((CameraCollectionCell*)cell).asset = asset;
	}
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CameraCropViewController *vc = [CameraCropViewController new];
    vc.delegate = self;
    vc.data = @{kTKPDCAMERA_DATAPHOTOKEY: @{kTKPDCAMERA_DATARAWPHOTOKEY:[UIImage imageWithCGImage:[_assets[indexPath.row] thumbnail]]}};
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)CameraCropViewController:(UIViewController *)controller didFinishCroppingMediaWithInfo:(NSDictionary *)userinfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_CROPIMAGEPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
}

@end
