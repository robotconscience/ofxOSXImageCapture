#pragma once

#include "ofMain.h"

#include "ofxOSXImageCapture.h"

class testApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed  (int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
        
        void gotNewImage( string & image );
        
        // Core object
        ofxOSXImageCapture::DeviceManager   imageCapture;
        ofxOSXImageCapture::Camera*         camera;
    
        // fun stuff
        ofTrueTypeFont font;
        int time;
    
        // helpers
        bool    bCaptureStarted, bCaptured, bICSetup;
    
        ofImage img;
        string  latestImage;
};
