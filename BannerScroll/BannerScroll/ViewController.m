//
//  ViewController.m
//  BannerScroll
//
//  Created by KH on 16/3/23.
//  Copyright © 2016年 KH. All rights reserved.
//

#import "ViewController.h"
#import "PDCBannerScroll.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet PDCBannerScroll *view2;
@property (strong, nonatomic) IBOutlet PDCBannerScroll *view3;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *paths = @[@"0.jpg",@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg"];
    
    PDCBannerScroll *banner = [[PDCBannerScroll alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 150) andPaths:paths];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 25)];
    label.backgroundColor = [UIColor grayColor];
    label.alpha = 0.85;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14.0];
    banner.personalView = label;
    banner.callBackOnceAction = ^(NSString *path, NSInteger index){
        
        label.text = [NSString stringWithFormat:@"%@%@",@"这个是什么鬼？",path];
        
    };
    
//    banner.paths = paths;
    
    [self.view addSubview:banner];
    
    banner.clickAction = ^(NSString *path, NSInteger index){
        NSLog(@"%@ --- index:%ld",path,(long)index);
        
    };
    
    banner.scrollAction = ^(NSString *path, NSInteger index){
        
        label.text = [NSString stringWithFormat:@"%@%@",@"这个是什么鬼？",path];
    };
    
    
    self.view2.paths = paths;
    self.view2.timeInterval = 2.0;
    
    self.view3 = [[PDCBannerScroll alloc] initWithFrame:CGRectMake(0, 64 + 150 + 220, CGRectGetWidth(self.view.bounds), 150)];
    self.view3.paths = paths;
    self.view3.timeInterval = 5.0;
    
    [self.view addSubview:self.view3];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
