//
//  SMCircularImageView.m
//  Remember The Date
//
//  Created by Mylene Bayan on 23/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import "SMCircularImageView.h"

@interface SMCircularImageView ()

@property (assign, nonatomic) BOOL didLayoutSubviews;

@end

@implementation SMCircularImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self commonInit];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(nullable UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.didLayoutSubviews = NO;
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
 
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.didLayoutSubviews) {
        self.didLayoutSubviews = YES;
        
        [self addMaskToBounds:self.frame];
    }
}

- (void)addMaskToBounds:(CGRect)bounds {
    CGPathRef maskPath = CGPathCreateWithEllipseInRect(bounds, nil);
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.bounds = bounds;
    maskLayer.path = maskPath;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    CGPoint point = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    maskLayer.position = point;
    
    self.layer.mask = maskLayer;
}

@end
