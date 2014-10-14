//
//  FilterViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "FilterLocationViewController.h"
#import "FilterConditionViewController.h"
#import "FilterViewController.h"

#pragma mark Filter View Controller
@interface FilterViewController ()<FilterLocationViewControllerDelegate,FilterConditionViewControllerDelegate,UITextFieldDelegate>
{
    UITextField *_activetextfield;
    NSMutableDictionary *_detailfilter;
    NSInteger _type;
}
@property (weak, nonatomic) IBOutlet UITextField *pricemaxcatalog;
@property (weak, nonatomic) IBOutlet UITextField *pricemincatalog;
@property (weak, nonatomic) IBOutlet UITextField *pricemin;
@property (weak, nonatomic) IBOutlet UITextField *pricemax;
@property (strong, nonatomic) IBOutlet UIView *productview;
@property (strong, nonatomic) IBOutlet UIView *catalogview;
@property (strong, nonatomic) IBOutlet UIView *shopview;
@property (weak, nonatomic) IBOutlet UIScrollView *container;

@property (weak, nonatomic) IBOutlet UIButton *shoplocationbutton;
@property (weak, nonatomic) IBOutlet UIButton *productlocationbutton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *shopsegmentcontrol;
@property (weak, nonatomic) IBOutlet UISegmentedControl *productsegmentcontrol;
@property (weak, nonatomic) IBOutlet UIButton *conditionbutton;

@property (strong, nonatomic) IBOutlet UIView *detailcatalogview;
@property (weak, nonatomic) IBOutlet UIButton *detailcataloglocationbutton;

@end

