//
//  SortViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "sortfiltershare.h"
#import "SortViewController.h"
#import "UIImage+ImageEffects.h"

@interface SortViewController ()

@property (strong, nonatomic) NSArray *sortValues;

@end

@implementation SortViewController

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

#pragma mark - View Lifecylce

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Urutkan";
    
    self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
    
    [self createDoneButton];
    [self createCancelButton];

    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBarHidden = NO;
    
    [self setSortValues];
}

- (void)createCancelButton {
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(tap:)];
    barButtonItem.tag = 10;
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)createDoneButton {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:(self)
                                                                       action:@selector(tap:)];
    doneButton.tag = 11;
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)setSortValues {
    [AnalyticsManager trackUserInformation];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAGContainer *container = appDelegate.container;
    
    NSString *arrayString = @"";
    
    switch (_sortType) {
        case SortProductSearch:
            arrayString = [container stringForKey:@"search_product"];
            break;

        case SortHotlistDetail:
            arrayString = [container stringForKey:@"hotlist"];
            break;

        case SortCatalogSearch:
            arrayString = [container stringForKey:@"search_catalog"];
            break;

        case SortCatalogDetailSeach:
            arrayString = [container stringForKey:@"search_catalog_detail"];
            break;

        case SortProductShopSearch:
            arrayString = [container stringForKey:@"search_product_shop"];
            break;

        case SortManageProduct:
            arrayString = [container stringForKey:@"manage_product"];
            break;
            
        case SortImageSearch:
            arrayString = [container stringForKey:@"image_search"];

        default:
            break;
    }
    
    _sortValues = [self arrayFromString:arrayString];
}

// Since GTM cannot save JSONArray data, Array is made within a string e.q : "[1, 2, 3]"
- (NSArray *)arrayFromString:(NSString *)string {
    NSMutableArray *array = [NSMutableArray new];
    @try {
        NSArray *keyValues = [string componentsSeparatedByString:@","];
        for (NSString *keyValue in keyValues) {
            NSArray *tmp = [keyValue componentsSeparatedByString:@":"];
            [array addObject:@{tmp[0] : tmp[1]}];
        }
    }
    @catch (NSException *exception) {
        return array;
    }
    @finally {
        return array;
    }
}

#pragma mark - Memory Management

-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

#pragma mark - View Action

-(void)tap:(UIBarButtonItem *)button
{
    if (button.tag == 10) {
        //CANCEL
        if (self.presentingViewController != nil) {
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else if (button.tag == 11) {
        //DONE
        NSDictionary *orderDictionary = _sortValues[_selectedIndexPath.row];
        NSString *sortValue = [[orderDictionary allValues] objectAtIndex:0];
        [_delegate didSelectSort:sortValue atIndexPath:_selectedIndexPath];
        if (self.presentingViewController != nil) {
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sortValues.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        cell.tintColor = [UIColor colorWithRed:255.0/255.0 green:87.0/255.0 blue:34.0/255.0 alpha:1];
    }
    if (_sortValues.count > indexPath.row) {
        NSDictionary *sort =  _sortValues[indexPath.row];
        cell.textLabel.text = [[sort allKeys] objectAtIndex:0];
        cell.textLabel.font = [UIFont title2Theme];
        if (indexPath.row != _selectedIndexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
	return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [self.tableView reloadData];
}

#pragma mark - Getter

- (NSIndexPath *)selectedIndexPath {
    return _selectedIndexPath?:[NSIndexPath indexPathForRow:0 inSection:0];
}

@end
