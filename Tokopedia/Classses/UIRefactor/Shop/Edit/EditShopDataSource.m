//
//  EditShopDataSource.m
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopDataSource.h"

#import "EditShopTypeViewCell.h"
#import "EditShopImageViewCell.h"
#import "EditShopDescriptionViewCell.h"

@implementation EditShopDataSource

NSInteger const SectionForShopTagDescription = 2;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == SectionForShopTagDescription) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [self tableView:tableView shopTypeCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        cell = [self tableView:tableView shopImageCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell = [self tableView:tableView shopNameCellForRowAtIndexPath:indexPath];
        } else {
            cell = [self tableView:tableView shopDescriptionCellForRowAtIndexPath:indexPath];
        }
    } else if (indexPath.section == 3) {
        cell = [self tableView:tableView shopStatusCellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (EditShopTypeViewCell *)tableView:(UITableView *)tableView shopTypeCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditShopTypeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopType"];
    if ([self.shop.info.shop_is_gold boolValue]) {
        [cell showsGoldMerchantBadge];
    }    
    return cell;
}

- (EditShopImageViewCell *)tableView:(UITableView *)tableView shopImageCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditShopImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopImage"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_shop.image.logo]];
    UIImage *placeholderImage = [UIImage imageNamed:@"icon_default_shop.jpg"];
    [cell.shopImageView setImageWithURLRequest:request
                              placeholderImage:placeholderImage
                                       success:^(NSURLRequest *request,
                                                 NSHTTPURLResponse *response,
                                                 UIImage *image) {
                                           cell.shopImageView.image = image;
                                           cell.changeImageLabel.hidden = NO;
                                           [cell.activityIndicatorView stopAnimating];
    } failure:nil];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopNameCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopName"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"shopName"];
        cell.textLabel.text = @"Nama Toko";
        cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
        cell.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.detailTextLabel.text = _shop.info.shop_name;
    return cell;
}

- (EditShopDescriptionViewCell *)tableView:(UITableView *)tableView
      shopDescriptionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditShopDescriptionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopDescription"];
    if (indexPath.row == 1) {
        cell.textView.text = _shop.info.shop_tagline;
        cell.textView.tag = ShopTextViewForTag;
        NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
        [notification addObserver:self selector:@selector(taglineTextViewDidChange:) name:UITextViewTextDidChangeNotification object:cell.textView];

    } else if (indexPath.row == 2) {
        cell.textView.text = _shop.info.shop_description;
        cell.textView.tag = ShopTextViewForDescription;
        NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
        [notification addObserver:self selector:@selector(descriptionTextViewDidChange:) name:UITextViewTextDidChangeNotification object:cell.textView];

    }
    [cell updateCountLabel];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopStatusCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopStatus"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"shopStatus"];
        cell.textLabel.text = @"Status Toko";
        cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"GothamMedium" size:14];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:66.0/255.0 green:189.0/255.0 blue:65.0/255.0 alpha:1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (self.shop.isClosed) {
        cell.detailTextLabel.text = @"Tutup";
    } else if (self.shop.isOpen) {
        cell.detailTextLabel.text = @"Buka";
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:[self indexPathForShopImage]]) {
        return 113;
    } else if ([indexPath isEqual:[self indexPathForShopTag]]) {
        return 60;
    } else if ([indexPath isEqual:[self indexPathForShopDescription]]) {
        return 80;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self.delegate didTapShopPhoto];
    } else if (indexPath.section == 3) {
        [self.delegate didTapShopStatus];
    }
}

- (NSIndexPath *)indexPathForShopImage {
    return [NSIndexPath indexPathForRow:0 inSection:1];
}

- (NSIndexPath *)indexPathForShopTag {
    return [NSIndexPath indexPathForRow:1 inSection:2];
}

- (NSIndexPath *)indexPathForShopDescription {
    return [NSIndexPath indexPathForRow:2 inSection:2];
}

#pragma mark - Notification 

- (void)taglineTextViewDidChange:(NSNotification *)notification {
    TKPDTextView *textView = notification.object;
    self.shop.info.shop_tagline = textView.text;
}

- (void)descriptionTextViewDidChange:(NSNotification *)notification {
    TKPDTextView *textView = notification.object;
    self.shop.info.shop_description = textView.text;
}

@end
