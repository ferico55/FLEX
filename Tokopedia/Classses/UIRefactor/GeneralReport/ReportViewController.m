//
//  ReportViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/31/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "DetailMyReviewReputationViewController.h"
#import "InboxTalkViewController.h"
#import "ReportViewController.h"
#import "ProductReputationViewController.h"
#import "ProductTalkViewController.h"
#import "string.h"
#import "ShopReviewPageViewController.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "GeneralAction.h"
#import "LoginViewController.h"
#import "MyReviewDetailViewController.h"
#import "ReviewRequest.h"

@interface ReportViewController () <UITextViewDelegate, LoginViewDelegate> {
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    
    UserAuthentificationManager *_userManager;
    ReviewRequest *_reviewRequest;
}

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end

@implementation ReportViewController
@synthesize strProductID;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _userManager = [UserAuthentificationManager new];
    
    self.title = @"Lapor";
    [self setTextViewPlaceholder:@"Isi deskripsi laporan kamu disini.."];
    _operationQueue = [NSOperationQueue new];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tapBar:)];
    doneButton.tintColor = [UIColor whiteColor];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    if(![_userManager isLogin]) {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        navigationController.navigationBar.translucent = NO;
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        LoginViewController *controller = [LoginViewController new];
        controller.delegate = self;
        controller.isPresentedViewController = YES;
        controller.redirectViewController = self;
        navigationController.viewControllers = @[controller];
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        return;
    }
    
    _reviewRequest = [ReviewRequest new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _messageTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    
//    [_messageTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_messageTextView resignFirstResponder];
}

- (void)setTextViewPlaceholder:(NSString *)placeholderText
{
    _messageTextView.delegate = self;
    
    UIEdgeInsets inset = _messageTextView.textContainerInset;
    inset.top = 10;
    inset.left = 10;
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, _messageTextView.frame.size.width, 40)];
    placeholderLabel.text = placeholderText;
    placeholderLabel.font = [UIFont fontWithName:_messageTextView.font.fontName size:_messageTextView.font.pointSize];
    placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    placeholderLabel.tag = 1;
    [_messageTextView addSubview:placeholderLabel];
}

- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *placeholderLabel = (UILabel *)[textView viewWithTag:1];
    if (textView.text.length > 0) {
        placeholderLabel.hidden = YES;
    } else {
        placeholderLabel.hidden = NO;
    }
}



-(void)viewDidLayoutSubviews
{
    UIEdgeInsets inset = _messageTextView.textContainerInset;
    inset.top = 10;
    inset.left = 10;
    _messageTextView.textContainerInset = inset;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [_messageTextView resignFirstResponder];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapBar:(UIBarButtonItem*)barButton {
    switch (barButton.tag) {
        case 2 : {
            if([_messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
                StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFillDescLaporan] delegate:self];
                [stickyAlertView show];
            }
            else {
                [self configureRestkit];
                [self sendReport];
            }
            break;
        }
        default:
            break;
    }
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
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST
                                                                                             pathPattern:[_delegate getPath] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];

}

- (void)sendReport {
    if ([_delegate respondsToSelector:@selector(didFinishWritingReportWithReviewID:talkID:shopID:textMessage:)]) {
        [_delegate didFinishWritingReportWithReviewID:_strReviewID
                                               talkID:_strCommentTalkID
                                               shopID:_strShopID
                                          textMessage:_messageTextView.text];
//        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if(_request.isExecuting)return;
        
        NSMutableDictionary *param = [NSMutableDictionary new];
        if([_delegate isMemberOfClass:[ProductReputationViewController class]] ||
           [_delegate isMemberOfClass:[DetailMyReviewReputationViewController class]] ||
           [_delegate isMemberOfClass:[ShopReviewPageViewController class]] ||
           [_delegate isMemberOfClass:[MyReviewDetailViewController class]]) {
            [param setObject:@"report_review" forKey:@"action"];
            [param setObject:_strReviewID forKey:@"review_id"];
            [param setObject:_strShopID forKey:@"shop_id"];
        }
        else {
            [param addEntriesFromDictionary:(_strCommentTalkID==nil? [_delegate getParameter] :
                                             @{@"action" : @"report_product_talk",
                                               @"talk_id" : _strCommentTalkID?:@(0),
                                               @"shop_id" : _strShopID? :@(0)
                                               })];
        }
        
        [param setObject:_messageTextView.text forKey:@"text_message"];
        
        if([_delegate isMemberOfClass:[ProductTalkViewController class]] ||
           [_delegate isMemberOfClass:[InboxTalkViewController class]] ||
           [_delegate isMemberOfClass:[ProductReputationViewController class]] ||
           [_delegate isMemberOfClass:[DetailMyReviewReputationViewController class]]) {
            NSString *tempProductID = strProductID;
            if(tempProductID==nil || [_delegate isMemberOfClass:[ProductTalkViewController class]])
                tempProductID = [((ProductTalkViewController *) _delegate).data objectForKey:kTKPD_PRODUCTIDKEY];
            [param setObject:tempProductID forKey:kTKPD_PRODUCTIDKEY];
        }
        
        _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:[_delegate getPath] parameters:[param encrypt]];
        
        [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSLog(@"%@", operation.HTTPRequestOperation.responseString);
            [self requestSuccess:mappingResult withOperation:operation];
            [_timer invalidate];
            _timer = nil;
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"%@", operation.HTTPRequestOperation.responseString);
            [_timer invalidate];
            _timer = nil;
            [self requestFail:error];
            StickyAlertView *stickyError = [[StickyAlertView alloc] initWithErrorMessages:@[CStringErrorKirimLaporan] delegate:self];
            [stickyError show];
        }];
        
        [_operationQueue addOperation:_request];
        
        _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    
}

- (void)requestSuccess:(id)object withOperation:(RKObjectRequestOperation *)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    GeneralAction *generalaction = stat;
    BOOL status = [generalaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcess:object];
    }
}

- (void)requestProcess:(id)object {
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            GeneralAction *generalaction = stat;
            BOOL status = [generalaction.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(generalaction.message_error)
                {
                    NSArray *array = generalaction.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
                } else {
                    //success
                    if ([generalaction.result.is_success isEqualToString:@"1"]) {
                        NSArray *array = generalaction.message_status?:[[NSArray alloc] initWithObjects:SUCCESS_REPORT_TALK, nil];
                        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
                        [stickyAlertView show];
                        if ([_delegate isKindOfClass:[UINavigationController class]]) {
                            UINavigationController *nav = (UINavigationController *)_delegate;
                            [nav.navigationController popViewControllerAnimated:YES];
                        }
                        else if([_delegate isMemberOfClass:[ProductReputationViewController class]] || [_delegate isMemberOfClass:[DetailMyReviewReputationViewController class]] || [_delegate isMemberOfClass:[MyReviewDetailViewController class]]) {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }
                    else {
                        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedSendReport] delegate:self];
                        [stickyAlertView show];
                    }
                }
            }
        }
        else{
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

- (void)requestFail:(id)error {
    
}

- (void)requestTimeout {
    
}

// implement this to dismiss login view controller (-_-")
- (void)redirectViewController:(id)viewController {

}


@end
