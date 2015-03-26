//
//  CameraCollectionViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "camera.h"
#import "CameraController.h"
#import "CameraCollectionViewController.h"
#import "CameraCollectionCell.h"

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

@interface CameraCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate, CameraControllerDelegate>
{
    BOOL _isnodata;
    NSMutableArray *_groupAlbums;
    
    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *mutableArray;
    
    BOOL _isNeedDismiss;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property(nonatomic, strong) NSMutableArray *assets;

@end

@implementation CameraCollectionViewController

static int count=0;
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
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selesai" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [backBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = backBarButtonItem;
    
    [_collectionview registerNib:[UINib nibWithNibName:@"CameraCollectionCell" bundle:[NSBundle mainBundle]]
        forCellWithReuseIdentifier:@"CameraCollectionCellIdentifier"];
    
    if (!self.assets) {
        _assets = [[NSMutableArray alloc] init];
    } else {
        [_assets removeAllObjects];
    }
    
    if (!_assetsGroup) {
        [self getAllPictures];
    }
    else
    {
        [self getAssetPhotosGroup:_assetsGroup];
    }
    
    _groupAlbums = [NSMutableArray new];
}

-(void)getAllPictures
{
    imageArray=[[NSArray alloc] init];
    mutableArray =[[NSMutableArray alloc]init];
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    
    library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                [_assets addObject:result];
                [_collectionview reloadData];
            }
        }
    };
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
            count=[group numberOfAssets];
        }
    };
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}

-(void)getAssetPhotosGroup:(ALAssetsGroup*)album
{
    _assetsGroup = album;
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [_assets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    [_collectionview reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _assets.count+1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = @"CameraCollectionCellIdentifier";

		cell = (CameraCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];

        if (indexPath.row == 0) {
            ((CameraCollectionCell*)cell).thumb.image = [UIImage imageNamed:@"icon_camera_grey_active.png"];
        }
        else{
            // load the asset for this cell
            ALAsset *asset = _assets[indexPath.row-1];
            // apply the image to the cell
            ((CameraCollectionCell*)cell).thumb.image = [UIImage imageWithCGImage:[asset thumbnail]];
        }
	}
    
    return cell;
}

-(IBAction)tap:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        CameraController* c = [CameraController new];
        [c snap];
        c.delegate = self;
        c.isTakePicture = YES;
        c.tag = self.tag;
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:c];
        nav.wantsFullScreenLayout = YES;
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    else
    {
        ALAsset *asset = _assets[indexPath.row-1];
        UIImage *rawImage = [UIImage imageWithCGImage:[[asset defaultRepresentation]
                                                  fullScreenImage]];
        NSString* mediaType = @"public.image";
        NSString* imageName = [[asset defaultRepresentation] filename];
        
        float actualHeight = rawImage.size.height;
        float actualWidth = rawImage.size.width;
        float imgRatio = actualWidth/actualHeight;
        float widthView = self.view.frame.size.width;
        float heightView = self.view.frame.size.height;
        float maxRatio = widthView/heightView;
        
        if(imgRatio!=maxRatio){
            if(imgRatio < maxRatio){
                imgRatio = heightView / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = heightView;
            }
            else{
                imgRatio = widthView / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = widthView;
            }
        }
        CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        [rawImage drawInRect:rect];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //NSString *imageName;
        NSData* imageDataResizedImage;
        if (imageName) {
            NSString *extensionOFImage =[imageName substringFromIndex:[imageName rangeOfString:@"."].location+1 ];
            if ([extensionOFImage isEqualToString:@"jpg"])
                imageDataResizedImage =  UIImagePNGRepresentation(resizedImage);
            else
                imageDataResizedImage = UIImageJPEGRepresentation(resizedImage, 1.0);
        }
        else{
            imageDataResizedImage =  UIImagePNGRepresentation(resizedImage);
        }
        
        NSDictionary *userInfo = @{kTKPDCAMERA_DATAPHOTOKEY:@{
                                   kTKPDCAMERA_DATARAWPHOTOKEY:rawImage?:@"",
                                   kTKPDCAMERA_DATAMEDIATYPEKEY:mediaType?:@"",
                                   kTKPDCAMERA_DATAPHOTOKEY:resizedImage?:@"",
                                   DATA_CAMERA_IMAGENAME:imageName?:@"image.png",
                                   DATA_CAMERA_IMAGEDATA:imageDataResizedImage?:@""
                                   }};
        
        [_delegate didDismissController:self withUserInfo:userInfo];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didDismissCameraController:(CameraController *)controller withUserInfo:(NSDictionary *)userinfo
{
    [_delegate didDismissController:self withUserInfo:userinfo];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
