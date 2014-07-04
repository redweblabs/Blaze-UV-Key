#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofRegisterTouchEvents(this);
    
    initialBufferSize   = 512;
    sampleRate          = 44100;
    
    buffer              = new float[initialBufferSize];
    
    memset(buffer, 0, initialBufferSize * sizeof(float));
    
    ofSoundStreamSetup(1, 1, this, sampleRate, initialBufferSize, 4);
    ofSetFrameRate(60);
    
    width = 320;
    height = 580;
    
    ofEnableAntiAliasing();
    ofEnableSmoothing();
    
    ofSoundGetSpectrum(1);
    
    txt.setGlobalDpi(145);
    txt.setSpaceSize(0.6);
    txt.loadFont(fontName, 92);
    
    smallTxt.setGlobalDpi(145);
    smallTxt.setSpaceSize(0.6);
    smallTxt.loadFont("opensans-light.ttf", 12);
    
    background.loadImage("background.png");
    logo.loadImage("logo.png");
    
    loadingCoords.set(width / 2 - 75, height / 2 - 81);
    loading0.loadImage("loading/0.jpg");
    loading1.loadImage("loading/1.jpg");
    loading2.loadImage("loading/2.jpg");
    loading3.loadImage("loading/3.jpg");
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    float avg_power = 0.0f;	
    
    myfft.powerSpectrum(0, (int)initialBufferSize/2, buffer, initialBufferSize, &magnitude[0], &phase[0], &power[0], &avg_power);
    
    static int index=0;
    
    myfft.powerSpectrum(0, (int)initialBufferSize/2, buffer, initialBufferSize, &magnitude[0], &phase[0], &power[0], &avg_power);
    
    for(int j=1; j < BUFFER_SIZE/2; j++) {
		freq[index][j] = magnitude[j];
	}
	
    int start = 0;
    
    for(int i = start + 5; i < (int)(BUFFER_SIZE / 2); i += 1){
        magnitude[i] = (magnitude[i-5] + magnitude[i-4] + magnitude[i-3] + magnitude[i-2] + magnitude[i-1] + magnitude[i] + magnitude[i+1] + magnitude[i+2] + magnitude[i+3] + magnitude[i+4] + magnitude[i+5]) / 10;
    }
    
    if((magnitude[62] + magnitude[63] + magnitude[64]) / 3  > 8){
        
        binPos = 0;
        
        for(int k = 0; k < binSize; k += 1){
            
            binary[k] = 0;
            
        }
        
        analysed = false;
        
    }
    
    if((magnitude[42] + magnitude[43] + magnitude[44]) / 3  > 8){
        
        if(!analysed){
            processBinary();
        }
        
        cout << "\n";
        
    }

}

void ofApp::draw(){
    
    ofBackgroundHex(uvColor);
    
    long grabTime = 50000;
    
    if((magnitude[90] + magnitude[91] + magnitude[92]) / 3 > 8){
          
        if(ofGetElapsedTimeMicros() - lastMeasure > grabTime){
            cout << 0;
            binary[binPos] = 0;
            binPos += 1;
            
            lastMeasure = ofGetElapsedTimeMicros();
        }
        
    }
    
    if((magnitude[23] + magnitude[24] + magnitude[25]) / 3 > 10){
        if(ofGetElapsedTimeMicros() - lastMeasure > grabTime){
            cout << 1;
            binary[binPos] = 1;
            binPos += 1;
            
            lastMeasure = ofGetElapsedTimeMicros();
        }
        
    }

    
    ofBackground(255, 255, 255);
 
    buttonCoords.set ( width / 2 - 100, (height / 2) - 25);
    
    if(!buttonTapped){
        
        ofSetColor(0, 0, 0);
        ofRectRounded(buttonCoords, 200, 50, 30);
        
        if(!buttonDown){
            ofSetColor(255, 255, 255);
        } else {
            ofSetColor(0, 0, 0);
        }
        
        ofFill();
        
        buttonCoords.x += 2;
        buttonCoords.y += 2;
        
        ofRectRounded(buttonCoords, 196, 46, 30);
        
        if(!buttonDown){
            ofSetColor(0, 0, 0);
        } else {
            ofSetColor(255, 255, 255);
        }
        
        smallTxt.drawString("scan now", buttonCoords.x + 45, buttonCoords.y + 30);
        
        ofSetColor(255, 255, 255);
        
    } else {
        
        if(ofGetElapsedTimeMillis() - tapTime < 3000){
            
            if(ofGetElapsedTimeMillis() - frameTime < 250){
                
                switch (loadingPoint) {
                    case 0:
                        loading0.draw(loadingCoords);
                        break;
                    
                    case 1:
                        loading1.draw(loadingCoords);
                        break;
                        
                    case 2:
                        loading2.draw(loadingCoords);
                        break;
                        
                    case 3:
                        loading3.draw(loadingCoords);
                        break;
                        
                    default:
                        break;
                }
                
            } else {
                
                frameTime = ofGetElapsedTimeMillis();
                
                loading0.draw(loadingCoords);
                
                if(loadingPoint < 3){
                    loadingPoint += 1;
                } else {
                    loadingPoint = 0;
                }
                
            }
            
        } else {
            ofSetColor(0,0,0);
            txt.drawString(ofToString(currentUVReading), (width / 2) - 50, (height / 2) + 50);
        }   
    
    }

}

