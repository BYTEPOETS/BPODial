//
//  NSAffineTransform+Rotation.m
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import "NSAffineTransform+Rotation.h"

@implementation NSAffineTransform (Rotation)

+ (NSAffineTransform *)transformRotatingAroundPoint:(NSPoint) p byDegrees:(CGFloat) deg
{
    NSAffineTransform * transform = [NSAffineTransform transform];
    [transform translateXBy: p.x yBy: p.y];
    [transform rotateByDegrees:deg];
    [transform translateXBy: -p.x yBy: -p.y];
    return transform;
}

@end
