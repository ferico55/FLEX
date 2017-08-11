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

@property (weak, nonatomic) IBOutlet UIButton *resetButton;

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
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame = self.view.frame;
    frame.size.width = screenRect.size.width;
    frame.size.height = screenRect.size.height;
    self.view.frame = frame;
    frame = self.productview.frame;
    frame.size.width = screenRect.size.width;
    frame.size.height = screenRect.size.height;
    self.productview.frame = frame;
    frame = self.catalogview.frame;
    frame.size.width = screenRect.size.width;
    frame.size.height = screenRect.size.height;
    self.catalogview.frame = frame;
    frame = self.shopview.frame;
    frame.size.width = screenRect.size.width;
    frame.size.height = screenRect.size.height;
    self.shopview.frame = frame;
    
    [self.navigationController.navigationBar setTranslucent:NO];
        
    _type = [[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] integerValue]?:0;
    switch (_type) {
        case kTKPDFILTER_DATATYPEHOTLISTVIEWKEY:
        case kTKPDFILTER_DATATYPEPRODUCTVIEWKEY:
        {
            [self.view insertSubview:_productview belowSubview:_resetButton];
            break;
        }
        case kTKPDFILTER_DATATYPECATALOGVIEWKEY:
        { 
            [self.view insertSubview:_catalogview belowSubview:_resetButton];
            break;
        }
        case kTKPDFILTER_DATATYPESHOPVIEWKEY:
        {
            [self.view insertSubview:_shopview belowSubview:_resetButton];
            break;
        }
        case kTKPDFILTER_DATATYPESHOPPRODUCTVIEWKEY:
        {
            [self.view insertSubview:_shopview belowSubview:_resetButton];
            break;
        }
        default:
            break;
    }
    
    UIBarButtonItem *barbutton1;
    //TODO:: Change image
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                  style:UIBarButtonItemStylePlain
                                                 target:(self)
                                                 action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor whiteColor]];
    [barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;

    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                  style:UIBarButtonItemStyleDone
                                                 target:(self)
                                                 action:@selector(tap:)];
	[barbutton1 setTag:11];
    self.navigationItem.rightBarButtonItem = barbutton1;
    
    _detailfilter = [NSMutableDictionary new];
    NSDictionary *datafilter = [_data objectForKey:kTKPDFILTER_DATAFILTERKEY]?:@{};
    [_detailfilter setObject:[datafilter objectForKey:@"floc"]?:@"" forKey:@"floc"];
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTER_DATASORTVALUEKEY]?:@"" forKey:kTKPDFILTER_APICONDITIONKEY];
    
    NSInteger pricemin = [[datafilter objectForKey:@"pmin"] integerValue];
    NSInteger pricemax = [[datafilter objectForKey:@"pmax"] integerValue];
    [_detailfilter setObject:@(pricemin?:0) forKey:@"pmin"];
    [_detailfilter setObject:@(pricemax?:0) forKey:@"pmax"];
    
    _pricemin.text = (pricemin>0)?[NSString stringWithFormat:@"%zd",pricemin]:0;
    _pricemax.text = (pricemax>0)?[NSString stringWithFormat:@"%zd",pricemax]:0;
    _pricemincatalog.text = (pricemin>0)?[NSString stringWithFormat:@"%zd",pricemin]:0;
    _pricemaxcatalog.text = (pricemax>0)?[NSString stringWithFormat:@"%zd",pricemax]:0;
    
    NSString *location = [datafilter objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY]?:@"Semua Lokasi";
    [_shoplocationbutton setTitle:location forState:UIControlStateNormal];
    [_productlocationbutton setTitle:location forState:UIControlStateNormal];
    [_detailcataloglocationbutton setTitle:location forState:UIControlStateNormal];
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY]?:@"Semua Lokasi" forKey:kTKPDFILTER_APILOCATIONNAMEKEY];
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY];
    
    NSString *condition = [datafilter objectForKey:kTKPDFILTER_APICONDITIONNAMEKEY] ?:@"Semua Kondisi";
    [_conditionbutton setTitle:condition forState:UIControlStateNormal];
    [_detailfilter setObject:condition forKey:kTKPDFILTER_APICONDITIONKEY];
    [_detailfilter setObject:[datafilter objectForKey:kTKPDFILTERCONDITION_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0] forKey:kTKPDFILTERCONDITION_DATAINDEXPATHKEY];
    
    NSInteger goldshopvalue = [[datafilter objectForKey:@"fshop"] integerValue];
    switch (goldshopvalue) {
        case 0:
            [_detailfilter setObject:@(goldshopvalue) forKey:@"fshop"];
            break;
        case 2:
        {
            switch (_type) {
                case kTKPDFILTER_DATATYPESHOPVIEWKEY:
                {
                    [_detailfilter setObject:@(goldshopvalue) forKey:@"fshop"];
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
                case kTKPDFILTER_DATATYPEHOTLISTVIEWKEY:
                case kTKPDFILTER_DATATYPEPRODUCTVIEWKEY:
                { 
                    [_detailfilter setObject:@(goldshopvalue) forKey:@"fshop"];
                    _productsegmentcontrol.selectedSegmentIndex = 1;
                    break;
                }
                case kTKPDFILTER_DATATYPECATALOGVIEWKEY:
                {
                    [_detailfilter setObject:@(goldshopvalue) forKey:@"fshop"];
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
    
    [_pricemin addTarget:self action:@selector(priceTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [_pricemax addTarget:self action:@selector(priceTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];

    [_pricemincatalog addTarget:self action:@selector(priceTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [_pricemaxcatalog addTarget:self action:@selector(priceTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
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
                NSInteger priceMin = [[_detailfilter objectForKey:@"pmin"] integerValue];
                NSInteger priceMax = [[_detailfilter objectForKey:@"pmax"] integerValue];
 
                if (priceMax != 0 && priceMax < priceMin) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Harga minimum harus lebih kecil dari harga maksimum."] delegate:self];
                    [alert show];
                } else {
                    NSDictionary *userinfo = _detailfilter;
                    [_delegate FilterViewController:self withUserInfo:userinfo];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
                if (_type == kTKPDFILTER_DATATYPECATALOGVIEWKEY) {
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
                [_productlocationbutton setTitle:@"Semua Lokasi" forState:UIControlStateNormal];
                [_shoplocationbutton setTitle:@"Semua Lokasi" forState:UIControlStateNormal];
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
                [_detailfilter setObject:@(0) forKey:@"fshop"];
                break;
            case 1:
            {
                switch (_type) {
                    case kTKPDFILTER_DATATYPEHOTLISTVIEWKEY:
                    case kTKPDFILTER_DATATYPEPRODUCTVIEWKEY:
                    case kTKPDFILTER_DATATYPECATALOGVIEWKEY:
                    {
                        [_detailfilter setObject:@(3) forKey:@"fshop"];
                        break;
                    }
                    case kTKPDFILTER_DATATYPESHOPVIEWKEY:
                    {
                        [_detailfilter setObject:@(2) forKey:@"fshop"];
                        break;
                    }
                    case kTKPDFILTER_DATATYPESHOPPRODUCTVIEWKEY:
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
            
        default:
            break;
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
    [_detailfilter setObject:[data objectForKey:@"floc"] forKey:@"floc"];
    [_detailfilter setObject:[data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY] forKey:kTKPDFILTER_APILOCATIONNAMEKEY];
    [_detailfilter setObject:[data objectForKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY] forKey:kTKPDFILTERLOCATION_DATAINDEXPATHKEY];
}

-(void)FilterConditionViewController:(FilterConditionViewController *)viewcontroller withdata:(NSDictionary *)data
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

- (void)priceTextFieldChanged:(UITextField *)textField
{
    if (textField == _pricemin || textField == _pricemincatalog) {
        [_detailfilter setObject:textField.text forKey:@"pmin"];
    } else if (textField == _pricemax || textField == _pricemaxcatalog) {
        [_detailfilter setObject:textField.text forKey:@"pmax"];
    }
}

#pragma mark - Keyboard Notification
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
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _scrollviewContentSize = [_container contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if ((self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height)> _keyboardPosition.y) {
                                 UIEdgeInsets inset = _container.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height + 10));
                                 [_container setContentInset:inset];
                             }
                         }
                         completion:^(BOOL finished){
                         }];

    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _container.contentInset = contentInsets;
                         _container.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


@end
