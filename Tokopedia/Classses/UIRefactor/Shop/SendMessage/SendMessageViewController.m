//
//  SendMessageViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SendMessageViewController.h"
#import "detail.h"
#import "SendMessage.h"
#import "StickyAlert.h"
#import "InboxMessageAction.h"
#import "GeneralAction.h"

@implementation MessageTextView
@synthesize del;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        self.delegate = self;
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self=[super initWithCoder:aDecoder]) {
        self.delegate = self;
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
        return;
    
    if([[self text] length] == 0)
        [[self viewWithTag:999] setAlpha:1];
    else
        [[self viewWithTag:999] setAlpha:0];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return [del textViewShouldBeginEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return [del textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if (_placeHolderLabel == nil )
        {
            _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.bounds.size.width - 16, 0)];
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.numberOfLines = 0;
            _placeHolderLabel.font = self.font;
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            [self addSubview:_placeHolderLabel];
        }
        
        _placeHolderLabel.text = self.placeholder;
        [_placeHolderLabel sizeToFit];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

@end












@interface SendMessageViewController () <CustomTxtViewProtocol>{
    BOOL _isnodata;
    
}

@property (weak, nonatomic) IBOutlet UILabel *shoplabel;
@property (weak, nonatomic) IBOutlet MessageTextView *messagefield;
@property (weak, nonatomic) IBOutlet UITextField *messagesubjectfield;


@end

@implementation SendMessageViewController {
    UIRefreshControl *_refreshControl;
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    NSInteger _requestcount;
    NSTimer *_timer;
    NSOperationQueue *_operationQueue;
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.title = kTKPDTITLE_SEND_MESSAGE;
    if (self) {
        _isnodata = YES;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UIBarButtonItem *barbuttonleft;
    UIBarButtonItem *barbuttonright;
    //NSBundle* bundle = [NSBundle mainBundle];
    
    barbuttonleft = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonleft setTintColor:[UIColor whiteColor]];
    [barbuttonleft setTag:10];
    self.navigationItem.leftBarButtonItem = barbuttonleft;
    
    barbuttonright = [[UIBarButtonItem alloc] initWithTitle:@"Kirim" style:UIBarButtonItemStyleDone target:(self) action:@selector(tap:)];
    [barbuttonright setTintColor:[UIColor whiteColor]];
    [barbuttonright setTag:11];
    
    self.navigationItem.rightBarButtonItem = barbuttonright;
    
    _messagefield.del = self;
    _messagefield.placeholder = kTKPDMESSAGE_PLACEHOLDER;
    _messagefield.placeholderColor = [UIColor lightGrayColor];
    
    _shoplabel.text = [_data objectForKey:@"shop_name"];
    
    _messagesubjectfield.text = _subject?:@"";
    _messagefield.text = _message?:@"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Shop - Send Message Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doSendMessage {
    NSDictionary* param = @{
                            @"message" : _messagefield.text,
                            @"message_subject" : _messagesubjectfield.text,
                            @"to_shop_id" : [_data objectForKey:@"shop_id"]?:@"",
                            @"to_user_id" : [_data objectForKey:@"user_id"]?:@""
                            };
    
    TokopediaNetworkManager* requestManager = [TokopediaNetworkManager new];
    requestManager.isUsingHmac = YES;
    
    [requestManager requestWithBaseUrl:[NSString kunyitUrl]
                                  path:@"/v1/message"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[GeneralAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 [self requestsuccess:successResult withOperation:operation];
                             } onFailure:nil];

}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    GeneralAction* info = [result objectForKey:@""];
    
    NSString *is_success = [[info data] is_success];
    
    if([is_success isEqualToString:kTKPD_STATUSSUCCESS]) {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:@[KTKPDMESSAGE_DELIVERED] delegate:self];
        [stickyAlertView show];
        [self.navigationController popViewControllerAnimated:TRUE];
    } else {
        
        NSArray *array = [[NSArray alloc] initWithObjects:KTKPDMESSAGE_UNDELIVERED, nil];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
        [alert show];
    }
    
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
                if (_request.isExecuting) return;
                if(_messagesubjectfield.text.length == 0) {
                    NSArray *array = [[NSArray alloc] initWithObjects:kTKPDSUBJECT_EMPTY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
                }
                else if(_messagefield.text.length == 0) {
                    NSArray *array = [[NSArray alloc] initWithObjects:kTKPDMESSAGE_EMPTY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
                } else {
                    [self doSendMessage];
                }
                
                break;
            }
                
                
            default:
                break;
        }
        
    }
    
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        
        switch (button.tag) {
            case 10: {
                
                break;
            }
                
            case 11 : {
                [self doSendMessage];
                break;
            }
            default:
                break;
        }
    }
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

@end
