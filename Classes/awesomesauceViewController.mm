//
//  awesomesauceViewController.m
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "awesomesauceViewController.h"
#import "awesomesauceAppDelegate.h"
#import "EAGLView.h"
#import "graphics.h"
#import "HUDHandler.h"

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface awesomesauceViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end

@implementation awesomesauceViewController

@synthesize animating, context, displayLink;
@synthesize currentlyEditingLabel;
@synthesize addTrackButton;
@synthesize clearTrackButton;
@synthesize futureButton;
@synthesize addTrackLabel;
@synthesize clearTrackLabel;
@synthesize futureLabel;
@synthesize bpmSlider;
@synthesize bpmLabel1, bpmLabel2, bpmLabel3;
@synthesize instPicker;
@synthesize saveFutureButton0;
@synthesize saveFutureButton1;
@synthesize cancelFutureButton;
@synthesize futureLengthSlider;
@synthesize futureLengthLabel;
@synthesize futureLengthTitle;
@synthesize futureDescription;
@synthesize track1, track2, track3, track4, drumTrack;
@synthesize drumpadLabel, drumpad1, drumpad2, drumpad3, drumpad4, drumpad5, drumpad6, drumpad7, drumpad8;
@synthesize tracks;
@synthesize futureControls;
@synthesize mainControls;
@synthesize drumControls;
@synthesize HUD;

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackAddedHandler:) name:@"track_added" object:nil];
	
}

- (void) trackAddedHandler:(NSNotification *)notification {
	numTracks++;
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] addNewMatrix:false];
	
	MixerView *temp = (MixerView *)[tracks objectAtIndex:(numTracks - 1)];
	[temp enableTrack:@"Sine"];
	
	[self matrixChanged];
	
	//TODO: 5 is a magic number so we should replace that at some point
	//also the tableview not working is kinda lame
	if(numTracks >= 5) {
		addTrackButton.hidden = YES;
		addTrackLabel.hidden = YES;
	}
}

- (void) trackAddedInterface {
	numTracks++;
	
	MixerView *temp = (MixerView *)[tracks objectAtIndex:(numTracks - 1)];
	[temp enableTrack:@"Sine"];
	
	[self matrixChanged];
	
	//TODO: 5 is a magic number so we should replace that at some point
	//also the tableview not working is kinda lame
	if(numTracks >= 5) {
		addTrackButton.hidden = YES;
		addTrackLabel.hidden = YES;
	}
}

