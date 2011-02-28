//
//  ArrangeViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/27/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ArrangeViewProtocol;
@protocol FlipViewProtocol;


@interface ArrangeViewController : UIViewController {
	id <FlipViewProtocol, ArrangeViewProtocol> delegate;
}

@property (nonatomic, retain) id <ArrangeViewProtocol, FlipViewProtocol> delegate;

- (IBAction) returnToMain:(id)sender;

@end

@protocol ArrangeViewProtocol
@end
