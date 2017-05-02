//
//  AlertListBankView.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/28/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertListBankView.h"
#import "AlertListBankCell.h"
#import "TransactionSystemBank.h"

@implementation AlertListBankView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.tableView.layer.cornerRadius = 5;
}

#pragma mark - Table Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlertListBankCell* cell = nil;
    
    NSString *cellid = @"AlertListBankCellIdentifier";
    
    if (_list.count>0) {
        cell = (AlertListBankCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [AlertListBankCell newcell];
        }
        
        TransactionSystemBank *content = _list[indexPath.row];
        cell.textCellLabel.text = [NSString stringWithFormat:@"Bank %@",content.sb_bank_name]?:@"";
        cell.detailTextCellLabel.text = content.sb_account_no?:@"";
        cell.subDetailCellLabel.text = content.sb_account_name?:@"";
        
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:content.sb_picture] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        
        UIImageView *thumb = cell.thumbnail?:@"";
        thumb.image = nil;
        [cell.thumbnail setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [thumb setImage:image];
#pragma clang diagnosti c pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    }
    
    return cell;
}

@end
