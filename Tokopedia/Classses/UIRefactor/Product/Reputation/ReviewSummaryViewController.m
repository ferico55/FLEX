//
//  ReviewSummaryViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ReviewSummaryViewController.h"
#import "TKPDTextView.h"
#import "DetailReputationReview.h"
#import "GeneralAction.h"
#import "GeneralActionResult.h"
#import "GenerateHostRequest.h"
#import "GiveReviewRatingViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ReviewRequest.h"
#import "ReviewImageAttachment.h"
#import "AttachedPicture.h"

@interface ReviewSummaryViewController ()
<
TokopediaNetworkManagerDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet TKPDTextView *reviewMessageTextView;
@property (weak, nonatomic) IBOutlet UIView *attachedImagesView;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *attachedImagesArray;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *qualityStarsArray;
@property (weak, nonatomic) IBOutlet UILabel *qualityLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *accuracyStarsArray;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachedImagesViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;


@end

@implementation ReviewSummaryViewController {
    TokopediaNetworkManager *_networkManager;
    GenerateHostRequest *_generateHostRequest;
    __weak RKObjectManager *_objectManager;
    
    GeneratedHost *_generatedHost;
    ReviewRequest *_reviewRequest;
    
    NSInteger _counter;
    
    NSMutableDictionary *_fileUploaded;
    NSString *_postKey;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Ringkasan Ulasan";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kirim"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToSend:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    _qualityStarsArray = [NSArray sortViewsWithTagInArray:_qualityStarsArray];
    _accuracyStarsArray = [NSArray sortViewsWithTagInArray:_accuracyStarsArray];
    
    [self setData];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.isUsingHmac = NO;
    
    _generateHostRequest = [GenerateHostRequest new];
    
    [_generateHostRequest requestGenerateHostWithNewAdd:@"1"
                                              onSuccess:^(GenerateHostResult *result) {
                                                  _generatedHost = result.generated_host;
                                                  self.navigationItem.rightBarButtonItem.enabled = YES;
                                              }
                                              onFailure:^(NSError *errorResult) {
                                                  
                                              }];
    
    _reviewRequest = [ReviewRequest new];
    _fileUploaded = [NSMutableDictionary new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods
- (void)setData {
    _productName.text = [NSString convertHTML:_review.product_name];
    
    [_productImage setImageWithURL:[NSURL URLWithString:_review.product_image]
                  placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]];
    
    _reviewMessageTextView.text = _reviewMessage;
    
    
    for (int ii = 0; ii < _qualityStarsArray.count; ii++) {
        UIImageView *temp = [_qualityStarsArray objectAtIndex:ii];
        temp.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:((ii < _qualityRate)? @"icon_star_active":@"icon_star") ofType:@"png"]];
    }
    
    for (int ii = 0; ii < _accuracyStarsArray.count; ii++) {
        UIImageView *temp = [_accuracyStarsArray objectAtIndex:ii];
        temp.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:((ii < _accuracyRate)? @"icon_star_active":@"icon_star") ofType:@"png"]];
    }
    
    [self setQualityLabel];
    [self setAccuracyLabel];
    
    _attachedImagesArray = [NSArray sortViewsWithTagInArray:_attachedImagesArray];
    
    if ([self isNoImageUploaded]) {
        _attachedImagesViewHeight.constant = 8;
        _textViewHeight.constant = 139.0;
    } else {
        for (NSInteger ii = 0; ii < _attachedImages.count; ii++) {
            AttachedPicture *pict = _attachedImages[ii];
            
            if (![pict.thumbnailUrl isEqualToString:@""]) {
                [((UIImageView*)_attachedImagesArray[ii]) setImageWithURL:[NSURL URLWithString:pict.thumbnailUrl]
                                                         placeholderImage:[UIImage imageNamed:@"image_not_loading.png"]];
            } else {
                ((UIImageView*)_attachedImagesArray[ii]).image = pict.image;
            }
            
            ((UIImageView*)_attachedImagesArray[ii]).hidden = NO;
            
            
        }
    }
}

