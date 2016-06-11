//
//  XZDrawView.m
//  XZDrawboardDemo
//
//  Created by 徐章 on 16/6/11.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "XZDrawView.h"

@interface XZDrawView(){

    /** 当前绘制的路径*/
    CGMutablePathRef _currentPath;
    /** 所有路径数组*/
    NSMutableArray *_pathArray;
    /** 线条颜色数组*/
    NSMutableArray *_colorArray;
    /** 线条宽带数组*/
    NSMutableArray<NSNumber *> *_widthArray;
}

@end

@implementation XZDrawView

- (id)initWithFrame:(CGRect)frame{

    self= [super initWithFrame:frame];
    if (self) {
        
        self.lineColor = [UIColor blackColor];
        self.lineWidth = 1.0f;
        _pathArray = [NSMutableArray array];
        _colorArray = [NSMutableArray array];
        _widthArray = [NSMutableArray array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_pathArray.count > 0) {
        
        for (NSInteger i = 0 ; i < _pathArray.count; i++) {
            
            UIColor *color = _colorArray[i];
            [color setStroke];
            CGContextSetLineWidth(context, _widthArray[i].floatValue);
            
            if (CGColorEqualToColor(color.CGColor, [UIColor clearColor].CGColor)) {
                
                CGContextSetBlendMode(context, kCGBlendModeClear);
            }else{
                
                CGContextSetBlendMode(context, kCGBlendModeNormal);
            }
            
            
            CGMutablePathRef path = (__bridge CGMutablePathRef)((_pathArray[i]));
            CGContextAddPath(context, path);
            CGContextDrawPath(context, kCGPathStroke);
        }
        
    }
    
    if (_currentPath) {
        
        [self.lineColor setStroke];
        CGContextSetLineWidth(context, self.lineWidth);
        
        if (CGColorEqualToColor(self.lineColor.CGColor, [UIColor clearColor].CGColor)) {
            
            CGContextSetBlendMode(context, kCGBlendModeClear);
        }else{
            
            CGContextSetBlendMode(context, kCGBlendModeNormal);
        }
        
        
        CGContextAddPath(context, _currentPath);
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (void)revokeLastOperation{

    if (_pathArray.count > 0 && _colorArray.count > 0 && _widthArray.count > 0) {
        [_pathArray removeLastObject];
        [_colorArray removeLastObject];
        [_widthArray removeLastObject];
        
        [self setNeedsDisplay];
    }
}

- (void)removeAll{

    [_pathArray removeAllObjects];
    [_colorArray removeAllObjects];
    [_widthArray removeAllObjects];
    [self setNeedsDisplay];
}

- (UIImage *)drawImage{

    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;

}
#pragma mark - UITouch_Methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    UITouch *touch = [touches anyObject];
    _currentPath = CGPathCreateMutable();
    CGPoint point = [touch locationInView:self];
    CGPathMoveToPoint(_currentPath, NULL, point.x, point.y);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    CGPathAddLineToPoint(_currentPath, NULL, point.x, point.y);
    
    [self setNeedsDisplay];
    
    if (![_pathArray containsObject:(__bridge id _Nonnull)(_currentPath)]) {
        
        [_pathArray addObject:(__bridge id _Nonnull)(_currentPath)];
        [_colorArray addObject:self.lineColor];
        [_widthArray addObject:@(self.lineWidth)];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPathRelease(_currentPath);
    _currentPath = nil;
}

@end
