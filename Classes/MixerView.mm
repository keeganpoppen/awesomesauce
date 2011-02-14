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
	matrixHandler->matrices[trackNum]->isOn = onSwitch.on;
}

- (void)dealloc {
    [super dealloc];
}


@end
