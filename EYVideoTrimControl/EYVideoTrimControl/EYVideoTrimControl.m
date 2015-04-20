//
//  EYVideoTrimControl.m
//  EYVideoTrimControl
//
//  Created by Eric Yang on 2015-04-17.
//  Copyright 2015 appcpu.com Productions. All rights reserved.
//

typedef enum : int {
    DRAG_NONE=0,
    DRAG_BEGIN,
    DRAG_END,
    DRAG_NOW,
} DRAG_TYPE;



#import "EYVideoTrimControl.h"

@interface EYVideoTrimControl()


@property (nonatomic) DRAG_TYPE dragType;



- (NSRect)_gradientBounds;
- (NSRect)_trimBounds;
- (NSPoint)_viewPointFromGradientLocation: (CGFloat)location;
- (CGFloat)_gradientLocationFromViewPoint: (NSPoint)point;
@end

// ------------

@implementation EYVideoTrimControl

@synthesize target, actionBegin,actionEnd,actionNow , gradientHeight;



- (id)initWithFrame: (NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self initData];
}
-(void)initData{
    self.gradientHeight = kGradientHeight;
    
    self.beginRatio=0.4;
    self.endRatio=0.8;
    self.nowRatio=0.6;
    self.dragType=DRAG_NONE;
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowWillClose:) name: @"NSWindowWillCloseNotification" object: nil];
}
- (void)drawRect: (NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    
    //view bg
    [[NSColor clearColor] set];
    [NSBezierPath fillRect:dirtyRect];
    

    NSRect viewRect = [self _gradientBounds];
    NSBezierPath* viewOutline = [NSBezierPath bezierPathWithRoundedRect: viewRect xRadius: kViewCornerRoundness yRadius: kViewCornerRoundness];
    [viewOutline setLineWidth: kViewBorderWidth];

    //drag bg
    [[NSColor grayColor] set];
    [viewOutline fill];
    
    // DRAW VIEW BORDER
    [kViewBorderColor set];
    [viewOutline stroke];
    
    //draw trim bg
    [COLORRGB(0x72a6e6) set];
    [NSBezierPath fillRect:[self _trimBounds]];
    
    //draw now line
    
    
    [COLORRGB(0x333333) set];
    NSBezierPath * path = [NSBezierPath bezierPath];
    [path setLineWidth: 1];
    [path  moveToPoint: [self _nowLineBegin]];
    [path lineToPoint:[self _nowLineEnd]];
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}


- (void)mouseDown: (NSEvent*)theEvent
{
    if (_dragType!=DRAG_NONE) {  return;  }
    
    NSPoint mouseLocation = [theEvent locationInWindow];
    mouseLocation = [self convertPoint: mouseLocation fromView: nil];

    CGPoint beginPoint=[self _viewPointFromGradientLocation: _beginRatio];
    CGRect beginRect=CGRectMake(beginPoint.x-kTouchDeviationWidth/2, beginPoint.y-[self _trimBounds].size.height/2, kTouchDeviationWidth, [self _trimBounds].size.height);
    if (NSPointInRect(mouseLocation, beginRect)) {
        _dragType=DRAG_BEGIN;
        NSLog(@"drag begin ...");
        return;
    }
    
    CGPoint endPoint=[self _viewPointFromGradientLocation: _endRatio];
    CGRect endRect=CGRectMake(endPoint.x-kTouchDeviationWidth/2, endPoint.y-[self _trimBounds].size.height/2, kTouchDeviationWidth, [self _trimBounds].size.height);
    if (NSPointInRect(mouseLocation, endRect)) {
        _dragType=DRAG_END;
        NSLog(@"drag end ...");
        return;
    }

    CGPoint nowPoint=[self _viewPointFromGradientLocation: _nowRatio];
    CGFloat hight=([self bounds].size.height - gradientHeight)*6/8+ gradientHeight;
    CGRect nowRect=CGRectMake(nowPoint.x-kTouchDeviationWidth/2, nowPoint.y-hight/2, kTouchDeviationWidth,hight );
    if (NSPointInRect(mouseLocation, nowRect)) {
        _dragType=DRAG_NOW;
        NSLog(@"drag now ...");
        return;
    }
    _dragType=DRAG_NONE;
    [self setNeedsDisplay: TRUE];
}


