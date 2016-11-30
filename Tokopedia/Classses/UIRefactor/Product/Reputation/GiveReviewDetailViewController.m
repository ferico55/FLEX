//
//  GiveReviewDetailViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "GiveReviewDetailViewController.h"
#import "TKPDTextView.h"
#import "DetailReputationReview.h"
#import "ReviewSummaryViewController.h"
#import "CameraAlbumListViewController.h"
#import "CameraCollectionViewController.h"
#import "CameraController.h"
#import "ProductAddCaptionViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ReviewImageAttachment.h"
#import "Tokopedia-Swift.h"
#import "AttachedPicture.h"

#import <QuartzCore/QuartzCore.h>

@interface GiveReviewDetailViewController () <CameraCollectionViewControllerDelegate, CameraControllerDelegate, ProductAddCaptionDelegate, UITextViewDelegate> {
    BOOL _hasImages;
    
    NSMutableArray *_attachedPictures;
    NSMutableArray *_uploadedPictures;
    NSMutableArray *_tempUploadedPictures;
    NSMutableArray *_imageIDs;
    
    NSArray *_selectedAssets;
    
    NSMutableDictionary *_productReviewPhotoObjects;
    NSMutableDictionary *_imagesToUpload;
}

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet TKPDTextView *reviewDetailTextView;
@property (weak, nonatomic) IBOutlet UIView *attachedImageView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *attachedImagesArray;


@end

@implementation GiveReviewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isEdit? @"Ubah Ulasan" : @"Tulis Ulasan";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToContinue:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:nil];
    
    _attachedPictures = [NSMutableArray new];
    _uploadedPictures = [NSMutableArray new];
    _tempUploadedPictures = [NSMutableArray new];
    _imageIDs = [NSMutableArray new];
    
    _selectedAssets = [NSArray new];
    _attachedImagesArray = [NSArray sortViewsWithTagInArray:_attachedImagesArray];
    _productReviewPhotoObjects = [NSMutableDictionary new];
    _imagesToUpload = [NSMutableDictionary new];
    
    _reviewDetailTextView.placeholder = @"Tulis Ulasan Anda";
    _reviewDetailTextView.delegate = self;
    
    _productName.text = [NSString convertHTML:_review.product_name];
    [_productImage setImageWithURL:[NSURL URLWithString:_review.product_image]
                  placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]];
    
    if (_review.review_image_attachment.count > 0) {
        _hasImages = YES;
        
        for (int ii = 0; ii < _review.review_image_attachment.count; ii++) {
            ReviewImageAttachment *imageAttachment = _review.review_image_attachment[ii];
            
            NSURL *url = [NSURL URLWithString:imageAttachment.uri_thumbnail];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            __block UIImage *image = nil;
            __weak typeof(self) weakSelf = self;
            
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                                       if (!connectionError) {
                                           image = [[UIImage alloc] initWithData:data];
                                       } else {
                                           image = [UIImage imageNamed:@"icon_toped_loading_grey-01.png"];
                                       }
                                       
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           AttachedPicture *pict = [AttachedPicture new];
                                           pict.image = image;
                                           pict.largeUrl = imageAttachment.uri_large;
                                           pict.thumbnailUrl = imageAttachment.uri_thumbnail;
                                           pict.imageDescription = imageAttachment.desc;
                                           pict.attachmentID = imageAttachment.attachment_id;
                                           pict.isDeleted = @"0";
                                           pict.isPreviouslyUploaded = @"1";
                                           
                                           [_uploadedPictures addObject:pict];
                                           [_attachedPictures addObject:pict];
                                           [_tempUploadedPictures addObject:pict];
                                           
                                           [weakSelf setAttachedPictures];
                                       });
                                   }];
        }
    } else {
        [self setAttachedPictures];
    }
    
    if (_isEdit) {
        _reviewDetailTextView.text = [NSString convertHTML:_review.review_message];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.title = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = _isEdit ? @"Ubah Ulasan" : @"Tulis Ulasan";
    
    [AnalyticsManager trackScreenName:@"Give Review Detail Page"];
}

- (void)setAttachedPictures {
    if (_attachedPictures.count > 0) {
        for (int jj = 0; jj < _attachedPictures.count; jj++) {
            for (UIImageView *imageView in _attachedImagesArray) {
                if (imageView.tag == 20 + jj) {
                    AttachedPicture *pict = _attachedPictures[jj];
                    
                    if (![pict.thumbnailUrl isEqualToString:@""]) {
                        [imageView setImageWithURL:[NSURL URLWithString:pict.thumbnailUrl]
                                  placeholderImage:[UIImage imageNamed:@"image_not_loading.png"]];
                    } else {
                        imageView.image = pict.image;
                    }
                    
                    
                    imageView.userInteractionEnabled = YES;
                }
            }
        }
        
        if (_attachedPictures.count < 5) {
            [self initCameraIconAtIndex:_attachedPictures.count];
        }
    } else {
        [self initCameraIconAtIndex:0];
    }
}

