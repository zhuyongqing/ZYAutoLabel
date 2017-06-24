//
//  ZYAutoLabel.h
//  ImageSlide
//
//  Created by zhuyongqing on 2017/4/6.
//  Copyright © 2017年 zhuyongqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYAutoLabel : UIView

@property(nonatomic,strong) NSString *text;

@property(nonatomic,weak) UIView *selfView;

@property(nonatomic,assign) CGFloat scale;


@end
