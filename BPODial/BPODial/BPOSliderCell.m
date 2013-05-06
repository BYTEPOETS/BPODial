//
//  BPOSliderCell.m
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import "BPOSliderCell.h"
#import "NSAffineTransform+Rotation.h"

#define CELL_SIZE   168.0f

@implementation BPOSliderCell

- (NSSliderType)sliderType
{
    return NSCircularSlider;
}


- (CGSize)cellSizeForBounds:(NSRect)aRect
{
    return CGSizeMake(CELL_SIZE, CELL_SIZE);
}


- (CGRect)drawingRectForBounds:(NSRect)aRect
{
    return aRect;
}


- (NSRect)knobRectFlipped:(BOOL)flipped
{
    return CGRectMake(27.0f, 17.0f, 114.0f, 114.0f);
}


//- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
//{
//    [super drawWithFrame:cellFrame inView:controlView];
//}


//- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
//{
//    
//}


- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    // TODO: draw inset background
    [[NSColor yellowColor] setFill];
    NSRectFill(aRect);
}


//- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view
//{
//    
//}


//- (void)setFloatValue:(float)aFloat
//{
//    NSLog(@"new value: %f", aFloat);
//    [super setFloatValue:aFloat];
//    [self drawKnob];
//}


#define INDICATOR_BASE_WIDTH    20.0f
#define INDICATOR_HEIGHT        10.0f
#define TOTAL_DEGREES           116.0f

- (void)drawKnob:(NSRect)knobRect
{
    [[NSColor greenColor] setFill];
    NSFrameRect(knobRect);
    
    [[NSColor redColor] setFill];

    NSRect circleRect = NSMakeRect(knobRect.origin.x + 7.0f, knobRect.origin.y, 100.0f, 100.0f);
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:circleRect];
    NSBezierPath *indicatorPath = [self _indicatorPathForRect:circleRect];
    [circlePath appendBezierPath:indicatorPath];

    CGFloat normalizedMax = self.maxValue - self.minValue;
    CGFloat normalizedValue = self.floatValue - self.minValue;
    CGFloat percent = normalizedValue / normalizedMax;
    CGFloat degrees = TOTAL_DEGREES / 2.0f - TOTAL_DEGREES * percent;
    
    NSAffineTransform *rotation = [NSAffineTransform transformRotatingAroundPoint:NSMakePoint(NSMidX(circleRect), NSMidY(circleRect)) byDegrees:degrees];
    NSBezierPath *drawPath = [rotation transformBezierPath:circlePath];
    [drawPath fill];
}


- (NSBezierPath *)_indicatorPathForRect:(NSRect)circleRect
{
    CGFloat indicatorCenterX = circleRect.origin.x + circleRect.size.width / 2.0f;
    
    NSBezierPath *indicatorPath = [NSBezierPath bezierPath];
    indicatorPath.lineJoinStyle = NSBevelLineJoinStyle;
    [indicatorPath moveToPoint:NSMakePoint(indicatorCenterX - INDICATOR_BASE_WIDTH / 2.0f, NSMaxY(circleRect) - 2.0f)];
    [indicatorPath lineToPoint:NSMakePoint(indicatorCenterX + INDICATOR_BASE_WIDTH / 2.0f, NSMaxY(circleRect) - 2.0f)];
    
    NSPoint arcCenter = NSMakePoint(indicatorCenterX, NSMaxY(circleRect) + INDICATOR_HEIGHT - 2.0f);
    [indicatorPath appendBezierPathWithArcWithCenter:arcCenter
                                              radius:3.0f
                                          startAngle:45.0f
                                            endAngle:135.0f
                                           clockwise:NO];
    
    
    [indicatorPath closePath];
    
    return indicatorPath;
}


@end
