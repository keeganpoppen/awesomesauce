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

@interface awesomesauceViewController : UIViewController
{
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
	IBOutlet UISegmentedControl *instPicker;
	
	//table replacements
	IBOutlet UILabel *track1Name;
	IBOutlet UILabel *track2Name;
	IBOutlet UILabel *track3Name;
	
	IBOutlet UIButton *track1Edit;
	IBOutlet UIButton *track2Edit;
	IBOutlet UIButton *track3Edit;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)matrixChanged; //called whenever the matrix is changed
- (void)startAnimation;
- (void)stopAnimation;
- (IBAction)clearCurrentMatrix;
- (IBAction)addMatrix;
- (IBAction)instPickerChanged:(UISegmentedControl *)sender;
- (IBAction)editTrackButtons:(UIButton *)sender;


@end
