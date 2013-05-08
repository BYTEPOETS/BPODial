//
//  BPOSliderCell.h
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BPOSliderCell : NSSliderCell

@property (nonatomic, assign) CGFloat scaleInDegrees;
@property (nonatomic, assign) BOOL concave;

@end
