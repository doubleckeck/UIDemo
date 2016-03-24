//
//  ViewController.m
//  PDCQRScaner
//
//  Created by KH on 16/3/11.
//  Copyright © 2016年 KH. All rights reserved.
//

#import "ViewController.h"
#import "PDCQRScaner.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender
{
    
    PDCQRScaner *controller = [[PDCQRScaner alloc] initWithSize:CGSizeMake(200, 200) andScanMoveImage:nil];
    
    [self presentViewController:controller animated:YES completion:nil];
    
    __block typeof(controller) weakController = controller;
    
    /**
     *  得到结果
     *
     *  @param QRString 扫描得到的字符传
     *
     */
    controller.callBack = ^(NSString *QRString){
        NSLog(@"%@",QRString);
        [weakController dismissViewControllerAnimated:YES completion:nil];
    };
    
    /**
     *  取消
     */
    controller.cancelCalBack = ^{
        [weakController dismissViewControllerAnimated:YES completion:nil];
    };
}

- (IBAction)push:(UIButton *)sender
{
    PDCQRScaner *controller = [[PDCQRScaner alloc] initWithSize:CGSizeMake(200, 200) andScanMoveImage:nil];
    
    [self.navigationController pushViewController:controller animated:YES];
    
    __block typeof(controller) weakController = controller;
    
    /**
     *  得到结果
     *
     *  @param QRString 扫描得到的字符传
     *
     */
    controller.callBack = ^(NSString *QRString){
        NSLog(@"%@",QRString);
        [weakController dismissViewControllerAnimated:YES completion:nil];
    };
    
    /**
     *  取消
     */
    controller.cancelCalBack = ^{
        [weakController.navigationController popViewControllerAnimated:YES];
    };
}
@end
