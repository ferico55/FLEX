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
    
    BOOL _hasProductReviewPhoto;
    
    NSMutableDictionary *_fileUploaded;
    NSString *_postKey;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_uploadedImages == nil) {
        _hasProductReviewPhoto = NO;
    } else {
        _hasProductReviewPhoto = YES;
    }
    
    self.title = @"Ringkasan Ulasan";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kirim"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToSend:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    _qualityStarsArray = [NSArray sortViewsWithTagInArray:_qualityStarsArray];
    _accuracyStarsArray = [NSArray sortViewsWithTagInArray:_accuracyStarsArray];
    
    [self setData];
    [self generateImageIDs];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods
- (void)setData {
    _productName.text = [NSString convertHTML:_detailReputationReview.product_name];
    
    [_productImage setImageWithURL:[NSURL URLWithString:_detailReputationReview.product_image]
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
        _attachedImagesViewHeight.constant = 0;
        _textViewHeight.constant = 147.0;
    } else {
        for (int ii = 0; ii < _uploadedImages.count; ii++) {
            ((UIImageView*)_attachedImagesArray[ii]).image = [[_uploadedImages[ii] objectForKey:@"photo"] objectForKey:@"photo"];
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
    if (_uploadedImages != nil) {
        return NO;
    }
    
    return YES;
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
        if ([_reviewMessage isEqualToString:_detailReputationReview.review_message] && [_detailReputationReview.product_accuracy_point intValue] == _accuracyRate && [_detailReputationReview.product_rating_point intValue] == _qualityRate) {
            StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[@"Tidak ada perubahan ulasan"] delegate:self];
            [stickyAlertView show];
            
            return NO;
        }
    }
    
    return YES;
}

- (void)generateImageIDs {
    
}

