//
//  UIViewController+PDCAlertSheet.h
//  Test_Alert
//
//  Created by KH on 16/2/24.
//  Copyright © 2016年 KH. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    #define IPHONE_OS_VERSION_MIN_IPHONE_8_0    //less than 8.0
#else
    #define IPHONE_OS_VERSION_MAX_IPHONE_8_0    //greater than or equal to 8.0
#endif

#define NO_USE -1000

/**
 *  click button
 *
 *  @param index index
 */
typedef void(^click)(NSInteger index);
typedef void(^configuration)(UITextField *field, NSInteger index);
typedef void(^clickHaveField)(NSArray<UITextField *> *fields, NSInteger index);

@interface UIViewController (PDCAlertSheet)
#ifdef IPHONE_OS_VERSION_MIN_IPHONE_8_0
    <UIAlertViewDelegate,UIActionSheetDelegate>
#endif
/**
 *  use alert
 *
 *  @param title    title
 *  @param message  message
 *  @param others   other button title
 *  @param animated animated
 *  @param click    button action
 */
-(void)PDCAlertWithTitle:(NSString *)title
                 message:(NSString *)message
               andOthers:(NSArray <NSString *> *)others
                animated:(BOOL )animated
                  action:(click )click;


/**
 *  use action sheet
 *
 *  @param title             title
 *  @param message           message just system verson max or equal 8.0.
 *  @param destructive       button title is red color
 *  @param destructiveAction destructive action
 *  @param others            other button
 *  @param animated          animated
 *  @param click             other button action
 */
-(void)PDCActionSheetWithTitle:(NSString *)title
                       message:(NSString *)message
                   destructive:(NSString *)destructive
             destructiveAction:(click )destructiveAction
                     andOthers:(NSArray <NSString *> *)others
                      animated:(BOOL )animated
                        action:(click )click;


/**
 *  use alert include textField
 *
 *  @param title         title
 *  @param message       message
 *  @param buttons       buttons
 *  @param number        number of textField
 *  @param configuration configuration textField
 *  @param animated      animated
 *  @param click         button action
 */
-(void)PDCAlertWithTitle:(NSString *)title
                 message:(NSString *)message
                 buttons:(NSArray<NSString *> *)buttons
         textFieldNumber:(NSInteger )number
           configuration:(configuration )configuration
                animated:(BOOL )animated
                  action:(clickHaveField )click;
@end
