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
#import "CompositionsViewController.h"
#import "FlipViewProtocol.h"

#import "HUDHandler.h"

@interface awesomesauceViewController : UIViewController <SynthViewProtocol, FlipViewProtocol, SocialViewProtocol>
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
	IBOutlet UILabel *addTrackLabel;
	IBOutlet UILabel *clearTrackLabel;
	IBOutlet UILabel *futureLabel;
	IBOutlet UISlider *bpmSlider;
	IBOutlet UILabel *bpmLabel1;
	IBOutlet UILabel *bpmLabel2;
	IBOutlet UILabel *bpmLabel3;
	IBOutlet UISegmentedControl *instPicker;
	
	//table replacements
	IBOutlet MixerView *track1;
	IBOutlet MixerView *track2;
	IBOutlet MixerView *track3;
	IBOutlet MixerView *track4;
	IBOutlet MixerView *drumTrack;
	
	//drum pad
	IBOutlet UILabel *drumpadLabel;
	IBOutlet UIButton *drumpad1;
	IBOutlet UIButton *drumpad2;
	IBOutlet UIButton *drumpad3;
	IBOutlet UIButton *drumpad4;
	IBOutlet UIButton *drumpad5;
	IBOutlet UIButton *drumpad6;
	IBOutlet UIButton *drumpad7;
	IBOutlet UIButton *drumpad8;
	
	//future ui
	UIButton *saveFutureButton0;
	UIButton *saveFutureButton1;
	UIButton *cancelFutureButton;
	UISlider *futureLengthSlider;
	UILabel *futureLengthLabel;
	UILabel *futureLengthTitle;
	UILabel *futureDescription;
	
	NSMutableArray *tracks;
	NSMutableArray *futureControls;
	NSMutableArray *mainControls;
	NSMutableArray *drumControls;
	int numTracks;
	
	//cool HUD
	HUDHandler *HUD;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) IBOutlet UILabel *currentlyEditingLabel;
@property (nonatomic, retain) IBOutlet UIButton *addTrackButton;
@property (nonatomic, retain) IBOutlet UIButton *clearTrackButton;
@property (nonatomic, retain) IBOutlet UIButton *futureButton;
@property (nonatomic, retain) IBOutlet UILabel *addTrackLabel;
@property (nonatomic, retain) IBOutlet UILabel *clearTrackLabel;
@property (nonatomic, retain) IBOutlet UILabel *futureLabel;
@property (nonatomic, retain) IBOutlet UISlider *bpmSlider;
@property (nonatomic, retain) IBOutlet UILabel *bpmLabel1;
@property (nonatomic, retain) IBOutlet UILabel *bpmLabel2;
@property (nonatomic, retain) IBOutlet UILabel *bpmLabel3;
@property (nonatomic, retain) IBOutlet UISegmentedControl *instPicker;
@property (nonatomic, retain) IBOutlet MixerView *track1;
@property (nonatomic, retain) IBOutlet MixerView *track2;
@property (nonatomic, retain) IBOutlet MixerView *track3;
@property (nonatomic, retain) IBOutlet MixerView *track4;
@property (nonatomic, retain) IBOutlet MixerView *drumTrack;
@property (nonatomic, retain) IBOutlet UILabel *drumpadLabel;
@property (nonatomic, retain) IBOutlet UIButton *drumpad1;
@property (nonatomic, retain) IBOutlet UIButton *drumpad2;
@property (nonatomic, retain) IBOutlet UIButton *drumpad3;
@property (nonatomic, retain) IBOutlet UIButton *drumpad4;
@property (nonatomic, retain) IBOutlet UIButton *drumpad5;
@property (nonatomic, retain) IBOutlet UIButton *drumpad6;
@property (nonatomic, retain) IBOutlet UIButton *drumpad7;
@property (nonatomic, retain) IBOutlet UIButton *drumpad8;
@property (nonatomic, retain) UIButton *saveFutureButton0;
@property (nonatomic, retain) UIButton *saveFutureButton1;
@property (nonatomic, retain) UIButton *cancelFutureButton;
@property (nonatomic, retain) UISlider *futureLengthSlider;
@property (nonatomic, retain) UILabel *futureLengthLabel;
@property (nonatomic, retain) UILabel *futureLengthTitle;
@property (nonatomic, retain) UILabel *futureDescription;
@property (nonatomic, retain) NSMutableArray *tracks;
@property (nonatomic, retain) NSMutableArray *futureControls;
@property (nonatomic, retain) NSMutableArray *mainControls;
@property (nonatomic, retain) NSMutableArray *drumControls;

@property (nonatomic, retain) HUDHandler *HUD;

- (void)matrixChanged; //called whenever the matrix is changed
- (void)startAnimation;
- (void)stopAnimation;
- (void)initializeMixer;
- (void)initializeControls;
- (void)trackAddedHandler:(NSNotification *)notification;
- (void)saveFuture:(id)sender;
- (void)cancelFuture:(id)sender;
- (void)toggleMainScreen:(bool)isMain;
- (void)futureLengthChanged:(UISlider *)slider;
- (void)trackAddedInterface;
- (void)updateBpmSlider:(float)val;
- (void)hideDrumpad:(bool)toHide;
- (IBAction)printAge;
- (IBAction)clearCurrentMatrix;
- (IBAction)addMatrix;
- (IBAction)resetClock;
- (IBAction)flipToSynthView:(id)sender;
- (IBAction)flipToSocialView:(id)sender;
- (IBAction)futureButtonPressed:(id)sender;
- (IBAction)bpmChanged:(UISlider *)sender;
- (IBAction)instPickerChanged:(UISegmentedControl *)sender;
- (IBAction)drumpadPressed:(id)sender;

@end
