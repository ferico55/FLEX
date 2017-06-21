//
//  ProductTalkFormViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductTalkFormViewController.h"
#import "detail.h"
#import "StickyAlert.h"
#import "ProductTalkForm.h"
#import "inbox.h"
#import "stringrestkit.h"

@interface ProductTalkFormViewController () <UITextViewDelegate>{
    BOOL _isnodata;
    
}

@property (weak, nonatomic) IBOutlet UILabel *productlabel;

@property (weak, nonatomic) IBOutlet UITextView *talkfield;
@property (weak, nonatomic) IBOutlet UITextField *talksubjectfield;
@property (weak, nonatomic) IBOutlet UIImageView *productimage;


@end

@implementation ProductTalkFormViewController {
    UIRefreshControl *_refreshControl;

    TokopediaNetworkManager *_networkManager;
    UIBarButtonItem *_sendButton;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.title = kTKPDTITLE_NEW_TALK;
    if (self) {
        _isnodata = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;

    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UIBarButtonItem *barbuttonleft;
    //NSBundle* bundle = [NSBundle mainBundle];
    
    barbuttonleft = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonleft setTintColor:[UIColor whiteColor]];
    [barbuttonleft setTag:10];
    self.navigationItem.leftBarButtonItem = barbuttonleft;
    
    _sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Kirim" style:UIBarButtonItemStyleDone target:(self) action:@selector(tap:)];
    [self disableSendButton];
    [_sendButton setTag:11];
    
    self.navigationItem.rightBarButtonItem = _sendButton;
    
    _talkfield.delegate = self;
    _talkfield.text = kTKPDMESSAGE_PLACEHOLDER;
    _talkfield.textColor = [UIColor lightGrayColor]; //optional
    
    
}

- (void) disableSendButton {
    [_sendButton setTintColor:[UIColor colorWithRed:127.0/255.0f green:127.0/255.0f blue:127.0/255.0f alpha:1.0]];
}

- (void) enableSendButton {
    [_sendButton setTintColor:[UIColor whiteColor]];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:kTKPDMESSAGE_PLACEHOLDER]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = kTKPDMESSAGE_PLACEHOLDER;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

- (void) textViewDidChange:(UITextView *)textView {
    if ([self isTalkFieldTextLengthBelowFive]) {
        [self disableSendButton];
    } else {
        [self enableSendButton];
    }
}

- (Boolean) isTalkFieldTextLengthBelowFive  {
    if ([_talkfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length < 5) {
        return YES;
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _productlabel.text = [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY];
    
    UIImageView *thumb = _productimage;
    UIImage *placeholderImage = [UIImage imageNamed:@"icon_shop_grey.png"];
    NSURL *url = [NSURL URLWithString:[_data objectForKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [thumb setImageWithURLRequest:request
                 placeholderImage:placeholderImage
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
#pragma clang diagnostic pop
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [thumb setImage:placeholderImage];
    }];
}

-(void)doProductTalkForm {
    _sendButton.enabled = NO;

    NSDictionary* param = @{
                            kTKPDTALK_TALKMESSAGE:[_talkfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                            kTKPDMESSAGE_PRODUCTIDKEY:[_data objectForKey:kTKPDMESSAGE_PRODUCTIDKEY]
                            };

    [_networkManager requestWithBaseUrl:[NSString kunyitUrl]
                                   path:@"/talk/v2/create"
                                 method:RKRequestMethodPOST
                              parameter:param
                                mapping:[ProductTalkForm mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  [self requestsuccess:successResult withOperation:operation];
                                  [_refreshControl endRefreshing];
                                  _sendButton.enabled = YES;
                              }
                              onFailure:^(NSError *errorResult) {
                                  _sendButton.enabled = YES;
                              }];
}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    
    NSString *is_success = [[info result] is_success];
    //TODO ini jgn pake new_talk_id 
    NSString *talk_id = [[info result] talk_id];
    
    if([is_success isEqualToString:kTKPD_STATUSSUCCESS]) {
        NSArray *array = [[NSArray alloc] initWithObjects:KTKPDTALK_DELIVERED, nil];
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
        [stickyAlertView show];
        
        //enable comment button talk
        NSDictionary *userinfo;
        userinfo = @{TKPD_TALK_MESSAGE:_talkfield.text,
                     TKPD_TALK_ID:talk_id,
                     TKPD_TALK_SHOP_ID:[_data objectForKey:TKPD_TALK_SHOP_ID]
                     };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTalk" object:nil userInfo:userinfo];
        [self.navigationController popViewControllerAnimated:TRUE];
    } else {
        NSArray *array = [[NSArray alloc] initWithObjects:KTKPDTALK_UNDELIVERED, nil];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
        [alert show];
    }
    
}

-(void) requesttimeout {
    
}


#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        
        switch (button.tag) {
            case 10: {
                [self.navigationController popViewControllerAnimated:TRUE];
                break;
            }
            
            case 11 : {
                if([self isTalkFieldTextLengthBelowFive] || [_talkfield.text isEqualToString:kTKPDMESSAGE_PLACEHOLDER]) {
                    NSArray *array = [[NSArray alloc] initWithObjects:KTKPDMESSAGE_EMPTYFORM2, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
                } else {
                    [self doProductTalkForm];
                }
                
                break;
            }
                
                
            default:
                break;
        }
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
