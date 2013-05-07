//
//  VectorMath.m
//  BPODial
//
//  Created by Martin Höller on 07.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import "VectorMath.h"
#include "math.h"


CGFloat vecLength(CGPoint a)
{
    return sqrtf(vecSquareLength(a));
}


CGFloat vecSquareLength(const CGPoint a)
{
	return vecDotProduct(a, a);
}


CGPoint vecMultiply(CGPoint a, CGFloat s)
{
    return CGPointMake(a.x * s, a.y * s);
}


CGPoint vecAdd(CGPoint a , CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}


CGPoint vecSub(CGPoint a , CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}


CGPoint vecNormalize(CGPoint a)
{
    return vecMultiply(a, 1.0f / vecLength(a));
}


CGFloat vecDotProduct(CGPoint a, CGPoint b)
{
    return a.x * b.x + a.y * b.y;
}


CGFloat vecAngle(CGPoint a, CGPoint b)
{
    CGPoint normalizedA = vecNormalize(a);
	CGPoint normalizedB = vecNormalize(b);
	CGFloat angle = atan2f(normalizedA.x * normalizedB.y - normalizedA.y * normalizedB.x, vecDotProduct(normalizedA, normalizedB));
	
    // floating point precicion check
    if (fabs(angle) < FLT_EPSILON)
    {
        return 0.0f;
    }
    
	return angle;
}


CGPoint vecRotateByAngle(CGPoint a, CGPoint pivot, CGFloat angle)
{
    CGPoint r = vecSub(a, pivot);
	CGFloat cosa = cosf(angle);
    CGFloat sina = sinf(angle);
	CGFloat t = r.x;
	r.x = t * cosa - r.y * sina + pivot.x;
	r.y = t * sina + r.y * cosa + pivot.y;
	return r;
}