//
//  SettingShipmentInfoViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/18/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "SettingShipmentInfoViewController.h"

@interface SettingShipmentInfoViewController ()
{
    NSString *_info;
}

@property (weak, nonatomic) IBOutlet UIView *viewcontent;
@property (weak, nonatomic) IBOutlet UILabel *labelinfo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@end

@implementation SettingShipmentInfoViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Compatible for both ios6 and ios7.
    
    _info = [_data objectForKey:kTKPDDETAIL_DATAINFOLOGISTICKEY]?:@"-";
    //NSInteger type = [[_data objectForKey:kTKPDDETAIL_DATATYPEKEY]integerValue];
    //
    //switch (type) {
    //    case kTKPDDETAIL_DATALOGISTICJNEKEY:
    //        _info = @"*AWB System*\nDengan menggunakan Sistem Kode Resi Otomatis, Anda tidak perlu lagi melakukan input nomor resi secara manual. Cukup cetak kode booking dan tunjukkan ke agen JNE yang mendukung, nomor resi akan otomatis masuk ke Tokopedia.\n\nJenis Paket JNE\n*Reguler*\nJNE Reguler adalah paket reguler yang ditawarkan JNE. Kecepatan pengiriman tergantung dari lokasi pengiriman dan lokasi tujuan. Untuk kota yang sama, umumnya memakan waktu 2-3 hari.\n*YES*\nJNE YES adalah paket dengan prioritas pengiriman tercepat yang ditawarkan JNE. Hanya saja perlu diperhatikan kecepatan barang diterima juga dipengaruhi oleh kecepatan penjual melakukan pengiriman barang.\n*OKE*\nJNE OKE adalah paket ekonomis yang ditawarkan JNE. Umumnya pengiriman melalui paket ini membutuhkan waktu yang lebih lama. Dukungan kota nya pun masih terbatas.";
    //        break;
    //    case kTKPDDETAIL_DATALOGISTICTIKIKEY:
    //        _info = @"Jenis Paket TIKI\n*Reguler*\nTIKI Paket Reguler adalah paket yang dapat menjangkau seluruh Indonesia hanya dalam waktu kurang dari 7 hari kerja.";
    //        break;
    //    case kTKPDDETAIL_DATALOGISTICRPXKEY:
    //        _info = @"Jenis Paket RPX\n*Next Day Package*\nNext Day Package adalah paket yang Anda kirim akan tiba esok hari sesuai jam kerja.\n*Economy Package*\nRPX Economy Package adalah paket ekonomis yang ditawarkan RPX. Kecepatan pengiriman tergantung dari lokasi pengiriman dan lokasi tujuan. Umumnya memakan waktu 2-3 hari untuk kota yang sama.";
    //        break;
    //    case kTKPDDETAIL_DATALOGISTICPOSKEY:
    //        _info = @"Jenis Paket POS\n*Pos Kilat Khusus*\nGunakan Pos Kilat Khusus, sebagai pilihan tepat untuk pengiriman Suratpos yang mengandalkan kecepatan kiriman dan menjangkau ke seluruh pelosok Indonesia.\n*Paket Biasa*\nGunakan Paket Biasa untuk mengirimkan barang-barang berharga Anda, kemanapun tujuannya sesuai keinginan Anda. Paket Biasa adalah layanan hemat untuk pengiriman barang-barang berharga dalam cakupan nasional maupun internasional.";
    //        break;
    //    case kTKPDDETAIL_DATALOGISTICPANDUKEY:
    //        _info = @"Jenis Paket PANDU Logistics\n*Reguler*\nPandu Reguler adalah paket pengiriman yang ditawarkan Pandu Logistics. Untuk kota yang sama. umumnya memakan waktu 2-3 hari.";
    //        break;
    //    case kTKPDDETAIL_DATALOGISTICFIRSTKEY:
    //        _info = @"Jenis Paket FIRST Logistics\n*Reguler Service*\nPaket Reguler adalah servis paket pengiriman yang pada umumnya membutuhkan waktu 2-3 hari kerja.";
    //        break;
    //    default:
    //        _info = @"-";
    //        break;
    //}
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize constrainedSize = CGSizeMake(_labelinfo.frame.size.width  , 9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"HelveticaNeue" size:11.0], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_info attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    if (requiredHeight.size.width > _labelinfo.frame.size.width) {
        requiredHeight = CGRectMake(0,0, _labelinfo.frame.size.width, requiredHeight.size.height);
    }
    _labelinfo.text = _info;
    [_labelinfo sizeToFit];
    CGRect newFrame = _viewcontent.frame;
    newFrame.size.height = _labelinfo.frame.size.height; //requiredHeight.size.height;
    _viewcontent.frame = newFrame;
    
    _scrollview.contentSize = _viewcontent.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
