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
@synthesize saveFutureButton;
@synthesize cancelFutureButton;
@synthesize futureLengthSlider;
@synthesize futureLengthLabel;
@synthesize futureLengthTitle;
@synthesize futureDescription;
@synthesize track1, track2, track3, track4, track5;
@synthesize tracks;
@synthesize futureControls;
@synthesize mainControls;

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
	}
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
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)initializeControls {
	//set depressed button states
	[addTrackButton setImage: [UIImage imageNamed: @"plus_clicked.png"] forState: UIControlStateHighlighted];
	[clearTrackButton setImage: [UIImage imageNamed: @"delete_clicked.png"] forState: UIControlStateHighlighted];
	[futureButton setImage: [UIImage imageNamed: @"future_clicked.png"] forState: UIControlStateHighlighted];
	
	//[mixerTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	//add in new stuff
	saveFutureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[saveFutureButton addTarget:self action:@selector(saveFuture:) forControlEvents:UIControlEventTouchUpInside];
	[saveFutureButton setTitle:@"Save" forState:UIControlStateNormal];
	saveFutureButton.frame = CGRectMake(20.0, 90.0, 210.0, 40.0);
	[self.view addSubview:saveFutureButton];
	
	cancelFutureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[cancelFutureButton addTarget:self action:@selector(cancelFuture:) forControlEvents:UIControlEventTouchUpInside];
	[cancelFutureButton setTitle:@"Cancel" forState:UIControlStateNormal];
	cancelFutureButton.frame = CGRectMake(20.0, 150.0, 210.0, 40.0);
	[self.view addSubview:cancelFutureButton];
	
	CGRect sliderTitleFrame = CGRectMake(20.0, 210.0, 210.0, 30.0);
	futureLengthTitle = [[UILabel alloc] initWithFrame:sliderTitleFrame];
	futureLengthTitle.text = @"Automation Length";
	[self.view addSubview:futureLengthTitle];
	
	CGRect sliderFrame = CGRectMake(20.0, 250.0, 160.0, 10.0);
	futureLengthSlider = [[UISlider alloc] initWithFrame:sliderFrame];
	//TODO: a bpm label?
    [futureLengthSlider addTarget:self action:@selector(futureLengthChanged:) forControlEvents:UIControlEventValueChanged];
    [futureLengthSlider setBackgroundColor:[UIColor clearColor]];
    futureLengthSlider.minimumValue = 2;
    futureLengthSlider.maximumValue = 16;
    futureLengthSlider.continuous = NO;
    futureLengthSlider.value = 8;
	[self.view addSubview:futureLengthSlider];
	
	CGRect sliderLabelFrame = CGRectMake(190.0, 250.0, 50.0, 30.0);
	futureLengthLabel = [[UILabel alloc] initWithFrame:sliderLabelFrame];
	futureLengthLabel.text = @"8";
	[self.view addSubview:futureLengthLabel];
	
	CGRect descFrame = CGRectMake(20.0, 270.0, 210.0, 380.0);
	futureDescription = [[UILabel alloc] initWithFrame:descFrame];
	futureDescription.text = @"Want your track to change over time? Draw in what you want this track to look like in the future. Then select using the slider how long you want it to take to get there (8 means it'll take 8 bars, or 8 iterations of the whole grid, to change). Then, hit save. Our sophisticated algorithms will morph the initial grid into your ending grid in the awesomest way possible.";
	futureDescription.lineBreakMode = UILineBreakModeWordWrap;
	futureDescription.numberOfLines = 0;
	[self.view addSubview:futureDescription];
	
	//add items to arrays
	futureControls = [[NSMutableArray alloc] init];
	[futureControls addObject:saveFutureButton];
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
	[tracks addObject:track5];
	
	NSEnumerator *enumerator = [tracks objectEnumerator];
	MixerView *element;
	int i = 0;
	while(element = (MixerView *)[enumerator nextObject])
    {
		[element setTrackNum:i];
		[element setMatrixHandler:mh];
		[element setParent:self];
		[element disableTrack];
		
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = element.bounds;
		if(i == mh->currentMatrix) {
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor orangeColor] CGColor], (id)[[UIColor redColor] CGColor], nil];
		}
		else {
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor darkGrayColor] CGColor], nil];
		}
		[element.layer insertSublayer:gradient atIndex:0];
		
		i++;
    }
	
	[track1 enableTrack:@"Sine"];
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

- (void)matrixChanged {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	NSString *newText = [NSString stringWithFormat: @"Currently Editing Track %d", mh->currentMatrix+1];
	[currentlyEditingLabel setText:newText];
	
	//highlight current track, unhighlight old track
	NSEnumerator *enumerator = [tracks objectEnumerator];
	MixerView *element;
	int i = 0;
	while(element = (MixerView *)[enumerator nextObject])
    {
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = element.bounds;
		if(i == mh->currentMatrix) {
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor orangeColor] CGColor], (id)[[UIColor redColor] CGColor], nil];
			NSLog(@"pokemon %d", mh->currentMatrix);
		}
		else {
			gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor darkGrayColor] CGColor], nil];
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
- (IBAction)clearCurrentMatrix {
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] clearCurrentMatrix];
}

- (IBAction)addMatrix {
	numTracks++;
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] addNewMatrix:true];
	
	MixerView *temp = (MixerView *)[tracks objectAtIndex:(numTracks - 1)];
	[temp enableTrack:@"Sine"];
	
	[self matrixChanged];
	
	//TODO: 5 is a magic number so we should replace that at some point
	//also the tableview not working is kinda lame
	if(numTracks >= 5) {
		addTrackButton.hidden = YES;
	}
}

// button action
- (IBAction) flipToSynthView:(id)sender {
	setMainScreen(false);
	SynthViewController *controller = [[SynthViewController alloc] initWithNibName:@"SynthViewController" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	//initialize controller with params, e.g. current track num, the track's current synth, etc
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	
	//set text label of currently edited track
	NSString *newText = [NSString stringWithFormat: @"Currently Editing Track %d", mh->currentMatrix+1];
	[[controller titleLabel] setText:newText];
	[[controller envLength] setValue:mh->getCurrentMatrix()->note_length];
	[[controller envAttack] setValue:mh->getCurrentMatrix()->note_attack];
	[[controller envRelease] setValue:mh->getCurrentMatrix()->note_release];
	
	[controller release];
}

- (IBAction)flipToSocialView:(id)sender {
	setMainScreen(false);
	SocialViewController *controller = [[SocialViewController alloc] initWithNibName:@"SocialViewController" bundle:nil];
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
	//TODO
	NSLog(@"save future pressed");
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	int len = (int)[futureLengthSlider value];
	mh->startFuture(len);
	[self toggleMainScreen:YES];
}

- (void)cancelFuture:(id)sender {
	//TODO
	NSLog(@"cancel future pressed");
	[self toggleMainScreen:YES];
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
	[self changeInstrument:newInst withIndex:0];
}

// delegate methods for FlipViewProtocol
- (void) closeMe {
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

// delegate methods for SynthViewProtocol
-(void) changeInstrument:(int)newInst withIndex:(int)index {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->changeInstrument(newInst, index);
}

-(void) changeEnvLength:(float)newVal {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->setCurrentTrackEnvLength(newVal);
}

-(void) changeEnvAttack:(float)newVal {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->setCurrentTrackEnvAttack(newVal);
}

-(void) changeEnvRelease:(float)newVal {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->setCurrentTrackEnvRelease(newVal);
}

@end
