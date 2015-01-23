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
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    NSInteger _requestcount;
    NSTimer *_timer;
    NSOperationQueue *_operationQueue;
    
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
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UIBarButtonItem *barbuttonleft;
    UIBarButtonItem *barbuttonright;
    //NSBundle* bundle = [NSBundle mainBundle];
    
    barbuttonleft = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonleft setTintColor:[UIColor whiteColor]];
    [barbuttonleft setTag:10];
    self.navigationItem.leftBarButtonItem = barbuttonleft;
    
    barbuttonright = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonright setTintColor:[UIColor blackColor]];
    [barbuttonright setTag:11];
    
    self.navigationItem.rightBarButtonItem = barbuttonright;
    
    _talkfield.delegate = self;
    _talkfield.text = kTKPDMESSAGE_PLACEHOLDER;
    _talkfield.textColor = [UIColor lightGrayColor]; //optional
    
    _operationQueue = [NSOperationQueue new];
    
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _productlabel.text = [_data objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTNAMEKEY];
    
    UIImageView *thumb = _productimage;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[_data objectForKey:kTKPDDETAILPRODUCT_APIIMAGESRCKEY]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    //request.URL = url;
    
    thumb.image = nil;
    //thumb.hidden = YES;	//@prepareforreuse then @reset
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        //NSLOG(@"thumb: %@", thumb);
        [thumb setImage:image];
        
#pragma clang diagnostic pop
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
    
}


-(void)doProductTalkForm {
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY:kTKPDTALK_ADDTALK,
                            kTKPDTALK_TALKMESSAGE:_talkfield.text,
                            kTKPDMESSAGE_PRODUCTIDKEY:[_data objectForKey:kTKPDMESSAGE_PRODUCTIDKEY]
                            };
    
    _requestcount ++;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"action/talk.pl" parameters:[param encrypt]];
    
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestsuccess:mappingResult withOperation:operation];
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        /** failure **/

    }];
    
    [_operationQueue addOperation:_request];
    
    _timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

}

-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    
    NSString *is_success = [[info result] is_success];
    //TODO ini jgn pake new_talk_id 
    NSString *talk_id = [[info result] talk_id];
    
    if([is_success isEqualToString:kTKPD_STATUSSUCCESS]) {
        NSArray *array = [[NSArray alloc] initWithObjects:KTKPDTALK_DELIVERED, nil];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
        
        //enable comment button talk
        NSDictionary *userinfo;
        userinfo = @{TKPD_TALK_MESSAGE:_talkfield.text,
                     TKPD_TALK_ID:talk_id,
                     TKPD_TALK_SHOP_ID:[_data objectForKey:TKPD_TALK_SHOP_ID]
                     };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTalk" object:nil userInfo:userinfo];
    } else {
        
        NSArray *array = [[NSArray alloc] initWithObjects:KTKPDTALK_UNDELIVERED, nil];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
    }
    
}

-(void) configureRestkit {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProductTalkForm class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProductTalkFormResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success", @"talk_id":@"talk_id"}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:@"action/talk.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
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
                if (_request.isExecuting) return;
                if(_talkfield.text.length < 3) {
                    NSArray *array = [[NSArray alloc] initWithObjects:KTKPDMESSAGE_EMPTYFORM, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                } else {
                    NSDictionary *userinfo;
                    userinfo = @{TKPD_TALK_MESSAGE:_talkfield.text};
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTalk" object:nil userInfo:userinfo];
                    [self configureRestkit];
                    [self doProductTalkForm];
                    [self.navigationController popViewControllerAnimated:TRUE];
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
                if (_request.isExecuting) return;
                [self doProductTalkForm];
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
