//
//  FilterViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "FilterLocationViewController.h"
#import "FilterViewController.h"

@interface FilterViewController ()<FilterLocationViewControllerDelegate,UITextFieldDelegate>
{
    UITextField *_activetextfield;
    NSMutableDictionary *_detailfilter;
}
@property (weak, nonatomic) IBOutlet UITextField *pricemaxcatalog;
@property (weak, nonatomic) IBOutlet UITextField *pricemincatalog;
@property (weak, nonatomic) IBOutlet UITextField *pricemin;
@property (weak, nonatomic) IBOutlet UITextField *pricemax;
@property (strong, nonatomic) IBOutlet UIView *productview;
@property (strong, nonatomic) IBOutlet UIView *catalogview;
@property (strong, nonatomic) IBOutlet UIView *shopview;

@property (weak, nonatomic) IBOutlet UIButton *shoplocationbutton;
@property (weak, nonatomic) IBOutlet UIButton *productlocationbutton;


@end

@implementation FilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEHOTLISTVIEWKEY]||[[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEPRODUCTVIEWKEY]) {
        [self.view addSubview: _productview];
    }
    if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPESHOPVIEWKEY]) {
        [self.view addSubview: _shopview];
    }
    if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPECATALOGVIEWKEY]) {
        [self.view addSubview: _catalogview];
    }
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    //TODO:: Change image
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    //TODO:: Change image
    img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONNOTIFICATION ofType:@"png"]];
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
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
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
                                           kTKPDFILTER_APIPRICEMAXKEY:[_detailfilter objectForKey:kTKPDFILTER_APIPRICEMAXKEY]?:@""};
                    
                    if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEHOTLISTVIEWKEY]||[[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEPRODUCTVIEWKEY]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"setfilterProduct" object:nil userInfo:userinfo];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                    if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPESHOPVIEWKEY]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"setfilterShop" object:nil userInfo:userinfo];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                    if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPECATALOGVIEWKEY]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"setfilterCatalog" object:nil userInfo:userinfo];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
                //LOCATION
                FilterLocationViewController *vc = [FilterLocationViewController new];
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
                //product
                if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEHOTLISTVIEWKEY]||[[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPEPRODUCTVIEWKEY]) {
                    [_detailfilter setObject:@(3) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                }
                //shop
                if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPESHOPVIEWKEY]) {
                    [_detailfilter setObject:@(2) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                }
                //catalog
                if ([[_data objectForKey:kTKPDFILTER_DATAFILTERTYPEVIEWKEY] isEqualToString: kTKPDFILTER_DATATYPECATALOGVIEWKEY]) {
                    [_detailfilter setObject:@(3) forKey:kTKPDFILTER_APISHOPTYPEKEY];
                }
                else
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

-(void)FilterLocationViewController:(UIViewController *)viewcontroller withdata:(NSDictionary *)data
{
    [_shoplocationbutton setTitle:[data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY] forState:UIControlStateNormal];
    [_productlocationbutton setTitle:[data objectForKey:kTKPDFILTER_APILOCATIONNAMEKEY] forState:UIControlStateNormal];
    [_detailfilter setObject:[data objectForKey:kTKPDFILTER_APILOCATIONKEY] forKey:kTKPDFILTER_APILOCATIONKEY];
}

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

@end
