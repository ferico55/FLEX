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
@interface ReportViewController () <UITextViewDelegate, LoginViewDelegate> {
    UserAuthentificationManager *_userManager;
}

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) UIViewController* HelpViewController;
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

// implement this to dismiss login view controller (-_-")
- (void)redirectViewController:(id)viewController {
    [_HelpViewController.navigationController pushViewController:viewController animated:YES];
}

//#pragma mark - user without login
- (void)displayFrom:(UIViewController *)viewController {
    _userManager = [UserAuthentificationManager new];
    if(![_userManager isLogin]) {
        _HelpViewController = viewController;
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        navigationController.navigationBar.translucent = NO;
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        LoginViewController *controller = [LoginViewController new];
        controller.delegate = self;
        controller.isPresentedViewController = YES;
        controller.redirectViewController = self;
        navigationController.viewControllers = @[controller];
        [viewController.navigationController presentViewController:navigationController animated:YES completion:nil];
    }else{
        [viewController.navigationController pushViewController:self animated:YES];
    }
}

@end
