//
//  VectorMath.h
//  BPODial
//
//  Created by Martin Höller on 07.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

// returns the length of a vector
CGFloat vecLength(CGPoint a);

// returns the square length of a vector
CGFloat vecSquareLength(const CGPoint a);

// multiplies a vector by a scalar factor
CGPoint vecMultiply(CGPoint a, CGFloat s);

// adds a to b
CGPoint vecAdd(CGPoint a , CGPoint b);

// subtracts b from a
CGPoint vecSub(CGPoint a , CGPoint b);

// normalizes a vector to length 1
CGPoint vecNormalize(CGPoint a);

// calculates the dot product between two vectors
CGFloat vecDotProduct(CGPoint a, CGPoint b);

// angle in radians between two vectors
CGFloat vecAngle(CGPoint a, CGPoint b);

// rotates a point around a pivot point
// @param a the point to rotate
// @param pivot the pivot point around a is rotated
// @param angle the angle (in radians) which a is rotated by
CGPoint vecRotateByAngle(CGPoint a, CGPoint pivot, CGFloat angle);

