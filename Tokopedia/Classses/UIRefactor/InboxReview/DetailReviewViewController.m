//
//  DetailReviewViewController.m
//
//
//  Created by Tokopedia on 12/11/14.
//
//

#import "DetailReviewViewController.h"
#import "InboxReview.h"
#import "UserAuthentificationManager.h"
#import "GeneralAction.h"
#import "string_inbox_review.h"

@interface DetailReviewViewController () <HPGrowingTextViewDelegate, UIScrollViewDelegate>
{
    HPGrowingTextView *_growingtextview;
    UserAuthentificationManager *_userManager;
}

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNamelabel;
@property (weak, nonatomic) IBOutlet UILabel *productNamelabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *commentlabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewRespondLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewCreateTimeLabel;
@property (weak, nonatomic) IBOutlet StarsRateView *qualityrate;
@property (weak, nonatomic) IBOutlet StarsRateView *speedrate;
@property (weak, nonatomic) IBOutlet StarsRateView *servicerate;
@property (weak, nonatomic) IBOutlet StarsRateView *accuracyrate;
@property (weak, nonatomic) IBOutlet UIButton *commentbutton;
@property (weak, nonatomic) IBOutlet UIButton *editReviewButton;
@property (weak, nonatomic) IBOutlet UIButton *reportReviewButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteReviewButton;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UIView *respondView;
@property (weak, nonatomic) IBOutlet UIView *talkInputView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation DetailReviewViewController {
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSInteger _requestDeleteCommentCount;
    __weak RKObjectManager *_objectDeleteCommentManager;
    __weak RKManagedObjectRequestOperation *_requestDeleteComment;
    NSOperationQueue *_operationDeleteCommentQueue;
    
    NSInteger *_requestCount;
    InboxReviewList *_review;
    NSString *_commentReview;
    NSTimer *_timer;
}

#pragma mark - Initialization
- (void)initNavigationBar {
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    [barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;
}


#pragma mark - ViewController Life
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userManager = [UserAuthentificationManager new];
    _operationQueue = [NSOperationQueue new];
    _operationDeleteCommentQueue = [NSOperationQueue new];
    
    self.hidesBottomBarWhenPushed = YES;
    
    [self initNavigationBar];
    [self initReviewData];
    [self initTalkInputView];
    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
}

- (void)hideInputView {
    _talkInputView.hidden = YES;
    
    CGRect newFrame = _talkInputView.frame;
    newFrame.size.height = 0;
    _talkInputView.frame = newFrame;
}

- (void)initReviewData {
    _review = _data;
    
    [_userNamelabel setText:_review.review_user_name];
    [_timelabel setText:_review.review_create_time];
    
    if([_review.review_response.response_message isEqualToString:@"0"]) {
        [_commentbutton setTitle:@"0 Comment" forState:UIControlStateNormal];
        
        _respondView.hidden = YES;
        
    } else {
        [_commentbutton setTitle:@"1 Comment" forState:UIControlStateNormal];
        
        _respondView.hidden = NO;
        [self hideInputView];
        _reviewCreateTimeLabel.text = _review.review_response.response_create_time;
        _reviewRespondLabel.text = _review.review_response.response_message;
        _reviewRespondLabel.numberOfLines = 0;
        [_reviewRespondLabel sizeToFit];
    }
    
    if([_review.review_response.response_message isEqualToString:@"0"] &&
    [_review.review_response.response_create_time isEqualToString:@"0"] &&
       [_is_owner isEqualToString:@"0"])
    {
        [self hideInputView];
    }
    
    
    _productNamelabel.text = _review.review_product_name;
    NSString *stringWithoutBr = [_review.review_message stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    _commentlabel.text = stringWithoutBr;
    
    if([[NSString stringWithFormat:@"%@", _userManager.getShopId]  isEqualToString:_review.review_shop_id]) {
        _deleteReviewButton.hidden = YES;
    }
    
    _qualityrate.starscount = [_review.review_rate_quality integerValue];
    _speedrate.starscount = [_review.review_rate_speed integerValue];
    _servicerate.starscount = [_review.review_rate_service integerValue];
    _accuracyrate.starscount = [_review.review_rate_accuracy integerValue];
    
//    _talkInputView.hidden = YES;
    
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_review.review_user_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *userImageView =_userImageView;
    userImageView.image = nil;
    [userImageView setImageWithURLRequest:userImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [userImageView setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    
    NSURLRequest *productImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_review.review_product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *productImageView = _productImageView;
    productImageView.image = nil;
    [productImageView setImageWithURLRequest:productImageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [productImageView setImage:image];
#pragma clang diagnostic pop
    } failure:nil];
    
}

-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        switch (barButton.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
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
                _commentReview = _growingtextview.text;
                _reviewRespondLabel.text = _commentReview;
                _reviewCreateTimeLabel.text = @"Just now";
                _growingtextview.text = nil;
                [_growingtextview resignFirstResponder];
                _respondView.hidden = NO;
                _talkInputView.hidden = YES;
                [_commentbutton setTitle:@"1 Comment" forState:UIControlStateNormal];
                [self sendComment];
                break;
            }
                
            case 11 : {
                [self deleteComment];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - UITextView Delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = _talkInputView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    _talkInputView.frame = r;
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.view.frame;
    
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height - 65);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    
    // set views with new info
    self.view.frame = containerFrame;
    
    [_talkInputView becomeFirstResponder];
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
//    self.view.backgroundColor = [UIColor clearColor];
    CGRect containerFrame = self.view.frame;
    
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height + 65;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.view.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_growingtextview resignFirstResponder];
}

