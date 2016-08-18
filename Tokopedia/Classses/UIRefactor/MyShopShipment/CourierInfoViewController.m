//
//  CourierInfoViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CourierInfoViewController.h"

@interface CourierInfoViewController ()

@end

@implementation CourierInfoViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        self.tableView.tableFooterView = self.tableFooterView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courier.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"service"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"service"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    ShipmentServiceData *service = [self.courier.services objectAtIndex:indexPath.row];

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;

    NSDictionary *nameAttributes = @{
        NSFontAttributeName            : [UIFont title2ThemeMedium],
        NSParagraphStyleAttributeName  : style,
    };

    NSDictionary *descriptionAttributes = @{
        NSFontAttributeName            : [UIFont title2Theme],
        NSParagraphStyleAttributeName  : style,
    };
    
    NSString *name = [NSString stringWithFormat:@"\n%@\n", service.name];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:name attributes:nameAttributes];
    cell.textLabel.numberOfLines = 0;
    [cell.textLabel sizeToFit];
    
    NSString *description = [NSString stringWithFormat:@"%@\n", service.productDescription];
    cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:description attributes:descriptionAttributes];
    cell.detailTextLabel.numberOfLines = 0;
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentServiceData *service = [self.courier.services objectAtIndex:indexPath.row];
    
    NSString *name = [NSString stringWithFormat:@"\n%@\n", service.name];
    CGRect serviceNameRect = [name boundingRectWithSize:CGSizeMake(300.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont title2ThemeMedium]} context:nil];

    NSString *description = [NSString stringWithFormat:@"%@\n", service.productDescription];
    CGRect serviceDescriptionRect = [description boundingRectWithSize:CGSizeMake(300.0f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont title2Theme]} context:nil];

    CGFloat totalHeight = serviceNameRect.size.height + serviceDescriptionRect.size.height + 40; // Padding

    return totalHeight;
}

- (UIView *)tableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    return view;
}

@end
