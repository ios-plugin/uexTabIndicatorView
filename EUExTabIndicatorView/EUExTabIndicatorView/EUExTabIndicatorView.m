//
//  EUExTabIndicatorView.m
//  EUExTabIndicatorView
//
//  Created by wang on 16/10/9.
//  Copyright © 2016年 com.wzyu. All rights reserved.
//

#import "EUExTabIndicatorView.h"
#import "BYConditionBar.h"
#import "Constants.h"
#import "EUtility.h"
#import <AppCanKit/AppCanWindowObject.h>
#import <AppCanKit/ACEXTScope.h>
@interface EUExTabIndicatorView()<UIScrollViewDelegate>
@property (nonatomic ,strong) BYConditionBar *conditionBar;
@property (nonatomic, strong) UIScrollView<AppCanScrollViewEventProducer> *scrollView;
@property (nonatomic, strong) UIScrollView<AppCanScrollViewEventProducer> *container;
@end

@implementation EUExTabIndicatorView
-(instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if(self = [super initWithWebViewEngine:engine]){
    }
    return self;
}

-(void)open:(NSMutableArray*)inArguments{
    ACArgsUnpack(NSDictionary * dict) = inArguments;
    if (![self.webViewEngine conformsToProtocol:@protocol(AppCanWindowObject)]) {
        return;
    }
    id<AppCanWindowObject> window = (id<AppCanWindowObject>)self.webViewEngine;
    CGFloat x = dict[@"x"]?[dict[@"x"] floatValue]:0;
    CGFloat y = dict[@"y"]?[dict[@"y"] floatValue]:0;
    CGFloat w = dict[@"w"]?[dict[@"w"] floatValue]:BYScreenWidth;
    CGFloat h = dict[@"h"]?[dict[@"h"] floatValue]:40;
    NSString *bgColor = dict[@"bgColor"]?:nil;
    NSString *textColor = dict[@"textColor"]?:nil;
    NSString *dividerColor = dict[@"dividerColor"]?:nil;
    NSString *indicatorColor = dict[@"indicatorColor"]?:nil;
    NSString *containerId = dict[@"containerId"]?:nil;
    NSString *multiPopName = dict[@"multiPopName"]?:nil;
    NSArray *titles = dict[@"titles"];
    int bindMode = [dict[@"bindMode"] intValue]?:0;
    self.conditionBar = [[BYConditionBar alloc]initWithFrame:CGRectMake(x, y,w , h) AndTitles:titles bgColor:bgColor textColor:textColor dividerColor:dividerColor indicatorColor:indicatorColor];
    [[self.webViewEngine webView] addSubview:self.conditionBar];
    if (bindMode == 0) {
        self.container = [window pluginViewContainerForName:containerId];
        for (int i = 0; i<titles.count; i++) {
            UIView *view = [[UIView alloc]init];
            view.backgroundColor = [UIColor whiteColor];
            CGRect rect = CGRectMake(0, 0, self.container.frame.size.width ,self.container.frame.size.height);
            rect.origin.x = i*rect.size.width;
            view.frame = rect;
            [window addSubView:view toPluginViewContainerWithName:containerId atIndex:i];
        }
        [self.container addScrollViewEventObserver:self];
        self.container.backgroundColor = [UIColor whiteColor];
        @weakify(self);
        self.conditionBar.callBackBlock = ^(NSUInteger index){
            @strongify(self);
            [self.container setContentOffset:CGPointMake(index * self.container.frame.size.width, 0)];
        };
    }
    else {
        self.scrollView = [window multiPopoverForName:multiPopName];
        if (self.scrollView) {
            [self.scrollView addScrollViewEventObserver:self];
        }
        @weakify(self);
        self.conditionBar.callBackBlock = ^(NSUInteger index){
            @strongify(self);
            [self.scrollView setContentOffset:CGPointMake(index * self.scrollView.frame.size.width, 0)];
        };
    }
   

}

-(void)setVisible:(NSMutableArray*)inArguments{
    ACArgsUnpack(NSNumber *isShow) = inArguments;
    if ([isShow integerValue] == 0) {
        self.conditionBar.hidden = YES;
    }
    if ([isShow integerValue] == 1) {
        self.conditionBar.hidden = NO;
    }
}

-(void)close:(NSMutableArray*)inArguments{
    [self clean];
    
}
-(void)clean{
    if (self.conditionBar) {
        [_conditionBar removeFromSuperview];
        self.conditionBar = nil;
    }
    if(self.scrollView){
        [self.scrollView removeScrollViewEventObserver:self];
    }
    if (self.container) {
        [self.container removeScrollViewEventObserver:self];
    }
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offSet = scrollView.contentOffset;
    NSInteger index = round(offSet.x/scrollView.frame.size.width);
   [self.conditionBar viewSelectWithButtonIndex:index];
    
}


@end