#pragma mark - Actions
- (IBAction)tapToSend:(id)sender {
    if ([self isSuccessValidateReview]) {
        [self sendButtonIsLoading:YES];
        
        [_reviewRequest requestReviewValidationWithReputationID:_detailReputationReview.reputation_id
                                                      productID:_detailReputationReview.product_id
                                                   accuracyRate:_accuracyRate
                                                    qualityRate:_qualityRate
                                                        message:[_reviewMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                                                         shopID:_detailReputationReview.shop_id
                                                       serverID:_generatedHost.server_id
                                          hasProductReviewPhoto:_hasAttachedImages
                                                 reviewPhotoIDs:_imageIDs
                                             reviewPhotoObjects:_imageDescriptions
                                                      onSuccess:^(SubmitReviewResult *result) {
                                                          if (_hasAttachedImages) {
                                                              _postKey = result.post_key;
                                                              for (NSString *imageID in _imageIDs) {
                                                                  [self requestUploadImageWithImageID:imageID];
                                                              }
                                                          } else {
                                                              NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                                                              
                                                              for (UIViewController *aViewController in allViewControllers) {
                                                                  if ([aViewController isKindOfClass:[MyReviewDetailViewController class]]) {
                                                                      [self.navigationController popToViewController:aViewController animated:NO];
                                                                  }
                                                              }
                                                          }
                                                      }
                                                      onFailure:^(NSError *errorResult) {
                                                          [self sendButtonIsLoading:NO];
                                                      }];
    }
}

#pragma mark - Tokopedia Network Manager
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameter = @{@"action"           : (_isEdit? @"edit_reputation_review":@"insert_reputation_review"),
                                @"accuracy_rate"    : @(_accuracyRate),
                                @"product_id"       : _detailReputationReview.product_id,
                                @"quality_rate"     : @(_qualityRate),
                                @"reputation_id"    : _detailReputationReview.reputation_id,
                                @"review_message"   : [_reviewMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                                @"shop_id"          : _detailReputationReview.shop_id,
                                @"review_id"        : _detailReputationReview.review_id!=nil?_detailReputationReview.review_id:@""
                                };
    
    return parameter;
}

- (NSString *)getPath:(int)tag {
    return @"action/reputation.pl";
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    GeneralAction *list = stat;
    
    return list.status;
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodPOST;
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromArray:@[@"status",
                                                   @"message_error",
                                                   @"message_status",
                                                   @"server_process_time"]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[@"feedback_id",
                                                   @"is_success"]];
    
    RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"result"
                                                                                   toKeyPath:@"result"
                                                                                 withMapping:resultMapping];
    [statusMapping addPropertyMapping:resultRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:[self getPath:0]
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return _objectManager;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    GeneralAction *action = [result objectForKey:@""];
    
    if (action.result.is_success) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[_isEdit? @"Anda telah berhasil mengubah ulasan":@"Anda telah berhasil mengisi ulasan"]
                                                                         delegate:self];
        [alert show];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"d MMMM yyyy, HH:mm";
        
        if (_isEdit) {
            _detailReputationReview.viewModel.review_is_allow_edit = _detailReputationReview.review_is_allow_edit = @"0";
            _detailReputationReview.viewModel.review_update_time = _detailReputationReview.review_update_time = [formatter stringFromDate:[NSDate new]];
        } else {
            _detailReputationReview.viewModel.review_is_allow_edit = _detailReputationReview.review_is_allow_edit = @"1";
            _detailReputationReview.viewModel.review_update_time = _detailReputationReview.review_update_time = [formatter stringFromDate:[NSDate new]];
            
            UserAuthentificationManager *user = [UserAuthentificationManager new];
            NSDictionary *userData = [user getUserLoginData];
            _detailReputationReview.review_full_name = [userData objectForKey:@"full_name"]?:@"-";
            _detailReputationReview.review_user_label = @"Pembeli";
            if (user.reputation) {
                _detailReputationReview.review_user_reputation = user.reputation;
            }
        }
        
        _detailReputationReview.review_id = action.result.feedback_id;
        _detailReputationReview.viewModel.review_is_skipable = _detailReputationReview.review_is_skipable = @"0";
        _detailReputationReview.viewModel.review_message = _detailReputationReview.review_message = [_reviewMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _detailReputationReview.viewModel.product_rating_point = _detailReputationReview.product_rating_point = [NSString stringWithFormat:@"%d", _qualityRate];
        _detailReputationReview.viewModel.product_accuracy_point = _detailReputationReview.product_accuracy_point = [NSString stringWithFormat:@"%d", _accuracyRate];
        [_detailMyReviewReputation successGiveReview];
        [self.navigationController popViewControllerAnimated:YES];
        
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        for (UIViewController *aViewController in allViewControllers) {
            if ([aViewController isKindOfClass:[DetailMyReviewReputationViewController class]]) {
                [self.navigationController popToViewController:aViewController animated:YES];
            }
        }
        
    } else {
        StickyAlertView *alert;
        if (action.message_error != nil && action.message_error.count > 0) {
            alert = [[StickyAlertView alloc] initWithErrorMessages:action.message_error
                                                          delegate:self];
        } else {
            alert = [[StickyAlertView alloc] initWithErrorMessages:@[_isEdit? @"Anda gagal memperbaharui ulasan":@"Anda gagal mengisi ulasan"]
                                                          delegate:self];
        }
        
        [alert show];
    }
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    [self sendButtonIsLoading:NO];
    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[_isEdit? @"Anda gagal memperbaharui ulasan":@"Anda gagal mengisi ulasan"]
                                                                             delegate:self];
    [stickyAlertView show];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (void)requestUploadImageWithImageID:(NSString*)imageID {
    [_reviewRequest requestUploadReviewImageWithHost:_generatedHost.upload_host
                                                data:[_imagesToUpload objectForKey:imageID] imageID:imageID
                                               token:_token
                                           onSuccess:^(UploadReviewImageResult *result) {
                                               [_fileUploaded setObject:result.pic_obj forKey:imageID];
                                           }
                                           onFailure:^(NSError *errorResult) {
                                           
                                           }];
}

@end
