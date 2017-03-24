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
#import "UIBarButtonItem+BlocksKit.h"

#import <QuartzCore/QuartzCore.h>

@interface GiveReviewDetailViewController () <CameraCollectionViewControllerDelegate, CameraControllerDelegate, ProductAddCaptionDelegate, UITextViewDelegate> {
    BOOL _hasImages;
    
    NSMutableArray *_uploadedPictures;
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
@property (strong, nonatomic) ReviewSummaryViewController *reviewSummaryViewController;
// this property prevent crash when user continously press Next (Lanjut) button
@property (nonatomic) BOOL isSubmitButtonValid;

@end

@implementation GiveReviewDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _isEdit? @"Ubah Ulasan" : @"Tulis Ulasan";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Lanjut" style:UIBarButtonItemStyleDone handler:^(id sender) {
        if ([self isSuccessValidateMessage] && _isSubmitButtonValid) {
            [self generateProductReviewPhotoObject:_attachedPictures
                                  uploadedPictures:_uploadedPictures];
            
            if (_attachedPictures.count > 0) {
                _hasImages = YES;
            }
            
            _reviewSummaryViewController.review = _review;
            _reviewSummaryViewController.isEdit = _isEdit;
            _reviewSummaryViewController.qualityRate = _qualityRate;
            _reviewSummaryViewController.accuracyRate = _accuracyRate;
            _reviewSummaryViewController.reviewMessage = _reviewMessage;
            _reviewSummaryViewController.token = _token;
            _reviewSummaryViewController.imagesToUpload = _imagesToUpload;
            _reviewSummaryViewController.imageDescriptions = _productReviewPhotoObjects;
            _reviewSummaryViewController.hasAttachedImages = _hasImages;
            _reviewSummaryViewController.imageIDs = _imageIDs;
            _reviewSummaryViewController.attachedImages = _attachedPictures;
            
            _isSubmitButtonValid = NO;
            [self.navigationController pushViewController:_reviewSummaryViewController animated:YES];
        }
    }];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    
    _attachedPictures = [NSMutableArray new];
    _uploadedPictures = [NSMutableArray new];
    _tempUploadedPictures = [NSMutableArray new];
    _imageIDs = [NSMutableArray new];
    
    _selectedAssets = [NSMutableArray new];
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
            __weak typeof(self) weakSelf = self;
            
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                                       UIImage *image;
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
    
    //reviewSummaryViewController di init di sini supaya facebook share switchnya bisa dimemorize
    _reviewSummaryViewController = [ReviewSummaryViewController new];
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
    _isSubmitButtonValid = YES;
    [AnalyticsManager trackScreenName:@"Give Review Detail Page"];
}

-(NSArray<AttachedPicture *> *)attachedImageWithoutDeletedImage{
    NSMutableArray *attached = [NSMutableArray new];
    
    for (AttachedPicture *pict in _attachedPictures) {
        if (![pict.isDeleted isEqualToString:@"1"]) {
            [attached addObject:pict];
        }
    }
    
    return [attached copy];
}

-(void)setAttachedPictures{
    
    for (UIImageView *imageView in _attachedImagesArray) {
        imageView.hidden = YES;
        [imageView setUserInteractionEnabled:YES];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView.layer setBorderColor:[[UIColor clearColor] CGColor]];
        [imageView.layer setBorderWidth:0];
        [imageView.layer setCornerRadius:0];
        [imageView.layer setMasksToBounds:NO];
    }
    
    int i = 0;
    for (AttachedPicture *pict in _attachedPictures) {
        if (![pict.isDeleted isEqualToString:@"1"] && i<_attachedImagesArray.count) {
            
            ((UIImageView*)_attachedImagesArray[i]).hidden = NO;
            
            AttachedPicture *picture = [self attachedImageWithoutDeletedImage][i];
            
            if (![picture.thumbnailUrl isEqualToString:@""]) {
                
                [((UIImageView*)_attachedImagesArray[i]) setImageWithURL:[NSURL URLWithString:picture.thumbnailUrl]
                          placeholderImage:[UIImage imageNamed:@"image_not_loading.png"]];
                
            } else {
                ((UIImageView*)_attachedImagesArray[i]).image = picture.image;
            }
            i++;
        }
    }
    
    if ([self attachedImageWithoutDeletedImage].count<_attachedImagesArray.count) {
        [self initCameraIconAtIndex:[self attachedImageWithoutDeletedImage].count];
    }
    
}

#pragma mark - Methods
- (void)initCameraIconAtIndex:(NSInteger)index {
    for (UIImageView *image in _attachedImagesArray) {
        if (image.tag == index) {
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
- (IBAction)tapImage:(UITapGestureRecognizer*)sender {
    if (sender.view.tag == [self attachedImageWithoutDeletedImage].count) {
        
        [TKPImagePickerController showImagePicker:self
                                     assetType:DKImagePickerControllerAssetTypeAllPhotos
                           allowMultipleSelect:YES
                                    showCancel:YES
                                    showCamera:YES
                                   maxSelected:(5 - ([self attachedImageWithoutDeletedImage].count-_selectedAssets.count))
                                selectedAssets:_selectedAssets
                                    completion:^(NSArray<DKAsset *> *asset) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            ProductAddCaptionViewController *vc = [[ProductAddCaptionViewController alloc] initWithSelectedAssets:[asset mutableCopy] isEdit:_isEdit uploadedPicture:[_uploadedPictures mutableCopy] selectedImageIndex:(int)([self attachedImageWithoutDeletedImage].count+asset.count-1) delegate:self];
                                            [vc addImageFromAsset];

                                            
                                            [self.navigationController pushViewController:vc animated:NO];
                                        });
                                    }];
        
    } else {
        ProductAddCaptionViewController *vc = [[ProductAddCaptionViewController alloc] initWithSelectedAssets:[_selectedAssets mutableCopy] isEdit:_isEdit uploadedPicture:[_uploadedPictures mutableCopy] selectedImageIndex:(int)sender.view.tag delegate:self];

        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Product Add Caption Delegate
- (void)updateSelectedAssets:(NSMutableArray *)selectedAssets uploadedPictures:(NSMutableArray *)uploadedPictures{
    
    _attachedPictures = [uploadedPictures copy];
    _selectedAssets = [selectedAssets copy];
    _uploadedPictures = [uploadedPictures copy];
    
    if ([self attachedImageWithoutDeletedImage].count == 0) {
        _hasImages = NO;
    }
    
    [self setAttachedPictures];
}

@end