- (void)setQualityLabel {
    NSString *quality = @"";
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"Kualitas:"
                                                                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Book" size:11.0]}];
    
    switch (_qualityRate) {
        case 0:
            quality = @"";
            break;
        case 1:
            quality = @"Sangat Buruk";
            break;
        case 2:
            quality = @"Buruk";
            break;
        case 3:
            quality = @"Netral";
            break;
        case 4:
            quality = @"Bagus";
            break;
        case 5:
            quality = @"Sangat Bagus";
            break;
        default:
            break;
    }
    
    [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:quality
                                                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Medium" size:11.0]}]];
    
    _qualityLabel.attributedText = mutableString;
}

- (void)setAccuracyLabel {
    NSString *accuracy = @"";
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"Akurasi:"
                                                                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Book" size:11.0]}];
    
    switch (_accuracyRate) {
        case 0:
            accuracy = @"";
            break;
        case 1:
            accuracy = @"Sangat Buruk";
            break;
        case 2:
            accuracy = @"Buruk";
            break;
        case 3:
            accuracy = @"Netral";
            break;
        case 4:
            accuracy = @"Bagus";
            break;
        case 5:
            accuracy = @"Sangat Bagus";
            break;
        default:
            break;
    }
    
    [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [mutableString appendAttributedString:[[NSAttributedString alloc] initWithString:accuracy
                                                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Medium" size:11.0]}]];
    
    _accuracyLabel.attributedText = mutableString;
}

- (BOOL)isNoImageUploaded {
    if (_attachedImages.count > 0) {
        return false;
    } else {
        return true;
    }
}

- (void)sendButtonIsLoading:(BOOL)isProcessing {
    if (isProcessing) {
        UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        act.color = [UIColor whiteColor];
        [act startAnimating];
        self.navigationItem.rightBarButtonItem.customView = act;
    } else {
        self.navigationItem.rightBarButtonItem.customView = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kirim"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(tapToSend:)];
    }
}

- (BOOL)isSuccessValidateReview {
    if (_isEdit) {
        if ([_reviewMessage isEqualToString:_review.review_message] && [_review.product_accuracy_point intValue] == _accuracyRate && [_review.product_rating_point intValue] == _qualityRate && [_isAttachedImagesModified isEqualToString:@"0"]) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Tidak ada perubahan ulasan"] delegate:self];
            [stickyAlertView show];
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Actions
- (IBAction)tapToSend:(id)sender {
    if ([self isSuccessValidateReview]) {
        [self sendButtonIsLoading:YES];
        
        if (_isEdit) {
            [_reviewRequest requestEditReviewWithImageWithReviewID:_review.review_id
                                                         productID:_review.product_id
                                                      accuracyRate:_accuracyRate
                                                       qualityRate:_qualityRate
                                                      reputationID:_review.reputation_id
                                                           message:_reviewMessage
                                                            shopID:_review.shop_id
                                             hasProductReviewPhoto:_hasAttachedImages
                                                    reviewPhotoIDs:_imageIDs
                                                reviewPhotoObjects:_imageDescriptions
                                                    imagesToUpload:_imagesToUpload
                                                             token:_token
                                                              host:_generatedHost.upload_host
                                                         onSuccess:^(SubmitReviewResult *result) {
                                                             NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                                             
                                                             StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil mengubah ulasan"]
                                                                                                                              delegate:self];
                                                             [alert show];
                                                             
                                                             for (UIViewController *aViewController in allViewControllers) {
                                                                 if ([aViewController isKindOfClass:[MyReviewDetailViewController class]]) {
                                                                     [self.navigationController popToViewController:aViewController animated:YES];
                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshData"
                                                                                                                         object:nil];
                                                                 }
                                                             }
                                                         }
                                                         onFailure:^(NSError *error) {
                                                             [self sendButtonIsLoading:NO];
                                                         }];
        } else {
            [_reviewRequest requestSubmitReviewWithImageWithReputationID:_review.reputation_id
                                                               productID:_review.product_id
                                                            accuracyRate:_accuracyRate
                                                             qualityRate:_qualityRate
                                                                 message:[_reviewMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                                                  shopID:_review.shop_id
                                                                serverID:_generatedHost.server_id
                                                   hasProductReviewPhoto:_hasAttachedImages
                                                          reviewPhotoIDs:_imageIDs
                                                      reviewPhotoObjects:_imageDescriptions
                                                          imagesToUpload:_imagesToUpload
                                                                   token:_token
                                                                    host:_generatedHost.upload_host
                                                               onSuccess:^(SubmitReviewResult *result) {
                                                                   NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                                                   
                                                                   StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[@"Anda telah berhasil mengisi ulasan"]
                                                                                                                                    delegate:self];
                                                                   [alert show];
                                                                   
                                                                   for (UIViewController *aViewController in allViewControllers) {
                                                                       if ([aViewController isKindOfClass:[MyReviewDetailViewController class]]) {
                                                                           [self.navigationController popToViewController:aViewController animated:YES];
                                                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshData"
                                                                                                                               object:nil];
                                                                       }
                                                                   }
                                                               }
                                                               onFailure:^(NSError *error) {
                                                                   [self sendButtonIsLoading:NO];
                                                               }];
        }
        
    }
}

@end
