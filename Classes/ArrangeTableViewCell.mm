//
//  ArrangeTableViewCell.m
//  awesomesauce
//
//  Created by Ravi Parikh on 3/7/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import "ArrangeTableViewCell.h"


@implementation ArrangeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
}

- (void)setParent:(ArrangeViewController *)avc {
	parent = avc;
}

- (IBAction)editButtonPressed:(UIButton *)sender {
	[[parent delegate] closeAndSwitchTrack:trackNum];
}

- (IBAction)onSwitchToggled {
	matrixHandler->setMatrixOn(trackNum, onSwitch.on);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)dealloc {
    [super dealloc];
}


@end
