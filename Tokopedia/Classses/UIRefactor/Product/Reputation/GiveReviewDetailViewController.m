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
#import <QuartzCore/QuartzCore.h>

@interface GiveReviewDetailViewController () <CameraCollectionViewControllerDelegate, CameraControllerDelegate, ProductAddCaptionDelegate, UITextViewDelegate> {
    NSMutableArray *_selectedImagesCameraController;
    NSMutableArray *_selectedIndexPathCameraController;
    NSMutableArray *_attachedImageURL;
    
    NSMutableArray *_uploadingImages;
    NSMutableArray *_uploadedImages;
    NSMutableArray *_attachedImages;
    
    NSMutableDictionary *_imagesToUpload;
    
    NSOperationQueue *_operationQueue;
    
    BOOL _isFinishedUploadingImage;
    BOOL _hasImages;
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
    
    self.title = _isEdit?@"Ubah Ulasan":@"Tulis Ulasan";
    _reviewDetailTextView.placeholder = @"Tulis Ulasan Anda";
    
    _attachedImagesArray = [NSArray sortViewsWithTagInArray:_attachedImagesArray];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Lanjut"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToContinue:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:nil];
    
    [self initData];
    
    
    _operationQueue = [NSOperationQueue new];
    
    _uploadingImages = [NSMutableArray new];
    _selectedImagesCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _selectedIndexPathCameraController = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _attachedImageURL = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    _attachedImages = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
    
    _imagesToUpload = [NSMutableDictionary new];
    
    _isFinishedUploadingImage = YES;
    
    _reviewDetailTextView.delegate = self;
    
    if (_detailReputationReview.review_image_attachment.count > 0) {
        NSMutableArray *tempImageCaptions = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"", @"", nil];
        
        for (int ii = 0; ii < _detailReputationReview.review_image_attachment.count; ii++) {
            ReviewImageAttachment *image = _detailReputationReview.review_image_attachment[ii];
            [tempImageCaptions replaceObjectAtIndex:ii withObject:image.desc];
        }
        
        NSDictionary *tempUserInfo = @{@"attached_images":_detailReputationReview.review_image_attachment,
                                       @"images-captions":tempImageCaptions
                                       };
        
        _userInfo = tempUserInfo;
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
    self.title = _isEdit?@"Ubah Ulasan":@"Tulis Ulasan";
}

#pragma mark - Methods
- (void)initData {
    _productName.text = [NSString convertHTML:_detailReputationReview.product_name];
    
    // Set Product Image
    [_productImage setImageWithURL:[NSURL URLWithString:_detailReputationReview.product_image]
                  placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]];
    
    if (_isEdit) {
        _reviewDetailTextView.text = [NSString convertHTML:_detailReputationReview.review_message];
        
        for (int ii = 0; ii < _detailReputationReview.review_image_attachment.count; ii++) {
            ReviewImageAttachment *imageAttachment = _detailReputationReview.review_image_attachment[ii];
            
            for (UIImageView *image in _attachedImagesArray) {
                if (image.tag == 20 + ii) {
                    [image setImageWithURL:[NSURL URLWithString:imageAttachment.uri_thumbnail]
                         placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]];
                    image.userInteractionEnabled = YES;
                }
            }
        }
        
        if (_detailReputationReview.review_image_attachment.count < 5) {
            [self initCameraIconAtIndex:_detailReputationReview.review_image_attachment.count];
        }
        
    } else {
        [self initCameraIconAtIndex:0];
    }
}

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

- (NSInteger)totalUploadedAndUploadingImage {
    NSMutableArray *fileThumbImage = [NSMutableArray new];
    for (NSString *image in _uploadedImages) {
        if (![image isEqualToString:@""]) {
            [fileThumbImage addObject:image];
        }
    }
    
    return fileThumbImage.count + _uploadingImages.count;
}

- (BOOL)image:(UIImage*)image1 isEqualTo:(UIImage*)image2 {
    return [UIImagePNGRepresentation(image1) isEqual:UIImagePNGRepresentation(image2)];
}

