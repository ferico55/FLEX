//
//  SettingEtalaseDetailViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "EtalaseList.h"
#import "SettingEtalaseDetailViewController.h"
#import "SettingEtalaseEditViewController.h"

#pragma mark - Setting Etalase Detail View Controller
@interface SettingEtalaseDetailViewController ()
{
    EtalaseList *_etalase;
}

@property (weak, nonatomic) IBOutlet UILabel *labelname;
@property (weak, nonatomic) IBOutlet UILabel *labeltotal;

- (IBAction)tap:(id)sender;

@end

@implementation SettingEtalaseDetailViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _etalase = [_data objectForKey:kTKPDDETAIL_DATAETALASEKEY];
    self.title = _etalase.etalase_name;
    [self setDefaultData:_data];
        
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    barbutton1 = [[UIBarButtonItem alloc] initWithTitle:@"Ubah" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbutton1 setTintColor:[UIColor blackColor]];
    barbutton1.tag = 11;
    self.navigationItem.rightBarButtonItem = barbutton1;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            case 11:
            {   //Edit
                NSIndexPath *indexpath = [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SettingEtalaseEditViewController *vc = [SettingEtalaseEditViewController new];
                vc.data = @{kTKPDDETAIL_DATAETALASEKEY : [_data objectForKey:kTKPDDETAIL_DATAETALASEKEY]?:[NSNull null],
                            kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                            kTKPDDETAIL_DATATYPEKEY : @(kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY),
                            kTKPDDETAIL_DATAINDEXPATHKEY : indexpath
                            };
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
                
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 11:
            {
                //delete etalase
                if ([_etalase.etalase_total_product isEqualToString:@"0"]) {
                    [_delegate DidTapButton:btn withdata:_data];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    NSArray *array = [[NSArray alloc]initWithObjects:@"Tidak dapat menghapus etalase. \nSilahkan pindahkan product ke etalase lainnya terlebih dahulu.",nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
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
        _labelname.text = _etalase.etalase_name;
        _labeltotal.text = _etalase.etalase_total_product;
    }
}
@end
