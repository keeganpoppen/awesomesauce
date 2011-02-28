//
//  ArrangeViewController.h
//  awesomesauce
//
//  Created by Ravi Parikh on 2/27/11.
//  Copyright 2011 AwesomeBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ArrangeViewProtocol;


@interface ArrangeViewController : UIViewController {
	id <ArrangeViewProtocol> delegate;
}

@property (nonatomic, retain) id <ArrangeViewProtocol> delegate;

- (IBAction) returnToMain:(id)sender;

@end

@protocol ArrangeViewProtocol
-(void) closeArrangeView;
@end
