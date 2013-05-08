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
#define KNOB_BASE_RADIUS        50.0f
#define TICK_MARK_DISTANCE      KNOB_BASE_RADIUS + 25.0f

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
    self.apertureInDegrees = 116.0f;
    self.concave = NO;
    self.tickMarkRadius = 3.0f;
    self.numberOfTickMarks = 5;
}


- (NSSliderType)sliderType
{
    return NSCircularSlider;
}


- (void)setScaleInDegrees:(CGFloat)apertureInDegrees
{
    if (apertureInDegrees > 180.0f)
    {
        apertureInDegrees = 180.0f;
    }
    
    if (apertureInDegrees < 25.0f)
    {
        apertureInDegrees = 25.0f;
    }
    
    _apertureInDegrees = apertureInDegrees;
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
    return CGRectMake((CELL_SIZE - 114.0f) / 2.0, (CELL_SIZE - 114.0f) / 2.0 - 10.0f, 114.0f, 114.0f);
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

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    [NSGraphicsContext saveGraphicsState];
    
    [self _drawBackground];
    [self _drawTickMarksInRect:aRect];
    
    [NSGraphicsContext restoreGraphicsState];
}


- (void)_drawBackground
{
    NSRect rect = NSMakeRect(0.0f, 0.0f, CELL_SIZE, CELL_SIZE);
    //// General Declarations
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    //// Color Declarations
    NSColor* fillColor = [NSColor colorWithCalibratedRed: 0.802 green: 0.802 blue: 0.802 alpha: 1];
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0.84 green: 0.84 blue: 0.84 alpha: 1];
    NSColor* shadowColor2 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.295];
    NSColor* shadowColor3 = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.3];
    NSColor* color3 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.295];
    
    //// Gradient Declarations
    NSGradient* gradient = [[NSGradient alloc] initWithStartingColor: strokeColor endingColor: fillColor];
    
    //// Shadow Declarations
    NSShadow* outerShadow = [[NSShadow alloc] init];
    [outerShadow setShadowColor: shadowColor2];
    [outerShadow setShadowOffset: NSMakeSize(1.1, -1.1)];
    [outerShadow setShadowBlurRadius: 1];
    NSShadow* innerShadow = [[NSShadow alloc] init];
    [innerShadow setShadowColor: shadowColor3];
    [innerShadow setShadowOffset: NSMakeSize(0.1, -1.1)];
    [innerShadow setShadowBlurRadius: 3];
    
    //// Oval Drawing
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect:rect];
    [NSGraphicsContext saveGraphicsState];
    [outerShadow set];
    CGContextBeginTransparencyLayer(context, NULL);
    [gradient drawInBezierPath: ovalPath angle: -90];
    CGContextEndTransparencyLayer(context);
    
    ////// Oval Inner Shadow
    NSRect ovalBorderRect = NSInsetRect([ovalPath bounds], -innerShadow.shadowBlurRadius, -innerShadow.shadowBlurRadius);
    ovalBorderRect = NSOffsetRect(ovalBorderRect, -innerShadow.shadowOffset.width, -innerShadow.shadowOffset.height);
    ovalBorderRect = NSInsetRect(NSUnionRect(ovalBorderRect, [ovalPath bounds]), -1, -1);
    
    NSBezierPath* ovalNegativePath = [NSBezierPath bezierPathWithRect: ovalBorderRect];
    [ovalNegativePath appendBezierPath: ovalPath];
    [ovalNegativePath setWindingRule: NSEvenOddWindingRule];
    
    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow* innerShadowWithOffset = [innerShadow copy];
        CGFloat xOffset = innerShadowWithOffset.shadowOffset.width + round(ovalBorderRect.size.width);
        CGFloat yOffset = innerShadowWithOffset.shadowOffset.height;
        innerShadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [innerShadowWithOffset set];
        [[NSColor grayColor] setFill];
        [ovalPath addClip];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform translateXBy: -round(ovalBorderRect.size.width) yBy: 0];
        [[transform transformBezierPath: ovalNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    [NSGraphicsContext restoreGraphicsState];
    
    [color3 setStroke];
    [ovalPath setLineWidth: 1];
    [ovalPath stroke];
}


- (void)_drawTickMarksInRect:(NSRect)rect
{
    // calculate angle for tickmarks
    CGFloat maxAngle = 90.0f + self.apertureInDegrees / 2.0f;
    CGFloat minAngle = 90.0f - self.apertureInDegrees / 2.0f;
    CGFloat tickMarkAngle = self.apertureInDegrees / (self.numberOfTickMarks - 1);
    
    NSRect circleRect = [self circleRectForKnobRect:[self knobRectFlipped:self.controlView.isFlipped]];
    CGPoint center = CGPointMake(NSMidX(circleRect), NSMidY(circleRect) + 5.0f);
    CGPoint edgePoint = CGPointMake(TICK_MARK_DISTANCE, 0.0f);
    
    for (NSInteger count = 0; count < self.numberOfTickMarks; count++)
    {
        CGFloat angle = maxAngle - count * tickMarkAngle;
        CGPoint tickMarkPoint = vecAdd(vecRotateByAngle(edgePoint, NSZeroPoint, DEGREES_TO_RADIANS(angle)), center);
        
        CGFloat percentage = [self percentageOfAngle:(angle - minAngle)];
        BOOL filled = percentage <= [self _currentPercentage];
        
        [self _drawTickMarkAtPoint:tickMarkPoint filled:filled];
        
        if (count == 0)
        {
            [self _drawLabelForTickMarkAtPoint:tickMarkPoint withtText:@"min"];
        }
        
        if (count == self.numberOfTickMarks - 1)
        {
            [self _drawLabelForTickMarkAtPoint:tickMarkPoint withtText:@"max"];
        }
    }
}


- (void)_drawTickMarkAtPoint:(CGPoint)point filled:(BOOL)filled
{
    NSRect rect = NSMakeRect(point.x - self.tickMarkRadius, point.y - self.tickMarkRadius, self.tickMarkRadius * 2.0f, self.tickMarkRadius * 2.0f);

    //// Color Declarations
    NSColor* fillColor = nil;
    if (filled)
    {
        fillColor = [NSColor colorWithCalibratedRed: 0.086 green: 0.761 blue: 1 alpha: 1];
    }
    else
    {
        fillColor = [NSColor colorWithCalibratedWhite: 0.510 alpha: 1];
    }

    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.158];
    NSColor* shadowColor2 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: strokeColor];
    [shadow setShadowOffset: NSMakeSize(1.1, -1.1)];
    [shadow setShadowBlurRadius: 1];
    NSShadow* shadow2 = [[NSShadow alloc] init];
    [shadow2 setShadowColor: shadowColor2];
    [shadow2 setShadowOffset: NSMakeSize(1.1, -1.1)];
    [shadow2 setShadowBlurRadius: 1];
    
    //// Oval Drawing
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect: rect];
    [NSGraphicsContext saveGraphicsState];
    [shadow2 set];
    [fillColor setFill];
    [ovalPath fill];
    
    ////// Oval Inner Shadow
    NSRect ovalBorderRect = NSInsetRect([ovalPath bounds], -shadow.shadowBlurRadius, -shadow.shadowBlurRadius);
    ovalBorderRect = NSOffsetRect(ovalBorderRect, -shadow.shadowOffset.width, -shadow.shadowOffset.height);
    ovalBorderRect = NSInsetRect(NSUnionRect(ovalBorderRect, [ovalPath bounds]), -1, -1);
    
    NSBezierPath* ovalNegativePath = [NSBezierPath bezierPathWithRect: ovalBorderRect];
    [ovalNegativePath appendBezierPath: ovalPath];
    [ovalNegativePath setWindingRule: NSEvenOddWindingRule];
    
    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow* shadowWithOffset = [shadow copy];
        CGFloat xOffset = shadowWithOffset.shadowOffset.width + round(ovalBorderRect.size.width);
        CGFloat yOffset = shadowWithOffset.shadowOffset.height;
        shadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [shadowWithOffset set];
        [[NSColor grayColor] setFill];
        [ovalPath addClip];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform translateXBy: -round(ovalBorderRect.size.width) yBy: 0];
        [[transform transformBezierPath: ovalNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    [NSGraphicsContext restoreGraphicsState];
}


- (void)_drawLabelForTickMarkAtPoint:(CGPoint)point withtText:(NSString *)text
{
    //// Color Declarations
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0.302 green: 0.302 blue: 0.302 alpha: 1];
    NSColor* shadowColor2 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.808];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: shadowColor2];
    [shadow setShadowOffset: NSMakeSize(0.1, -1.1)];
    [shadow setShadowBlurRadius: 0];
    
    //// Abstracted Attributes
    NSFont* font = [NSFont fontWithName: @"HelveticaNeue-Medium" size: 11];
    
    
    //// Drawing
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment: NSCenterTextAlignment];
    
    NSDictionary* fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       font, NSFontAttributeName,
                                       strokeColor, NSForegroundColorAttributeName,
                                       style, NSParagraphStyleAttributeName, nil];
    
    
    CGSize size = [text sizeWithAttributes:fontAttributes];
    CGPoint drawPoint = CGPointMake(point.x - size.width / 2.0f, point.y - size.height - 10.0f);
    [text drawAtPoint:drawPoint withAttributes:fontAttributes];
    [NSGraphicsContext restoreGraphicsState];
}


