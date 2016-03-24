//
//  PDCQRScaner.h
//  PDCQRScaner
//
//  Created by KH on 16/3/11.
//  Copyright © 2016年 KH. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  回调block
 *
 *  @param QRString 扫描返回的字符串
 */
typedef void(^callBack)(NSString *QRString);

/**
 *  按钮回调
 */
typedef void(^actionCallBack)();

@interface PDCQRScaner : UIViewController

/**
 *  扫描速度，默认2秒
 */
@property (assign, nonatomic) CGFloat duration;

/**
 *  扫描完成回调
 */
@property (copy, nonatomic) callBack callBack;

/**
 *  取消回调
 */
@property (copy, nonatomic) actionCallBack cancelCalBack;

/**
 *  首先要验证设备是否支持扫描
 *
 *  @param metadataObjectTypes 支持的扫描参数 如：AVMetadataObjectTypeQRCode
 *
 *  @return YES 支持，NO 不支持
 */
+(BOOL )supportsMetadataObjectTypes:(NSArray<NSString *> *)metadataObjectTypes;

/**
 *  初始化方法
 *
 *  @param size  扫描框的大小
 *  @param image 扫描的效果图
 *
 *  @return self-controller
 */
-(instancetype )initWithSize:(CGSize )size andScanMoveImage:(UIImage *)image;

@end
