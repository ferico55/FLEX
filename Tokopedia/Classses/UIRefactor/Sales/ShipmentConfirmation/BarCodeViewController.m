//
//  BarCodeViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 6/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "BarCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#define CStringFailedShowBarcodeCamera @"Gagal menampilkan kamera deteksi barcode"

@interface BarCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation BarCodeViewController
{
    UIView *viewDetectionBarCode;
    AVCaptureSession *session;
    AVCaptureDevice *device;
    AVCaptureDeviceInput *deviceInput;
    AVCaptureMetadataOutput *deviceOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    int nCountBarcode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    viewDetectionBarCode = [[UIView alloc] init];
    viewDetectionBarCode.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    viewDetectionBarCode.layer.borderColor = [UIColor orangeColor].CGColor;
    viewDetectionBarCode.layer.borderWidth = 3;
    [self.view addSubview:viewDetectionBarCode];
    
    session = [[AVCaptureSession alloc] init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (deviceInput) {
        [session addInput:deviceInput];
    } else {
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedShowBarcodeCamera] delegate:self];
        [stickyAlertView show];
        [self clearObjectBarcode];
        return;
    }
    
    deviceOutput = [[AVCaptureMetadataOutput alloc] init];
    [deviceOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:deviceOutput];
    
    deviceOutput.metadataObjectTypes = [deviceOutput availableMetadataObjectTypes];
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50);
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:previewLayer];
    [session startRunning];
    [self.view bringSubviewToFront:viewDetectionBarCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Method
- (void)clearObjectBarcode
{
    if(session) {
        [session stopRunning];
    }
}

- (void)cancelCamera:(id)sender
{
    [_delegate didFinishScan:nil];
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                viewDetectionBarCode.frame = highlightViewRect;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if(detectionString != nil) {
            break;
        }
    }
    
    if(nCountBarcode==30 && detectionString!=nil) {
        [self clearObjectBarcode];
        [_delegate didFinishScan:detectionString];
    }
    
    nCountBarcode++;
}
@end