- (CGFloat)_currentPercentage
{
    CGFloat normalizedMax = self.maxValue - self.minValue;
    CGFloat normalizedValue = self.floatValue - self.minValue;
    return normalizedValue / normalizedMax;
    
}


- (void)drawKnob:(NSRect)knobRect
{
    NSRect circleRect = [self circleRectForKnobRect:knobRect];
    CGFloat degrees = self.apertureInDegrees / 2.0f - self.apertureInDegrees * [self _currentPercentage];
    NSAffineTransform *rotation = [NSAffineTransform transformRotatingAroundPoint:NSMakePoint(NSMidX(circleRect), NSMidY(circleRect)) byDegrees:degrees];
    NSAffineTransform *translation = [NSAffineTransform transform];
    [translation translateXBy:circleRect.origin.x yBy:circleRect.origin.y];

    
    //// General Declarations
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    //// Color Declarations
    NSColor* fillColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0.4];
    NSColor* shadowColor2 = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.1];
    NSColor* color = [NSColor colorWithCalibratedRed: 0.837 green: 0.837 blue: 0.837 alpha: 1];
    NSColor* shadowColor4 = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.1];
    NSColor* strokeColor2 = [NSColor colorWithCalibratedRed: 0.597 green: 0.597 blue: 0.597 alpha: 1];

    //// Gradient Declarations
    NSGradient* fill = [[NSGradient alloc] initWithStartingColor: color endingColor: fillColor];
    NSGradient* strokeGradient = [[NSGradient alloc] initWithStartingColor: fillColor endingColor: strokeColor2];
    
    //// Shadow Declarations
    NSShadow* innerShadow = [[NSShadow alloc] init];
    [innerShadow setShadowColor: shadowColor2];
    [innerShadow setShadowOffset: NSMakeSize(-2.1, 4.1)];
    [innerShadow setShadowBlurRadius: 1];
    NSShadow* dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor: shadowColor4];
    [dropShadow setShadowOffset: NSMakeSize(3.1, -3.1)];
    [dropShadow setShadowBlurRadius: 19];

    
    //// Bezier Drawing
    NSBezierPath* bezierPath = [self _knobPath];
    bezierPath = [translation transformBezierPath:bezierPath];
    bezierPath = [rotation transformBezierPath:bezierPath];
    
    [NSGraphicsContext saveGraphicsState];
    [dropShadow set];
    
    CGFloat angle = 121.0f;
    if (self.concave)
    {
        angle = -76.0f;
    }
    
    CGContextBeginTransparencyLayer(context, NULL);
    [fill drawInBezierPath: bezierPath angle: angle];
    CGContextEndTransparencyLayer(context);

    

    [fill drawInBezierPath: bezierPath angle: -angle];
    
    ////// Bezier Inner Shadow
    NSRect bezierBorderRect = NSInsetRect([bezierPath bounds], -innerShadow.shadowBlurRadius, -innerShadow.shadowBlurRadius);
    bezierBorderRect = NSOffsetRect(bezierBorderRect, -innerShadow.shadowOffset.width, -innerShadow.shadowOffset.height);
    bezierBorderRect = NSInsetRect(NSUnionRect(bezierBorderRect, [bezierPath bounds]), -1, -1);
    bezierBorderRect.size.height += 20;
    
    NSBezierPath* bezierNegativePath = [NSBezierPath bezierPathWithRect: bezierBorderRect];
    [bezierNegativePath appendBezierPath: bezierPath];
    [bezierNegativePath setWindingRule: NSEvenOddWindingRule];
    
    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow* innerShadowWithOffset = [innerShadow copy];
        CGFloat xOffset = innerShadowWithOffset.shadowOffset.width + round(bezierBorderRect.size.width);
        CGFloat yOffset = innerShadowWithOffset.shadowOffset.height;
        innerShadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [innerShadowWithOffset set];
        [[NSColor grayColor] setFill];
        [bezierPath addClip];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform translateXBy: -round(bezierBorderRect.size.width) yBy: 0];
        [[transform transformBezierPath: bezierNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    [strokeColor setStroke];
    [bezierPath setLineWidth: 1];
    [bezierPath stroke];

    
    NSBezierPath *strokeBezierPath = [self _strokePath];
    strokeBezierPath = [translation transformBezierPath:strokeBezierPath];
    strokeBezierPath = [rotation transformBezierPath:strokeBezierPath];
    [strokeGradient drawInBezierPath: strokeBezierPath angle: 66];
    
        
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
}


- (NSBezierPath *)_knobPath
{
    NSBezierPath* bezierPath = [NSBezierPath bezierPath];
    [bezierPath moveToPoint: NSMakePoint(85.36, 14.64)];
    [bezierPath curveToPoint: NSMakePoint(85.36, 85.36) controlPoint1: NSMakePoint(104.88, 34.17) controlPoint2: NSMakePoint(104.88, 65.83)];
    [bezierPath curveToPoint: NSMakePoint(55.79, 99.67) controlPoint1: NSMakePoint(77.07, 93.64) controlPoint2: NSMakePoint(66.6, 98.41)];
    [bezierPath curveToPoint: NSMakePoint(50.5, 107) controlPoint1: NSMakePoint(55.79, 99.67) controlPoint2: NSMakePoint(52.14, 107.03)];
    [bezierPath curveToPoint: NSMakePoint(45.29, 99.78) controlPoint1: NSMakePoint(48.86, 106.97) controlPoint2: NSMakePoint(45.29, 99.78)];
    [bezierPath curveToPoint: NSMakePoint(14.64, 85.36) controlPoint1: NSMakePoint(34.1, 98.73) controlPoint2: NSMakePoint(23.21, 93.92)];
    [bezierPath curveToPoint: NSMakePoint(14.64, 14.64) controlPoint1: NSMakePoint(-4.88, 65.83) controlPoint2: NSMakePoint(-4.88, 34.17)];
    [bezierPath curveToPoint: NSMakePoint(85.36, 14.64) controlPoint1: NSMakePoint(34.17, -4.88) controlPoint2: NSMakePoint(65.83, -4.88)];
    [bezierPath closePath];
    [bezierPath setLineCapStyle: NSRoundLineCapStyle];
    [bezierPath setLineJoinStyle: NSBevelLineJoinStyle];
    return bezierPath;
}


- (NSBezierPath *)_strokePath
{
    //// Stroke Bezier Drawing
    NSBezierPath* strokeBezierPath = [NSBezierPath bezierPath];
    [strokeBezierPath moveToPoint: NSMakePoint(86.77, 13.21)];
    [strokeBezierPath curveToPoint: NSMakePoint(86.77, 86.66) controlPoint1: NSMakePoint(107.08, 33.49) controlPoint2: NSMakePoint(107.08, 66.38)];
    [strokeBezierPath curveToPoint: NSMakePoint(56.02, 101.52) controlPoint1: NSMakePoint(78.37, 95.05) controlPoint2: NSMakePoint(67.58, 100.19)];
    [strokeBezierPath lineToPoint: NSMakePoint(56.82, 100.97)];
    [strokeBezierPath curveToPoint: NSMakePoint(56.55, 101.5) controlPoint1: NSMakePoint(56.77, 101.07) controlPoint2: NSMakePoint(56.68, 101.25)];
    [strokeBezierPath curveToPoint: NSMakePoint(55.83, 102.83) controlPoint1: NSMakePoint(56.33, 101.92) controlPoint2: NSMakePoint(56.09, 102.37)];
    [strokeBezierPath curveToPoint: NSMakePoint(53.65, 106.41) controlPoint1: NSMakePoint(55.09, 104.18) controlPoint2: NSMakePoint(54.35, 105.41)];
    [strokeBezierPath curveToPoint: NSMakePoint(50.49, 109) controlPoint1: NSMakePoint(52.45, 108.12) controlPoint2: NSMakePoint(51.54, 109.02)];
    [strokeBezierPath curveToPoint: NSMakePoint(47.43, 106.47) controlPoint1: NSMakePoint(49.48, 108.98) controlPoint2: NSMakePoint(48.58, 108.1)];
    [strokeBezierPath curveToPoint: NSMakePoint(45.26, 102.93) controlPoint1: NSMakePoint(46.73, 105.48) controlPoint2: NSMakePoint(46, 104.26)];
    [strokeBezierPath curveToPoint: NSMakePoint(44.55, 101.61) controlPoint1: NSMakePoint(45.01, 102.47) controlPoint2: NSMakePoint(44.77, 102.02)];
    [strokeBezierPath curveToPoint: NSMakePoint(44.28, 101.08) controlPoint1: NSMakePoint(44.43, 101.36) controlPoint2: NSMakePoint(44.33, 101.18)];
    [strokeBezierPath lineToPoint: NSMakePoint(45.1, 101.64)];
    [strokeBezierPath curveToPoint: NSMakePoint(13.23, 86.66) controlPoint1: NSMakePoint(33.14, 100.52) controlPoint2: NSMakePoint(21.91, 95.33)];
    [strokeBezierPath curveToPoint: NSMakePoint(13.23, 13.21) controlPoint1: NSMakePoint(-7.08, 66.38) controlPoint2: NSMakePoint(-7.08, 33.49)];
    [strokeBezierPath curveToPoint: NSMakePoint(86.77, 13.21) controlPoint1: NSMakePoint(33.54, -7.07) controlPoint2: NSMakePoint(66.46, -7.07)];
    [strokeBezierPath closePath];
    [strokeBezierPath moveToPoint: NSMakePoint(85.33, 14.65)];
    [strokeBezierPath curveToPoint: NSMakePoint(14.67, 14.65) controlPoint1: NSMakePoint(65.82, -4.83) controlPoint2: NSMakePoint(34.18, -4.83)];
    [strokeBezierPath curveToPoint: NSMakePoint(14.67, 85.22) controlPoint1: NSMakePoint(-4.84, 34.14) controlPoint2: NSMakePoint(-4.84, 65.73)];
    [strokeBezierPath curveToPoint: NSMakePoint(45.29, 99.61) controlPoint1: NSMakePoint(23.01, 93.55) controlPoint2: NSMakePoint(33.8, 98.53)];
    [strokeBezierPath lineToPoint: NSMakePoint(46.11, 100.17)];
    [strokeBezierPath curveToPoint: NSMakePoint(46.36, 100.67) controlPoint1: NSMakePoint(46.15, 100.27) controlPoint2: NSMakePoint(46.24, 100.44)];
    [strokeBezierPath curveToPoint: NSMakePoint(47.05, 101.95) controlPoint1: NSMakePoint(46.57, 101.07) controlPoint2: NSMakePoint(46.8, 101.5)];
    [strokeBezierPath curveToPoint: NSMakePoint(49.09, 105.29) controlPoint1: NSMakePoint(47.75, 103.22) controlPoint2: NSMakePoint(48.45, 104.38)];
    [strokeBezierPath curveToPoint: NSMakePoint(50.53, 106.96) controlPoint1: NSMakePoint(49.83, 106.33) controlPoint2: NSMakePoint(50.47, 106.96)];
    [strokeBezierPath curveToPoint: NSMakePoint(51.98, 105.24) controlPoint1: NSMakePoint(50.57, 106.96) controlPoint2: NSMakePoint(51.23, 106.32)];
    [strokeBezierPath curveToPoint: NSMakePoint(54.05, 101.85) controlPoint1: NSMakePoint(52.63, 104.31) controlPoint2: NSMakePoint(53.34, 103.14)];
    [strokeBezierPath curveToPoint: NSMakePoint(54.74, 100.56) controlPoint1: NSMakePoint(54.3, 101.4) controlPoint2: NSMakePoint(54.53, 100.96)];
    [strokeBezierPath curveToPoint: NSMakePoint(54.99, 100.06) controlPoint1: NSMakePoint(54.86, 100.32) controlPoint2: NSMakePoint(54.95, 100.15)];
    [strokeBezierPath lineToPoint: NSMakePoint(55.79, 99.5)];
    [strokeBezierPath curveToPoint: NSMakePoint(85.33, 85.22) controlPoint1: NSMakePoint(66.89, 98.21) controlPoint2: NSMakePoint(77.26, 93.28)];
    [strokeBezierPath curveToPoint: NSMakePoint(85.33, 14.65) controlPoint1: NSMakePoint(104.84, 65.73) controlPoint2: NSMakePoint(104.84, 34.14)];
    [strokeBezierPath closePath];

    return strokeBezierPath;
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
//    tLastPointOnCircle = currentPointOnCircle;
//    tLastPoint = currentPoint;
//    tAngle = [self angleOfPoint:currentPointOnCircle];
//    tPercentage = percentage;
    // ---
    
    return YES;
}


#pragma mark - Geometry helpers

- (CGFloat)percentageOfAngle:(CGFloat)angle
{
    return 1.0f - angle / self.apertureInDegrees;
}


- (CGFloat)percentageOfPoint:(CGPoint)point
{
    CGFloat angle = RADIANS_TO_DEGREES([self angleOfPoint:point]);
    
    CGFloat minAngle = 90.0f - self.apertureInDegrees / 2.0f;
    CGFloat maxAngle = 90.0f + self.apertureInDegrees / 2.0f;
    
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
