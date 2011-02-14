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

- (void)setTrackNum:(int)num {
	trackNum = num;
}

- (IBAction)editButtonPressed:(UIButton *)sender {
	//MatrixHandler *mh = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] getMatrixHandler];
	//mh->currentMatrix = trackNum;
	NSLog(@"edit button pressed: %d", trackNum);
}


- (void)dealloc {
    [super dealloc];
}


@end
