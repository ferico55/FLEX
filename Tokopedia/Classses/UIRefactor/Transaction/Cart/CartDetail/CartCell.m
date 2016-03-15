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
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,1)];
    lineView.backgroundColor = [UIColor colorWithRed:(230.0/255.0f) green:(233/255.0f) blue:(237.0/255.0f) alpha:1.0f];
    [cell.contentView addSubview:lineView];
    return cell;
}


+(UITableViewCell*)cellPartialDetail:(NSArray*)partialDetail partialStrList:(NSArray*)partialStrList tableView:(UITableView*)tableView atIndextPath:(NSIndexPath*)indexPath
{
    static NSString *CellIdentifier = @"leftStockIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger choosenIndex;
    if (partialDetail.count>0) {
        choosenIndex = [partialStrList[indexPath.section] isEqualToString:@""]?0:1;
    }
    else
    {
        choosenIndex = 0;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"Stock Tersedia Sebagian";
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
    cell.detailTextLabel.text = [ARRAY_IF_STOCK_AVAILABLE_PARTIALLY[choosenIndex]objectForKey:DATA_NAME_KEY];
    cell.detailTextLabel.font = FONT_DETAIL_DEFAULT_CELL_TKPD;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    cell.clipsToBounds = YES;
    return cell;
}


+(UITableViewCell*)cellTextFieldPlaceholder:(NSString*)placeholder List:(NSArray<TransactionCartList *>*)list tableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath withText:(NSString*)text
{
    
    static NSString *CellIdentifier = @"textfieldCellIdentifier";
    BOOL isSaldoTokopediaTextField = (indexPath.section==list.count);
    NSInteger indexList = (isSaldoTokopediaTextField)?0:(indexPath.section);
    TransactionCartList *cart = list[indexList];
    NSArray *products = cart.cart_products;
    UITableViewCell *cell;
    
    //if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(15, 0, tableView.frame.size.width-15, 44)];
    
    textField.placeholder = placeholder;
    textField.text = text;
    textField.delegate = tableView.delegate;
    if ([placeholder isEqualToString:@"Nama Pengirim"]) {
        textField.tag = indexPath.section+1;
        textField.keyboardType = UIKeyboardTypeDefault;
    }
    else
    {
        textField.tag = -indexPath.section -1;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    textField.font = FONT_DEFAULT_CELL_TKPD;
    [textField setReturnKeyType:UIReturnKeyDone];
    textField.text = text;
    [cell addSubview:textField];
    //}
    
    return cell;
}

+(UITableViewCell*)cellIsDropshipper:(NSArray*)isDropshipper tableView:(UITableView*)tableView atIndextPath:(NSIndexPath*)indexPath
{
    NSString *cellid = @"GeneralSwitchCellIdentifier";
    
    GeneralSwitchCell *cell = (GeneralSwitchCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [GeneralSwitchCell newcell];
        cell.delegate = tableView.delegate;
    }
    
    cell.indexPath = indexPath;
    cell.textCellLabel.text = @"Dropshipper";
    if (isDropshipper.count>0) {
        cell.settingSwitch.on = [isDropshipper[indexPath.section] boolValue];
    }
    else
    {
        cell.settingSwitch.on = NO;
    }
    
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
    
    NSString *error1 = ([cart.cart_error_message_1 isEqualToString:@"0"] || !(cart.cart_error_message_1))?@"":cart.cart_error_message_1;
    NSString *error2 = ([cart.cart_error_message_2 isEqualToString:@"0"] || !(cart.cart_error_message_2))?@"":cart.cart_error_message_2;
    cell.textLabel.font = FONT_DEFAULT_CELL_TKPD;
    
    NSString *string = [NSString stringWithFormat:@"%@\n%@",error1, error2];
    [cell.textLabel setCustomAttributedText:string];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = [UIColor redColor];
    
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    cell.clipsToBounds = YES;
    cell.contentView.clipsToBounds = YES;
    
    return cell;
}
@end
