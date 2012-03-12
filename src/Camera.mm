//
//  Camera_.m
//  TetheredCapture
//
//  Created by Brett Renfer on 3/11/12.
//  Copyright (c) 2012 Robotconscience. All rights reserved.
//

#import "Camera.h"
#import "Events.h"

@implementation CameraDelegate

@synthesize bReady;
@synthesize bTakingPhotos;
@synthesize device;

ofxOSXImageCapture::Camera *    ofCamera = NULL;

// initialize with device

-(void) initWithDevice:(ICCameraDevice*)_device camera:(ofxOSXImageCapture::Camera *)camera{
    self.device = _device;
    self.device.delegate = self;
    ofCamera = camera;
}

/************************************************************
    DEVICE DELEGATE
************************************************************/

- (void)deviceDidBecomeReady:(ICDevice*)device {
    ofCamera->onDeviceReady();
    if ([self.device.capabilities containsObject:ICCameraDeviceCanTakePicture]){
        [self.device requestEnableTethering];
    } 
}

- (void)didRemoveDevice:(ICDevice*)removedDevice {
    ofCamera->onDeviceRemoved();
}

/************************************************************
     CAMERA DEVICE DELEGATE
************************************************************/
 
// called when loading new + old photos
- (void)cameraDevice:(ICCameraDevice*)camera didAddItem:(ICCameraItem*)item {
    if (ofCamera != NULL){
        if (ofCamera->isTakingPicture()){
            NSDictionary* options = [NSDictionary dictionaryWithObject:[NSURL fileURLWithPath:[NSString stringWithUTF8String:((string)ofToDataPath("", true)).c_str()]] forKey:ICDownloadsDirectoryURL];
            
            ofCamera->capturedImage( item );
            
            [camera requestDownloadFile:item options:options downloadDelegate:self didDownloadSelector:@selector(didDownloadFile:error:options:contextInfo:) contextInfo:NULL];
        } else {
            ofCamera->foundImage( item );
        }
    }
}


- (void) deviceDidBecomeReadyWithCompleteContentCatalog:(ICCameraDevice*)device {
    NSLog(@"Camera is all the way ready...");
}

/************************************************************
    DOWNLOAD DELEGATE
************************************************************/

// Download delegate
- (void)didDownloadFile:(ICCameraFile*)file error:(NSError*)error options:(NSDictionary*)options contextInfo:(void*)contextInfo
{
    NSLog( @"didDownloadFile called with:\n" );
    NSLog( @"  file:        %@\n", file );
    NSLog( @"  error:       %@\n", error );
    NSLog( @"  options:     %@\n", options );
    NSLog( @"  contextInfo: %p\n", contextInfo );
    ofCamera->downloadedImage( file );
}

- (void)didReceiveDownloadProgressForFile:(ICCameraFile*)file downloadedBytes:(off_t)downloadedBytes maxBytes:(off_t)maxBytes {
    
}

@end

namespace ofxOSXImageCapture {
    
    //--------------------------------------------------------------
    Camera::Camera ( ICCameraDevice * _cocoaCamera ){
        cocoaCamera = _cocoaCamera;
        bActive = true;
        bOpen = bOpening = bClosing = bTakingPicture = false;
    }
    
    //--------------------------------------------------------------
    void Camera::open(){
        if (!bActive || bOpening) return;
        bOpening = true;
        [cocoaCamera requestOpenSession];
    }
    
    //--------------------------------------------------------------
    void Camera::close(){
        if (!bActive || bClosing) return;
        bOpen = false;
        bClosing = true;
        [cocoaCamera requestCloseSession];
    }
    
    //--------------------------------------------------------------
    void Camera::takePicture(){
        if (!bActive) return;
        if (!bTakingPicture){
            if (canTakePicture()){
                bTakingPicture = true;
                [cocoaCamera requestTakePicture];
            }
        }
    }
    
    //--------------------------------------------------------------
    bool Camera::isReady(){
        return bOpen;
    }
    
    //--------------------------------------------------------------
    bool Camera::isTakingPicture(){
        if (!bActive) return false;
        return bTakingPicture;
    }
    
    //--------------------------------------------------------------
    bool Camera::canTakePicture(){
        if (!bActive) return false;
        return [cocoaCamera.capabilities containsObject:ICCameraDeviceCanTakePicture];
    }
    
    //--------------------------------------------------------------
    vector <string> Camera::getImages(){
        return downloadedImages;
    }
    
    //--------------------------------------------------------------
    // access to lower-level ICCameraItems
    //--------------------------------------------------------------
    vector<ICCameraItem *> Camera::getNewItems(){
        return newFiles;
    }
    
    //--------------------------------------------------------------
    vector<ICCameraItem *> Camera::getExistingItems(){
        return existingFiles;
    }
    
    //--------------------------------------------------------------
    // CALLED FROM DELEGATE
    //--------------------------------------------------------------
    void Camera::downloadedImage( ICCameraItem* image ){
        if (bTakingPicture){
            bTakingPicture = false;
            
            currentImage = string([[image name] UTF8String]);
            downloadedImages.push_back( currentImage );
            
            ofNotifyEvent(Events.onNewImage, currentImage, this);
        } else {
            // just from the first time you opened camera
            existingFiles.push_back( image );
        }
    }
    
    //--------------------------------------------------------------
    void Camera::capturedImage( ICCameraItem* image ){
        newFiles.push_back( image );
    }
    
    //--------------------------------------------------------------
    void Camera::foundImage( ICCameraItem* image ){
        existingFiles.push_back( image );
    }

    //--------------------------------------------------------------
    void Camera::onDeviceRemoved(){
        bActive = false;
        bOpen = bOpening = bClosing = bTakingPicture = false;
        ofNotifyEvent(Events.onDeviceRemoved, *this, this);
    }
    
    //--------------------------------------------------------------
    // This is a little misleading... the device has been ready for a bit,
    // but now it's 100% ready to accept new commands
    void Camera::onDeviceReady(){
        bOpen = true;
        bOpening = false;
        ofLog( OF_LOG_NOTICE, "Device is ready. Trying to start tether." );
        
    };
    
};