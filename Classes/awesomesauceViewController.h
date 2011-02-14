//
//  awesomesauceViewController.h
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "MixerView.h"

@interface awesomesauceViewController : UIViewController
{
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
	IBOutlet UISegmentedControl *instPicker;
	
	//table replacements
	IBOutlet MixerView *track1;
	IBOutlet MixerView *track2;
	IBOutlet MixerView *track3;
	
	NSMutableArray *tracks;
	int numTracks;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)matrixChanged; //called whenever the matrix is changed
- (void)startAnimation;
- (void)stopAnimation;
- (void)initializeMixer;
- (IBAction)clearCurrentMatrix;
- (IBAction)addMatrix;
- (IBAction)instPickerChanged:(UISegmentedControl *)sender;


@end
