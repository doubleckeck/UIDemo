//
//  PDCQRScaner.m
//  PDCQRScaner
//
//  Created by KH on 16/3/11.
//  Copyright © 2016年 KH. All rights reserved.
//

#import "PDCQRScaner.h"
#import <AVFoundation/AVFoundation.h>

CGFloat space_y = 64.0f;
CGFloat duration_default = 2.0;

@interface PDCQRScaner ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *scanWindow;

@property (assign, nonatomic) CGFloat scanWidth;
@property (assign, nonatomic) CGFloat scanHeight;
@property (assign, nonatomic) CGFloat space_x;
@property (strong, nonatomic) UIImage *scanImage;

@end

@implementation PDCQRScaner

-(void)setDuration:(CGFloat)duration
{
    _duration = duration;
    duration_default = duration;
}

-(instancetype )initWithSize:(CGSize )size andScanMoveImage:(UIImage *)image
{
    if (self = [super init])
    {
        self.scanWidth = size.width;
        self.scanHeight = size.height;
        self.scanImage = image;
        if (image == nil)
        {
            self.scanImage = [UIImage imageNamed:@"PDCScan.bundle/scan_move"];
        }
        
        self.space_x = (CGRectGetWidth([UIScreen mainScreen].bounds) - self.scanWidth) * 0.5;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    
    duration_default = 2.0;
    
    if (self.navigationController && !self.navigationController.navigationBarHidden)
    {
        space_y = 64.0 + 61.8;
    }
    
    [self stepBackgroundView];
}

-(void)viewWillAppear:(BOOL)animated
{
    /**
     *  动画不能放在viewDidLoad里面
     */
    [self setScanWindow];
    [self startScan];
}

-(void)stepBackgroundView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:self.backgroundView];
    
    /**
     *  扫描窗口背景
     */
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.space_x, space_y, width - self.space_x * 2.0, self.scanHeight) cornerRadius:1] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    self.backgroundView.layer.mask = maskLayer;
}

-(void)setScanWindow
{
    /**
     *  扫描窗口
     */
    CGFloat width = CGRectGetWidth(self.view.frame);
    UIView *scanWindow = [[UIView alloc] initWithFrame:CGRectMake(self.space_x, space_y, width - self.space_x * 2.0, self.scanHeight)];
    scanWindow.clipsToBounds = YES;
    self.scanWindow = scanWindow;
    [self.view addSubview:scanWindow];
    
    /**
     *  扫描动画
     */
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.scanImage];
    imageView.frame = CGRectMake(0, -CGRectGetHeight(scanWindow.bounds), width - 2.0 * self.space_x, CGRectGetHeight(scanWindow.bounds));
    [scanWindow addSubview:imageView];

    CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
    scanNetAnimation.keyPath = @"transform.translation.y";
    scanNetAnimation.byValue = @(self.scanHeight);
    scanNetAnimation.duration = duration_default;
    scanNetAnimation.repeatCount = MAXFLOAT;
    [imageView.layer addAnimation:scanNetAnimation forKey:nil];
    
    /**
     *  取消按钮
     */
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 61.8, width, 40);
    [self.view addSubview:button];
    
    [self setOther];
}

-(void)setOther
{
    /**
     *  四个角
     */
    UIImageView *imageView1 = [UIImageView new];
    UIImageView *imageView2 = [UIImageView new];
    UIImageView *imageView3 = [UIImageView new];
    UIImageView *imageView4 = [UIImageView new];
    
    imageView1.image = [UIImage imageNamed:@"PDCScan.bundle/scan_1"];
    imageView2.image = [UIImage imageNamed:@"PDCScan.bundle/scan_2"];
    imageView3.image = [UIImage imageNamed:@"PDCScan.bundle/scan_3"];
    imageView4.image = [UIImage imageNamed:@"PDCScan.bundle/scan_4"];
    
    const CGFloat width = 19.0;
    
    imageView1.frame = CGRectMake(self.space_x, space_y, width, width);
    imageView2.frame = CGRectMake(self.space_x + self.scanWidth - width, space_y, width, width);
    imageView3.frame = CGRectMake(self.space_x, space_y + self.scanHeight - width + 2, width, width);
    imageView4.frame = CGRectMake(self.space_x + self.scanWidth - width, space_y + self.scanHeight - width + 2, width, width);
    
    [self.view addSubview:imageView1];
    [self.view addSubview:imageView2];
    [self.view addSubview:imageView3];
    [self.view addSubview:imageView4];
}

-(void)startScan
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input)
    {
        return;
    }
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
    CGRect rectOfInterest = CGRectMake(space_y / height,self.space_x / width,CGRectGetHeight(self.scanWindow.bounds) / height, CGRectGetWidth(self.scanWindow.bounds) / width);
    output.rectOfInterest = rectOfInterest;
    
    //设置代理,在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化session
    self.session = [[AVCaptureSession alloc] init];
    
    //质量
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([self.session canAddInput:input])
    {
        [self.session addInput:input];
    }
    
    if ([self.session canAddOutput:output])
    {
        [self.session addOutput:output];
    }
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.bounds;
    /**
     *  插入到最底层
     */
    [self.view.layer insertSublayer:layer atIndex:0];
    
    [self.session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    /**
     *  得到结果
     */
    if (metadataObjects.count > 0)
    {
        [self.session stopRunning];
        AVMetadataMachineReadableCodeObject *data = [metadataObjects objectAtIndex:0];
        if (self.callBack)
        {
            self.callBack(data.stringValue);
        }
    }
}

-(IBAction )cancel:(UIButton *)sender
{
    [self pr_cancel];
}

-(void)dismiss
{
    [self pr_cancel];
}

-(void)pr_cancel
{
    if (self.cancelCalBack)
    {
        self.cancelCalBack();
    }
}

+(BOOL )pr_isAvailable
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!captureDevice)
    {
        return NO;
    }

    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input || error)
    {
        return NO;
    }
    
    return YES;
}

+(BOOL )supportsMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    if (![self pr_isAvailable])
    {
        return NO;
    }
    
    AVCaptureDevice *captureDevice    = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    AVCaptureMetadataOutput *output   = [[AVCaptureMetadataOutput alloc] init];
    AVCaptureSession *session         = [[AVCaptureSession alloc] init];
    
    [session addInput:deviceInput];
    [session addOutput:output];
    
    if (metadataObjectTypes == nil || metadataObjectTypes.count == 0)
    {
        metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    
    for (NSString *metadataObjectType in metadataObjectTypes)
    {
        if (![output.availableMetadataObjectTypes containsObject:metadataObjectType])
        {
            return NO;
        }
    }
    return YES;
}

@end
