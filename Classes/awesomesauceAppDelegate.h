//
//  awesomesauceAppDelegate.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatrixHandler.h"

@class awesomesauceViewController;

@interface awesomesauceAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    awesomesauceViewController *viewController;

	MatrixHandler *matrixHandler;
}

-(void) clearCurrentMatrix;
-(void) timePassed:(float)time;
-(void) sonifyMatricesInfoBuffer:(Float32 *)buffer withNumFrames:(UInt32)numFrames withUserData:(void *)userData;
-(void) displayMatrix;
-(bool) toggleTouch:(int)row withYval:(int)col;
-(void) setTouch:(int)row withYval:(int)col withBool:(bool)is_on;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet awesomesauceViewController *viewController;

@end