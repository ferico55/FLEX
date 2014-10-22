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
@interface FilterViewController ()
    <FilterLocationViewControllerDelegate,
    FilterConditionViewControllerDelegate,
    UITextFieldDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate>
{
    UITextField *_activetextfield;
    NSMutableDictionary *_detailfilter;
    NSInteger _type;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
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
    [self.navigationController.navigationBar setTranslucent:NO];
    
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
//        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    }
    else
//        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    [barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    //TODO:: Change image
    //img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
        [barbutton1 setTintColor:[UIColor blackColor]];
    }
    else
        //barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
        barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor blackColor]];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _detailfilter = [NSMutableDictionary new];
    NSDictionary *datafilter = [_data objectForKey:kTKPDFILTER_DATAFILTERKEY]?:@{};
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTER_APILOCATIONKEY]?:@"" forKey:kTKPDFILTER_APILOCATIONKEY];
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTER_DATASORTVALUEKEY]?:@"" forKey:kTKPDFILTER_APICONDITIONKEY];
    
    NSInteger pricemin = [[datafilter objectForKey:kTKPDFILTER_APIPRICEMINKEY] integerValue];
    NSInteger pricemax = [[datafilter objectForKey:kTKPDFILTER_APIPRICEMAXKEY] integerValue];
    [_detailfilter setObject:@(pricemin?:0) forKey:kTKPDFILTER_APIPRICEMINKEY];
    [_detailfilter setObject:@(pricemax?:0) forKey:kTKPDFILTER_APIPRICEMAXKEY];
    
    _pricemin.text = (pricemin>0)?[NSString stringWithFormat:@"%d",pricemin]:0;
    _pricemax.text = (pricemax>0)?[NSString stringWithFormat:@"%d",pricemax]:0;
    _pricemincatalog.text = (pricemin>0)?[NSString stringWithFormat:@"%d",pricemin]:0;
    _pricemaxcatalog.text = (pricemax>0)?[NSString stringWithFormat:@"%d",pricemax]:0;
    
    NSString *location = [datafilter objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY]?:@"All Location";
    [_shoplocationbutton setTitle:location forState:UIControlStateNormal];
    [_productlocationbutton setTitle:location forState:UIControlStateNormal];
    [_detailcataloglocationbutton setTitle:location forState:UIControlStateNormal];
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY]?:@"All Location" forKey:kTKPDFILTER_APILOCATIONNAMEKEY];
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY];
    
    NSString *condition = [datafilter objectForKey:kTKPDFILTER_APICONDITIONNAMEKEY] ?:@"All Condition";
    [_conditionbutton setTitle:condition forState:UIControlStateNormal];
    [_detailfilter setObject:condition forKey:kTKPDFILTER_APICONDITIONKEY];
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTERCONDITION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDFILTERCONDITION_DATAINDEXPATHKEY];
    
    NSInteger goldshopvalue = [[datafilter objectForKey:kTKPDFILTER_APISHOPTYPEKEY] integerValue];
    switch (goldshopvalue) {
        case 0:
            [_detailfilter setObject:@(goldshopvalue) forKey:kTKPDFILTER_APISHOPTYPEKEY];
            break;
        case 2:
        {
            switch (_type) {
                case 5:
                {    //shop
                    [_detailfilter setObject:@(goldshopvalue) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                    _shopsegmentcontrol.selectedSegmentIndex=1;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 3:
        {
            switch (_type) {
                case 1:
                case 2:
                {   //product
                    [_detailfilter setObject:@(goldshopvalue) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                    _productsegmentcontrol.selectedSegmentIndex = 1;
                    break;
                }
                case 3:
                {   //catalog
                    [_detailfilter setObject:@(goldshopvalue) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                    _productsegmentcontrol.selectedSegmentIndex = 1;
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

    
    /** keyboard notification **/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
                        name:UIKeyboardWillShowNotification
                        object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
                        name:UIKeyboardWillHideNotification
                        object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
                                               kTKPDFILTER_APICONDITIONKEY:[_detailfilter objectForKey:kTKPDFILTER_APICONDITIONKEY]?:@"",
                                               kTKPDFILTER_APILOCATIONNAMEKEY: [_detailfilter objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY]?:@"",
                                               kTKPDFILTERLOCATION_DATAINDEXPATHKEY:[_detailfilter objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0],
                                               kTKPDFILTERCONDITION_DATAINDEXPATHKEY:[_detailfilter objectForKey:kTKPDFILTERCONDITION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0],
                                               kTKPDFILTER_APICONDITIONNAMEKEY : [_detailfilter objectForKey:kTKPDFILTER_APICONDITIONNAMEKEY]?:@""
                                               };
                    
                    switch (_type) {
                        case 1:
                        case 2:
                        {   //product
                            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_FILTERPRODUCTPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            break;
                        }
                        case 3:
                        {   //catalog
                            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_FILTERCATALOGPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            break;
                        }
                        case 4:
                        {    //detail catalog
                            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_FILTERDETAILCATALOGPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                            UINavigationController *nav = (UINavigationController *)self.presentingViewController;
                            [self dismissViewControllerAnimated:NO completion:^{
                                [nav popViewControllerAnimated:NO];
                            }];
                            break;
                        }
                        case 5:
                        {    //shop
                            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_FILTERSHOPPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                            break;
                        }
                        case 6:
                        {   //shop product
                            break;
                        }
                        default:
                            break;
                    }
                }
                else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"price max < price min" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
                    vc.data = @{kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY : [_data objectForKey:kTKPDFILTERLOCATION_DATALOCATIONARRAYKEY]?:@[],
                                kTKPDFILTER_DATAINDEXPATHKEY: [_detailfilter objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0]};
                }
                else
                {
                    vc.data = @{kTKPDFILTER_DATAINDEXPATHKEY: [_detailfilter objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0]};
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
                vc.data = @{kTKPDFILTER_DATAINDEXPATHKEY: [_detailfilter objectForKey:kTKPDFILTERCONDITION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0]};
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
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [_activetextfield resignFirstResponder];
            break;
        }
    }
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
    [_detailfilter setObject:[data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY] forKey:kTKPDFILTER_APILOCATIONNAMEKEY];
    [_detailfilter setObject:[data objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY] forKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY];
}

-(void)FilterConditionViewController:(UIViewController *)viewcontroller withdata:(NSDictionary *)data
{
    NSDictionary *conditiondata = [data objectForKey:kTKPDFILTER_DATACONDITIONKEY]?:@{};
    [_conditionbutton setTitle:[conditiondata objectForKey:kTKPDFILTER_DATASORTNAMEKEY] forState:UIControlStateNormal];
    [_detailfilter setObject:[conditiondata objectForKey:kTKPDFILTER_DATASORTVALUEKEY] forKey:kTKPDFILTER_APICONDITIONKEY];
    [_detailfilter setObject:[data objectForKey:kTKPDFILTERCONDITION_DATAINDEXPATHKEY] forKey:kTKPDFILTERCONDITION_DATAINDEXPATHKEY];
    [_detailfilter setObject:[conditiondata objectForKey:kTKPDFILTER_DATASORTNAMEKEY] forKey:kTKPDFILTER_APICONDITIONNAMEKEY];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

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
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        
        _scrollviewContentSize = [_container contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_container setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             _scrollviewContentSize = [_container contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             UIEdgeInsets inset = _container.contentInset;
                             inset.top += ((_activetextfield.frame.origin.y-_activetextfield.frame.size.height) - _keyboardPosition.y);
                             [_container setContentSize:_scrollviewContentSize];
                             [_container setContentInset:inset];
                         }
                         completion:^(BOOL finished){
                         }];

    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         _container.contentInset = contentInsets;
                         _container.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


@end
