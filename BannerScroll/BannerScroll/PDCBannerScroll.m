//
//  PDCBannerScroll.m
//  BannerScroll
//
//  Created by KH on 16/3/23.
//  Copyright © 2016年 KH. All rights reserved.
//

#import "PDCBannerScroll.h"

static inline CGFloat view_width(UIView *view)
{
    return CGRectGetWidth(view.bounds);
}

static inline CGFloat view_height(UIView *view)
{
    return CGRectGetHeight(view.bounds);
}

@interface PDCBannerScroll()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *mainScrollView;

@property (strong, nonatomic) UIImageView *imageView1;
@property (strong, nonatomic) UIImageView *imageView2;
@property (strong, nonatomic) UIImageView *imageView3;

@property (strong, nonatomic) UIPageControl *pageControl;

@property (assign, nonatomic) NSInteger index;

#ifdef DEBUG_BY_COLOR
@property (strong, nonatomic) UIColor *lastColor;
@property (strong, nonatomic) UIColor *nextColor;
@property (strong, nonatomic) UIColor *currentColor;
#else
@property (nonatomic, copy) NSString *lastPath;
@property (nonatomic, copy) NSString *nextPath;
@property (nonatomic, copy) NSString *currentPath;
#endif

@property (strong, nonatomic) NSTimer *timer;
@property (copy, nonatomic) download download;
@end

@implementation PDCBannerScroll
#pragma mark - init
-(instancetype )initWithFrame:(CGRect)frame andPaths:(NSArray <NSString *> *)paths
{
    if (self = [super initWithFrame:frame])
    {
        [self pr_setSubViews];
        self.paths = paths;
        [self pr_setPrama];
    }
    return self;
}

-(instancetype )initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self pr_setSubViews];
        [self pr_setPrama];
    }
    return self;
}

-(void )awakeFromNib
{
    [self pr_setSubViews];
    [self pr_setPrama];
}

-(void )pr_setSubViews
{

#if DEBUG_BY_COLOR
    self.colors = @[[UIColor redColor],
                    [UIColor greenColor],
                    [UIColor blueColor]];
#endif
    
    {
        //这里用三张图片做轮播
        self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * 3.0f, CGRectGetHeight(self.bounds));
        self.mainScrollView.contentOffset = CGPointMake(view_width(self.mainScrollView), 0);
        [self addSubview:self.mainScrollView];
        
        self.mainScrollView.pagingEnabled = YES;
        self.mainScrollView.showsVerticalScrollIndicator = NO;
        self.mainScrollView.showsHorizontalScrollIndicator = NO;
        
        self.mainScrollView.delegate = self;
    }
    
    {
        self.imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,view_width(self.mainScrollView), view_height(self.mainScrollView))];
        self.imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(view_width(self.mainScrollView),0 ,view_width(self.mainScrollView), view_height(self.mainScrollView))];
        self.imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(view_width(self.mainScrollView) * 2.0f, 0,view_width(self.mainScrollView), view_height(self.mainScrollView))];
        
        [self.mainScrollView addSubview:self.imageView1];
        [self.mainScrollView addSubview:self.imageView2];
        [self.mainScrollView addSubview:self.imageView3];
        
        self.imageView1.userInteractionEnabled = YES;
        self.imageView2.userInteractionEnabled = YES;
        self.imageView3.userInteractionEnabled = YES;
        
        [self.imageView1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)]];
        [self.imageView2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)]];
        [self.imageView3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)]];
    }
}

-(void )pr_setPrama
{
        self.timeInterval = 3.0;    //default
        self.index = 0;
        
        self.indicatorColor = [UIColor colorWithRed:0.733 green:0.839 blue:1.000 alpha:1.000];
        self.indicatorCurrentColor = [UIColor colorWithRed:254.0/255.0 green:198.0/255.0 blue:105.0/255.0 alpha:1];
    
}