- (void)updateBpmSlider:(float)val {
	bpmSlider.value = val;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc
{
    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
	
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
	
	[HUD unregisterListeners];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	HUD = [[HUDHandler alloc] init];
	//HUD.window = self.view.window;
	HUD.window = ((awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
	[HUD registerListeners];
}

- (void)initializeControls {
	//set depressed button states
	[addTrackButton setImage: [UIImage imageNamed: @"plus_clicked.png"] forState: UIControlStateHighlighted];
	[clearTrackButton setImage: [UIImage imageNamed: @"delete_clicked.png"] forState: UIControlStateHighlighted];
	[futureButton setImage: [UIImage imageNamed: @"future_clicked.png"] forState: UIControlStateHighlighted];
	
	//[mixerTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	//add in new stuff
	saveFutureButton0 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[saveFutureButton0 addTarget:self action:@selector(saveFuture:) forControlEvents:UIControlEventTouchUpInside];
	[saveFutureButton0 setTitle:@"There" forState:UIControlStateNormal];
	saveFutureButton0.frame = CGRectMake(20.0, 90.0, 210.0, 40.0);
	[self.view addSubview:saveFutureButton0];
	
	saveFutureButton1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[saveFutureButton1 addTarget:self action:@selector(saveFuture:) forControlEvents:UIControlEventTouchUpInside];
	[saveFutureButton1 setTitle:@"There and Back" forState:UIControlStateNormal];
	saveFutureButton1.frame = CGRectMake(20.0, 150.0, 210.0, 40.0);
	[self.view addSubview:saveFutureButton1];
	
	cancelFutureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[cancelFutureButton addTarget:self action:@selector(cancelFuture:) forControlEvents:UIControlEventTouchUpInside];
	[cancelFutureButton setTitle:@"Cancel" forState:UIControlStateNormal];
	cancelFutureButton.frame = CGRectMake(20.0, 210.0, 210.0, 40.0);
	[self.view addSubview:cancelFutureButton];
	
	CGRect sliderTitleFrame = CGRectMake(20.0, 270.0, 210.0, 30.0);
	futureLengthTitle = [[UILabel alloc] initWithFrame:sliderTitleFrame];
	futureLengthTitle.text = @"Automation Length";
	[self.view addSubview:futureLengthTitle];
	
	CGRect sliderFrame = CGRectMake(20.0, 310.0, 160.0, 20.0);
	futureLengthSlider = [[UISlider alloc] initWithFrame:sliderFrame];
    [futureLengthSlider addTarget:self action:@selector(futureLengthChanged:) forControlEvents:UIControlEventValueChanged];
    [futureLengthSlider setBackgroundColor:[UIColor clearColor]];
    futureLengthSlider.minimumValue = 2;
    futureLengthSlider.maximumValue = 16;
    futureLengthSlider.continuous = NO;
    futureLengthSlider.value = 8;
	[self.view addSubview:futureLengthSlider];
	
	CGRect sliderLabelFrame = CGRectMake(190.0, 310.0, 50.0, 30.0);
	futureLengthLabel = [[UILabel alloc] initWithFrame:sliderLabelFrame];
	futureLengthLabel.text = @"8";
	[self.view addSubview:futureLengthLabel];
	
	CGRect descFrame = CGRectMake(20.0, 350.0, 210.0, 380.0);
	futureDescription = [[UILabel alloc] initWithFrame:descFrame];
	futureDescription.text = @"Want your track to change over time? Draw in what you want this track to look like in the future. Then select using the slider how long you want it to take to get there (8 means it'll take 8 iterations of the whole grid, to change). Then, hit either 'There,' which morphs the grid into your future grid, or 'There And Back' which morphs into your specified grid and then back.";
	futureDescription.lineBreakMode = UILineBreakModeWordWrap;
	futureDescription.numberOfLines = 0;
	[self.view addSubview:futureDescription];
	
	//add items to arrays
	futureControls = [[NSMutableArray alloc] init];
	[futureControls addObject:saveFutureButton0];
	[futureControls addObject:saveFutureButton1];
	[futureControls addObject:cancelFutureButton];
	[futureControls addObject:futureLengthSlider];
	[futureControls addObject:futureLengthLabel];
	[futureControls addObject:futureLengthTitle];
	[futureControls addObject:futureDescription];
	
	NSEnumerator *futureEnum = [futureControls objectEnumerator];
	UIView *element;
	while(element = (UIView *)[futureEnum nextObject])
    {
		[element setHidden:YES];
	}
	
	mainControls = [[NSMutableArray alloc] init];
	[mainControls addObject:futureButton];
	[mainControls addObject:clearTrackButton];
	[mainControls addObject:addTrackButton];
	[mainControls addObject:bpmSlider];
	[mainControls addObject:instPicker];
	[mainControls addObject:bpmLabel1];
	[mainControls addObject:bpmLabel2];
	[mainControls addObject:bpmLabel3];
	[mainControls addObject:addTrackLabel];
	[mainControls addObject:clearTrackLabel];
	[mainControls addObject:futureLabel];
	
	drumControls = [[NSMutableArray alloc] init];
	[drumControls addObject:drumpadLabel];
	[drumControls addObject:drumpad1];
	[drumControls addObject:drumpad2];
	[drumControls addObject:drumpad3];
	[drumControls addObject:drumpad4];
	[drumControls addObject:drumpad5];
	[drumControls addObject:drumpad6];
	[drumControls addObject:drumpad7];
	[drumControls addObject:drumpad8];
	
	NSEnumerator *drumEnum = [drumControls objectEnumerator];
	int i = 0;
	while(element = (UIView *)[drumEnum nextObject])
    {
		if(i > 0) {
			UIImage *drumpadImage = [UIImage imageNamed:@"pad.png"];
			UIImage *drumpadImage_pressed = [UIImage imageNamed:@"pad_pressed.png"];
			UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, 130, 60)];
			if(i == 1) { tempLabel.text = @"Kick"; }
			else if (i == 2) { tempLabel.text = @"Snare 1"; }
			else if (i == 3) { tempLabel.text = @"Snare 2"; }
			else if (i == 4) { tempLabel.text = @"Clap 1"; }
			else if (i == 5) { tempLabel.text = @"Clap 2"; }
			else if (i == 6) { tempLabel.text = @"Open Hat"; }
			else if (i == 7) { tempLabel.text = @"Closed Hat"; }
			else if (i == 8) { tempLabel.text = @"Shaker"; }
			
			tempLabel.backgroundColor = [UIColor clearColor];
			tempLabel.textColor = [UIColor whiteColor];
			tempLabel.textAlignment =  UITextAlignmentCenter;
			tempLabel.font = [UIFont boldSystemFontOfSize:16];
			
			[element setBackgroundImage:drumpadImage forState:UIControlStateNormal];
			[element setBackgroundImage:drumpadImage_pressed forState:UIControlStateHighlighted];
			[element addSubview:tempLabel];
			[element setHidden:YES];
		}
		i++;
		
	}
	
	/*
	[drumpad1 setTitle:@"Kick" forState:UIControlStateNormal];
	[drumpad1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[drumpad1 setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	 */
	
	[self hideDrumpad:YES];
}

- (void)futureLengthChanged:(UISlider *)slider {
	NSString *string = [NSString stringWithFormat:@"%d", (int)futureLengthSlider.value];
	futureLengthLabel.text = string;
}

- (void)initializeMixer {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	tracks = [[NSMutableArray alloc] init];
	[tracks addObject:track1];
	[tracks addObject:track2];
	[tracks addObject:track3];
	[tracks addObject:track4];
	[tracks addObject:drumTrack];
	
	NSEnumerator *enumerator = [tracks objectEnumerator];
	MixerView *element;
	int i = 0;
	while(element = (MixerView *)[enumerator nextObject])
    {
		if(i == 4) {
			[element setTrackNum:-1];
		}
		else {
			[element setTrackNum:i];
		}
		[element setMatrixHandler:mh];
		[element setParent:self];
		[element disableTrack];
		
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = element.bounds;
		if(i == mh->currentMatrix) {
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor orangeColor] CGColor], (id)[[UIColor redColor] CGColor], nil];
		}
		else {
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.95 alpha:1.0] CGColor], (id)[[UIColor colorWithWhite:0.72 alpha:1.0] CGColor], nil];
		}
		[element.layer insertSublayer:gradient atIndex:0];
		
		i++;
    }
	
	[[self view] setBackgroundColor:[UIColor blackColor]];
	
	[track1 enableTrack:@"Sine"];
	[drumTrack enableTrack:@"Drums"];
	numTracks = 1;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        CADisplayLink *aDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

