//
//  ReviewFormViewController.m
//
//
//  Created by Tokopedia on 12/11/14.
//
//

#import "ReputationDetailFormViewController.h"
#import "RateView.h"
#import "ReviewList.h"
#import "GeneralAction.h"
#import "DetailProductViewController.h"
#import "NavigateViewController.h"
#import "DetailReputationReview.h"


#import "string_inbox_review.h"

@interface ReputationDetailFormViewController () <RateViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet RateView *qualityRateView;
@property (weak, nonatomic) IBOutlet RateView *accuracyRateView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *productNameButton;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UITextView *reviewMessage;
@property (weak, nonatomic) IBOutlet UILabel *reviewLastEdited;

@property (weak, nonatomic) UIImage *iconStarDefault;
@property (weak, nonatomic) UIImage *iconStarActive;
@property (weak, nonatomic) UIImage *iconStarHalf;

- (void)configureRestkit;
- (void)cancelCurrentAction;
- (void)doSendReview;
- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestFail;
- (void)requestTimeout;

@end

@implementation ReputationDetailFormViewController
{
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    NSInteger *_requestCount;
    
    int _defaultRating;
    int _maxRating;
    BOOL _editableRating;
    DetailReputationReview *_selectedReviewDetail;
    NSMutableArray *_errorMessages;
    UIBarButtonItem *_barbuttonright;
    NSDictionary *_editedParam;
    NavigateViewController *_TKPDNavigator;

}

#pragma mark - Initialization
- (void)buildReviewValue {
    
}

- (void)initNavigationBar {
    
    UIBarButtonItem *barbuttonleft;
    
    barbuttonleft = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonleft setTintColor:[UIColor whiteColor]];
    [barbuttonleft setTag:10];
    self.navigationItem.leftBarButtonItem = barbuttonleft;
    if(!_isViewForm) {
        _barbuttonright = [[UIBarButtonItem alloc] initWithTitle:@"Kirim" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [_barbuttonright setTintColor:[UIColor blackColor]];
        [_barbuttonright setTag:11];
        
        self.navigationItem.rightBarButtonItem = _barbuttonright;
    }
}

- (void)initRatingProperty {
    _iconStarActive = [UIImage imageNamed:kTKPDIMAGE_ICONSTAR_ACTIVE];
    _iconStarDefault = [UIImage imageNamed:kTKPDIMAGE_ICONSTAR];
    _iconStarHalf = [UIImage imageNamed:kTKPDIMAGE_ICONSTAR];
    
    _defaultRating = 0;
    _editableRating = YES;
    _maxRating = 5;
}

- (void)initQualityRatingStar {
    _qualityRateView.notSelectedImage = _iconStarDefault;
    _qualityRateView.halfSelectedImage = _iconStarHalf;
    _qualityRateView.fullSelectedImage = _iconStarActive;
    
    _qualityRateView.rating = _defaultRating;
    _qualityRateView.editable = _editableRating;
    _qualityRateView.maxRating = _maxRating;
    _qualityRateView.delegate = self;
}

- (void)initAccuracyRatingStar {
    _accuracyRateView.notSelectedImage = _iconStarDefault;
    _accuracyRateView.halfSelectedImage = _iconStarHalf;
    _accuracyRateView.fullSelectedImage = _iconStarActive;
    
    _accuracyRateView.rating = _defaultRating;
    _accuracyRateView.editable = _editableRating;
    _accuracyRateView.maxRating = _maxRating;
    _accuracyRateView.delegate = self;
}



- (void)initReviewTextView {
    _reviewMessage.delegate = self;
    _reviewMessage.text = @"Tulis Review-mu disini";
    _reviewMessage.textColor = [UIColor lightGrayColor];
}


- (void)initProductView {
    _selectedReviewDetail = (DetailReputationReview *)_data;
    
    [_productNameButton setTitle:_selectedReviewDetail.review_product_name forState:UIControlStateNormal];
    NSURLRequest *productImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_selectedReviewDetail.review_product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    _productImage.image = nil;
    [_productImage setImageWithURLRequest:productImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [_productImage setImage:image];
        _productImage.layer.cornerRadius = _productImage.frame.size.width/2;
#pragma clang diagnostic pop
    } failure:nil];
    
    
}

- (void)setRating {
    [_qualityRateView setRating:[_selectedReviewDetail.review_rate_quality floatValue]];
    [_accuracyRateView setRating:[_selectedReviewDetail.review_rate_accuracy floatValue]];
    
    [_qualityRateView setMinRating:[_selectedReviewDetail.review_rate_quality floatValue]];
    [_accuracyRateView setMinRating:[_selectedReviewDetail.review_rate_accuracy floatValue]];
}