#pragma mark - setter
#ifdef DEBUG_BY_COLOR
-(void )setColors:(NSArray<UIColor *> *)colors
{
    _colors = colors;
    self.imageView1.backgroundColor = [colors lastObject];
    self.imageView2.backgroundColor = [colors firstObject];
    if (colors.count > 1)
    {
        self.imageView3.backgroundColor = colors[1];
    }
    else
    {
        [self.imageView2 removeFromSuperview];
        [self.imageView3 removeFromSuperview];
        self.mainScrollView.contentSize = CGSizeMake(view_width(self.mainScrollView), view_height(self.mainScrollView));
    }
}
#else
-(void )setPaths:(NSArray<NSString *> *)paths
{
    _paths = paths;
    
    self.showPageControl = YES;
    
    self.autoScroll = YES;
    
    self.lastPath = [paths lastObject];
    self.currentPath = [paths firstObject];
    //imageView1
    [self setImageWithImageView:self.imageView1 path:self.lastPath];
    
    //imageView2
    [self setImageWithImageView:self.imageView2 path:self.currentPath];
    
    //imageView3
    if (paths.count > 1)
    {
        NSString *path = paths[1];
        [self setImageWithImageView:self.imageView3 path:path];
    }
    else
    {
        [self.imageView2 removeFromSuperview];
        [self.imageView3 removeFromSuperview];
        self.mainScrollView.contentSize = CGSizeMake(view_width(self.mainScrollView), view_height(self.mainScrollView));
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.callBackOnceAction)
        {
            self.callBackOnceAction(self.currentPath,0);
        }
    });
}
#endif

//设置自动滚动
-(void )setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    if (autoScroll)
    {
        if (self.timer == nil)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timerAutoScroll) userInfo:nil repeats:YES];
                [self.timer fire];
            });
        }
    }
    else
    {
        if (self.timer)
        {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

//设置pageControl
-(void )setShowPageControl:(BOOL)showPageControl
{
    _showPageControl = showPageControl;
    if (showPageControl)
    {
        if (self.pageControl == nil)
        {
            self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, view_height(self) - 30, view_width(self), 30)];
            self.pageControl.numberOfPages = self.paths.count;
            self.pageControl.currentPage = self.index;
            self.pageControl.enabled = NO;
            self.pageControl.pageIndicatorTintColor = self.indicatorColor;
            self.pageControl.currentPageIndicatorTintColor = self.indicatorCurrentColor;
            [self addSubview:self.pageControl];
        }
        else
        {
            self.pageControl.hidden = NO;
        }
    }
    else
    {
        self.pageControl.hidden = YES;
    }
}

-(void )setIndicatorColor:(UIColor *)indicatorColor
{
    _indicatorColor = indicatorColor;
    if (self.pageControl)
    {
        self.pageControl.pageIndicatorTintColor = indicatorColor;
    }
}

-(void )setIndicatorCurrentColor:(UIColor *)indicatorCurrentColor
{
    _indicatorCurrentColor = indicatorCurrentColor;
    if (self.pageControl)
    {
        self.pageControl.currentPageIndicatorTintColor = indicatorCurrentColor;
    }
}

-(void )scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.timer)
    {
        self.timer.fireDate = [NSDate distantFuture];
    }
    NSLog(@"1111");
}

-(void )setPersonalView:(UIView *)personalView
{
    if (personalView)
    {
        [self insertSubview:personalView atIndex:self.subviews.count - 1];
    }
}

#pragma mark - scrollView delegate
-(void )scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger x = scrollView.contentOffset.x;
#ifdef DEBUG_BY_COLOR
    if (x == 0)
    {
        [self subIndex];
        self.currentColor = self.colors[self.index];
        self.nextColor = self.imageView2.backgroundColor;
        [self subIndex];
        self.lastColor = self.colors[self.index];
        self.imageView2.backgroundColor = self.currentColor;
        self.imageView3.backgroundColor = self.nextColor;
        self.imageView1.backgroundColor = self.lastColor;
        [self addIndex];
    }
    else if(x == view_width(scrollView) * 2)
    {
        [self addIndex];
        self.currentColor = self.colors[self.index];
        self.lastColor = self.imageView2.backgroundColor;
        [self addIndex];
        self.nextColor = self.colors[self.index];
        self.imageView2.backgroundColor = self.currentColor;
        self.imageView3.backgroundColor = self.nextColor;
        self.imageView1.backgroundColor = self.lastColor;
        [self subIndex];
    }
