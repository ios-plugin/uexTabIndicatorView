//
//  BYConditionBar.m
//  EUExTabIndicatorView
//
//  Created by wang on 16/10/9.
//  Copyright © 2016年 com.wzyu. All rights reserved.
//

#import "BYConditionBar.h"
#import "Constants.h"
#import<AppCanKit/AppCanKit.h>
@interface BYConditionBar()
@property (nonatomic, strong) NSArray *lists;//titles
@property (nonatomic, strong) NSMutableArray *buttons_lists;
@property (nonatomic, strong) UIButton *select_button;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, assign) CGFloat max_width;//第一个button.orgin.x
@end
@implementation BYConditionBar
{
    CGFloat first_buttonX ;
    CGFloat  conditionBarButtonSpace;
}
- (id)initWithFrame:(CGRect)frame AndTitles:(NSArray*)titles bgColor:(NSString *)bgColor textColor:(NSString *)textColor dividerColor:(NSString *)dividerColor indicatorColor:(NSString *)indicatorColor
{
    if (self = [super initWithFrame:frame]) {
        self.bgColor = bgColor?[UIColor ac_ColorWithHTMLColorString:bgColor]:BYRGBA(238.0, 238.0, 238.0, 1.0);
        self.textColor = textColor?[UIColor ac_ColorWithHTMLColorString:textColor]:BYRGBA(111.0, 111.0, 111.0, 1.0);
        self.indicatorColor = indicatorColor?[UIColor ac_ColorWithHTMLColorString:indicatorColor]:BYRGBA(202.0, 51.0, 54.0, 1.0);
        self.dividerColor = dividerColor?[UIColor ac_ColorWithHTMLColorString:dividerColor]:BYRGBA(111.0, 111.0, 111.0, 0.8);
        self.backgroundColor = self.bgColor;
        self.lists =titles;
        
        conditionBarButtonSpace = 32;
        [self makeConditionBar];
    }
    return self;
}
-(NSArray *)lists
{
    if (!_lists) {
        _lists = [NSArray array];
    }
    return _lists;
}
-(NSMutableArray *)buttons_lists
{
    if (_buttons_lists == nil) {
        _buttons_lists = [NSMutableArray array];
    }
    return _buttons_lists;
}

