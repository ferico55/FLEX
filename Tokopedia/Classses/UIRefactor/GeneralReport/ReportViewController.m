//
//  ReportViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/31/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
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
#import "TKPDTabViewController.h"
#import "Tokopedia-Swift.h"

@interface ReportViewController () <UITextViewDelegate> {
    UserAuthentificationManager *_userManager;
}

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) UIViewController* viewControllerToNavigate;
@end

@implementation ReportViewController
@synthesize strProductID;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _userManager = [UserAuthentificationManager new];
    
    self.title = @"Lapor";
    [self setTextViewPlaceholder:@"Isi deskripsi laporan kamu disini.."];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tapBar:)];
    doneButton.tintColor = [UIColor whiteColor];
    doneButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneButton;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    [[AuthenticationService sharedService] ensureLoggedInFromViewController:_viewControllerToNavigate onSuccess:nil];
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
                [self sendReport];
            }
            break;
        }
        default:
            break;
    }
}


- (void)sendReport {
    self.onFinishWritingReport(_messageTextView.text);
}

//#pragma mark - user without login
- (void)displayFrom:(UIViewController *)viewController {
    _userManager = [UserAuthentificationManager new];
    _viewControllerToNavigate = viewController;
    [[AuthenticationService sharedService] ensureLoggedInFromViewController:_viewControllerToNavigate onSuccess:^{
        [viewController.navigationController pushViewController:self animated:YES];
    }];
}

@end