void ofApp::processBinary(){
    
    if(binPos < binSize){
        analysed = true;
        return;
    } else {
        cout << "\n";
    }
    
    for(int u = 0; u < binSize; u += 1){
        
        cout << binary[u] << "__";
        
    }
    
    string builtString = "";
    
    for(int l = 0; l < binSize; l += 1){
        
        builtString += ofToString(binary[l]);
        
    }
    
    cout << "string: " << builtString << "\n";
    
    cout << ofToInt(builtString) << "\n";
    
    binaryToBase10(ofToInt(builtString));
    
    analysed = true;
    
}

int ofApp::binaryToBase10(int n){
    int output = 0;
    
    for(int i=0; n > 0; i++) {
        
        if(n % 10 == 1) {
            output += (1 << i);
        }
        n /= 10;
    }
    
    if(output > 15){
        return 0;
    }
    
    cout << "output: " << output << "\n";
    
    currentUVReading = output;
    if(output == 0){
        
        uvColor = BLACK;
        
    } else if(output <= 2 && output > 0){
        
        uvColor = GREEN;
        
    } else if(output >= 3 && output <= 5){
        
        uvColor = YELLOW;
        
    } else if(output >= 6 && output <= 7){
        
        uvColor = ORANGE;
        
    } else if(output >= 8 && output <= 10){
        
        uvColor = RED;
    
    } else if(output >= 11){
        
        uvColor = PURPLE;
        
        currentUVReading = 11;
        
    }
    
    return output;
}

void ofApp::audioIn(float *input, int bufferSize, int nChannels){
    
    if(ofGetElapsedTimeMillis() - lastGrab < 10 && lastGrab != 0){
        return;
    }
    
    // just makes sure we didn't set "initialBufferSize" to something our audio card can't handle.
    if( initialBufferSize != bufferSize ){
        ofLog(OF_LOG_ERROR, "your buffer size was set to %i - but the stream needs a buffer size of %i", initialBufferSize, bufferSize);
        return;
    }
    
    // we copy the samples from the "input" which is our microphone, to a variable
    // our entire class knows about, buffer.  this buffer has been allocated to have
    // the same amount of memory as each "Frame" or "bufferSize" of audio has.
    // so we copy the whole 512 sample chunk into our buffer so we can draw it.
    for (int i = 0; i < bufferSize; i++){
        buffer[i] = input[i];
    }
    
    lastGrab = ofGetElapsedTimeMillis();
    
}

void ofApp::audioOut(float *output, int bufferSize, int nChannels, int deviceID, unsigned long long tickCount){

}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    if(touch.x > buttonCoords.x && touch.x < buttonCoords.x + 200){
        
        if(touch.y > buttonCoords.y && touch.y < buttonCoords.y + 50){
            buttonDown = true;
        }
        
    }
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
    if(!buttonTapped){
        
        if(touch.x > buttonCoords.x && touch.x < buttonCoords.x + 200){
            
            if(touch.y > buttonCoords.y && touch.y < buttonCoords.y + 50){
                buttonTapped = true;
                buttonDown = false;
                tapTime = ofGetElapsedTimeMillis();
                frameTime = tapTime;
            }
            
        }
    
    }

}

