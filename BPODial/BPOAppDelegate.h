//
//  BPOAppDelegate.h
//  BPODial
//
//  Created by Martin Höller on 06.05.13.
//  Copyright (c) 2013 BYTEPOETS GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BPODial;

@interface BPOAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet BPODial *dial;
@property (weak) IBOutlet NSTextField *label;

@property (weak) IBOutlet NSSlider *testSlider;

- (IBAction)valueChanged:(NSSlider *)sender;

@end
