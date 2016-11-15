//
//  BYConditionBar.h
//  EUExTabIndicatorView
//
//  Created by wang on 16/10/9.
//  Copyright © 2016年 com.wzyu. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^uexSegmentControlCallBackBlock)(NSUInteger index);
@interface BYConditionBar : UIScrollView
@property (nonatomic, copy) uexSegmentControlCallBackBlock callBackBlock;
@property (nonatomic, strong)UIColor *bgColor;
@property (nonatomic, strong)UIColor *textColor;
@property (nonatomic, strong)UIColor *dividerColor;
@property (nonatomic, strong)UIColor *indicatorColor;

- (id)initWithFrame:(CGRect)frame AndTitles:(NSArray*)titles bgColor:(NSString *)bgColor textColor:(NSString *)textColor dividerColor:(NSString *)dividerColor indicatorColor:(NSString *)indicatorColor;
-(void)viewSelectWithButtonIndex:(NSUInteger)index;
@end
