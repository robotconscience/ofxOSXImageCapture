OF ImageCapture interface
=======================================
Notes
* I'm pretty bad at writing Objective-C, so watch out for sketchy code
* Only works with cameras right now (scanners in the future maybe)
* Will work with any camera that works in Image Capture
* To use: 
 	- include + make a ofxOSXImageCapture object in your testApp
	- add a listener function for ofxOSXImageCapture.onNewImage event (returns string)
	- call listDevices()
	- wait until doneListing() returns true (this will change in the future...)
	- call openDevice( index ) where index is which device you want to open
		* note: untested for a bunch of devices... if you have scanners and cameras connected, the indexes are messed up. working on it!
	- if isDeviceReady() is true, go ahead and call takePicture()
	- captured images download to your bin/data folder 