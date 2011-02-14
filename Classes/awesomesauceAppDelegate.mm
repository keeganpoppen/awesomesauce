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
	matrixHandler->advanceTime(time);
}

-(void) sonifyMatricesInfoBuffer:(Float32 *)buffer withNumFrames:(UInt32)numFrames withUserData:(void *)userData {
	matrixHandler->sonifyAllMatrices(buffer, numFrames, userData);
}

-(void) displayMatrix {
	matrixHandler->displayCurrentMatrix();
}

-(bool) toggleTouch:(int)row withYval:(int)col {
	return matrixHandler->getCurrentMatrix()->toggleSquare(row, col);
}

-(void) setTouch:(int)row withYval:(int)col withBool:(bool)is_on {
	matrixHandler->getCurrentMatrix()->setSquare(row, col, is_on);
}

-(void) clearCurrentMatrix {
	matrixHandler->clearCurrentMatrix();
}

-(void) addNewMatrix:(BOOL)sendNotification {
	matrixHandler->addNewMatrix(sendNotification);
}

-(MatrixHandler *) getMatrixHandler {
	return matrixHandler;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window addSubview:self.viewController.view];
	
	matrixHandler = new MatrixHandler();
	[self.viewController initializeMixer];
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
