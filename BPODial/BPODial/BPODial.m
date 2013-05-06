//
//  BPODial.m
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import "BPODial.h"
#import "BPOSliderCell.h"

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
    
    self.cell = cell;

}


@end
