//
//  SynthViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/27/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SynthViewProtocol;


@interface SynthViewController : UIViewController {
	id <SynthViewProtocol> delegate;
}

@property (nonatomic, retain) id <SynthViewProtocol> delegate;

- (IBAction) returnToMain:(id)sender;

@end

@protocol SynthViewProtocol
-(void) closeSynthView;
@end
