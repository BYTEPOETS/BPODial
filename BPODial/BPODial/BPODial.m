//
//  BPODial.m
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import "BPODial.h"
#import "BPOSliderCell.h"

#define CELL_SIZE 168.0f

@implementation BPODial

+ (Class)cellClass
{
    return [BPOSliderCell class];
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _setupCell];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _setupCell];
    }
    
    return self;
}


- (id)init
{
    self = [super init];
    if (self)
    {
        [self _setupCell];
    }
    
    return self;
}


- (void)_setupCell
{
    BPOSliderCell *cell = [[BPOSliderCell alloc] init];
    cell.minValue = self.minValue;
    cell.maxValue = self.maxValue;
    
    [self setFrame:CGRectMake(self.frame.origin.x - (CELL_SIZE / 2) + 16, self.frame.origin.y - (CELL_SIZE / 2) + 16, CELL_SIZE, CELL_SIZE)];
    self.cell = cell;
}


#pragma mark - Additional configuration properties 

- (void)setTickMarkRadius:(CGFloat)tickMarkRadius
{
    [self.cell setTickMarkRadius:tickMarkRadius];
}


- (CGFloat)tickMarkRadius
{
    return [self.cell tickMarkRadius];
}


- (void)setConcave:(BOOL)concave
{
    [self.cell setConcave:concave];
}


- (BOOL)concave
{
    return [self.cell concave];
}


- (void)setApertureInDegrees:(CGFloat)apertureInDegrees
{
    [self.cell setApertureInDegrees:apertureInDegrees];
}


- (CGFloat)apertureInDegrees
{
    return [self.cell apertureInDegrees];
}


- (void)setMinLabel:(NSString *)minLabel
{
    [self.cell setMinLabel:minLabel];
}


- (NSString *)minLabel
{
    return [self.cell minLabel];
}


- (void)setMaxLabel:(NSString *)maxLabel
{
    [self.cell setMaxLabel:maxLabel];
}


- (NSString *)maxLabel
{
    return [self.cell maxLabel];
}

@end
