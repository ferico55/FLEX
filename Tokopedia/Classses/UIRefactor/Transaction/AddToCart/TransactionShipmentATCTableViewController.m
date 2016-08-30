//
//  TransactionShipmentATCTableViewController.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/20/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionShipmentATCTableViewController.h"
#import "TransactionShipmentATCTableViewCell.h"
#import "ShippingInfoShipments.h"

@interface TransactionShipmentATCTableViewController ()
{
    NSDictionary *_textAttributes;
    NSIndexPath *_selectedIndexPath;
}

@end

@implementation TransactionShipmentATCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.0;
    
    _textAttributes = @{
                        NSFontAttributeName            : [UIFont title2Theme],
                        NSParagraphStyleAttributeName  : style,
                        };
    
    if (!_tableViewCellStyle) {
        _tableViewCellStyle = UITableViewCellStyleDefault;
    }
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(tap:)];
    doneButton.tag = 1;
    self.navigationItem.rightBarButtonItem = doneButton;
    if(_selectedObject == nil) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    backButton.tag = 2;
    self.navigationItem.backBarButtonItem = backButton;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    id object = [_objects objectAtIndex:indexPath.row];
    id objectImage;
    if (_objectImages != nil && _objectImages.count > 0) {
        objectImage = [_objectImages objectAtIndex:indexPath.row];
    }
    
    
    if (_objects.count > 0) {
        cell = (TransactionShipmentATCTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if (cell == nil) {
            cell = [TransactionShipmentATCTableViewCell newCell];
        }
    }
    
    if (_objects.count > 0) {
        // Set auto resi shipment logo
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:objectImage] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
        UIImageView *logo = ((TransactionShipmentATCTableViewCell*)cell).autoResiLogo;
        logo.image = nil;
        [logo setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
            [logo setContentMode:UIViewContentModeLeft];
            [logo setImage:image];
#pragma clang diagnostic pop
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
        
        ((TransactionShipmentATCTableViewCell*)cell).shipmentNameLabel.text = [object description];
        ((TransactionShipmentATCTableViewCell*)cell).shipmentNameLabel.attributedText = [[NSAttributedString alloc] initWithString:[object description] attributes:_textAttributes];
    }
    
    if ([object isEqual:_selectedObject]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndexPath = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.navigationItem.rightBarButtonItem.isEnabled) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    _selectedObject = [_objects objectAtIndex:indexPath.row];
    _selectedIndexPath = indexPath;
    
    cell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            if ([self.delegate respondsToSelector:@selector(didSelectObject:senderIndexPath:)]) {
                [self.delegate didSelectObject:_selectedObject senderIndexPath:_senderIndexPath];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if (button.tag == 2) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

@end