- (BOOL)array:(NSArray*)arr containsObject:(NSDictionary*)object {
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        for (id objectInArray in arr) {
            if ([objectInArray isKindOfClass:[NSDictionary class]]) {
                NSDictionary *photoObjectInArray = [objectInArray objectForKey:@"photo"];
                NSDictionary *photoObject = [object objectForKey:@"photo"];
                if ([self image:[photoObjectInArray objectForKey:@"photo"] isEqualTo:[photoObject objectForKey:@"photo"]]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSString*)generateUniqueImageID {
    int unixTime = (int) [[NSDate date] timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%d", unixTime];
}

#pragma mark - Text Field Delegate 
- (void)textViewDidBeginEditing:(UITextView *)textView {
    _reviewDetailTextView.placeholder = nil;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [_reviewDetailTextView resignFirstResponder];
    _reviewDetailTextView.placeholder = @"Tulis Ulasan Anda";
}

#pragma mark - Actions
- (IBAction)tapToContinue:(id)sender {
    if ([self isSuccessValidateMessage]) {
        ReviewSummaryViewController *vc = [ReviewSummaryViewController new];
        vc.detailReputationReview = _detailReputationReview;
        vc.isEdit = _isEdit;
        vc.qualityRate = _qualityRate;
        vc.accuracyRate = _accuracyRate;
        vc.reviewMessage = _reviewMessage;
        vc.uploadedImages = [_userInfo objectForKey:@"selected_images"];
        vc.imagesCaption = [_userInfo objectForKey:@"images-captions"];
        vc.detailMyReviewReputation = _detailMyReviewReputation;
        vc.token = _token;
        vc.imagesToUpload = [_userInfo objectForKey:@"images-to-upload"];
        vc.imageDescriptions = _productReviewPhotoObjects;
        vc.hasAttachedImages = _hasImages;
        vc.imageIDs = [_userInfo objectForKey:@"all-image-ids"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)tapImage:(UITapGestureRecognizer*)sender {
    if ([self image:((UIImageView*)_attachedImagesArray[sender.view.tag-20]).image isEqualTo:[UIImage imageNamed:@"icon_camera.png"]]) {
        [self didTapImage:((UIImageView*)_attachedImagesArray[sender.view.tag-20])];
    } else {
        ProductAddCaptionViewController *vc = [ProductAddCaptionViewController new];
        vc.selectedIndexPaths = [_userInfo objectForKey:@"selected_indexpath"];
        vc.selectedImages = [_userInfo objectForKey:@"selected_images"];
        vc.imagesCaptions = [_userInfo objectForKey:@"images-captions"];
        vc.delegate = self;
        vc.selectedImageTag = (int)sender.view.tag;
        vc.review = _detailReputationReview;
        
        UINavigationController *nav = [[UINavigationController alloc]init];
        nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.tintColor = [UIColor whiteColor];
        NSArray *controllers = @[vc];
        [nav setViewControllers:controllers];
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

- (void)didTapImage:(UIImageView*)sender {
    CameraAlbumListViewController *albumVC = [CameraAlbumListViewController new];
    albumVC.title = @"Album";
    albumVC.delegate = self;
    CameraCollectionViewController *photoVC = [CameraCollectionViewController new];
    photoVC.title = @"All Picture";
    photoVC.delegate = self;
    photoVC.isAddEditProduct = YES;
    photoVC.tag = sender.tag;
    photoVC.review = _detailReputationReview;
    photoVC.attachedImagesCaptions = [_userInfo objectForKey:@"images-captions"];
    
    NSMutableArray *notEmptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in _attachedImagesArray) {
        if (image.image == nil) {
            [notEmptyImageIndex addObject:@(image.tag - 20)];
        }
    }
    
    NSMutableArray *selectedImage = [NSMutableArray new];
    for (id selected in _selectedImagesCameraController) {
        if (![selected isEqual:@""]) {
            [selectedImage addObject:selected];
        }
    }
    
    NSMutableArray *selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
    
    photoVC.maxSelected = 5 - _detailReputationReview.review_image_attachment.count;
    photoVC.selectedImagesArray = selectedImage;
    
    selectedIndexPath = [NSMutableArray new];
    for (NSIndexPath *selected in _selectedIndexPathCameraController) {
        if (![selected isEqual:@""]) {
            [selectedIndexPath addObject:selected];
        }
    }
    
    photoVC.selectedIndexPath = _selectedIndexPathCameraController;
    photoVC.isAddReviewImage = YES;
    
    UINavigationController *nav = [[UINavigationController alloc]init];
    nav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    nav.navigationBar.translucent = NO;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    NSArray *controllers = @[albumVC,photoVC];
    [nav setViewControllers:controllers];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Product Add Caption Delegate
- (void)didDismissController:(ProductAddCaptionViewController*)controller withUserInfo:(NSDictionary *)userinfo {
    _userInfo = userinfo;
    _productReviewPhotoObjects = [userinfo objectForKey:@"product-review-photo-objects"];
    _hasImages = YES;
    NSArray *selectedImages = [userinfo objectForKey:@"selected_images"];
    NSArray *selectedIndexpaths = [userinfo objectForKey:@"selected_indexpath"];
    
    // Cari Index Image yang kosong
    NSMutableArray *emptyImageIndex = [NSMutableArray new];
    for (UIImageView *image in _attachedImagesArray) {
        if (image.image == nil || [self image:image.image isEqualTo:[UIImage imageNamed:@"icon_camera.png"]]) {
            [emptyImageIndex addObject:@(image.tag - 20)];
        }
    }
    
    //Upload Image yg belum diupload tp dipilih
    int j = 0;
    for (NSDictionary *selected in selectedImages) {
        if ([selected isKindOfClass:[NSDictionary class]]) {
            if (j>=emptyImageIndex.count) {
                return;
            }
            if (![self array:[_selectedImagesCameraController copy] containsObject:selected]) {
                NSUInteger index = [emptyImageIndex[j] integerValue];
                [_selectedImagesCameraController replaceObjectAtIndex:index withObject:selected];
                NSMutableDictionary *data = [NSMutableDictionary new];
                [data addEntriesFromDictionary:selected];
                NSUInteger indexIndexPath = [_selectedImagesCameraController indexOfObject:selected];
                [data setObject:selectedIndexpaths[indexIndexPath] forKey:@"selected_indexpath"];
                [self setImageData:[data copy] tag:index];
                j++;
            }
        }
    }
}

- (void)setImageData:(NSDictionary*)data tag:(NSInteger)tag {
    id selectedIndexpaths = [data objectForKey:@"selected_indexpath"];
    [_selectedIndexPathCameraController replaceObjectAtIndex:tag withObject:selectedIndexpaths?:@""];
    
    NSInteger tagView = tag + 20;
    NSMutableDictionary *object = [NSMutableDictionary new];
    [object setObject:data forKey:@"photo"];
    UIImageView *imageView;
    
    NSDictionary* photo = [data objectForKey:@"photo"];
    
    UIImage* imagePhoto = [photo objectForKey:@"photo"];
    
    for (UIImageView *image in _attachedImagesArray) {
        if (image.tag == tagView) {
            imageView = image;
            image.image = imagePhoto;
            image.hidden = NO;
            image.userInteractionEnabled = YES;
            image.contentMode = UIViewContentModeScaleToFill;
            [_attachedImages replaceObjectAtIndex:tagView-20 withObject:image];
        }
        
        if (image.tag == tagView + 1) {
            if (image.image == nil) {
                image.image = [UIImage imageNamed:@"icon_camera.png"];
                image.userInteractionEnabled = YES;
                image.hidden = NO;
                image.contentMode = UIViewContentModeCenter;
                [image.layer setBorderColor:[[UIColor colorWithRed:200.0/255 green:199.0/255 blue:204.0/255 alpha:1] CGColor]];
                [image.layer setBorderWidth:1.0];
                image.layer.cornerRadius = 5.0;
                image.layer.masksToBounds = YES;
                
            }
        }
    }
    
    if (imageView != nil) {
        [object setObject:imageView forKey:@"data_selected_image_view"];
    }
    
    [object setObject:_selectedImagesCameraController[tag] forKey:@"data_selected_photo"];
    [object setObject:_selectedIndexPathCameraController[tag] forKey:@"data_selected_indexpath"];
}

@end