- (void) initTalkInputView {
    _growingtextview = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 10, 240, 45)];
    //    [_growingtextview becomeFirstResponder];
    _growingtextview.isScrollable = NO;
    _growingtextview.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _growingtextview.layer.borderWidth = 0.5f;
    _growingtextview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _growingtextview.layer.cornerRadius = 5;
    _growingtextview.layer.masksToBounds = YES;
    
    _growingtextview.minNumberOfLines = 1;
    _growingtextview.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    _growingtextview.returnKeyType = UIReturnKeyGo; //just as an example
    //    _growingtextview.font = [UIFont fontWithName:@"GothamBook" size:13.0f];
    _growingtextview.delegate = self;
    _growingtextview.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _growingtextview.backgroundColor = [UIColor whiteColor];
    _growingtextview.placeholder = @"Kirim pesanmu di sini..";
    
    
    [_talkInputView addSubview:_growingtextview];
    _talkInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}


-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_growingtextview resignFirstResponder];
}

#pragma mark - Action send comment review
- (void)sendComment {
    [self configureRestkit];
    [self doSendComment];
}

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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:ADD_REVIEW_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];

}
- (void)doSendComment {
    if(_request.isExecuting) return;
    _requestCount++;
    
    NSDictionary *param = @{@"action" : @"add_comment_review", @"review_id" : _review.review_id, @"text_comment" : _commentReview};
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:ADD_REVIEW_PATH parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];
    
    [_operationQueue addOperation:_request];
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *userinfo;
    
    userinfo = @{@"index": _index, @"review_comment" : _commentReview, @"review_comment_time" : @"Just Now"};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTotalComment" object:nil userInfo:userinfo];
}

#pragma mark - Action Delete Review
- (void)deleteComment {
    _respondView.hidden = YES;
    [_commentbutton setTitle:@"0 Comment" forState:UIControlStateNormal];
    
    [self configureDeleteCommentRestkit];
    [self doDeleteComment];
}

- (void)configureDeleteCommentRestkit {
    _objectDeleteCommentManager =  [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success"}];
    
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:@"action/review.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectDeleteCommentManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)doDeleteComment {
    if(_requestDeleteComment.isExecuting) return;
    _requestDeleteCommentCount++;
    
    NSDictionary *param = @{
                            @"review_id" : _review.review_id,
                            @"text_comment" : _review.review_response.response_message?:@"0",
                            @"action" : @"delete_comment_review"
                            };
    
    _requestDeleteComment = [_objectDeleteCommentManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"action/review.pl" parameters:[param encrypt]];
    
    
    [_requestDeleteComment setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessDeleteComment:mappingResult withOperation:operation];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_timer invalidate];
        _timer = nil;
        [self requestFailureDeleteComment:error];
    }];
    
    [_operationDeleteCommentQueue addOperation:_requestDeleteComment];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutDeleteComment) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

- (void)requestSuccessDeleteComment:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    GeneralAction *generalaction = stat;
    BOOL status = [generalaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessDeleteComment:object];
    }
}

- (void)requestFailureDeleteComment:(id)object {
    [self requestProcessDeleteComment:object];
}

- (void)requestProcessDeleteComment:(id)object {
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            GeneralAction *generalaction = stat;
            BOOL status = [generalaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(generalaction.message_error)
                {
                    [self cancelDeleteRow];
                    NSArray *array = generalaction.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                    
                } else {
                    NSDictionary *userinfo;
                    
                    userinfo = @{@"index": _index, @"review_comment" : @"0", @"review_comment_time" : @"Just Now"};
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTotalComment" object:nil userInfo:userinfo];
                }
            }
        }
        else{
            [self cancelActionDelete];
            [self cancelDeleteRow];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

- (void)requestTimeoutDeleteComment {
    [self cancelActionDelete];
}

- (void)cancelDeleteRow {
    _respondView.hidden = NO;
}

- (void)cancelActionDelete {
    [_requestDeleteComment cancel];
    _requestDeleteComment = nil;
    [_objectDeleteCommentManager.operationQueue cancelAllOperations];
    _objectDeleteCommentManager = nil;

}

@end
