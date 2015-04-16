//
//  ShopDeliveryViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "Address.h"
#import "ShopDeliveryCell.h"
#import "ShopDeliveryViewController.h"
#import "string_create_shop.h"
#import "string_address.h"

@interface ShopDeliveryViewController ()
@end

@implementation ShopDeliveryViewController
{
    NSArray *arrTitleSectionOne;
    BOOL hasLoadViewWillAppear;
    Address *address;
    
    UITextField *activeText;
}
@synthesize createShopViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    arrTitleSectionOne = @[CStringKotaAsal, CStringKodePos];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(! hasLoadViewWillAppear)
    {
        hasLoadViewWillAppear = !hasLoadViewWillAppear;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1;
        [self.view addGestureRecognizer:tapGesture];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Method
- (void)hideKeyboard:(id)sender
{
    [activeText resignFirstResponder];
    activeText = nil;
}


#pragma mark - View
- (void)initNavigation
{
    // Add logo in navigation bar
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}


#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        [cell setSeparatorInset:UIEdgeInsetsZero];
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
        [cell setPreservesSuperviewLayoutMargins:NO];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShopDeliveryCell *cell = [tableView dequeueReusableCellWithIdentifier:CTagCell];
    if(cell == nil)
    {
        cell = [[ShopDeliveryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CTagCell];
        [cell getTxtField].delegate = self;
        cell.contentView.userInteractionEnabled = YES;
    }
    [cell getLblText].text = arrTitleSectionOne[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell getLblValue].text = (address==nil)?CStringPilihProvinsi:address.location_province_name;
            [cell getTxtField].hidden = YES;
            [cell getLblValue].hidden = NO;
        }
            break;
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell getTxtField].hidden = NO;
            [cell getLblValue].hidden = YES;
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==0 && indexPath.row==0)
    {
        AddressViewController *vc = [AddressViewController new];
        vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEPROVINCEKEY),
                    kTKPDLOCATION_DATAINDEXPATHKEY : [NSIndexPath indexPathForRow:0 inSection:0],
                    kTKPDLOCATION_DATAPROVINCEIDKEY : address==nil?@(0):address.location_province_id
                    };
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0)
        return YES;
    
    NSCharacterSet *myCharSet = [NSCharacterSet alphanumericCharacterSet];
    for(int i = 0; i < [string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c])
            return YES;
    }
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    activeText = textField;
    return YES;
}


#pragma mark - AddressController Delegate
- (void)SettingAddressLocationView:(UIViewController*)vc withData:(NSDictionary*)data
{
    switch ([[data objectForKey:kTKPDLOCATION_DATALOCATIONTYPEKEY] integerValue]) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            if(address == nil)
                address = [Address new];
            address.location_province_name = [data objectForKey:kTKPDLOCATION_DATALOCATIONNAMEKEY];
            address.location_province_id = [NSString stringWithFormat:@"%d", [[data objectForKey:kTKPDLOCATION_DATALOCATIONVALUEKEY] intValue]];
            
            [tblShopDelivery beginUpdates];
            [tblShopDelivery reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [tblShopDelivery endUpdates];
        }
            break;
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self.view];
    NSIndexPath *indexPath = [tblShopDelivery indexPathForRowAtPoint:point];
    if (indexPath!=nil && indexPath.section==0 && indexPath.row==0)
        return NO;

    return YES;
}
@end
