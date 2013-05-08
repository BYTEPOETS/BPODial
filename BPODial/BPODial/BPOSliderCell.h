//
//  BPOSliderCell.h
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPOSliderCell : NSSliderCell

// The available aperture in degrees. Acceptable range is 25° to 180°
@property (nonatomic, assign) CGFloat apertureInDegrees;

// defines how big the tick marks are
@property (nonatomic, assign) CGFloat tickMarkRadius;

// defines the visual style of the knob
@property (nonatomic, assign) BOOL concave;

@end
