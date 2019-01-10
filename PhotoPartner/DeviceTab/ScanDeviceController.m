//
//  ScanDeviceController.m
//  PhotoPartner
//
//  Created by USER on 8/4/2018.
//  Copyright © 2018 MJF. All rights reserved.
//

#import "ScanDeviceController.h"
#import <AVFoundation/AVFoundation.h>

#define QRCodeWidth  260.0   //正方形二维码的边长
#define SCREENWidth  [UIScreen mainScreen].bounds.size.width   //设备屏幕的宽度
#define SCREENHeight [UIScreen mainScreen].bounds.size.height //设备屏幕的高度

@interface ScanDeviceController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, copy) NSString *license;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation ScanDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = NSLocalizedString(@"deviceScanNavigationItemTitle", nil);
    
    self.captureSession = nil;
    
    [self setupMaskView];//设置扫描区域之外的阴影视图
    [self setupScanWindowView];//设置扫描二维码区域的视图
    [self beginScanning];//开始扫二维码
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self startScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)startScan {
//    NSError *error;
//    //初始化捕捉设备
//    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//
//    //创建输入流
//    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
//    if (!input) {
//        NSLog(@"%@", [error localizedDescription]);
//        return;
//    }
//
//    //创建数据输出
//    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
//
//    //创建会话
//    self.captureSession = [[AVCaptureSession alloc] init];
//
//    //将输入添加到会话
//    [self.captureSession addInput:input];
//
//    //将输出添加到会话
//    [self.captureSession addOutput:captureMetadataOutput];
//
//    //设置输出数据类型
//    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
//
//    //创建串行队列，并加媒体输出流添加到队列当中
//    dispatch_queue_t dispatchQueue;
//    dispatchQueue = dispatch_queue_create("myQueue", NULL);
//
//    //设置代理
//    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
//
//    //实例化预览图层
//    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
//
//    //设置预览图层填充方式
//    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
//
//    //设置图层的frame
//    [self.videoPreviewLayer setFrame:self.view.layer.bounds];
//
//    //将图层添加到预览view的图层上
//    [self.view.layer addSublayer:self.videoPreviewLayer];
//
//    //扫描范围
//    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
//
//    //开始扫描
//    [self.captureSession startRunning];
//}
//
//- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
//    //判断是否有数据
//    if (metadataObjects != nil && [metadataObjects count] > 0) {
//        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
//        //判断回传的数据类型
//        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
//            self.license = [metadataObj stringValue];
//            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
//        }
//    }
//}
//
////停止扫描
//-(void)stopReading{
//    [self.captureSession stopRunning];
//    self.captureSession = nil;
//    [self.delegate license:self.license];
//    [self.videoPreviewLayer removeFromSuperlayer];
//    [[self navigationController] popViewControllerAnimated:YES];
//}
//
//- (void)license:(NSString *)license {
//    if ([self.delegate respondsToSelector:@selector(license:)]) {
//        [self.delegate license:self.license];
//    }
//}


- (void)setupMaskView {
    //设置统一的视图颜色和视图的透明度
    UIColor *color = [UIColor blackColor];
    float alpha = 0.7;
    //设置扫描区域外部上部的视图
    UIView *topView = [[UIView alloc]init];
    topView.frame = CGRectMake(0, 64, SCREENWidth, (SCREENHeight-64-QRCodeWidth)/2.0-64);
    topView.backgroundColor = color;
    topView.alpha = alpha;
    //设置扫描区域外部左边的视图
    UIView *leftView = [[UIView alloc]init];
    leftView.frame = CGRectMake(0, 64+topView.frame.size.height, (SCREENWidth-QRCodeWidth)/2.0,QRCodeWidth);
    leftView.backgroundColor = color;
    leftView.alpha = alpha;
    //设置扫描区域外部右边的视图
    UIView *rightView = [[UIView alloc] init];
    rightView.frame = CGRectMake((SCREENWidth-QRCodeWidth)/2.0+QRCodeWidth,64+topView.frame.size.height, (SCREENWidth-QRCodeWidth)/2.0,QRCodeWidth);
    rightView.backgroundColor = color;
    rightView.alpha = alpha;
    //设置扫描区域外部底部的视图
    UIView *botView = [[UIView alloc] init];
    botView.frame = CGRectMake(0, 64+QRCodeWidth+topView.frame.size.height,SCREENWidth,SCREENHeight-64-QRCodeWidth-topView.frame.size.height);
    botView.backgroundColor = color;
    botView.alpha = alpha;
    UILabel *botLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, botView.frame.size.width, 20)];
    botLabel.textColor = [UIColor whiteColor];
    botLabel.font = [UIFont systemFontOfSize:14.0f];
    botLabel.text = NSLocalizedString(@"deviceScanNoticeText", nil);
    botLabel.textAlignment = NSTextAlignmentCenter;
    [botView addSubview:botLabel];
    //将设置好的扫描二维码区域之外的视图添加到视图图层上
    [self.view addSubview:topView];
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
    [self.view addSubview:botView];
}

