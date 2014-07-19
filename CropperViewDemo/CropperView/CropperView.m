//
//  CropperView.m
//  Cropper
//
//  Created by 최 중관 on 2014. 7. 18..
//  Copyright (c) 2014년 JoongKwan Choi. All rights reserved.
//

#import "CropperView.h"

#import "CropperCornerManager.h"

@interface CropperView()
{
    @private
    id<ICropperCornerManager> _cropperCornerManager;
}

@end

@implementation CropperView

- (void)_initialization
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    _contentColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    _cropperCornerManager = [[CropperCornerManager alloc] initWithView:self];
    
    // add GestureRecognizer
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

#pragma mark -
#pragma mark life-cycle
- (id)init
{
    if (self = [super init])
    {
        // Initialization code
        [self _initialization];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Initialization code
        [self _initialization];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        // Initialization code
        [self _initialization];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeAllCroppers];
}

/**
 코너 정보 세트 추가
 */
- (void)addCropper:(CGRect)cropper
{
    [_cropperCornerManager addCropper:cropper];
}

/**
 모든 코너 정보 제거
 */
- (void)removeAllCroppers
{
    [_cropperCornerManager removeAllCroppers];
}

- (CGRect)cropperCornerFrameFromIndex:(NSUInteger)index
{
    return [_cropperCornerManager cropperCornerFrameFromIndex:index];
}

- (NSUInteger)count
{
    return [_cropperCornerManager count];
}

#pragma mark -
#pragma mark UIGestureRecognizer
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)sender
{
    CGPoint point   = [sender locationInView:[sender view]];
    NSInteger index = [_cropperCornerManager cornerIndexFromCGPoint:point];
    
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        for (id<ICropperCorner> cropperCorner in [_cropperCornerManager cropperCornersWithCornerMode:CropperCornerModeAll index:index])
        {
            // frame 전체적으로 이동 준비
            [cropperCorner setBeganCenter];
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translate = [sender translationInView:[sender view]];
        for (id<ICropperCorner> cropperCorner in [_cropperCornerManager cropperCornersWithCornerMode:CropperCornerModeAll index:index])
        {
            // frame 전체적으로 이동
            [_cropperCornerManager cropperCorner:cropperCorner translate:translate cropperCornerMode:CropperCornerModeAll];
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Fill black
    CGContextSetFillColorWithColor(context, _contentColor.CGColor);
    
    for (NSUInteger i = 0; i < [_cropperCornerManager count]; i++)
    {
        CGRect frame = [_cropperCornerManager cropperCornerFrameFromIndex:i];
        CGContextAddRect(context, frame);
    };

    CGContextFillPath(context);
}

@end
