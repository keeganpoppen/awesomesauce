//
//  MixerView.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/14/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatrixHandler.h"

@interface MixerView : UIView {
	IBOutlet UILabel *trackName;
	IBOutlet UIButton *editButton;
	int trackNum;
	MatrixHandler *matrixHandler;
}

- (void)setLabelText:(NSString *)labelText;
- (void)setTrackNum:(int)num;
- (void)setMatrixHandler:(MatrixHandler *)mh;
- (void)disableTrack;
- (void)enableTrack:(NSString *)labelText;
- (IBAction)editButtonPressed:(UIButton *)sender;

@end
