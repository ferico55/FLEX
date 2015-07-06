//
//  PenilaianUserCell.m
//  Tokopedia
//
//  Created by Tokopedia on 7/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PenilaianUserCell.h"

@implementation PenilaianUserCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



#pragma mark - Setter 
- (void)setPositif1:(NSString *)strText {
    lblPositif1.text = strText;
}

- (void)setPositif6:(NSString *)strText {
    lblPositif6.text = strText;
}

- (void)setPositif12:(NSString *)strText {
    lblPositif12.text = strText;
}

- (void)setNetral1:(NSString *)strText {
    lblNetral1.text = strText;
}

- (void)setNetral6:(NSString *)strText {
    lblNetral6.text = strText;
}

- (void)setNetral12:(NSString *)strText {
    lblNetral12.text = strText;
}

- (void)setBad1:(NSString *)strText {
    lblBad1.text = strText;
}

- (void)setBad6:(NSString *)strText {
    lblBad6.text = strText;
}

- (void)setBad12:(NSString *)strText {
    lblBad12.text = strText;
}
@end
