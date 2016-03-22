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
#import "ProductAddCaptionViewController.h"
#import "GiveReviewViewController.h"
#import "TKPDLiveCameraTableViewCell.h"
#import "TKPDPhotoPicker.h"

NSString *const TKPDCameraAlbumListLiveVideoCellIdentifier = @"TKPDCameraAlbumListLiveVideoCellIdentifier";

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

@interface CameraCollectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate, TKPDPhotoPickerDelegate>
{
    BOOL _isnodata;
    NSMutableArray *_groupAlbums;
    
    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *mutableArray;
    
    NSMutableArray *_selectedImages;
    
    BOOL _isNeedDismiss;
    BOOL _didPresentPicker;
    
    TKPDPhotoPicker *_photoPicker;
    NSMutableArray *selectedIndexPath;
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
    
    if (_maxSelected == 0) {
        _maxSelected = 5;
    }
    
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
    [_collectionview registerClass:[TKPDLiveCameraTableViewCell class] forCellWithReuseIdentifier:TKPDCameraAlbumListLiveVideoCellIdentifier];
    
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
    
    _collectionview.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    
    selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPath) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    TKPDLiveCameraTableViewCell *cameraCell = (TKPDLiveCameraTableViewCell *)[_collectionview cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [cameraCell freezeCapturedContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_didPresentPicker) {
        TKPDLiveCameraTableViewCell *cameraCell = (TKPDLiveCameraTableViewCell *)[_collectionview cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        [cameraCell restartCaptureSession];
        _didPresentPicker = NO;
    }
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
        
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        [self.assets addObjectsFromArray:[tmpAssets sortedArrayUsingDescriptors:@[sort]]];
//        self.assets = tmpAssets;
        
        [_collectionview reloadData];
    } failureBlock:failureBlock];
}

#pragma mark - assets

- (ALAssetsLibrary *)defaultAssetsLibrary
{
    if (library == nil) {
        library = [[ALAssetsLibrary alloc] init];
    }
    return library;
}

-(void)getAssetPhotosGroup:(ALAssetsGroup*)album
{
    _assetsGroup = album;
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            [tmpAssets addObject:result];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
    
    [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [self.assets addObjectsFromArray:[tmpAssets sortedArrayUsingDescriptors:@[sort]]];
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

        
        if (indexPath.row == 0) {
            
            TKPDLiveCameraTableViewCell *cameraCell = [_collectionview dequeueReusableCellWithReuseIdentifier:TKPDCameraAlbumListLiveVideoCellIdentifier forIndexPath:indexPath];
            cell = cameraCell;
            [cameraCell startLiveVideo];
        }
        else{
            cell = (CameraCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
            ((CameraCollectionCell*)cell).checkmarkImageView.hidden = YES;
            
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
    NSArray *arrayIndexPath = (_isAddEditProduct)?_selectedIndexPath:selectedIndexPath;
    for (id selected in arrayIndexPath) {
        if ([selected isKindOfClass:[NSIndexPath class]]) {
            if (((NSIndexPath*)selected).row>0) {
                ALAsset *asset = _assets[((NSIndexPath*)selected).row-1];
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
        }
    }
    if (_isAddReviewImage && _selectedImages.count > 0) {
        ProductAddCaptionViewController *vc = [ProductAddCaptionViewController new];
        vc.selectedImages = [_selectedImages copy];
        vc.selectedIndexPaths = arrayIndexPath;
        vc.delegate = _delegate;
        vc.review = _review;
        vc.imagesCaptions = _attachedImagesCaptions;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (_isAddMoreReviewImage) {
        [_delegate didReceiveImageWithSelectedImages:[_selectedImages copy]
                                  selectedIndexPaths:arrayIndexPath
                              attachedImagesCaptions:_attachedImagesCaptions];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    } else {
        [_delegate didDismissController:self withUserInfo:@{@"selected_images":[_selectedImages copy], @"selected_indexpath":arrayIndexPath}];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TKPDLiveCameraTableViewCell class]]) {
        TKPDLiveCameraTableViewCell *cameraCell = (TKPDLiveCameraTableViewCell *)cell;
        [cameraCell stopLiveVideo];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        _didPresentPicker = YES;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            TKPDLiveCameraTableViewCell *cameraCell = (TKPDLiveCameraTableViewCell *)[collectionView cellForItemAtIndexPath:indexPath];selectedIndexPath
//            [cameraCell freezeCapturedContent];
//        });
        
        _photoPicker = [[TKPDPhotoPicker alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera parentViewController:self pickerTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [_photoPicker setDelegate:self];
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
            [selectedIndexPath removeObject:indexPath];
            if ([self.delegate respondsToSelector:@selector(didRemoveImageDictionary:)]) {
                [_delegate didRemoveImageDictionary:selectedImage];
            }
            if(!_isAddEditProduct)[_selectedIndexPath removeObject:indexPath];
            else
            {
                for (int i=0; i<_selectedIndexPath.count; i++) {
                    if ([_selectedIndexPath[i] isEqual:indexPath]) {
                        [_selectedIndexPath replaceObjectAtIndex:i withObject:@""];
                        break;
                    }
                }
            }
        }
        else
        {
            if (selectedIndexPath.count < _maxSelected) {
                cell.checkmarkImageView.hidden = NO;
                [selectedIndexPath addObject:indexPath];
                if(!_isAddEditProduct)[_selectedIndexPath addObject:indexPath];
                else
                {
                    for (int i=0; i<_selectedIndexPath.count; i++) {
                        if ([_selectedIndexPath[i] isEqual:@""]) {
                            [_selectedIndexPath replaceObjectAtIndex:i withObject:indexPath];
                            break;
                        }
                    }
                }
            }
            
        }
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
    float widthView = kTKPDCAMERA_MAXIMAGESIZE.width;//self.view.frame.size.width;
    float heightView = kTKPDCAMERA_MAXIMAGESIZE.height;//self.view.frame.size.height;
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


-(void)dissmissViewController:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

// MARK: TKPDPhotoPickerDelegate methods

- (void)photoPicker:(TKPDPhotoPicker *)picker didDismissCameraControllerWithUserInfo:(NSDictionary *)userInfo {
    [_selectedImages addObject:userInfo];
    [_selectedIndexPath addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSDictionary *userInfoDict = @{@"selected_images":[_selectedImages copy], DATA_CAMERA_SOURCE_TYPE:@(UIImagePickerControllerSourceTypeCamera), @"selected_indexpath":_selectedIndexPath};
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [_delegate didDismissController:self withUserInfo:userInfoDict];
    
    _photoPicker = nil;
}

@end