#else
    if (x == 0)
    {
        [self lastPage];
    }
    else if(x == view_width(scrollView) * 2)
    {
        [self nextPage];
    }
#endif
    //这里设置inageView2始终在中间
    self.pageControl.currentPage = self.index;
    self.mainScrollView.contentOffset = CGPointMake(view_width(self.mainScrollView), 0);
    
    self.timer.fireDate = [NSDate dateWithTimeIntervalSinceNow:3.0];
}

#pragma mark - self method
-(void )needDownload:(download )needDownload
{
    self.download = needDownload;
}

#pragma mark - action
-(void )click:(UITapGestureRecognizer *)sender
{
    if (self.clickAction)
    {
        self.clickAction(self.paths[self.index],self.index);
    }
}

//timer
-(void )timerAutoScroll
{
    [self.mainScrollView setContentOffset:CGPointMake(view_width(self.mainScrollView) * 2, 0) animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self nextPage];
        self.pageControl.currentPage = self.index;
        self.mainScrollView.contentOffset = CGPointMake(view_width(self.mainScrollView), 0);
    });
    
}

#pragma mark - pravite method
-(NSInteger )subIndex
{
    self.index--;
    if (self.index < 0)
    {
#ifdef DEBUG_BY_COLOR
        self.index = self.colors.count - 1;
#else
        self.index = self.paths.count - 1;
#endif
    }
    return self.index;
}

-(NSInteger )addIndex
{
    self.index++;
#ifdef DEBUG_BY_COLOR
    if (self.index > self.colors.count - 1)
    {
#else
    if (self.index > self.paths.count - 1)
    {
#endif
        self.index = 0;
    }
    return self.index;
}
    
-(void )lastPage
{
    [self subIndex];
    self.nextPath = self.currentPath;
    self.currentPath = self.paths[self.index];
    [self subIndex];
    self.lastPath = self.paths[self.index];
    
    //imageView1
    [self setImageWithImageView:self.imageView1 path:self.lastPath];
    
    //imageView2
    [self setImageWithImageView:self.imageView2 path:self.currentPath];
    
    //imageView3
    [self setImageWithImageView:self.imageView3 path:self.nextPath];
    
    [self addIndex];
    
    if (self.scrollAction)
    {
        self.scrollAction(self.paths[self.index],self.index);
    }
}

-(void )nextPage
{
    [self addIndex];
    self.lastPath = self.currentPath;
    self.currentPath = self.paths[self.index];
    
    [self addIndex];
    self.nextPath = self.paths[self.index];
    
    //imageView1
    [self setImageWithImageView:self.imageView1 path:self.lastPath];
    
    //imageView2
    [self setImageWithImageView:self.imageView2 path:self.currentPath];
    
    //imageView3
    [self setImageWithImageView:self.imageView3 path:self.nextPath];
    
    [self subIndex];
    
    if (self.scrollAction)
    {
        self.scrollAction(self.paths[self.index],self.index);
    }
}

#ifndef DEBUG_BY_COLOR
-(BOOL )canOpenPath:(NSString *)path
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:path]];
}

-(void )setImageWithImageView:(UIImageView *)imageView path:(NSString *)path
{
    if ([self canOpenPath:path])
    {
        //回调自己调用接口下载图片
        if (self.download)
        {
            self.download(imageView, path);
        }
    }
    else
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            imageView.image = [UIImage imageWithContentsOfFile:path];
        }
        else
        {
            imageView.image = [UIImage imageNamed:path];
        }
    }
}
#endif
@end
