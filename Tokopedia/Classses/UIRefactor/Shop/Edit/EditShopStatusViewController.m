//
//  EditShopStatusViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopStatusViewController.h"
#import "EditShopNoteViewCell.h"
#import "AlertDatePickerView.h"

@interface EditShopStatusViewController () <TKPDAlertViewDelegate>

@end

@implementation EditShopStatusViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Status Toko";
        self.navigationItem.rightBarButtonItem = self.doneButton;
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNib];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)registerNib {
    UINib *nib = [UINib nibWithNibName:@"EditShopNoteViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"note"];
}

#pragma mark - Bar button item

- (UIBarButtonItem *)doneButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(didTapDoneButton:)];
    return button;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 2;
    } else {
        numberOfRows = self.shopIsClosed?1:0;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 120;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [self statusViewCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        cell = [self noteViewCellForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 2) {
        cell = [self dateViewCellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)statusViewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"status"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"status"];
        cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = [UIColor colorWithRed:66.0/255.0 green:189.0/255.0 blue:65.0/255.0 alpha:1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Buka";
            cell.accessoryType = self.shopIsClosed? UITableViewCellAccessoryNone: UITableViewCellAccessoryCheckmark;
        } else {
            cell.textLabel.text = @"Tutup";
            cell.accessoryType = self.shopIsClosed? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
        }        
    }
}

- (EditShopNoteViewCell *)noteViewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditShopNoteViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"note"];
    cell.statusTextView.text = _closedNote;
    cell.statusTextView.placeholder = @"Tulis Catatan";
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self
                     selector:@selector(noteTextViewDidChange:)
                         name:UITextViewTextDidChangeNotification
                       object:cell.statusTextView];
    return cell;
}

- (UITableViewCell *)dateViewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"date"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"date"];
        cell.textLabel.text = @"Tutup Sampai";
        cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"GothamMedium" size:14];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:66.0/255.0 green:189.0/255.0 blue:65.0/255.0 alpha:1];
    }
    if (self.shopIsClosed) {
        if ([self.closedUntil isEqualToString:@""]) {
            NSDate *today = [NSDate date];
            NSInteger daysToAdd = 7;
            NSInteger totalSecondsInOneDay = 86400;
            NSDate *nextWeekDate = [today dateByAddingTimeInterval:totalSecondsInOneDay*daysToAdd];
            cell.detailTextLabel.text = [self stringFromDate:nextWeekDate];
        } else {
            cell.detailTextLabel.text = self.closedUntil;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (self.shopIsClosed) {
                [self openShop];
            }
        } else if (indexPath.row == 1) {
            if (self.shopIsClosed == NO) {
                [self closeShop];
            }
        }
    } else if (indexPath.section == 2) {
        AlertDatePickerView *datePicker = [AlertDatePickerView newview];
        datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPESHOPEDITKEY)};
        datePicker.delegate = self;
        datePicker.isSetMinimumDate = YES;
        [datePicker show];
    }
}

- (void)openShop {
    self.shopIsClosed = NO;
    self.closedNote = @"";
    self.closedUntil = @"";
    NSArray *indexPaths = @[
        [NSIndexPath indexPathForRow:0 inSection:1],
        [NSIndexPath indexPathForRow:0 inSection:2],
    ];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)closeShop {
    NSDate *today = [NSDate date];
    NSInteger daysToAdd = 7;
    NSInteger totalSecondsInOneDay = 86400;
    NSDate *nextWeekDate = [today dateByAddingTimeInterval:totalSecondsInOneDay*daysToAdd];
    self.shopIsClosed = YES;
    self.closedNote = @"";
    self.closedUntil = [self stringFromDate:nextWeekDate];
    NSArray *indexPaths = @[
        [NSIndexPath indexPathForRow:0 inSection:1],
        [NSIndexPath indexPathForRow:0 inSection:2],
    ];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Action

- (void)didTapDoneButton:(UIButton *)button {
    if (self.formIsValid) {
        if ([self.delegate respondsToSelector:@selector(didFinishEditShopClosedNote:closedUntil:)]) {
            [self.delegate didFinishEditShopClosedNote:_closedNote closedUntil:_closedUntil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Catatan harus diisi."] delegate:self];
        [alert show];
    }
}

#pragma mark - Notification

- (void)noteTextViewDidChange:(NSNotification *)notification {
    TKPDTextView *textView = notification.object;
    self.closedNote = textView.text;
}

#pragma mark - Date to string

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    return [dateFormatter stringFromDate:date];
}

#pragma mark - Alert View Delegate

-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDate *date = [alertView.data objectForKey:@"datepicker"];
    NSCalendarUnit calendarUnit = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:calendarUnit fromDate:date];
    NSString *dateString = [NSString stringWithFormat:@"%zd/%zd/%zd", [components day], [components month], [components year]];
    self.closedUntil = dateString;
    [self.tableView reloadData];
}

- (BOOL)formIsValid {
    if (self.shopIsClosed && self.closedNote.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
