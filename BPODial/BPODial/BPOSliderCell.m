//
//  BPOSliderCell.m
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import "BPOSliderCell.h"
#import "NSAffineTransform+Rotation.h"
#import "VectorMath.h"


#define CELL_SIZE               168.0f
#define INDICATOR_BASE_WIDTH    20.0f
#define INDICATOR_HEIGHT        10.0f
#define KNOB_BASE_RADIUS        50.0f
#define TICK_MARK_DISTANCE      KNOB_BASE_RADIUS + 20.0f
#define TICK_MARK_RADIUS        3.0f

@interface BPOSliderCell ()
{
    CGPoint tLastPoint;
    CGPoint tLastPointOnCircle;
    CGFloat tAngle;
    CGFloat tPercentage;
}
@end


@implementation BPOSliderCell

- (id)init
{
    self = [super init];
    if (self)
    {
        [self _setup];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self _setup];
    }
    return self;
}


- (void)_setup
{
    self.scaleInDegrees = 116.0f;
    self.numberOfTickMarks = 9;
}


- (NSSliderType)sliderType
{
    return NSCircularSlider;
}


#pragma mark - Geometry configuration

- (CGSize)cellSizeForBounds:(NSRect)aRect
{
    return CGSizeMake(CELL_SIZE, CELL_SIZE);
}


- (NSRect)drawingRectForBounds:(NSRect)aRect
{
    return aRect;
}


- (NSRect)knobRectFlipped:(BOOL)flipped
{
    return CGRectMake(27.0f, 17.0f, 114.0f, 114.0f);
}


- (NSRect)trackRect
{
    return [self knobRectFlipped:self.controlView.isFlipped];
}


- (NSRect)circleRectForKnobRect:(NSRect)knobRect
{
    return NSMakeRect(knobRect.origin.x + 7.0f, knobRect.origin.y, KNOB_BASE_RADIUS * 2, KNOB_BASE_RADIUS * 2);
}

#pragma mark - Drawing

//- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
//{
//    [super drawWithFrame:cellFrame inView:controlView];
//}


//- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
//{
//    [super drawInteriorWithFrame:cellFrame inView:controlView];
//}


- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    [NSGraphicsContext saveGraphicsState];
    
    // TODO: draw inset background
    [[NSColor lightGrayColor] setFill];
    NSRectFill(aRect);
    
    [self _drawTickMarksInRect:aRect];
    
    [NSGraphicsContext restoreGraphicsState];
}


- (void)_drawTickMarksInRect:(NSRect)rect
{
    // calculate angle for tickmarks
    CGFloat maxAngle = 90.0f + self.scaleInDegrees / 2.0f;
    CGFloat minAngle = 90.0f - self.scaleInDegrees / 2.0f;
    CGFloat tickMarkAngle = self.scaleInDegrees / (self.numberOfTickMarks - 1);
    
    NSRect circleRect = [self circleRectForKnobRect:[self knobRectFlipped:self.controlView.isFlipped]];
    CGPoint center = CGPointMake(NSMidX(circleRect), NSMidY(circleRect));
    CGPoint edgePoint = CGPointMake(TICK_MARK_DISTANCE, 0.0f);
    
    for (NSInteger count = 0; count < self.numberOfTickMarks; count++)
    {
        CGFloat angle = maxAngle - count * tickMarkAngle;
        CGPoint tickMarkPoint = vecAdd(vecRotateByAngle(edgePoint, NSZeroPoint, DEGREES_TO_RADIANS(angle)), center);
        
        CGFloat percentage = [self percentageOfAngle:(angle - minAngle)];
        BOOL filled = percentage <= [self _currentPercentage];
        
        [self _drawTickMarkAtPoint:tickMarkPoint filled:filled];
    }
}


- (void)_drawTickMarkAtPoint:(CGPoint)point filled:(BOOL)filled
{
    NSRect rect = NSMakeRect(point.x - TICK_MARK_RADIUS, point.y - TICK_MARK_RADIUS, TICK_MARK_RADIUS * 2.0f, TICK_MARK_RADIUS * 2.0f);
    
    if (filled)
    {
        [[NSColor cyanColor] setFill];
    }
    else
    {
        [[NSColor darkGrayColor] setFill];
    }
    
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
    [path fill];
}


- (CGFloat)_currentPercentage
{
    CGFloat normalizedMax = self.maxValue - self.minValue;
    CGFloat normalizedValue = self.floatValue - self.minValue;
    return normalizedValue / normalizedMax;
    
}