- (void)setupScanWindowView {
    //设置扫描区域的位置(考虑导航栏和电池条的高度为64)
    UIView *scanWindow = [[UIView alloc] initWithFrame:CGRectMake((SCREENWidth-QRCodeWidth)/2.0,(SCREENHeight-QRCodeWidth-64)/2.0,QRCodeWidth,QRCodeWidth)];
    scanWindow.clipsToBounds = YES;
    [self.view addSubview:scanWindow];
    //设置扫描区域的动画效果
    CGFloat scanNetImageViewH = 241;
    CGFloat scanNetImageViewW = scanWindow.frame.size.width;
    UIImageView *scanNetImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"QR_Scan_Line"]];
    scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
    CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
    scanNetAnimation.keyPath =@"transform.translation.y";
    scanNetAnimation.byValue = @(QRCodeWidth);
    scanNetAnimation.duration = 2.0;
    scanNetAnimation.repeatCount = MAXFLOAT;
    [scanNetImageView.layer addAnimation:scanNetAnimation forKey:nil];
    [scanWindow addSubview:scanNetImageView];
    //设置扫描区域的四个角的边框
    CGFloat buttonWH = 18;
    UIButton *topLeft = [[UIButton alloc] initWithFrame:CGRectMake(0,0, buttonWH, buttonWH)];
    [topLeft setImage:[UIImage imageNamed:@"QR_Left_Top"]forState:UIControlStateNormal];
    [scanWindow addSubview:topLeft];
    UIButton *topRight = [[UIButton alloc]initWithFrame:CGRectMake(QRCodeWidth - buttonWH,0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"QR_Right_Top"]forState:UIControlStateNormal];
    [scanWindow addSubview:topRight];
    UIButton *bottomLeft = [[UIButton alloc]initWithFrame:CGRectMake(0,QRCodeWidth - buttonWH, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"QR_Left_Bottom"]forState:UIControlStateNormal];
    [scanWindow addSubview:bottomLeft];
    UIButton *bottomRight = [[UIButton alloc]initWithFrame:CGRectMake(QRCodeWidth-buttonWH,QRCodeWidth-buttonWH, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"QR_Right_Bottom"]forState:UIControlStateNormal];
    [scanWindow addSubview:bottomRight];
}

- (void)beginScanning {
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
    //特别注意的地方：有效的扫描区域，定位是以设置的右顶点为原点。屏幕宽所在的那条线为y轴，屏幕高所在的线为x轴
    CGFloat x = ((SCREENHeight-QRCodeWidth-64)/2.0)/SCREENHeight;
    CGFloat y = ((SCREENWidth-QRCodeWidth)/2.0)/SCREENWidth;
    CGFloat width = QRCodeWidth/SCREENHeight;
    CGFloat height = QRCodeWidth/SCREENWidth;
    output.rectOfInterest = CGRectMake(x, y, width, height);
    //设置代理在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //初始化链接对象
    self.captureSession = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [self.captureSession addInput:input];
    [self.captureSession addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [self.captureSession startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            self.license = [metadataObj stringValue];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
        }
    }
}

-(void)stopReading{
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.delegate license: self.license];
    [self.videoPreviewLayer removeFromSuperlayer];
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
