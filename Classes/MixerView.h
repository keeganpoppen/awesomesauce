//
//  MixerView.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/14/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MixerView : UIView {
	IBOutlet UILabel *trackName;
	IBOutlet UIButton *editButton;
	int trackNum;
}

- (void)setTrackNum:(int)num;
- (IBAction)editButtonPressed:(UIButton *)sender;

@end
