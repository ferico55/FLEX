//
//  CartCell.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CartCell.h"

@implementation CartCell

+(UITableViewCell*)cellDetailShipmentTable:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"shipmentDetailIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Detail Pengiriman";
    cell.textLabel.font = [UIFont title2Theme];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,1)];
    lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
    [cell.contentView addSubview:lineView];
    return cell;
}


+(UITableViewCell*)cellIsPartial:(NSString*)isPartial tableView:(UITableView*)tableView atIndextPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"leftStockIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Stock Tersedia Sebagian";
    cell.textLabel.font = [UIFont title2Theme];
    cell.detailTextLabel.text = [ARRAY_IF_STOCK_AVAILABLE_PARTIALLY[[isPartial integerValue]]objectForKey:DATA_NAME_KEY];
    cell.detailTextLabel.font = [UIFont title2Theme];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    cell.clipsToBounds = YES;
    return cell;
}


+(UITableViewCell*)cellTextFieldPlaceholder:(NSString*)placeholder List:(NSArray<TransactionCartList *>*)list tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath withText:(NSString*)text
{
    
    static NSString *cellIdentifier = @"GeneralTextFieldCellIdentifier";
    BOOL isSaldoTokopediaTextField = (indexPath.section==list.count);
    NSInteger indexList = (isSaldoTokopediaTextField)?0:(indexPath.section);
    TransactionCartList *cart = list[indexList];
    NSArray *products = cart.cart_products;
    
    GeneralTextFieldCell *cell = (GeneralTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [GeneralTextFieldCell newCell];
        cell.textField.delegate = tableView.delegate;
    }
    
    [cell.textField setPlaceholder:placeholder];
    [cell.textField setText:text];
    
    
    if ([placeholder isEqualToString:@"Nama Pengirim"]) {
        cell.textField.tag = indexPath.section + 1;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.errorIcon.hidden = !cart.isDropshipperNameError;
    } else {
        cell.textField.tag = -indexPath.section - 1;
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        cell.errorIcon.hidden = !cart.isDropshipperPhoneError;
    }
    
    return cell;
}

+(UITableViewCell*)cellIsDropshipper:(NSString*)isDropshipper tableView:(UITableView*)tableView atIndextPath:(NSIndexPath*)indexPath
{
    NSString *cellid = @"GeneralSwitchCellIdentifier";
    
    GeneralSwitchCell *cell = (GeneralSwitchCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralSwitchCell newcell];
        cell.delegate = tableView.delegate;
    }
    
    cell.indexPath = indexPath;
    cell.textCellLabel.text = @"Dropshipper";
    cell.settingSwitch.on = ([isDropshipper integerValue] == 1);

    return cell;
}

+(UITableViewCell*)cellCart:(NSArray<TransactionCartList*>*)list tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath page:(NSInteger)page
{
    NSString *cellid = @"TransactionCartCellIdentifier";
    
    TransactionCartCell *cell = (TransactionCartCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [TransactionCartCell newcell];
        cell.delegate = tableView.delegate;
    }
    TransactionCartList *cart = list[indexPath.section];
    NSInteger indexProduct = indexPath.row;
    NSArray *listProducts = cart.cart_products;
    ProductDetail *product = listProducts[indexProduct];
    
    cell.indexPage = page;
    cell.indexPath = indexPath;
    [cell setCartViewModel:cart.viewModel];
    [cell setViewModel:product.viewModel];
    cell.userInteractionEnabled = (page ==0);
    cell.actionSheetDelegate = tableView.delegate;
    return cell;
}


+(UITableViewCell *)cellErrorList:(NSArray<TransactionCartList*>*)list tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath
{
    TransactionCartList *cart = list[indexPath.section];
    
    static NSString *CellIdentifier = @"ErrorIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}
@end
