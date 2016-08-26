//
//  ResolutionCenterSellerEditViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterSellerEditViewController.h"
#import "ResolutionCenterSellerEditProductCell.h"
#import "TKPDTextView.h"
#import "RequestResolutionData.h"

@interface ResolutionCenterSellerEditViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *invoiceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *sellerInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *showAllComplainCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *solutionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *reasonCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *totalInvoiceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *refundValueCell;
@property (strong, nonatomic) IBOutlet TKPDTextView *reasonTextView;

@end

@implementation ResolutionCenterSellerEditViewController{
    BOOL _shouldShowAllProduct;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    
    [RequestResolutionData fetchCreateResolutionDataWithOrderId:@"123123" success:^(ResolutionCenterCreateResponse *data) {
        
    } failure:^(NSError *error) {
        
    }];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Table View
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return _invoiceCell;
        }else{
            return _sellerInfoCell;
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            return _showAllComplainCell;
        }else{
            ResolutionCenterSellerEditProductCell *cell = nil;
            NSString *cellid = @"ResolutionCenterSellerEditProductCell";
            
            cell = (ResolutionCenterSellerEditProductCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
            if (cell == nil) {
                cell = [ResolutionCenterSellerEditProductCell newcell];
            }
            return cell;
        }
    }else if(indexPath.section == 2){
        return _solutionCell;
    }else if(indexPath.section == 3){
        if(indexPath.row == 0){
            return _totalInvoiceCell;
        }else{
            return _refundValueCell;
        }
    }else if(indexPath.section == 4){
        return _reasonCell;
    }
    
    
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return (_shouldShowAllProduct)?3:1;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 2;
            break;
        case 4:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            return _invoiceCell.frame.size.height;
        }else{
            return _sellerInfoCell.frame.size.height;
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            return _showAllComplainCell.frame.size.height;
        }else{
            return 60;
        }
    }else if(indexPath.section == 2){
        return _solutionCell.frame.size.height;
    }else if(indexPath.section == 3){
        if(indexPath.row == 0){
            return _totalInvoiceCell.frame.size.height;
        }else{
            return _refundValueCell.frame.size.height;
        }
    }else if(indexPath.section == 4){
        return _reasonCell.frame.size.height;
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
        }else{
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            if(_shouldShowAllProduct){
                _shouldShowAllProduct = NO;
            }else{
                _shouldShowAllProduct = YES;
            }
            [_tableView reloadData];
        }else{
        }
    }else if(indexPath.section == 2){
    }else if(indexPath.section == 3){
        if(indexPath.row == 0){
        }else{
        }
    }else if(indexPath.section == 4){
    }
}

#pragma mark - TextView Delegate

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        _tableView.contentInset = contentInsets;
        _tableView.scrollIndicatorInsets = contentInsets;
        
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, _reasonTextView.frame.origin) ) {
            CGPoint scrollPoint = CGPointMake(0.0, _reasonTextView.frame.origin.y+kbSize.height+40 );
            [_tableView setContentOffset:scrollPoint animated:YES];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

@end
