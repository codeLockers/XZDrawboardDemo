//
//  XZDrawView.h
//  XZDrawboardDemo
//
//  Created by 徐章 on 16/6/11.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZDrawView : UIView

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) UIColor *lineColor;

- (void)revokeLastOperation;

- (void)removeAll;

- (UIImage *)drawImage;
@end
