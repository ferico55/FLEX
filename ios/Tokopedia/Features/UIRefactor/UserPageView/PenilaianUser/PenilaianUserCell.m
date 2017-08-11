//
//  PenilaianUserCell.m
//  Tokopedia
//
//  Created by Tokopedia on 7/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PenilaianUserCell.h"

@implementation PenilaianUserCell

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

- (void)setProgressSmileCount:(NSString *)strValue {
    progressSmile.progress = strValue==nil || [strValue isEqualToString:@""]? 0:[strValue floatValue];
    lblSmileCount.text = [NSString stringWithFormat:@"(%@)", strValue==nil?@"0":strValue];
}

- (void)setProgressSadCount:(NSString *)strValue {
    progressSad.progress = strValue==nil || [strValue isEqualToString:@""]? 0:[strValue floatValue];
    lblSadCount.text = [NSString stringWithFormat:@"(%@)", strValue==nil?@"0":strValue];
}

- (void)setProgressNetralCount:(NSString *)strValue {
    progressNetral.progress = strValue==nil || [strValue isEqualToString:@""]? 0:[strValue floatValue];
    lblNetralCount.text = [NSString stringWithFormat:@"(%@)", strValue==nil?@"0":strValue];
}

- (void)setWidthLabel {
    //Calculate widht total rate
    float width1 = [lblSadCount sizeThatFits:CGSizeMake(self.bounds.size.width/5.3f, 9999)].width;
    float width2 = [lblNetralCount sizeThatFits:CGSizeMake(self.bounds.size.width/5.3f, 9999)].width;
    float width3 = [lblSmileCount sizeThatFits:CGSizeMake(self.bounds.size.width/5.3f, 9999)].width;

    
    width1 = width1>width2? width1: width2;
    width1 = width1>width3? width1: width3;
    constLblWidthNetral.constant = constLblWidthSad.constant = constLblWidthSmile.constant = width1;
}
@end
