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
#import "GiveReviewRatingViewController.h"

@interface ReviewSummaryViewController () <TokopediaNetworkManagerDelegate>

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


@end

@implementation ReviewSummaryViewController {
    TokopediaNetworkManager *_networkManager;
    __weak RKObjectManager *_objectManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Ringkasan Ulasan";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Kirim"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(tapToSend:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Ubah"
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(tapToEdit:)];
    
    [self setData];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.isUsingHmac = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods
- (void)setData {
    _productName.text = [NSString convertHTML:_detailReputationReview.product_name];
    
    // Set Product Image
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_detailReputationReview.product_image]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    [_productImage setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-01.png"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                      [_productImage setImage:image];
#pragma clang diagnostic pop
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      NSLog(@"Failed get image");
                                  }];
    
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
//        _attachedImagesView.frame = CGRectMake(_attachedImagesView.frame.origin.x, _attachedImagesView.frame.origin.y, _attachedImagesView.frame.size.width, 0);
//        _attachedImagesView.hidden = YES;
//        [_reviewMessageTextView layoutIfNeeded];
        _attachedImagesViewHeight.constant = 0;
    } else {
        for (int ii = 0; ii < _uploadedImages.count; ii++) {
            if ([_uploadedImages[ii] isKindOfClass:[UIImageView class]]) {
                ((UIImageView*)_attachedImagesArray[ii]).image = ((UIImageView*)_uploadedImages[ii]).image;
                ((UIImageView*)_attachedImagesArray[ii]).hidden = NO;
                
            }
        }
    }
    
    
}

- (void)setQualityLabel {
    NSString *quality = @"";
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"Kualitas:"
                                                                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Book" size:14.0]}];
    
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
                                                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Medium" size:14.0]}]];
    
    _qualityLabel.attributedText = mutableString;
}

- (void)setAccuracyLabel {
    NSString *accuracy = @"";
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:@"Akurasi:"
                                                                                      attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Book" size:14.0]}];
    
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
                                                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Gotham Medium" size:14.0]}]];
    
    _accuracyLabel.attributedText = mutableString;
}

- (BOOL)isNoImageUploaded {
    for (id n in _uploadedImages) {
        if ([n isKindOfClass:[UIImageView class]]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Actions
- (IBAction)tapToSend:(id)sender {
    [_networkManager doRequest];
}

- (IBAction)tapToEdit:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Tokopedia Network Manager
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameter = @{@"accuracy_rate" : @(_accuracyRate),
                                @"product_id" : _detailReputationReview.product_id,
                                @"quality_rate" : @(_qualityRate),
                                @"reputation_id" : _detailReputationReview.reputation_id,
                                @"review_message" : [_reviewMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                                @"shop_id" : _detailReputationReview.shop_id,
                                @"review_id" : _detailReputationReview.review_id?:@""
                                };
    
    return parameter;
}

- (NSString *)getPath:(int)tag {
    return _isEdit?@"/v4/action/reputation/edit_reputation_review.pl":@"/v4/action/reputation/insert_reputation_review.pl";
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    GeneralAction *list = stat;
    
    return list.status;
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager sharedClientHttps];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromArray:@[@"status",
                                                   @"config",
                                                   @"server_process_time"]];
    
    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [dataMapping addAttributeMappingsFromArray:@[@"feedback_id",
                                                 @"is_success"]];
    
    RKRelationshipMapping *dataRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                 toKeyPath:@"data"
                                                                               withMapping:dataMapping];
    [statusMapping addPropertyMapping:dataRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodGET
                                                                                             pathPattern:[self getPath:0]
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return _objectManager;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

@end
