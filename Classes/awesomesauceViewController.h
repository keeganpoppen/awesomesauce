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
#import "SynthViewController.h"
#import "ArrangeViewController.h"
#import "SocialViewController.h"
#import "FlipViewProtocol.h"

@interface awesomesauceViewController : UIViewController <ArrangeViewProtocol, SynthViewProtocol, FlipViewProtocol, SocialViewProtocol>
{
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
	IBOutlet UILabel *currentlyEditingLabel;
	IBOutlet UIButton *addTrackButton;
	IBOutlet UIButton *clearTrackButton;
	IBOutlet UIButton *futureButton;
	IBOutlet UIButton *arrangeButton;
	IBOutlet UIButton *synthButton;
	IBOutlet UISlider *bpmSlider;
	IBOutlet UISegmentedControl *instPicker;
	
	//table replacements
	IBOutlet MixerView *track1;
	IBOutlet MixerView *track2;
	IBOutlet MixerView *track3;
	IBOutlet MixerView *track4;
	IBOutlet MixerView *track5;
	
	//future ui
	UIButton *saveFutureButton;
	UIButton *cancelFutureButton;
	UISlider *futureLengthSlider;
	
	NSMutableArray *tracks;
	int numTracks;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) IBOutlet UILabel *currentlyEditingLabel;
@property (nonatomic, retain) IBOutlet UIButton *addTrackButton;
@property (nonatomic, retain) IBOutlet UIButton *clearTrackButton;
@property (nonatomic, retain) IBOutlet UIButton *futureButton;
@property (nonatomic, retain) IBOutlet UIButton *arrangeButton;
@property (nonatomic, retain) IBOutlet UIButton *synthButton;
@property (nonatomic, retain) IBOutlet UISlider *bpmSlider;
@property (nonatomic, retain) IBOutlet UISegmentedControl *instPicker;
@property (nonatomic, retain) IBOutlet MixerView *track1;
@property (nonatomic, retain) IBOutlet MixerView *track2;
@property (nonatomic, retain) IBOutlet MixerView *track3;
@property (nonatomic, retain) IBOutlet MixerView *track4;
@property (nonatomic, retain) IBOutlet MixerView *track5;
@property (nonatomic, retain) UIButton *saveFutureButton;
@property (nonatomic, retain) UIButton *cancelFutureButton;
@property (nonatomic, retain) UISlider *futureLengthSlider;

- (void)matrixChanged; //called whenever the matrix is changed
- (void)startAnimation;
- (void)stopAnimation;
- (void)initializeMixer;
- (void)trackAddedHandler:(NSNotification *)notification;
- (void)saveFuture:(id)sender;
- (void)cancelFuture:(id)sender;
- (void)toggleMainScreen:(bool)isMain;
- (IBAction)clearCurrentMatrix;
- (IBAction)addMatrix;
- (IBAction)flipToSynthView:(id)sender;
- (IBAction)flipToArrangeView:(id)sender;
- (IBAction)flipToSocialView:(id)sender;
- (IBAction)futureButtonPressed:(id)sender;
- (IBAction)bpmChanged:(UISlider *)sender;
- (IBAction)instPickerChanged:(UISegmentedControl *)sender;

@end
