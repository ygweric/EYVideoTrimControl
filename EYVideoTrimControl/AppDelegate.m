//
//  AppDelegate.m
//  EYVideoTrimControl
//
//  Created by ericyang on 4/16/15.
//  Copyright (c) 2015 www.appcpu.com. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [_vtControl setActionBegin:@selector(actionBegin:)];
    [_vtControl setActionEnd:@selector(actionEnd:)];
    [_vtControl setActionNow:@selector(actionNow:)];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark -

-(void)actionBegin:(EYVideoTrimControl*)vt{
    NSLog(@"actionBegin....%f",vt.beginRatio);
}
-(void)actionEnd:(EYVideoTrimControl*)vt{
    NSLog(@"actionEnd....%f",vt.endRatio);
}
-(void)actionNow:(EYVideoTrimControl*)vt{
    NSLog(@"actionNow....%f",vt.nowRatio);
}


@end