- (void)hideDrumpad:(bool)toHide {
	NSEnumerator *drumEnum = [drumControls objectEnumerator];
	UIView *element;
	while(element = (UIView *)[drumEnum nextObject])
    {
		[element setHidden:toHide];
	}
}

- (void)matrixChanged {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	NSString *newText;
	if(mh->currentMatrix == -1) {
		newText = @"Currently Editing Drums";
		instPicker.hidden = YES;
		futureButton.hidden = YES;
		futureLabel.hidden = YES;
		[self hideDrumpad:NO];
	}
	else {
		newText = [NSString stringWithFormat: @"Currently Editing Track %d", mh->currentMatrix+1];
		instPicker.hidden = NO;
		futureButton.hidden = NO;
		futureLabel.hidden = NO;
		[self hideDrumpad:YES];
		instPicker.selectedSegmentIndex = mh->getCurrentMatrix()->getInstrument(0);
	}
	[currentlyEditingLabel setText:newText];
	//highlight current track, unhighlight old track
	NSEnumerator *enumerator = [tracks objectEnumerator];
	MixerView *element;
	int i = 0;
	while(element = (MixerView *)[enumerator nextObject])
    {
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = element.bounds;
		if([element getTrackNum] == mh->currentMatrix) {
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor orangeColor] CGColor], (id)[[UIColor redColor] CGColor], nil];
			NSLog(@"pokemon %d", mh->currentMatrix);
		}
		else {
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.95 alpha:1.0] CGColor], (id)[[UIColor colorWithWhite:0.72 alpha:1.0] CGColor], nil];
		}
		[(CALayer *)[element.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
		[element.layer insertSublayer:gradient atIndex:0];
		[element setNeedsDisplay];
		i++;
    }
	
}

- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] displayMatrix];
    
    [(EAGLView *)self.view presentFramebuffer];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

