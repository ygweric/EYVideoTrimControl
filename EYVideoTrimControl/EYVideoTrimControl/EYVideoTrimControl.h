//
//  EYVideoTrimControl.m
//  EYVideoTrimControl
//
//  Created by Eric Yang on 2015-04-17.
//  Copyright 2015 appcpu.com Productions. All rights reserved.
//
//

#import <Cocoa/Cocoa.h>



// Colors
#define kViewBorderColor [[NSColor blackColor] colorWithAlphaComponent: 0.56]

#define kGradientHeight 23.f
#define kViewXOffset 9.f

#define kTouchDeviationWidth 8.f
#define kMinMargin 3.f


// Gradient 'view'
#define kViewBorderWidth 1
#define kViewCornerRoundness 3



#define COLORRGBA(c,a) [NSColor colorWithCalibratedRed:(((c>>16)&0xFF)/255.0f) green:(((c>>8)&0xFF)/255.0f) blue:((c&0xFF)/255.0f) alpha:a]
#define COLORRGB(c)    [NSColor colorWithCalibratedRed:(((c>>16)&0xFF)/255.0f) green:(((c>>8)&0xFF)/255.0f) blue:((c&0xFF)/255.0f) alpha:1]


// -----------

@interface EYVideoTrimControl : NSView {
   
}


@property (nonatomic) float beginRatio;//percent 0.5
@property (nonatomic) float endRatio;
@property (nonatomic) float nowRatio;//playing now

@property (strong) IBOutlet id target;

@property (assign) SEL actionBegin;
@property (assign) SEL actionEnd;
@property (assign) SEL actionNow;




@property (assign) CGFloat gradientHeight;

@property (assign) BOOL editable;
@property (assign) BOOL drawsChessboardBackground;

// Not that much functions actually:

// -- only these two everyone knows
- (id)initWithFrame: (NSRect)frame;
- (void)drawRect: (NSRect)dirtyRect;

@end