- (void)drawKnob:(NSRect)knobRect
{
    [NSGraphicsContext saveGraphicsState];
    
    [[NSColor redColor] setFill];
    
    NSRect circleRect = [self circleRectForKnobRect:knobRect];
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:circleRect];
    NSBezierPath *indicatorPath = [self _indicatorPathForRect:circleRect];
    [circlePath appendBezierPath:indicatorPath];
    
    CGFloat degrees = self.scaleInDegrees / 2.0f - self.scaleInDegrees * [self _currentPercentage];
    
    NSAffineTransform *rotation = [NSAffineTransform transformRotatingAroundPoint:NSMakePoint(NSMidX(circleRect), NSMidY(circleRect)) byDegrees:degrees];
    NSBezierPath *drawPath = [rotation transformBezierPath:circlePath];
    [drawPath fill];
    
    
    // --- DEBUG DRAWING ---
    //    [[NSColor greenColor] setFill];
    //    NSFrameRect(knobRect);
    //
    //    [[NSColor greenColor] setFill];
    //    NSRect rect = NSMakeRect(tLastPoint.x - 3, tLastPoint.y-3, 6, 6);
    //    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:rect];
    //    [path fill];
    //
    //    [[NSColor blueColor] setFill];
    //    rect = NSMakeRect(tLastPointOnCircle.x - 3, tLastPointOnCircle.y-3, 6, 6);
    //    path = [NSBezierPath bezierPathWithOvalInRect:rect];
    //    [path fill];
    //
    //    NSString *valuesStr = [NSString stringWithFormat:@"%0.2f%%\n%0.2f°", tPercentage * 100, RADIANS_TO_DEGREES(tAngle)];
    //    [valuesStr drawAtPoint:NSMakePoint(NSMidX(knobRect), NSMidY(knobRect)) withAttributes:nil];
    // ---
    
    [NSGraphicsContext restoreGraphicsState];
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


#pragma mark - Tracking

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
    // calculate delta angle between lastPoint and currentPoint
    CGPoint currentPointOnCircle = [self pointOnCircleForPoint:currentPoint];
    
    CGFloat percentage = [self percentageOfPoint:currentPointOnCircle];
    self.integerValue = roundf((self.maxValue - self.minValue) * percentage) + self.minValue;
    
    [self.controlView setNeedsDisplay:YES];
    
    // --- DEBUG INFO
    tLastPointOnCircle = currentPointOnCircle;
    tLastPoint = currentPoint;
    tAngle = [self angleOfPoint:currentPointOnCircle];
    tPercentage = percentage;
    // ---
    
    return YES;
}

#pragma mark - Geometry helpers

- (CGFloat)percentageOfAngle:(CGFloat)angle
{
    return 1.0f - angle / self.scaleInDegrees;
}


- (CGFloat)percentageOfPoint:(CGPoint)point
{
    CGFloat angle = RADIANS_TO_DEGREES([self angleOfPoint:point]);
    
    // valid range: 32° - 148°
    
    CGFloat minAngle = 90.0f - self.scaleInDegrees / 2.0f;
    CGFloat maxAngle = 90.0f + self.scaleInDegrees / 2.0f;
    
    CGFloat resultAngle = 0.0f;
    
    if (angle < -90.0f
        && angle >= -180.0f) // top left quadrant
    {
        resultAngle = maxAngle;
    }
    else if (angle < 0.0f
             && angle >= -90.0f)    // top right quadrant
    {
        resultAngle = minAngle;
    }
    else
    {
        if (angle < minAngle)
        {
            resultAngle = minAngle;
        }
        else if (angle > maxAngle)
        {
            resultAngle = maxAngle;
        }
        else
        {
            resultAngle = angle;
        }
    }
    
    resultAngle = resultAngle - minAngle;
    return [self percentageOfAngle:resultAngle];
}


- (CGFloat)angleOfPoint:(CGPoint)point withCenter:(CGPoint)center
{
    // calculate angle between x-Axis and point
    CGPoint edgePoint = CGPointMake(KNOB_BASE_RADIUS, 0.0f);
    CGPoint translatedPoint = vecSub(point, center);
    return vecAngle(edgePoint, translatedPoint);
}


- (CGFloat)angleOfPoint:(CGPoint)point
{
    NSRect circleRect = [self circleRectForKnobRect:[self knobRectFlipped:self.controlView.isFlipped]];
    CGPoint center = CGPointMake(NSMidX(circleRect), NSMidY(circleRect));
    return [self angleOfPoint:point withCenter:center];
}


- (NSPoint)pointOnCircleForPoint:(NSPoint)point
{
    NSRect circleRect = [self circleRectForKnobRect:[self knobRectFlipped:self.controlView.isFlipped]];
    CGPoint center = CGPointMake(NSMidX(circleRect), NSMidY(circleRect));
    
    CGFloat angle = [self angleOfPoint:point withCenter:center];
    CGPoint edgePoint = CGPointMake(KNOB_BASE_RADIUS, 0.0f);
    
    // rotate a point on the x-Axis on the edge of the circle by the calculated angle
    return vecAdd(vecRotateByAngle(edgePoint, NSZeroPoint, angle), center);
}


@end