@implementation FilterViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = kTKPDFILTER_TITLEFILTERKEY;
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _type = [[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] integerValue]?:0;
    switch (_type) {
        case 1:
        case 2:
        {   //product
            [self.view addSubview: _productview];
            break;
        }
        case 3:
        {   //catalog
            [self.view addSubview: _catalogview];
            break;
        }
        case 4:
        {    //detail catalog
            [self.view addSubview: _detailcatalogview];
            break;
        }
        case 5:
        {    //shop
            [self.view addSubview: _shopview];
            break;
        }
        case 6:
        {   //shop product
            [self.view addSubview: _shopview];
            break;
        }
        default:
            break;
    }
    
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
    //TODO:: Change image
    //img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    }
    else
        //barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _detailfilter = [NSMutableDictionary new];
    
    /** keyboard notification **/
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillBeHidden:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark - View Gesture
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem*)sender;
        switch (button.tag) {
            case 10:
            {
                //CANCEL
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                //SUBMIT
                NSInteger pricemin = [[_detailfilter objectForKey:kTKPDFILTER_APIPRICEMINKEY] integerValue];
                NSInteger pricemax = [[_detailfilter objectForKey:kTKPDFILTER_APIPRICEMAXKEY] integerValue];
                if (pricemax>=pricemin){
                    NSDictionary *userinfo = @{kTKPDFILTER_APILOCATIONKEY:[_detailfilter objectForKey:kTKPDFILTER_APILOCATIONKEY]?:@"",
                                               kTKPDFILTER_APISHOPTYPEKEY:[_detailfilter objectForKey:kTKPDFILTER_APISHOPTYPEKEY]?:@"",
                                               kTKPDFILTER_APIPRICEMINKEY:[_detailfilter objectForKey:kTKPDFILTER_APIPRICEMINKEY]?:@"",
                                               kTKPDFILTER_APIPRICEMAXKEY:[_detailfilter objectForKey:kTKPDFILTER_APIPRICEMAXKEY]?:@"",
                                               kTKPDFILTER_APICONDITIONKEY:[_detailfilter objectForKey:kTKPDFILTER_APICONDITIONKEY]?:@""};
                    
                    switch (_type) {
                        case 1:
                        case 2:
                        {   //product
                            [[NSNotificationCenter defaultCenter] postNotificationName:TKPD_FILTERPRODUCTPOSTNOTIFICATIONNAME object:nil userInfo:userinfo];
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            break;
                        }
                        case 3:
                        {   //catalog
                            [[NSNotificationCenter defaultCenter] postNotificationName:TKPD_FILTERCATALOGPOSTNOTIFICATIONNAME object:nil userInfo:userinfo];
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            break;
                        }
                        case 4:
                        {    //detail catalog
                            [[NSNotificationCenter defaultCenter] postNotificationName:TKPD_FILTERDETAILCATALOGPOSTNOTIFICATIONNAME object:nil userInfo:userinfo];
                            UINavigationController *nav = (UINavigationController *)self.presentingViewController;
                            [self dismissViewControllerAnimated:NO completion:^{
                                [nav popViewControllerAnimated:NO];
                            }];
                            break;
                        }
                        case 5:
                        {    //shop
                            [[NSNotificationCenter defaultCenter] postNotificationName:TKPD_FILTERSHOPPOSTNOTIFICATIONNAME object:nil userInfo:userinfo];
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            break;
                        }
                        case 6:
                        {   //shop product
                            [self.view addSubview: _shopview];
                            break;
                        }
                        default:
                            break;
                    }
                }
                else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"price max < price min" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case 10:
            {
                // select location
                FilterLocationViewController *vc = [FilterLocationViewController new];
                if (_type == 3) {
                    //catalog
                    vc.data = @{kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY : [_data objectForKey:kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY]?:@[]};
                }
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 11:
            {
                // action reset
                [_detailfilter removeAllObjects];
                _pricemax.text = nil;
                _pricemin.text = nil;
                _pricemincatalog.text = nil;
                _pricemaxcatalog.text = nil;
                [_productlocationbutton setTitle:@"All Location" forState:UIControlStateNormal];
                [_shoplocationbutton setTitle:@"All Location" forState:UIControlStateNormal];
                [_shopsegmentcontrol setSelectedSegmentIndex:0];
                [_productsegmentcontrol setSelectedSegmentIndex:0];
                break;
            }
            case 12:
            {
                // select condition
                FilterConditionViewController *vc = [FilterConditionViewController new];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *button = (UISegmentedControl*)sender;
        switch (button.selectedSegmentIndex) {
            case 0:
                [_detailfilter setObject:@(0) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                break;
            case 1:
            {
                switch (_type) {
                    case 1:
                    case 2:
                    {   //product
                        [_detailfilter setObject:@(3) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                        break;
                    }
                    case 3:
                    {   //catalog
                        [_detailfilter setObject:@(3) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                        break;
                    }
                    case 4:
                    {    //detail catalog
                        break;
                    }
                    case 5:
                    {    //shop
                        [_detailfilter setObject:@(2) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                        break;
                    }
                    case 6:
                    {   //shop product
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
            default:
                break;
            }
    }
}
- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
}

#pragma mark - Filter View Controller Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // allow backspace
    if (!string.length){
        return YES;
    }

    // Prevent invalid character input, if keyboard is numberpad
    if (textField.keyboardType == UIKeyboardTypeNumberPad){
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            // BasicAlert(@"", @"This field accepts only numeric entries.");
            return NO;
        }
    }
    
    // only enable the OK/submit button if they have entered all numbers for the last four of their SSN (prevents early submissions/trips to authentication server)
    return YES;
}

#pragma mark - Delegate
-(void)FilterLocationViewController:(UIViewController *)viewcontroller withdata:(NSDictionary *)data
{
    [_shoplocationbutton setTitle:[data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY] forState:UIControlStateNormal];
    [_productlocationbutton setTitle:[data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY] forState:UIControlStateNormal];
    [_detailcataloglocationbutton setTitle:[data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY] forState:UIControlStateNormal];
    [_detailfilter setObject:[data objectForKey:kTKPDFILTER_APILOCATIONKEY] forKey:kTKPDFILTER_APILOCATIONKEY];
}

-(void)FilterConditionViewController:(UIViewController *)viewcontroller withdata:(NSDictionary *)data
{
    NSDictionary *conditiondata = [data objectForKey:kTKPDFILTER_DATACONDITIONKEY]?:@{};
    [_conditionbutton setTitle:[conditiondata objectForKey:kTKPDFILTER_DATASORTNAMEKEY] forState:UIControlStateNormal];
    [_detailfilter setObject:[conditiondata objectForKey:kTKPDFILTER_DATASORTVALUEKEY] forKey:kTKPDFILTER_APICONDITIONKEY];
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _activetextfield = textField;
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _pricemin || textField == _pricemincatalog) {
        [_detailfilter setObject:textField.text forKey:kTKPDFILTER_APIPRICEMINKEY];
    }
    if (textField == _pricemax || textField == _pricemaxcatalog) {
        [_detailfilter setObject:textField.text forKey:kTKPDFILTER_APIPRICEMAXKEY];
    }
    return YES;
}

#pragma mark - Keyboard Notification
// Called when the UIKeyboardWillShowNotification is sent
- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _container.contentInset = contentInsets;
    _container.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    //if (!CGRectContainsPoint(aRect, _activetextfield.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _activetextfield.frame.origin.y-kbSize.height);
        [_container setContentOffset:scrollPoint animated:YES];
    //}
}
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _container.contentInset = contentInsets;
    _container.scrollIndicatorInsets = contentInsets;
    
}


@end
