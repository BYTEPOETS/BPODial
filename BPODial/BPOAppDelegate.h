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

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet BPODial *dial;
@property (weak) IBOutlet NSTextField *label;


- (IBAction)valueChanged:(NSSlider *)sender;

@end
