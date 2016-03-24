//
//  ViewController.m
//  Test_Alert
//
//  Created by KH on 16/2/24.
//  Copyright © 2016年 KH. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+PDCAlertSheet.h"

#define Cancel @"取消"
#define Sure @"确定"


@interface ViewController ()<UIAlertViewDelegate,UIActionSheetDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)ios7Alert:(UIButton *)sender
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ios7Alert" message:nil delegate:self cancelButtonTitle:Cancel otherButtonTitles:Sure,nil];
//    [alert addButtonWithTitle:@"111222"];
//    [alert show];
    [self PDCAlertWithTitle:@"ios7Alert" message:@"ios7Alert message" buttons:@[Cancel,Sure] textFieldNumber:1 configuration:^(UITextField *field, NSInteger index) {
        if (index == 0)
        {
            field.secureTextEntry = YES;
            field.placeholder = @"密麻麻们";
        }
    } animated:YES action:^(NSArray<UITextField *> *fields, NSInteger index) {
        NSLog(@"%@",fields[0].text);
    }];
}

- (IBAction)ios7Actionsheet:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"ios7Actionsheet" delegate:self cancelButtonTitle:Cancel destructiveButtonTitle:Sure otherButtonTitles:@"1",@"2", nil];
    [sheet showInView:self.view];
}

- (IBAction)ios8Alert:(UIButton *)sender
{
    
    [self PDCAlertWithTitle:@"ios8Alert" message:@"ios8Alert message" andOthers:@[Cancel,Sure] animated:YES action:^(NSInteger index){
//        NSLog(@"click %d",index);
    }];
}

- (IBAction)ios8Actionsheet:(UIButton *)sender
{
    [self PDCActionSheetWithTitle:@"ios8Actionsheet" message:@"ios8Actionsheet message" destructive:Sure destructiveAction:^(NSInteger index) {
        NSLog(@"click destructive");
    } andOthers:@[Cancel,@"1",@"2"] animated:YES action:^(NSInteger index) {
//        NSLog(@"click %d",index);
    }];
}
@end
