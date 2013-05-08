//
//  NSAffineTransform+Rotation.m
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import "NSAffineTransform+Rotation.h"

@implementation NSAffineTransform (Rotation)

+ (NSAffineTransform *)transformRotatingAroundPoint:(NSPoint)point byDegrees:(CGFloat)angle
{
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:point.x yBy:point.y];
    [transform rotateByDegrees:angle];
    [transform translateXBy:-point.x yBy:-point.y];
    return transform;
}

@end
