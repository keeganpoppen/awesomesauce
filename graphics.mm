//
//  graphics.mm
//  awesomesauce
//
//  Created by Keegan Poppen on 2/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "graphics.h"
#import "mo_gfx.h"
#import "awesomesauceAppDelegate.h"

#import "mo_touch.h"

/*
 * TouchMatrixDisplay methods
 */

TouchMatrixDisplay::TouchMatrixDisplay(TouchMatrix *parentMatrix) {
	parent = parentMatrix;
}

void TouchMatrixDisplay::display() {
	// reset projection matrix
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glOrthof( -1.0f, 1.0f, -1.5f, 1.5f, 1.0f, 1.0f);
	
	// modelview
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	
	// set clear color to black
	glClearColor( 0, 0, 0, 1.0f );
	glClear( GL_COLOR_BUFFER_BIT );
	
	// map the viewport
	MoGfx::ortho( 320, 480, 1 );
	
	glEnableClientState( GL_VERTEX_ARRAY );
	
	//draw stuff sample
	
	static const GLfloat half_width = 10;
    static const GLfloat squareVertices[] = {
        -half_width, -half_width,
        half_width, -half_width,
        -half_width, half_width,
        half_width, half_width,
    };
	
	
	//active color: yellow
	GLfloat active_r = 1.0;
	GLfloat active_g = 1.0;
	GLfloat active_b = 0.3;
	
	//on color: blue
	GLfloat on_r = 0.3;
	GLfloat on_g = 0.5;
	GLfloat on_b = 1.0;
	
	//off color: dark grey
	GLfloat off_r = 0.1;
	GLfloat off_g = 0.1;
	GLfloat off_b = 0.1;
	
	/*
	parent->squares[1][1] = true;
	parent->squares[2][3] = true;
	parent->squares[3][4] = true;
	parent->squares[4][6] = true;
	 */
	
	int activeCol = parent->getColumn();
	
	for (int col = 0; col < 16; ++col) {
		for (int row = 0; row < 16; ++row) {
			glColor4f( off_r, off_g, off_b, 1.0 );
			//TODO: replace with checking if active for reals
			if(parent->squares[row][col]) {
				glColor4f( on_r, on_g, on_b, 1.0 );
				if(col == activeCol) {
					glColor4f( active_r, active_g, active_b, 1.0 );
				}
			}
			GLfloat x = 10.0 + row * 20.0;
			GLfloat y = 10.0 + col * 20.0;
			
			glPushMatrix();
			glTranslatef( x, y, 0.0 );
			// vertex
			glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
			
			// triangle strip
			glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
			glPopMatrix();
		}
	}
}

/*
 * END TouchMatrixDisplay methods
 */

// touch callback
void touchCallback( NSSet * touches, UIView * view, const std::vector<MoTouchTrack> & touchPts, void * data)
{
    // iterate over touch points
    CGPoint location;
    for( UITouch * touch in touches )
    {
        // get the location
        location = [touch locationInView:nil];
		
		// transform: to make landscape
        double temp = location.x;
        location.x = location.y;
        location.y = temp;
		if( touch.phase == UITouchPhaseBegan )
        {
			int xval = (int) (location.x - 10.0) / 20.0;
			int yval = (int) (location.y - 10.0) / 20.0;
			NSLog( @"began: %d, %d", xval, yval );
			
			//TODO: toggle point
			[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] registerTouch:xval withYval:yval];
		}
		else if( touch.phase == UITouchPhaseMoved )
        {
			//NSLog( @"moved: %f, %f,", location.x, location.y );
			//eventually we will handle this case, but for now no
		}
    }
}

// initialize
bool graphicsInit() {
	MoTouch::addCallback( touchCallback, NULL );
	return true;
}
