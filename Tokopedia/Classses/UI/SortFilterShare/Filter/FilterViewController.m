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
    NSMutableDictionary *_detailfilter;
}
@property (weak, nonatomic) IBOutlet UITextField *pricemin;
@property (weak, nonatomic) IBOutlet UITextField *pricemax;


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
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
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
                NSDictionary *userinfo = @{kTKPDFILTER_APILOCATIONKEY:[_detailfilter objectForKey:kTKPDFILTER_APILOCATIONKEY]?:@"",
                                           kTKPDFILTER_APISHOPTYPEKEY:[_detailfilter objectForKey:kTKPDFILTER_APISHOPTYPEKEY]?:@"",
                                           kTKPDFILTER_APIPRICEMINKEY:[_detailfilter objectForKey:kTKPDFILTER_APIPRICEMINKEY]?:@"",
                                           kTKPDFILTER_APIPRICEMAXKEY:[_detailfilter objectForKey:kTKPDFILTER_APIPRICEMAXKEY]?:@""};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setfilter" object:nil userInfo:userinfo];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
                [_detailfilter setObject:@(3) forKey:kTKPDFILTER_APISHOPTYPEKEY];
            default:
                break;
        }
    }
}

#pragma mark - Filter View Controller Delegate
-(void)FilterLocationViewController:(UIViewController *)viewcontroller withdata:(NSDictionary *)data
{
    [_detailfilter setObject:[data objectForKey:kTKPDFILTER_APILOCATIONKEY] forKey:kTKPDFILTER_APILOCATIONKEY];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _pricemin) {
        [_detailfilter setObject:textField.text forKey:kTKPDFILTER_APIPRICEMINKEY];
    }
    if (textField == _pricemax) {
        [_detailfilter setObject:textField.text forKey:kTKPDFILTER_APIPRICEMAXKEY];
    }
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)pricemax:(id)sender {
}
@end
