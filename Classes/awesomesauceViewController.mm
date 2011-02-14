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
		gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor lightGrayColor] CGColor], (id)[[UIColor darkGrayColor] CGColor], nil];
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
	instPicker.selectedSegmentIndex = mh->getCurrentMatrix()->instrument;
	NSString *newText = [NSString stringWithFormat: @"Currently Editing Track %d", mh->currentMatrix+1];
	[currentlyEditingLabel setText:newText];
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
	[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] addNewMatrix];
	
	MixerView *temp = (MixerView *)[tracks objectAtIndex:(numTracks - 1)];
	[temp enableTrack:@"Sine"];
	
	[self matrixChanged];
	
	//TODO: 7 is a magic number so we should replace that at some point
	//also the tableview not working is kinda lame
	if(numTracks >= 7) {
		addTrackButton.hidden = YES;
	}
}

- (IBAction)instPickerChanged:(UISegmentedControl *)sender {
	MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	int newInst = [sender selectedSegmentIndex];
	mh->changeInstrument(newInst);
	MixerView *temp = (MixerView *)[tracks objectAtIndex:mh->currentMatrix];
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
