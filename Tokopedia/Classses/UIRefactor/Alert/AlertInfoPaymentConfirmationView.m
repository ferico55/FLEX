//
//  AlertInfoPaymentConfirmationView.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertInfoPaymentConfirmationView.h"

@implementation AlertInfoPaymentConfirmationView

- (void)awakeFromNib
{
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:12];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSString *string = @"Pastikan slip Setoran / Transfer Tunai berisi keterangan e-mail, nama atau nomor invoice Anda.\n\nApabila lupa mengisi, kirimkan bukti pembayaran via scan e-mail ke";
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    _info1Label.attributedText = attributedText;
    
    self.layer.cornerRadius = 5;
}
@end