-(void)loadData{
    CGFloat totalWidth = 0;
    for (int i = 0; i < self.lists.count; i ++) {
        NSString *string = [NSString stringWithFormat:@"%@",self.lists[i]];
        totalWidth += [self calculateSizeWithFont:conditionBarButtonTitleFont Width:MAXFLOAT Height:self.frame.size.height Text:string].size.width;
    }
    if (self.lists.count == 2) {
        conditionBarButtonSpace = 80;
    }
    if (self.lists.count == 3) {
        conditionBarButtonSpace = 50;
    }
    if (self.lists.count == 4) {
        conditionBarButtonSpace = 40;
    }
    self.max_width = (BYScreenWidth - totalWidth- (self.lists.count-1)*conditionBarButtonSpace)/2;
    if (self.lists.count>4) {
        self.max_width = 20;
    }
}
-(CGRect)calculateSizeWithFont:(NSInteger)Font Width:(NSInteger)Width Height:(NSInteger)Height Text:(NSString *)Text
{
    CGRect size;
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:Font]};
    size= [Text boundingRectWithSize:CGSizeMake(Width, Height)
                                 options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                              attributes:attr
                                 context:nil];
    return size;
}
-(UIButton *)makePropertyButtonWithTitle:(NSString *)title Index:(NSInteger)index
{
    CGFloat height = conditionBarButtonTitleFont +4;
    CGFloat buttonW = [self calculateSizeWithFont:conditionBarButtonTitleFont Width:MAXFLOAT Height:self.frame.size.height Text:title].size.width;
    UIButton *property_button = [[UIButton alloc] initWithFrame:CGRectMake(self.max_width, 0, buttonW, self.frame.size.height)];
    UIView *dividerView = [[UIView alloc]initWithFrame:CGRectMake(property_button.frame.size.width+conditionBarButtonSpace/2, (property_button.frame.size.height - height)/2, 1, height)];
    dividerView.backgroundColor = self.dividerColor;
    dividerView.tag = 1024+index;
    [property_button addSubview:dividerView];
    property_button.tag = index;
    property_button.titleLabel.font = [UIFont systemFontOfSize:conditionBarButtonTitleFont];
    [property_button setTitle:title forState:0];
    [property_button setTitleColor:self.textColor forState:UIControlStateNormal];
    [property_button setTitleColor:self.indicatorColor forState:UIControlStateSelected];
    
    [property_button addTarget:self
                        action:@selector(viewSelectWithButton:)
              forControlEvents:UIControlEventTouchUpInside];
    self.max_width += buttonW + conditionBarButtonSpace;
    [self.buttons_lists addObject:property_button];
    return property_button;
}
//外部调用
-(void)viewSelectWithButtonIndex:(NSUInteger)index{
    UIButton *button = self.buttons_lists[index];
    [self selectWithButton:button];
}
//内部调用
-(void)viewSelectWithButton:(UIButton *)button
{
    
    [self selectWithButton:button];
    if (self.callBackBlock) {
        self.callBackBlock(button.tag);
    }
    
}
-(void)selectWithButton:(UIButton *)button{
    if (self.select_button != button) {
        button.selected = YES;
        self.select_button.selected = NO;
        self.select_button = button;
    }
    CGFloat animate_time = 0.3;
    //指示条发生变化
    [UIView animateWithDuration:animate_time animations:^{
        NSLog(@"button.frame.size.width   %f",button.frame.size.width);
        CGRect buttonBg_view_frame     = self.indicatorView.frame;
        buttonBg_view_frame.size.width = button.frame.size.width+20;
        self.indicatorView.frame       = buttonBg_view_frame;
        CGFloat trans_width            = button.frame.origin.x - first_buttonX ;
        self.indicatorView.transform  = CGAffineTransformMakeTranslation(trans_width, 0);
    }];
    //    点击后button位置调整
    if (self.lists.count>5) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animate_time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat width = self.frame.size.width;
        [UIView animateWithDuration:animate_time animations:^{
            if(button.frame.origin.x < width/2){
                self.contentOffset = CGPointMake(0, 0);
            }
            else if (button.frame.origin.x >= width/2 && button.frame.origin.x<self.contentSize.width - width/2 ) {
                
                self.contentOffset = CGPointMake((button.tag-2)*(button.frame.size.width+conditionBarButtonSpace) , 0);
                
            }
            else {
                self.contentOffset = CGPointMake(self.contentSize.width - width-20 , 0);
            }}];
        
     });
  }
}


-(void)makeConditionBar{
     [self loadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showsHorizontalScrollIndicator = NO;
        CGFloat first_buttonW = 0;
        for (int i =0; i<_lists.count; i++) {
            UIButton *button = [self makePropertyButtonWithTitle:_lists[i] Index:i];
            if (i == 0) {
                button.selected = YES;
                self.select_button = button;
                first_buttonW = [self calculateSizeWithFont:conditionBarButtonTitleFont Width:MAXFLOAT Height:self.frame.size.height Text:_lists[i]].size.width;
                first_buttonX =  button.frame.origin.x;
                
            }
            if (i == _lists.count -1) {
                UIView *view = [button viewWithTag:(1024+ _lists.count -1)];
                [view removeFromSuperview];
            }
            
            [self addSubview:button];
        }
        if (self.lists.count>5) {
            self.contentSize = CGSizeMake(self.max_width, self.frame.size.height);
        }
        
        self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(first_buttonX - 10 ,self.frame.size.height-5  ,first_buttonW+20, 2.5)];
        self.indicatorView.backgroundColor = self.indicatorColor;
        [self insertSubview:self.indicatorView atIndex:0];
        [self viewSelectWithButton:self.select_button];
        

    });

}


@end