- (void)mouseDragged: (NSEvent*)theEvent
{
    if (_dragType==DRAG_NONE) {  return;  }
    
    NSPoint mouseLocation = [theEvent locationInWindow];
    mouseLocation = [self convertPoint: mouseLocation fromView: nil];
    
    switch (_dragType) {
        case DRAG_BEGIN:
        {
            float tmp=[self _gradientLocationFromViewPoint: mouseLocation];
            _beginRatio=tmp<_endRatio? tmp:(_endRatio- kMinMargin/[self _gradientBounds].size.width);
            
//            NSLog(@"_beginRatio tmp:%f >>> %f",tmp,_beginRatio);
            if (target && actionBegin) {
//            NSLog(@"actionBegin....>>>>>>> target: %@ select: %s",target,sel_getName(actionBegin));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [target performSelector:actionBegin withObject:self];
#pragma clang diagnostic pop
            }
        }
            break;
        case DRAG_END:
        {
            float tmp=[self _gradientLocationFromViewPoint: mouseLocation];
            _endRatio=_beginRatio<tmp? tmp:(_beginRatio+ kMinMargin/[self _gradientBounds].size.width);
//            NSLog(@"_endRatio tmp:%f >>> %f",tmp,_endRatio);
            if (target && actionEnd) {
//            NSLog(@"actionEnd....>>>>>>> target: %@ select: %s",target,sel_getName(actionEnd));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [target performSelector:actionEnd withObject:self];
#pragma clang diagnostic pop
            }
        }
            break;
        case DRAG_NOW:
        {
            _nowRatio=[self _gradientLocationFromViewPoint: mouseLocation];
//            NSLog(@"_nowRatio >>> %f",_nowRatio);
            if (target && actionNow) {
//            NSLog(@"actionNow....>>>>>>> target: %@ select: %s",target,sel_getName(actionNow));
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [target performSelector:actionNow withObject:self];
#pragma clang diagnostic pop
                
            }
        }
            break;
            
        default:
            break;
    }
    [self setNeedsDisplay: TRUE];
}
- (void)mouseUp: (NSEvent*)theEvent
{
    if (_dragType==DRAG_NONE) {  return;  }
    
    _dragType=DRAG_NONE;
    [self setNeedsDisplay: TRUE];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)windowWillClose: (NSNotification*)aNot
{
    NSLog(@"windowWillClose ...");
}


//(NSRect) viewRect = (origin = (x = 9, y = 10.5), size = (width = 850, height = 23))
- (NSRect)_gradientBounds
{
    NSRect viewRect = [self bounds];
    viewRect.origin.x += kViewXOffset;
    viewRect.size.width -= kViewXOffset * 2;
    
    if (gradientHeight > 0 && gradientHeight < [self bounds].size.height) {
        viewRect.size.height = gradientHeight;
        viewRect.origin.y += ([self bounds].size.height - gradientHeight) / 2;
    }
//    NSLog(@"_gradientBounds: %@",NSStringFromRect(viewRect));
    return viewRect;
}
- (NSRect)_trimBounds
{
    NSRect viewRect = [self bounds];
    //we need set width before x, otherwise the ratio is wrong
    viewRect.size.width =(self.endRatio-self.beginRatio)*([self _gradientBounds].size.width );
    viewRect.size.height=gradientHeight;
    
    viewRect.origin.x += self.beginRatio* [self _gradientBounds].size.width+ kViewXOffset;
    viewRect.origin.y += ([self bounds].size.height - gradientHeight) / 2;
//    NSLog(@"_trimBounds: %@",NSStringFromRect(viewRect));
    return viewRect;
}



- (NSPoint)_nowLineBegin
{
    NSPoint point ;
    point.x = self.nowRatio* [self _gradientBounds].size.width+ kViewXOffset;
    point.y = ([self bounds].size.height - gradientHeight) / 8;
//    NSLog(@"_nowLineBegin: %@",NSStringFromPoint(point));
    return point;
}
- (NSPoint)_nowLineEnd
{
    NSPoint point ;
    point.x = self.nowRatio* [self _gradientBounds].size.width+ kViewXOffset;
    point.y = [self bounds].size.height- ([self bounds].size.height - gradientHeight) / 8 ;
//    NSLog(@"_nowLineEnd: %@",NSStringFromPoint(point));
    return point;
}

- (NSPoint)_viewPointFromGradientLocation: (CGFloat)location
{
//    NSLog(@"_viewPointFromGradientLocation >> gradientBounds.width: %f  ,location: %f",[self _gradientBounds].size.width,location);
    return NSMakePoint(location * [self _gradientBounds].size.width + kViewXOffset, [self bounds].size.height / 2);
}
- (CGFloat)_gradientLocationFromViewPoint: (NSPoint)point
{
//    NSLog(@" >> %f",MAX(0, MIN(1, (point.x - kViewXOffset) / [self _gradientBounds].size.width)));
    return MAX(0, MIN(1, (point.x - kViewXOffset) / [self _gradientBounds].size.width)); //   0<= XX <= 1
}




@end
