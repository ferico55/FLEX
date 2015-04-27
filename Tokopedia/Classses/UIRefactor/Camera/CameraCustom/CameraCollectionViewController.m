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
    
    NSMutableArray *_selectedImages;
    
    BOOL _isNeedDismiss;
    
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
    _selectedImages = [NSMutableArray new];
    if (_selectedIndexPath == nil || _selectedIndexPath.count == 0) {
        _selectedIndexPath = [NSMutableArray new];
    }
    
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
    
    [_selectedImages addObjectsFromArray:_selectedImagesArray];
}

-(void)getAllPictures
{
    _assets = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];

    ALAssetsLibrary *assetsLibrary = [self defaultAssetsLibrary];
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
            {
                errorMessage = @"You can enable access in Privacy Setting";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This app does not have access to your photos or videos." message:errorMessage delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alert show];
                UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_close_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dissmissViewController:)];
                [backBarButtonItem setTintColor:[UIColor whiteColor]];
                self.navigationItem.leftBarButtonItem = backBarButtonItem;
                self.navigationItem.rightBarButtonItem = nil;
                break;
            }
            default:
                errorMessage = @"Reason unknown.";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
                [alert show];
                break;
        }
    };

    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                
                [tmpAssets addObject:result];
            }
        }];
        
        
        //NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        //self.assets = [tmpAssets sortedArrayUsingDescriptors:@[sort]];
        self.assets = tmpAssets;
        
        [_collectionview reloadData];
    } failureBlock:failureBlock];
}

#pragma mark - assets

- (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
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
        ((CameraCollectionCell*)cell).checkmarkImageView.hidden = YES;
        
        if (indexPath.row == 0) {
            ((CameraCollectionCell*)cell).thumb.image = [UIImage imageNamed:@"icon_camera_album.png"];
        }
        else{
            for (NSIndexPath *selected in _selectedIndexPath) {
                ((CameraCollectionCell*)cell).checkmarkImageView.hidden = !([indexPath isEqual:selected]);
                if (([indexPath isEqual:selected])) {
                    break;
                }
            }
            
            // load the asset for this cell
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                // Load image on a non-ui-blocking thread
                ALAsset *asset = _assets[indexPath.row-1];
                UIImage *thumb = [UIImage imageWithCGImage:[asset thumbnail]];
                
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    // Assign image back on the main thread
                    ((CameraCollectionCell*)cell).thumb.image = thumb;
                });
            });
            

        }
	}
    
    return cell;
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

-(IBAction)tap:(id)sender
{
    [_selectedImages removeAllObjects];
    for (NSIndexPath *selected in _selectedIndexPath) {
        ALAsset *asset = _assets[selected.row-1];
        UIImage *rawImage = [UIImage imageWithCGImage:[[asset defaultRepresentation]
                                                       fullScreenImage]];
        NSString* mediaType = @"public.image";
        NSString* imageName = [[asset defaultRepresentation] filename];
        
        UIImage *resizedImage = [self resizedImage:rawImage];
        
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
        
        NSDictionary *selectedImage = @{kTKPDCAMERA_DATAPHOTOKEY:@{
                                                kTKPDCAMERA_DATARAWPHOTOKEY:rawImage?:@"",
                                                kTKPDCAMERA_DATAMEDIATYPEKEY:mediaType?:@"",
                                                kTKPDCAMERA_DATAPHOTOKEY:resizedImage?:@"",
                                                DATA_CAMERA_IMAGENAME:imageName?:@"image.png",
                                                DATA_CAMERA_IMAGEDATA:imageDataResizedImage?:@""
                                                }};
        [_selectedImages addObject:selectedImage];
        
    }
    [_delegate didDismissController:self withUserInfo:@{@"selected_images":[_selectedImages copy], @"selected_indexpath":[_selectedIndexPath copy]}];
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
        
        UIImage *resizedImage = [self resizedImage:rawImage];
        
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
        
        NSDictionary *selectedImage = @{kTKPDCAMERA_DATAPHOTOKEY:@{
                                                kTKPDCAMERA_DATARAWPHOTOKEY:rawImage?:@"",
                                                kTKPDCAMERA_DATAMEDIATYPEKEY:mediaType?:@"",
                                                kTKPDCAMERA_DATAPHOTOKEY:resizedImage?:@"",
                                                DATA_CAMERA_IMAGENAME:imageName?:@"image.png",
                                                DATA_CAMERA_IMAGEDATA:imageDataResizedImage?:@""
                                                }};
        
        CameraCollectionCell* cell = (CameraCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
        if ([_selectedIndexPath containsObject:indexPath]) {
            cell.checkmarkImageView.hidden = YES;
            [_selectedIndexPath removeObject:indexPath];
            [_delegate didRemoveImageDictionary:selectedImage];
        }
        else
        {
            if (_selectedIndexPath.count <5) {
                cell.checkmarkImageView.hidden = NO;
                [_selectedIndexPath addObject:indexPath];
            }
            
        }
        //cell.checkmarkImageView.hidden = !cell.checkmarkImageView.hidden;
        //NSMutableArray *selectedTemp= [NSMutableArray new];
        
        //if ([[_selectedImages copy] containsObject:selectedImage]) {
        //if ([self Array:[_selectedImages copy] containObject:selectedImage]) {
        //    for (NSDictionary *objectInArray in [_selectedImages copy]) {
        //        NSDictionary *photoObjectInArray = [objectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
        //        NSDictionary *photoObject = [selectedImage objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
        //        if (![self image:[photoObjectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY] isEqualTo:[photoObject objectForKey:kTKPDCAMERA_DATAPHOTOKEY]]) {
        //            [selectedTemp addObject:objectInArray];
        //        }
        //    }
        //    cell.checkmarkImageView.hidden = YES;
        //    //[_selectedImages removeObject:selectedImage];
        //    [_selectedImages removeAllObjects];
        //    [_selectedImages addObjectsFromArray:selectedTemp];
        //}
        //else
        //{
        //    if (_selectedImages.count < 5)
        //        cell.checkmarkImageView.hidden = NO;
        //        [_selectedImages addObject:selectedImage];
        //}

        //[_collectionview reloadData];
    }
}

-(BOOL)Array:(NSArray*)array containObject:(NSDictionary*)object
{
    for (NSDictionary *objectInArray in array) {
        NSDictionary *photoObjectInArray = [objectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
        NSDictionary *photoObject = [object objectForKey:kTKPDCAMERA_DATAPHOTOKEY];
        if ([self image:[photoObjectInArray objectForKey:kTKPDCAMERA_DATAPHOTOKEY] isEqualTo:[photoObject objectForKey:kTKPDCAMERA_DATAPHOTOKEY]]) {
            return YES;
        }
    }
    return NO;
}

-(UIImage *)resizedImage:(UIImage*)rawImage
{
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
    
    return resizedImage;
}

-(void)didDismissCameraController:(CameraController *)controller withUserInfo:(NSDictionary *)userinfo
{
    NSDictionary *userInfoDict = @{@"selected_images":@[userinfo]};
    [_delegate didDismissController:self withUserInfo:userInfoDict];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)dissmissViewController:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
