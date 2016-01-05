//
//  AlertLuckyView.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDAlertView.h"

@interface AlertLuckyView : TKPDAlertView

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) UIColor *upperColor;

@property (weak, nonatomic) IBOutlet UIView *upperView;
@property (weak, nonatomic) IBOutlet UILabel *FirstLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLineLabel;
@property (weak, nonatomic) IBOutlet UILabel *Line3Label;
@property (weak, nonatomic) IBOutlet UIButton *klikDisiniButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end
