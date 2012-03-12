#include "testApp.h"

using namespace ofxOSXImageCapture;

//--------------------------------------------------------------
void testApp::setup(){
    // setup image capture + connect listener
    imageCapture.listDevices();
    ofAddListener(ofxOSXImageCapture::Events.onNewImage, this, &testApp::gotNewImage);
    
    // load font
    font.loadFont("frabk.ttf", 150);
    
    bCaptureStarted = bICSetup = false;
    ofBackground(ofRandom(50,150), ofRandom(50,150), ofRandom(50,150));
    
    camera = NULL;
} 

//--------------------------------------------------------------
void testApp::update(){
    
    // if done discovering devices, set up first device
    if ( imageCapture.doneListing() && camera == NULL && imageCapture.getCameras()->size() > 0){
        camera = imageCapture.openCamera(0);
    } else if ( imageCapture.doneListing() && imageCapture.getCameras()->size() <= 0 ){
        //cout<<"no cameras :("<<endl;
    }
    
    // set capture start time
    if (bCaptureStarted && time == -1){
        time = ofGetElapsedTimef();
    }
    
    // time for your close-up!
    if ( bCaptureStarted && ofGetElapsedTimef() - time >= 3){
        if (!bCaptured){
            bCaptured = true;
            
            // make sure we have a camera
            if ( camera != NULL ){
                // try to take a picture
                if ( camera->isReady()){
                    if ( camera->canTakePicture()){
                        camera->takePicture();
                    } else {
                        ofLog( OF_LOG_WARNING, "Your camera cannot take tethered pictures. Sorry!" );
                    }
                } else {
                    ofLog(OF_LOG_ERROR, "Device is not quite ready yet");
                }
            }
            
        }
    }
}

//--------------------------------------------------------------
void testApp::draw(){
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    string toDraw = "";
        
    if ( !imageCapture.doneListing()){
        toDraw = "discovering\ndevices";
    } else if ( imageCapture.getCameras()->size() <= 0){
        toDraw = "no cameras found\n:(";
    } else if ( camera != NULL && !camera->isReady()){
        toDraw = "connecting\nto camera";
    } else if (bCaptureStarted){
        if (ofGetElapsedTimef() - time > 3){
            toDraw = "Snap!";
        } else if (ofGetElapsedTimef() - time >= 2){
            toDraw = "1";
        } else if (ofGetElapsedTimef() - time >= 1){
            toDraw = "2";
        } else if (ofGetElapsedTimef() - time >= 0){
            toDraw = "3";
        }
    } else {
        toDraw = "hit space\nto start capture!";
    }
    
    font.drawString(toDraw, ofGetWidth()/2-font.stringWidth(toDraw)/2.0, ofGetHeight()/2.0-font.stringHeight(toDraw)/2.0 + font.getLineHeight()/2.0);
    if( img.bAllocated()) img.draw(ofGetWidth()/2, ofGetHeight()/2, ofGetWidth()*.75, ofGetHeight()*.75 );
}

//--------------------------------------------------------------
void testApp::gotNewImage( string & image ){
    img.loadImage( image );
    latestImage = ofToDataPath( image, true );
    bCaptureStarted = false;
}

//--------------------------------------------------------------
void testApp::keyPressed(int key){}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
	if(key == ' ') {
		if (!bCaptureStarted){
            img.clear();
            bCaptureStarted = true;
            bCaptured = false;
            time = -1;
            ofBackground(ofRandom(50,150), ofRandom(50,150), ofRandom(50,150));
        }
        //camera.takePhoto();
	}
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){}
