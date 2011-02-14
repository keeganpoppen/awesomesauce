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

@interface awesomesauceViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
	IBOutlet UITableView *mixerTable;
	IBOutlet UISegmentedControl *instPicker;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) IBOutlet UITableView *mixerTable;

- (void)startAnimation;
- (void)stopAnimation;
- (IBAction)clearCurrentMatrix;
- (IBAction)addMatrix;
- (IBAction)instPickerChanged:(UISegmentedControl *)sender;


@end