- (void)initReviewForm {
    if(_isEditForm) {
        self.title = @"Ubah Ulasan";
        [_reviewMessage setText:[_selectedReviewDetail.review_message stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"]];
        
        [self setRating];
        
        if([_selectedReviewDetail.review_is_allow_edit isEqualToString:@"1"]) {
            _reviewLastEdited.hidden = YES;
        } else {
            _reviewLastEdited.hidden = NO;
            _reviewMessage.editable = NO;
            _qualityRateView.editable = NO;
            _accuracyRateView.editable = NO;
            [_reviewLastEdited setText:[NSString stringWithFormat:@"Last edited on %@", _selectedReviewDetail.review_create_time]];
        }
    } else if (_isViewForm){
        self.title = @"Lihat Ulasan";
        
        NSString *htmlString = _selectedReviewDetail.review_message;
//        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        _reviewMessage.attributedText = attributedString;
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 3.0;
        [attributes setObject:style forKey:NSParagraphStyleAttributeName];
        
        UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
        [attributes setObject:font forKey:NSFontAttributeName];
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[NSString convertHTML:htmlString] attributes:attributes];
        _reviewMessage.attributedText = attributedString;
        [self setRating];
        
        if([_selectedReviewDetail.review_is_allow_edit isEqualToString:@"1"]) {
            _reviewLastEdited.hidden = YES;
        } else {
            [_reviewLastEdited setText:[NSString stringWithFormat:@"Last edited on %@", _selectedReviewDetail.review_create_time]];
            _reviewLastEdited.hidden = NO;
        }
        
        _reviewMessage.editable = NO;
        _qualityRateView.editable = NO;
        _accuracyRateView.editable = NO;
    }
    else  {
        self.title = @"Tulis Ulasan";
        _reviewLastEdited.hidden = YES;
    }
}

#pragma mark - ViewController Life
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    [self initNavigationBar];
    [self initRatingProperty];
    [self initQualityRatingStar];
    [self initAccuracyRatingStar];

    [self initReviewTextView];
    [self initProductView];
    [self initReviewForm];
    _TKPDNavigator = [NavigateViewController new];
}


#pragma mark - Request + Restkit Init
- (void)configureRestkit {
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:ADD_REVIEW_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)doSendReview {
    if(_request.isExecuting) return;
    
    [self configureRestkit];
    
    
    
    _requestCount++;
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:ADD_REVIEW_PATH parameters:[[self getEditedParam] encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];
    
    [_operationQueue addOperation:_request];
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    GeneralAction *generalaction = info;
    BOOL status = [generalaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        if([generalaction.result.is_success isEqualToString:@"1"]) {
            
        } else {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:generalaction.message_error delegate:self];
            [alert show];
        }
    }
    
}

- (void)requestFail {
    
}

- (void)requestTimeout {
    
}

- (void)cancelCurrentAction {
    
}

- (NSDictionary *)getEditedParam {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setMaximumFractionDigits:0];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    
    _editedParam = @{
                     @"action" : _isEditForm ? @"edit_product_review" : @"add_product_review",
                     @"mode" : _isEditForm ? @"edit" : @"",
                     @"review_id" : _isEditForm ? _selectedReviewDetail.review_id : @"",
                     @"shop_id" : _selectedReviewDetail.shop_id,
                     @"product_id" : _selectedReviewDetail.review_product_id,
                     @"review_message" : _reviewMessage.text,
                     @"rate_product" : [formatter stringFromNumber:[NSNumber numberWithFloat:_qualityRateView.rating]],
                     @"rate_accuracy" : [formatter stringFromNumber:[NSNumber numberWithFloat:_accuracyRateView.rating]],
                     };
    
    return _editedParam;
}

#pragma mark - IBAction
-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        switch (barButton.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
                
            case 11 : {
                if([self validateReviewValue]) {
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    NSDictionary *userinfo;
                    _editedParam = [self getEditedParam];
                    userinfo = @{@"data":[self getEditedParam], @"index" : @(_reviewIndex)};
                    if(_isEditForm) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAfterEditingReview" object:nil userInfo:userinfo];
                    } else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAfterWriteReview" object:nil userInfo:userinfo];
                    }
                    
                    
                    [self doSendReview];
                } else {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:_errorMessages delegate:self];
                    [alert show];
                }
                break;
            }
                
            default:
                break;
        }
    }
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        switch (button.tag) {
            case 10:
            {
                [_TKPDNavigator navigateToProductFromViewController:self withName:_selectedReviewDetail.review_product_name withPrice:nil withId:_selectedReviewDetail.review_product_id withImageurl:_selectedReviewDetail.review_product_image withShopName:nil];
                
                break;
            }
                
            case 11 : {
                [self buildReviewValue];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Rating Delegate
- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {
    self.statusLabel.text = [NSString stringWithFormat:@"Rating: %f", rating];
}

#pragma mark - Memory Manage
- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Textview Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Tulis Review-mu disini"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Tulis Review-mu disini";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_reviewMessage resignFirstResponder];
}

#pragma mark - Value Validation
- (BOOL)validateReviewValue {
    _errorMessages = [NSMutableArray new];
    NSString *errorMessage;
    
    if(!_reviewMessage || _reviewMessage.text.length < 30) {
        errorMessage = @"Pesan review harus lebih dari 30 karakter";
        [_errorMessages addObject:errorMessage];
    }
    
    if(_qualityRateView.rating == 0 ||
       _accuracyRateView.rating == 0) {
        errorMessage = @"Rating tidak boleh kosong";
        [_errorMessages addObject:errorMessage];
    }
    
    if([_errorMessages count] == 0) {
        return YES;
    } else {
        return NO;
    }
    
}


@end