#pragma mark - Methods
- (void)initCameraIconAtIndex:(NSInteger)index {
    for (UIImageView *image in _attachedImagesArray) {
        if (image.tag == 20 + index) {
            image.image = [UIImage imageNamed:@"icon_camera.png"];
            image.alpha = 1;
            image.hidden = NO;
            image.userInteractionEnabled = YES;
            image.contentMode = UIViewContentModeCenter;
            [image.layer setBorderColor:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
            [image.layer setBorderWidth:1.0];
            image.layer.cornerRadius = 5.0;
            image.layer.masksToBounds = YES;
        }
    }
}

- (BOOL)isSuccessValidateMessage {
    if ([_reviewDetailTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Ulasan harus diisi."] delegate:self];
        [stickyAlertView show];
        return NO;
    } else if ([_reviewDetailTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 30) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Ulasan yang diberikan harus minimal 30 karakter."] delegate:self];
        [stickyAlertView show];
        return NO;
    } else {
        _reviewMessage = _reviewDetailTextView.text;
        return YES;
    }
}

- (BOOL)image:(UIImage*)image1 isEqualTo:(UIImage*)image2 {
    return [UIImagePNGRepresentation(image1) isEqual:UIImagePNGRepresentation(image2)];
}

- (NSString*)generateUniqueImageID {
    int unixTime = (int) [[NSDate date] timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%d", unixTime];
}

- (void)generateProductReviewPhotoObject:(NSMutableArray*)attachedPictures
                        uploadedPictures:(NSMutableArray*)uploadedPictures {
    _productReviewPhotoObjects = [NSMutableDictionary new];
    _imagesToUpload = [NSMutableDictionary new];
    _imageIDs = [NSMutableArray new];
    
    for (int ii = 0; ii < uploadedPictures.count; ii++) {
        AttachedPicture *pict = uploadedPictures[ii];
        NSMutableDictionary *photoObject = [NSMutableDictionary new];
        
        [photoObject setObject:pict.imageDescription
                        forKey:@"file_desc"];
        [photoObject setObject:pict.attachmentID
                        forKey:@"attachment_id"];
        [photoObject setObject:pict.isDeleted
                        forKey:@"is_deleted"];
        
        NSString *uniqueID;
        
        if ([pict.isPreviouslyUploaded isEqualToString:@"0"]) {
            uniqueID = [[self generateUniqueImageID] stringByAppendingString:[NSString stringWithFormat:@"%zd", ii]];
        } else {
            uniqueID = pict.attachmentID;
        }
        
        [_productReviewPhotoObjects setObject:photoObject
                                       forKey:uniqueID];
        
        [_imageIDs addObject:uniqueID];
    }
    
    for (int ii = 0; ii < attachedPictures.count; ii++) {
        AttachedPicture *pict = attachedPictures[ii];
        NSMutableDictionary *photoObject = [NSMutableDictionary new];
        
        [photoObject setObject:pict.imageDescription
                        forKey:@"file_desc"];
        [photoObject setObject:pict.attachmentID
                        forKey:@"attachment_id"];
        [photoObject setObject:pict.isDeleted
                        forKey:@"is_deleted"];
        
        NSString *uniqueID;
        
        if ([pict.isPreviouslyUploaded isEqualToString:@"0"]) {
            uniqueID = [[self generateUniqueImageID] stringByAppendingString:[NSString stringWithFormat:@"%zd", ii]];
        } else {
            uniqueID = pict.attachmentID;
        }
        
        [_productReviewPhotoObjects setObject:photoObject
                                       forKey:uniqueID];
        
        NSDictionary *temp = @{@"image" : pict.image,
                               @"name"  : pict.fileName?:@"image.png"};
        
        if (![_imageIDs containsObject:uniqueID]) {
            [_imageIDs addObject:uniqueID];
        }
        
        if ([pict.isPreviouslyUploaded isEqualToString:@"0"]) {
            [_imagesToUpload setObject:temp
                                forKey:uniqueID];
        }
    }
}

#pragma mark - Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    _reviewDetailTextView.placeholder = nil;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [_reviewDetailTextView resignFirstResponder];
    _reviewDetailTextView.placeholder = @"Tulis Ulasan Anda";
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    _reviewMessage = newString;
    
    return YES;
}

#pragma mark - Actions
- (IBAction)tapToContinue:(id)sender {
    if ([self isSuccessValidateMessage]) {
        [self generateProductReviewPhotoObject:_attachedPictures
                              uploadedPictures:_uploadedPictures];
        
        if (_attachedPictures.count > 0) {
            _hasImages = YES;
        }
        
        ReviewSummaryViewController *vc = [ReviewSummaryViewController new];
        vc.review = _review;
        vc.isEdit = _isEdit;
        vc.qualityRate = _qualityRate;
        vc.accuracyRate = _accuracyRate;
        vc.reviewMessage = _reviewMessage;
        vc.token = _token;
        vc.imagesToUpload = _imagesToUpload;
        vc.imageDescriptions = _productReviewPhotoObjects;
        vc.hasAttachedImages = _hasImages;
        vc.imageIDs = _imageIDs;
        vc.attachedImages = _attachedPictures;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)tapImage:(UITapGestureRecognizer*)sender {
    if ([self image:((UIImageView*)_attachedImagesArray[sender.view.tag-20]).image isEqualTo:[UIImage imageNamed:@"icon_camera.png"]]) {
        [ImagePickerController showImagePicker:self
                                     assetType:DKImagePickerControllerAssetTypeallPhotos
                           allowMultipleSelect:YES
                                    showCancel:YES
                                    showCamera:YES
                                   maxSelected:(5 - _tempUploadedPictures.count)
                                selectedAssets:_selectedAssets
                                    completion:^(NSArray<DKAsset *> *asset) {
                                        if (asset.count == 0) {
                                            if (_attachedPictures.count > 0) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    NSMutableArray *temp = [_tempUploadedPictures mutableCopy];
                                                    _selectedAssets = [NSArray new];
                                                    
                                                    ProductAddCaptionViewController *vc = [ProductAddCaptionViewController new];
                                                    vc.delegate = self;
                                                    vc.attachedPictures = temp;
                                                    vc.isEdit = _isEdit;
                                                    vc.selectedAssets = asset;
                                                    vc.uploadedPictures = _uploadedPictures;
                                                    vc.tempUploadedPictures = _tempUploadedPictures;
                                                    vc.selectedImageTag = sender.view.tag;
                                                    
                                                    [self.navigationController pushViewController:vc animated:NO];
                                                });
                                            }
                                        } else if (asset.count > 0) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                NSMutableArray *temp = [_tempUploadedPictures mutableCopy];
                                                
                                                for (int ii = 0; ii < asset.count; ii++) {
                                                    DKAsset *dk = asset[ii];
                                                    AttachedPicture *pict = [AttachedPicture new];
                                                    BOOL isAdded = NO;
                                                    
                                                    for (int jj = 0; jj < _attachedPictures.count; jj++) {
                                                        AttachedPicture *tempPict = _attachedPictures[jj];
                                                        if ([tempPict.fileName isEqualToString:dk.fileName]) {
                                                            pict = tempPict;
                                                            
                                                            [temp addObject:pict];
                                                            isAdded = YES;
                                                        }
                                                    }
                                                    
                                                    if (!isAdded) {
                                                        pict.image = dk.resizedImage;
                                                        pict.fileName = dk.fileName;
                                                        pict.thumbnailUrl = @"";
                                                        pict.largeUrl = @"";
                                                        pict.imageDescription = @"";
                                                        pict.attachmentID = @"0";
                                                        pict.isDeleted = @"0";
                                                        pict.isPreviouslyUploaded = @"0";
                                                        
                                                        [temp addObject:pict];
                                                        isAdded = YES;
                                                    }
                                                }
                                                
                                                ProductAddCaptionViewController *vc = [ProductAddCaptionViewController new];
                                                vc.delegate = self;
                                                vc.attachedPictures = temp;
                                                vc.isEdit = _isEdit;
                                                vc.selectedAssets = asset;
                                                vc.uploadedPictures = _uploadedPictures;
                                                vc.tempUploadedPictures = _tempUploadedPictures;
                                                vc.selectedImageTag = sender.view.tag;
                                                
                                                [self.navigationController pushViewController:vc animated:NO];
                                            });
                                        }
                                    }];
        
    } else {
        ProductAddCaptionViewController *vc = [ProductAddCaptionViewController new];
        vc.delegate = self;
        vc.attachedPictures = _attachedPictures;
        vc.isEdit = _isEdit;
        vc.selectedAssets = _selectedAssets;
        vc.uploadedPictures = _uploadedPictures;
        vc.tempUploadedPictures = _tempUploadedPictures;
        vc.selectedImageTag = sender.view.tag;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Product Add Caption Delegate
- (void)updateAttachedPictures:(NSArray *)attachedPictures
                selectedAssets:(NSArray *)selectedAssets
              uploadedPictures:(NSArray *)uploadedPictures
          tempUploadedPictures:(NSArray *)tempUploadedPictures {
    _attachedPictures = [attachedPictures mutableCopy];
    _selectedAssets = selectedAssets;
    _uploadedPictures = [uploadedPictures mutableCopy];
    _tempUploadedPictures = [tempUploadedPictures mutableCopy];
    
    if (_attachedPictures.count == 0) {
        _hasImages = NO;
    }
    
    for (UIImageView *imageView in _attachedImagesArray) {
        imageView.image = nil;
        imageView.userInteractionEnabled = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView.layer setBorderColor:[[UIColor clearColor] CGColor]];
        [imageView.layer setBorderWidth:0];
        [imageView.layer setCornerRadius:0];
        [imageView.layer setMasksToBounds:NO];
    }
    
    [self setAttachedPictures];
}

@end
