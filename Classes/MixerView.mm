//
//  MixerView.m
//  awesomesauce
//
//  Created by Ravi Parikh on 2/14/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "MixerView.h"


@implementation MixerView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
	
	//UIImage *backgroundImage = [[UIImage imageNamed:@"blue_gradient.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	//[editButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	
    return self;
}

- (void)setLabelText:(NSString *)labelText {
	trackName.text = labelText;
}

- (void)setTrackNum:(int)num {
	trackNum = num;
}

- (void)disableTrack {
	editButton.hidden = YES;
	onSwitch.hidden = YES;
}

- (void)enableTrack:(NSString *)labelText {
	editButton.hidden = NO;
	onSwitch.hidden = NO;
	trackName.text = labelText;
}

- (void)setMatrixHandler:(MatrixHandler *)mh {
	matrixHandler = mh;
	NSLog(@"go");
}

- (void)setParent:(awesomesauceViewController *)avc {
	parent = avc;
}

- (IBAction)editButtonPressed:(UIButton *)sender {
	matrixHandler->currentMatrix = trackNum;
	[parent matrixChanged];
}

- (IBAction)onSwitchToggled {
	matrixHandler->setMatrixOn(trackNum, onSwitch.on);
}

- (void)dealloc {
    [super dealloc];
}


@end
