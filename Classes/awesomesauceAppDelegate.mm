//
//  awesomesauceAppDelegate.m
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "awesomesauceAppDelegate.h"
#import "awesomesauceViewController.h"
#import "audio.h"
#import "graphics.h"

@implementation awesomesauceAppDelegate

@synthesize window;
@synthesize viewController;

-(void) timePassed:(float)time {
	touchMatrix->advanceTime(time);
}

-(void) sonifyMatricesInfoBuffer:(Float32 *)buffer withNumFrames:(UInt32)numFrames withUserData:(void *)userData {
	touchMatrix->sonifyMatrix(buffer, numFrames, userData);
}

-(void) displayMatrix {
	touchMatrix->displayMatrix();
}

-(bool) toggleTouch:(int)row withYval:(int)col {
	return touchMatrix->toggleSquare(row, col);
}

-(void) setTouch:(int)row withYval:(int)col withBool:(bool)is_on {
	touchMatrix->setSquare(row, col, is_on);
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window addSubview:self.viewController.view];
	
	touchMatrix = new TouchMatrix();

	audioInit();
	graphicsInit();
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.viewController stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
    [viewController release];
    [window release];
    
    [super dealloc];
}

@end
