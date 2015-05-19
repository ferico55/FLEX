//
//  ShopEditStatusViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "detail.h"

#import "ClosedInfo.h"
#import "ShopEditStatusViewController.h"

#import "URLCacheController.h"

#import "AlertDatePickerView.h"

#pragma mark - Shop Edit Status View Controller
@interface ShopEditStatusViewController ()<UITextViewDelegate, TKPDAlertViewDelegate>
{
    NSInteger _type;
    
    UITextView *_activetextview;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    NSMutableDictionary *_datainput;
    
    BOOL _isnodata;
    NSInteger _requestcount;
    
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    RKResponseDescriptor *_responseDescriptor;
    NSOperationQueue *_operationQueue;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
}

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumbicon;
@property (weak, nonatomic) IBOutlet UIView *viewcontentclose;
@property (weak, nonatomic) IBOutlet UILabel *labelcatatan;
@property (weak, nonatomic) IBOutlet UIButton *buttondate;
@property (weak, nonatomic) IBOutlet UITextView *textviewnote;

- (IBAction)tap:(id)sender;
- (IBAction)gesture:(id)sender;

@end

@implementation ShopEditStatusViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    self.title = @"Ubah Status Toko";
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _type = [[_data objectForKey:kTKPDDETAIL_DATASTATUSSHOPKEY]integerValue];
    
    [self setDefaultData:_data];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activetextview resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {   // shop status
                AlertDatePickerView *v = [AlertDatePickerView newview];
                v.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPESHOPEDITKEY)};
                v.tag = 10;
                v.delegate = self;
                v.isSetMinimumDate = YES;
                [v show];
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
                //back
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case 11:
            {
                //save
                NSMutableArray *messages = [NSMutableArray new];
                NSInteger status = [[_datainput objectForKey:kTKPDSHOPEDIT_APISTATUSKEY]integerValue]?:_type;
                if (status==kTKPDDETAIL_DATASTATUSSHOPCLOSED) {
                    NSString *reason = [_datainput objectForKey:kTKPDSHOPEDIT_APICLOSEDNOTEKEY];
                    if (reason && ![reason isEqualToString:@""]) {
                        NSDictionary *info = _datainput;
                        [_delegate ShopEditStatusViewController:self withData:info];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        [messages addObject:@"Catatan harus diisi."];
                    }
                    if (messages.count>0) {
                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
                        [alert show];
                    }
    
                }
                else
                {
                    [_delegate ShopEditStatusViewController:self withData:_datainput];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)gesture:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                break;
            }
            case UIGestureRecognizerStateChanged: {
                break;
            }
            case UIGestureRecognizerStateEnded: {
                [_activetextview resignFirstResponder];
                if (gesture.view.tag) {
                    _type = gesture.view.tag - 9;
                    [_datainput setObject:@(_type) forKey:kTKPDSHOPEDIT_APISTATUSKEY];
                    [self setDefaultData:_data];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        switch (_type) {
            case kTKPDDETAIL_DATASTATUSSHOPOPEN:
            {
                _viewcontentclose.hidden = YES;
                ((UIImageView*)_thumbicon[0]).hidden = NO;
                ((UIImageView*)_thumbicon[1]).hidden = YES;
                break;
            }
            case kTKPDDETAIL_DATASTATUSSHOPCLOSED:
            {
                _viewcontentclose.hidden = NO;
                NSString *note = [_data objectForKey:kTKPDSHOPEDIT_APICLOSEDNOTEKEY];
                _textviewnote.text = [note isEqualToString:@"0"]?@"":note;
                [_datainput setObject:note forKey:kTKPDSHOPEDIT_APICLOSEDNOTEKEY];
                
                ((UIImageView*)_thumbicon[0]).hidden = YES;
                ((UIImageView*)_thumbicon[1]).hidden = NO;
                
                NSDateComponents* deltaComps = [NSDateComponents new];
                [deltaComps setDay:7];
                NSDate* tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps toDate:[NSDate date] options:0];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:tomorrow];
                NSInteger year = [components year];
                NSInteger month = [components month];
                NSInteger day = [components day];
                NSString *datestring = [NSString stringWithFormat:@"%zd/%zd/%zd",day,month,year];
                
                NSString *closedUntil = [_data objectForKey:kTKPDDETAILSHOP_APICLOSEDUNTILKEY]?:datestring;
                [_datainput setObject:closedUntil forKey:kTKPDDETAILSHOP_APICLOSEDUNTILKEY];
                NSString *until = [closedUntil isEqualToString:@"0"]?datestring:closedUntil;
                [_buttondate setTitle:until forState:UIControlStateNormal];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 10:
        {
            // alert date picker date
            NSDictionary *data = alertView.data;
            NSDate *date = [data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
            NSInteger year = [components year];
            NSInteger month = [components month];
            NSInteger day = [components day];
            NSString *datestring = [NSString stringWithFormat:@"%zd/%zd/%zd",day,month,year];
            [_datainput setObject:datestring forKey:kTKPDDETAILSHOP_APICLOSEDUNTILKEY];
            [_buttondate setTitle:datestring forState:UIControlStateNormal];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - TextView Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];    
    _activetextview = textView;

    _labelcatatan.hidden = YES;

    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _textviewnote) {
        if(textView.text.length != 0 && ![textView.text isEqualToString:@""]){
            [_datainput setObject:textView.text forKey:kTKPDSHOPEDIT_APICLOSEDNOTEKEY];
        }
    }
    return YES;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)info {

}

- (void)keyboardWillHide:(NSNotification *)info {
}

@end
