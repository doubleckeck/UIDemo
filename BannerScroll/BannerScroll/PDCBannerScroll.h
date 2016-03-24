//
//  PDCBannerScroll.h
//  BannerScroll
//
//  Created by KH on 16/3/23.
//  Copyright © 2016年 KH. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define DEBUG_BY_COLOR  //测试用于debug看效果

typedef void(^clickAction)(NSString *path, NSInteger index);
typedef void(^download)(UIImageView *imageView, NSString *urlPath);
typedef clickAction callBackAction;

@interface PDCBannerScroll : UIView
//----------------------------------------------------------------------------------
/**
 *  初始化方法，也可用其它初始化方法
 *
 *  @param frame frame
 *  @param paths 路径,图片名或者url，可混合
 *
 *  @return PDCBannerScroll
 */
-(instancetype )initWithFrame:(CGRect)frame andPaths:(NSArray <NSString *> *)paths;

#ifndef DEBUG_BY_COLOR
/**
 *  设置路径,如果用系统方法或者xib创建的首先应该设置paths
 */
@property (strong, nonatomic) NSArray<NSString *> *paths;
#endif

/**
 *  只会在设置paths的时候会调用
 */
@property (copy, nonatomic) callBackAction callBackOnceAction;

/**
 *  点击回调事件
 */
@property (copy, nonatomic) clickAction clickAction;

/**
 *  滚动事件
 */
@property (copy, nonatomic) callBackAction scrollAction;

/**
 *  滚动间隔时间，需设置自动滚动前先设，默认3.0s,需大于等于0.5秒
 *  只要这个时间大于系统默认动画时间就可以
 */
@property (assign, nonatomic) NSTimeInterval timeInterval;
/**
 *  是否自动滚动，默认YES
 */
@property (assign, nonatomic) BOOL autoScroll;


/**
 *  pageControl设置,默认为YES
 */
@property (assign, nonatomic) BOOL showPageControl;
/**
 *  指示器未选中颜色默认[UIColor colorWithRed:0.733 green:0.839 blue:1.000 alpha:1.000]
 */
@property (strong, nonatomic) UIColor *indicatorColor;
/**
 *  指示器选中颜色，默认[UIColor colorWithRed:254.0/255.0 green:198.0/255.0 blue:105.0/255.0 alpha:1]
 */
@property (strong, nonatomic) UIColor *indicatorCurrentColor;

/**
 *  自定义view
 */
@property (strong, nonatomic) UIView *personalView;

/**
 *  需要自己下载图片，因为我不知道你要用什么接口下载
 *
 *  @param needDownload 返回下载的参数
 */
-(void )needDownload:(download )needDownload;

//----------------------------------------------------------------------------------
//我debug初期用的
#ifdef DEBUG_BY_COLOR
/**
 *  本人调试用的，不是调试把宏（DEBUG_BY_COLOR）注释掉
 */
@property (strong, nonatomic) NSArray<UIColor *> *colors;
#endif
@end
