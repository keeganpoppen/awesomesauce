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
    static const GLfloat normals[] = {
        0, 0, 1,
        0, 0, 1,
        0, 0, 1,
        0, 0, 1
    };
    
    static const GLfloat texCoords[] = {
        0, 1,
        1, 1,
        0, 0,
        1, 0
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
	
	
	// enable texture mapping
    glEnable( GL_TEXTURE_2D );
    // enable blending
    glEnable( GL_BLEND );
    // blend function
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
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
			glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			glTranslatef( x, y, 0.0 );
			// vertex
			glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
			// normal
			glNormalPointer( GL_FLOAT, 0, normals );
			// texture coordinate
			glTexCoordPointer( 2, GL_FLOAT, 0, texCoords );
			
			// triangle strip
			glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
			glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			glPopMatrix();
		}
	}
	
	
    // disable
    glDisable( GL_TEXTURE_2D );
    glDisable( GL_BLEND );
}

/*
 * END TouchMatrixDisplay methods
 */

bool pad_is_on;
bool current_touches[16][16];
GLuint g_texture[1];

void resetCurrentTouches() {
	for (int i = 0; i < 16; ++i) {
		for (int j = 0; j < 16; ++j) {
			current_touches[i][j] = false;
		}
	}
}

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
		
		//TODO: better location detection
		//TODO: don't use magic numbers for 20 and 10
		int xval = (int) (location.x - 10.0) / 20.0;
		int yval = (int) (location.y - 10.0) / 20.0;
		NSLog( @"began: %d, %d", xval, yval );
		if( touch.phase == UITouchPhaseBegan )
        {
			
			//TODO: toggle point
			pad_is_on = [(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] toggleTouch:xval withYval:yval];
			current_touches[xval][yval] = true;
		}
		else if( touch.phase == UITouchPhaseMoved )
        {
			if(!current_touches[xval][yval]) {
				[(awesomesauceAppDelegate *)[[UIApplication sharedApplication] delegate] setTouch:xval withYval:yval withBool:pad_is_on];
				current_touches[xval][yval] = true;
			}
			//NSLog( @"moved: %f, %f,", location.x, location.y );
			//eventually we will handle this case, but for now no
		}
		else if( touch.phase == UITouchPhaseEnded )
        {
			resetCurrentTouches();
			//NSLog( @"moved: %f, %f,", location.x, location.y );
			//eventually we will handle this case, but for now no
		}
    }
}

// initialize
bool graphicsInit() {
	MoTouch::addCallback( touchCallback, NULL );
	resetCurrentTouches();
	
	// TEXTURE STUFF
    // generate texture name
    glGenTextures( 1, &g_texture[0] );
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, g_texture[0] );
    // setting parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	//load the texture
    MoGfx::loadTexture( @"square_texture", @"png" );
	
	return true;
}
