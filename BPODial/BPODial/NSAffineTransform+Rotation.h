//
//  NSAffineTransform+Rotation.h
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAffineTransform (Rotation)
+ (NSAffineTransform *)transformRotatingAroundPoint:(NSPoint)p byDegrees:(CGFloat)deg;
@end
