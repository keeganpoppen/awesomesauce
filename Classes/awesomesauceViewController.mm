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
	
	//TODO: 7 is a magic number so we should replace that at some point
	//also the tableview not working is kinda lame
	if(numTracks >= 7) {
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
	
	//[mixerTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)initializeMixer {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	tracks = [[NSMutableArray alloc] init];
	[tracks addObject:track1];
	[tracks addObject:track2];
	[tracks addObject:track3];
	[tracks addObject:track4];
	[tracks addObject:track5];
	[tracks addObject:track6];
	[tracks addObject:track7];
	
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
	
	//TODO: 7 is a magic number so we should replace that at some point
	//also the tableview not working is kinda lame
	if(numTracks >= 7) {
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

// button action
- (IBAction) flipToArrangeView:(id)sender {
	setMainScreen(false);
	ArrangeViewController *controller = [[ArrangeViewController alloc] initWithNibName:@"ArrangeViewController" bundle:nil];
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	//TODO: initialize controller with params, e.g. current track num, bpm, etc
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	[[controller bpmSlider] setValue:(mh->bpm / 4.0)];
	
	
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

// delegate methods for FlipViewProtocol
- (void) closeMe {
	[self dismissModalViewControllerAnimated:YES];
	setMainScreen(true);
}

-(MatrixHandler *) getMatrixHandler {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	return mh;
}

// delegate methods for ArrangeViewProtocol
-(void) changeBpm:(float)newBpm {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	mh->setBpm(newBpm);
}

- (int) getNumTracks {
	return numTracks;
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