//Interface Builder IB stuff
- (IBAction)drumpadPressed:(id)sender {
	int num = 0;
	if(sender == drumpad1) {
		num = 1;
	}
	else if(sender == drumpad2) {
		num = 2;
	}
	else if(sender == drumpad3) {
		num = 3;
	}
	else if(sender == drumpad4) {
		num = 4;
	}
	else if(sender == drumpad5) {
		num = 5;
	}
	else if(sender == drumpad6) {
		num = 6;
	}
	else if(sender == drumpad7) {
		num = 7;
	}
	else if(sender == drumpad8) {
		num = 8;
	}
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->pressPad(num-1);
}

- (IBAction)clearCurrentMatrix {
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] clearCurrentMatrix];
}

- (IBAction)addMatrix {
	numTracks++;
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] addNewMatrix:true];
	
	MixerView *temp = (MixerView *)[tracks objectAtIndex:(numTracks - 1)];
	[temp enableTrack:@"Sine"];
	
	[self matrixChanged];
	
	//TODO: 4 is a magic number so we should replace that at some point
	//also the tableview not working is kinda lame
	if(numTracks >= 4) {
		addTrackButton.hidden = YES;
		addTrackLabel.hidden = YES;
	}
}

- (IBAction)flipToSocialView:(id)sender {
	setMute(true);
	setMainScreen(false);
	CompositionsViewController *controller = [[CompositionsViewController alloc] initWithNibName:@"CompositionsViewController" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	//TODO: initialize controller with params
	
	[controller release];
}

- (IBAction)futureButtonPressed:(id)sender {
	[self toggleMainScreen:NO];
}

- (void)saveFuture:(id)sender {
	int type = 0;
	if(sender == saveFutureButton1) {
		type = 1;
	}
	NSLog(@"save future pressed");
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	int len = (int)[futureLengthSlider value];
	mh->startFuture(len, type);
	[self toggleMainScreen:YES];
}

- (void)cancelFuture:(id)sender {
	NSLog(@"cancel future pressed");
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->cancelFuture();
	[self toggleMainScreen:YES];
}

- (IBAction)printAge {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	NSLog(@"current age: %f", mh->time_elapsed);
}

- (IBAction)resetClock {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->time_elapsed = 0.0;
	NSLog(@"RESET!");
}

-(void)toggleMainScreen:(bool)isMain {
	NSEnumerator *mainEnum = [mainControls objectEnumerator];
	UIView *element1;
	while(element1 = (UIView *)[mainEnum nextObject])
    {
		[element1 setHidden:!isMain];
	}
	
	NSEnumerator *enumerator = [tracks objectEnumerator];
	MixerView *element2;
	while(element2 = (MixerView *)[enumerator nextObject])
    {
		[element2 setHidden:!isMain];
	}
	
	NSEnumerator *futureEnum = [futureControls objectEnumerator];
	UIView *element3;
	while(element3 = (UIView *)[futureEnum nextObject])
    {
		[element3 setHidden:isMain];
	}
	
	setFutureMode(!isMain);
}

- (IBAction)bpmChanged:(UISlider *)sender {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->setBpm([sender value]);
}

- (IBAction)instPickerChanged:(UISegmentedControl *)sender {
	int newInst = [sender selectedSegmentIndex];
	[self changeInstrument:newInst];
}

// delegate methods for FlipViewProtocol
- (void) closeMe {
	setMute(false);
	[self dismissModalViewControllerAnimated:YES];
	setMainScreen(true);
}

-(MatrixHandler *) getMatrixHandler {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	return mh;
}

// delegate methods for ArrangeViewProtocol which no longer exists
-(void) changeBpm:(float)newBpm {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->setBpm(newBpm);
}

- (void) closeAndSwitchTrack:(int)trackNum {
	[self dismissModalViewControllerAnimated:YES];
	setMainScreen(true);
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->currentMatrix = trackNum;
	[self matrixChanged];
}

- (int) getNumTracks {
	return numTracks;
}

-(void) stopPlayback {
	setPlayback(false);
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->resetTime();
}

-(void) pausePlayback {
	setPlayback(false);
}

-(void) startPlayback {
	setPlayback(true);
}

-(void) changeInstrument:(int)newInst {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->changeInstrument(newInst);
	int trackNum = mh->currentMatrix;
	MixerView *temp = (MixerView *) [tracks objectAtIndex:trackNum];
	if(newInst == 0) {
		[temp setLabelText:@"Sine"];
	}
	else if(newInst == 1) {
		[temp setLabelText:@"Square"];
	}
	else if(newInst == 2) {
		[temp setLabelText:@"Saw"];
	}
}

@end
