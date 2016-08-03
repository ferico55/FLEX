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
@property (copy, nonatomic) void (^deleteImageObject)(ProductEditImages *imageObject, DKAsset *imageAsset);

@end

@implementation ProductEditImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Edit Gambar";
    
    _section0Cells = [NSArray sortViewsWithTagInArray:_section0Cells];
    
    _dataInput = [NSMutableDictionary new];
    
    [self setDefaultData:_data];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** keyboard notification **/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
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

-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _productImageView.image = _uploadedImage;
        
        BOOL isDefaultImage = [[_data objectForKey:DATA_IS_DEFAULT_IMAGE]boolValue];
        _defaultPictLabel.hidden = !isDefaultImage;
        _setDefaultButton.hidden = isDefaultImage;
        _isDefaultImage = isDefaultImage;
        
        NSString *productName = [_data objectForKey:DATA_PRODUCT_IMAGE_NAME_KEY];
        _productNameTextField.text = productName;
        
        if (_isDefaultFromWS) {
            _deleteImageButton.hidden = YES;
        }
    }
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case BUTTON_PRODUCT_DELETE_PRODUCT_IMAGE:
            {
                BOOL isDefaultImage = _isDefaultImage;
                if (!_isDefaultFromWS && _type == TYPE_ADD_EDIT_PRODUCT_EDIT) {
                    isDefaultImage = NO;
                }
                if (isDefaultImage) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:ERRORMESSAGE_INVALID_DELETE_PRODUCT_IMAGE delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:CONFIRMATIONMESSAGE_DELETE_PRODUCT_IMAGE delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya",nil];
                    [alertView show];
                }
                break;
            }
            case BUTTON_PRODUCT_UPDATE_PRODUCT_IMAGE:
            {
                _photoPicker = [[TKPDPhotoPicker alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera
                                                      parentViewController:self
                                                     pickerTransitionStyle:UIModalTransitionStyleCrossDissolve];
                _photoPicker.delegate = self;
                break;
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButtonItem = (UIBarButtonItem*)sender;
        switch (barButtonItem.tag) {
            case BARBUTTON_PRODUCT_SAVE:
                //[_delegate ProductEditImageViewController:self withUserInfo:];
                break;
            case BARBUTTON_PRODUCT_BACK:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }
    }
}
- (IBAction)gesture:(id)sender {
    [_activeTextField resignFirstResponder];
}
- (IBAction)tapDefaultPict:(UIButton*)sender {
    [_delegate setDefaultImage:_selectedImage];
    
    sender.hidden = YES;
    _defaultPictLabel.hidden = NO;
    _isDefaultImage = YES;
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
    NSString *productName = textField.text;
    NSInteger indexImage = [[_data objectForKey:kTKPDDETAIL_DATAINDEXKEY]integerValue];
    [_delegate setProductImageName:productName atIndex:indexImage];
    return YES;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _table.contentInset = contentInsets;
    _table.scrollIndicatorInsets = contentInsets;
    
    if (_activeTextField == _productNameTextField) {
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

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
