//
//  EditShopNoteViewCell.h
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKPDTextView.h"

@interface EditShopNoteViewCell : UITableViewCell <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet TKPDTextView *statusTextView;

@end
