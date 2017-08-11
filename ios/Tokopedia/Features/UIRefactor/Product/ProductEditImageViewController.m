//
//  ProductEditImageViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductEditImageViewController.h"

#import "Tokopedia-Swift.h"

@interface ProductEditImageViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UITextField *productNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *deleteImageButton;
@property (weak, nonatomic) IBOutlet UILabel *defaultPictLabel;
@property (weak, nonatomic) IBOutlet UIButton *setDefaultButton;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cells;

@property (copy, nonatomic) void (^defaultImageObject)(ProductEditImages *imageObject);
@property (copy, nonatomic) void (^deleteImageObject)(ProductEditImages *imageObject);

@end

@implementation ProductEditImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Edit Gambar";
    
    _section0Cells = [NSArray sortViewsWithTagInArray:_section0Cells];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    /** keyboard notification **/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    [self setAppearance];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setAppearance{
    
    _productImageView.image = _imageObject.image;
    _defaultPictLabel.hidden = ![_imageObject.image_primary boolValue];
    _setDefaultButton.hidden = [_imageObject.image_primary boolValue];
    
    _productNameTextField.text = _imageObject.image_description?:@"";
    
    _deleteImageButton.hidden = [_imageObject.image_primary boolValue];
}


#pragma mark - View Action
- (IBAction)onTapDeleteImageButton:(id)sender {
    if (self.deleteImageObject) {
        self.deleteImageObject(_imageObject);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onTapDefaultPict:(UIButton*)sender {
    sender.hidden = YES;
    _defaultPictLabel.hidden = NO;
    _imageObject.image_primary = @"1";
    self.deleteImageButton.hidden = YES;
    if(self.defaultImageObject){
        self.defaultImageObject(_imageObject);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _section0Cells.count;
            break;
        case 1:
            return _section1Cells.count;
            break;

        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell= nil;
    switch (indexPath.section) {
        case 0:
            cell = _section0Cells[indexPath.row];
            break;
        case 1:
            cell = _section1Cells[indexPath.row];
            break;

        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_deleteImageButton.hidden) {
        return 1;
    }
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [_section0Cells[indexPath.row] frame].size.height;
            break;
        case 1:
            return [_section1Cells[indexPath.row] frame].size.height;
            break;
        default:
            break;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 40;
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _imageObject.image_description = textField.text;
    return YES;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _table.contentInset = contentInsets;
    _table.scrollIndicatorInsets = contentInsets;
    [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _table.contentInset = contentInsets;
                         _table.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


@end
