//
//  ViewController.m
//  XZDrawboardDemo
//
//  Created by 徐章 on 16/6/9.
//  Copyright © 2016年 徐章. All rights reserved.
//

#import "ViewController.h"
#import "XZDrawView.h"

#define UISCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISlider *widthSlider;
@property (weak, nonatomic) IBOutlet UISlider *colorSlider;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *cleanBtn;
@property (nonatomic, strong) XZDrawView *drawView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.widthSlider.backgroundColor = [UIColor colorWithPatternImage:[self widthSliderBackgroundImage]];
    [self.widthSlider addTarget:self action:@selector(widthSlider_Changed:) forControlEvents:UIControlEventValueChanged];
    [self.widthSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [self.widthSlider setMinimumTrackTintColor:[UIColor clearColor]];
    
    self.colorSlider.backgroundColor = [UIColor colorWithPatternImage:[self colorSliderBackgroudImage]];
    [self.colorSlider addTarget:self action:@selector(colorSlider_Changed:) forControlEvents:UIControlEventValueChanged];
    [self.colorSlider setMaximumTrackTintColor:[UIColor clearColor]];
    [self.colorSlider setMinimumTrackTintColor:[UIColor clearColor]];
    self.colorSlider.thumbTintColor = [UIColor blackColor];
    
    self.drawView = [[XZDrawView alloc] initWithFrame:self.imageView.bounds];
    [self.imageView addSubview:self.drawView];
    self.drawView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)widthSliderBackgroundImage{

    CGSize size = CGSizeMake(UISCREEN_WIDTH - 60.0f + 4.0f, 30.0f);
    
    CGFloat startRadius = 2.0f;
    CGFloat endRadius = 9.0f;
    
    CGPoint startPoint = CGPointMake(startRadius, 15.0f);
    CGPoint endPoint    = CGPointMake(size.width - endRadius, 15.0f);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(context, startPoint.x, startPoint.y, startRadius, -M_PI_2, M_PI_2, YES);
    CGContextAddLineToPoint(context, size.width - endRadius, size.height/2.0f + endRadius);
    CGContextAddArc(context, endPoint.x, endPoint.y, endRadius, M_PI_2, -M_PI_2, YES);
    CGContextClosePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)colorSliderBackgroudImage{

    CGSize size = CGSizeMake(UISCREEN_WIDTH - 60.0f + 4.0f, 30.0f);
    
    CGFloat radius = 5.0f;

    CGPoint startPoint = CGPointMake(radius, 15.0f);
    CGPoint endPoint    = CGPointMake(size.width - radius, 15.0f);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect frame = CGRectMake(radius, (size.height-10)/2, size.width-10, radius);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:radius].CGPath;
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillPath(context);

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {
        0.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 0.0f, 1.0f,
        0.0f, 1.0f, 1.0f, 1.0f,
        0.0f, 0.0f, 1.0f, 1.0f
    };
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 4);
    CGFloat locations[] = {0.0f, 0.5/3.0, 1/3.0, 1.5/3.0, 2/3.0, 2.5/3.0, 1.0};
    
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(colorSpaceRef, components, locations, count);
    
    CGContextDrawLinearGradient(context, gradientRef, startPoint, endPoint, kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorSpaceRef);
    CGGradientRelease(gradientRef);
    
    return image;

}

#pragma mark - UIButton_Pressed
- (void)widthSlider_Changed:(UISlider *)sender{
    
    self.drawView.lineWidth = sender.value;
}

- (void)colorSlider_Changed:(UISlider *)sender{

    UIColor *color;
    if(sender.value<1/3.0)
        color = [UIColor colorWithWhite:sender.value/0.3 alpha:1];
    else
        color = [UIColor colorWithHue:((sender.value-1/3.0)/0.7)*2/3.0 saturation:1 brightness:1 alpha:1];
    
    sender.thumbTintColor=color;
    
    self.drawView.lineColor = color;
}


- (IBAction)rubberBtn_Pressed:(id)sender {
    
    self.drawView.lineColor = [UIColor clearColor];
    
}

- (IBAction)revokeBtn_Pressed:(id)sender {
    
    [self.drawView revokeLastOperation];
}

- (IBAction)cleanBtn_Pressed:(id)sender {
    
    [self.drawView removeAll];
}

- (IBAction)completeBtn_Pressed:(id)sender {
  
   UIImage *image = [self groupImage:[self.drawView drawImage] with:self.imageView.image];
    
    [self.drawView removeFromSuperview];
    
    self.imageView.image = image;
}

- (UIImage*)groupImage:(UIImage*)imageOne with:(UIImage *)imageTwo
{

    UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, YES, [UIScreen mainScreen].scale);

    [imageTwo drawInRect:self.imageView.bounds];
    
    [imageOne drawInRect:self.imageView.bounds];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;

}


@end
