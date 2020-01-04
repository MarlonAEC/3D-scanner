import processing.serial.*;
import processing.opengl.*;
import kinectOrbit.*;
import SimpleOpenNI.*;

KinectOrbit myOrbit;
SimpleOpenNI kinect;

String portName;// = Serial.list()[1];
Serial myPort;// = new Serial(this, portName,9600);// puerto serie por el cual se envia la informacion de si se movió o no el motor
boolean serial = false; // definiendo si se movio el motor
int value_of_angle = 0;
//Inicialización de los vectores para la nube de puntos
ArrayList<PVector> scanPoints = new ArrayList<PVector>(100000); // nube de puntos
ArrayList<PVector> scanColors = new ArrayList<PVector>(100000); // color del objeto
ArrayList<PVector> objectPoints = new ArrayList<PVector>(100000);// nube de puntos
ArrayList<PVector> objectColors = new ArrayList<PVector>(100000);// color del objeto

//Escaneando las variables del espacio
float baseHeight = -67;
float modelWidth = 400;
float modelHeight = 400;
PVector axis = new PVector(0, baseHeight, 1050);

//Parametros de Escaneo
int scanLines = 200;
int scanRes = 1;
boolean scanning;
boolean arrived;
int turnTableAngle = 0;
float[] shotNumber = new float[3];
int currentShot = 0;

void drawPointCloud(int steps) {
      // draw the 3D point depth map
      int index;
      PVector realWorldPoint;
      stroke(255);
      for (int y = 0; y < kinect.depthHeight(); y += steps) {
          for (int x = 0; x < kinect.depthWidth(); x += steps) {
                index = x + y * kinect.depthWidth();
                realWorldPoint = kinect.depthMapRealWorld()[index];
                stroke(150);
                point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
          }
      }
}

void drawObjects() {
      pushStyle();
      strokeWeight(4);
      for (int i = 1; i < objectPoints.size(); i++) {
            stroke(objectColors.get(i).x, objectColors.get(i).y, objectColors.get(i).z);
            point(objectPoints.get(i).x, objectPoints.get(i).y, objectPoints.get(i).z + axis.z);
      }
      for (int i = 1; i < scanPoints.size(); i++) {
            stroke(scanColors.get(i).x, scanColors.get(i).y, scanColors.get(i).z);
            point(scanPoints.get(i).x, scanPoints.get(i).y, scanPoints.get(i).z + axis.z);
      }
      popStyle();
}

void setup()
{
     size(800, 600, OPENGL);
     myOrbit = new KinectOrbit(this, 0, "kinect");
     myOrbit.drawCS(true);
     myOrbit.drawGizmo(true);
     myOrbit.setCSScale(200);
     myOrbit.drawGround(true);
      
     kinect = new SimpleOpenNI(this);
     kinect.setMirror(false);
     kinect.enableDepth();
     kinect.enableRGB();
     kinect.alternativeViewPointDepthToImage();
     portName = Serial.list()[1];
     myPort = new Serial(this, portName,9600);
     
     //println(Serial.list());
     if(serial){

         myPort.bufferUntil('\n');
      }
}

void scan() {
    for (PVector v : scanPoints) {
        boolean newPoint = true;
        for (PVector w : objectPoints) {
              if (v.dist(w) < 1)
                  newPoint = false;
        }
     //  if (newPoint) {
              objectPoints.add(v.get());
              int index = scanPoints.indexOf(v);
              objectColors.add(scanColors.get(index).get());}
    if (currentShot <8){
      currentShot++;      
      moveTable();
  turnTableAngle += 45;
//      println(currentShot);
//      println(shotNumber);
      }
      else 
          scanning = false;
    //println("TERMINE");
     arrived = false;
  
  println(objectPoints.size());
}

void updateObject(int scanWidth, int step)
{
    int index;
    PVector realWorldPoint;
    scanPoints.clear();
    scanColors.clear();
    
    float angle = map(turnTableAngle, 0, 360, 0, 2 * PI);
    pushMatrix();
    translate(axis.x, axis.y, axis.z);
    rotateY(angle);
    line(0,0,100,0);
    popMatrix();
    int xMin = (int) (kinect.depthWidth() / 2 - scanWidth / 2); int xMax = (int)(kinect.depthWidth() / 2 + scanWidth / 2);
     for (int y = 0; y < kinect.depthHeight(); y += step) {
          for (int x = xMin; x < xMax; x += step) {
                index = x + (y * kinect.depthWidth());
                realWorldPoint = kinect.depthMapRealWorld()[index];
                color pointCol = kinect.rgbImage().pixels[index];
                if (realWorldPoint.y < modelHeight + baseHeight && realWorldPoint.y > baseHeight) {
                     if (abs(realWorldPoint.x - axis.x) < modelWidth / 2) { // Check x
                          if (realWorldPoint.z < axis.z + modelWidth / 2 && realWorldPoint.z > axis.z -modelWidth / 2) { // Check z
                                PVector rotatedPoint;         
                                realWorldPoint.z -= axis.z;
                                realWorldPoint.x -= axis.x;
                                rotatedPoint = vecRotY(realWorldPoint, angle);   
                                scanPoints.add(rotatedPoint.get());
                                scanColors.add(new PVector(red(pointCol), green(pointCol), blue(pointCol)));
                            }
                       }
                  }
            }
       }
}

PVector vecRotY(PVector vecIn, float phi) {
      // Rotate the vector around the y-axis
      PVector rotatedVec = new PVector();
      rotatedVec.x = vecIn.x * cos(phi) - vecIn.z * sin(phi);
      rotatedVec.z = vecIn.x * sin(phi) + vecIn.z * cos(phi);
      rotatedVec.y = vecIn.y;
      return rotatedVec;
}

void moveTable() {
      myPort.write("H");
      //myPort.write((int) map(angle, 0, 2*PI, 0, 255));
      //println("new angle = " + angle);
}

public void serialEvent(Serial myPort) {
      // get the ASCII string:
      String inString = myPort.readString();
  
   if(inString != null)
     inString.trim();
     if (inString.equals("B")) {
    arrived = true;
    println("arrived");
//     turnTableAngle += 10;                                  
                 
      println(inString);
            //inString = inString.substring(0, inString.indexOf('\n') - 1);
    /* if( inString != null ){
           if(currentShot < 8){
                 scan();*/
                  /*  delay(5000);
                 //inString = myPort.readString();
                  currentShot++;
                  serial = true;
           }
       } */          
     }


}

//void leer()
//{
//  String S = myPort.readString();
//  println(S);
//}

void drawBoundingBox() {
    stroke(255, 0, 0);
    line(axis.x, axis.y, axis.z, axis.x, axis.y + 100, axis.z);
    noFill();
    pushMatrix();
    translate(axis.x, axis.x + baseHeight + modelHeight / 2, axis.z);
    box(modelWidth, modelHeight, modelWidth);
    popMatrix();
}

void exportPly(char key) {
      PrintWriter output;
      String viewPointFileName;
      viewPointFileName = "myPoints" + key + ".ply";
      output = createWriter(dataPath(viewPointFileName));
      output.println("ply");
      output.println("format ascii 1.0");
      output.println("comment This is your Processing ply file");
      output.println("element vertex " + (objectPoints.size()-1));
      output.println("property float x");
      output.println("property float y");
      output.println("property float z");
      output.println("property uchar red");
      output.println("property uchar green");
      output.println("property uchar blue");
      output.println("end_header");
      for (int i = 0; i < objectPoints.size() - 1; i++) {
          output.println((objectPoints.get(i).x / 1000) + " "  
          + (objectPoints.get(i).y / 1000) + " "
          + (objectPoints.get(i).z / 1000) + " "
          + (int) objectColors.get(i).x + " "
          + (int) objectColors.get(i).y + " "
          + (int) objectColors.get(i).z);
      }
      output.flush(); // Write the remaining data
      output.close(); // Finish the file
}


public void keyPressed() {
      switch (key) {
      case 'r': // Send the turntable to start position
          moveTable();
          scanning = false;
      break;
      case 's': // Start scanning
          objectPoints.clear();
          objectColors.clear();
          currentShot = 0;
          scanning = true;
          arrived = false;
          //portName = Serial.list()[1];
          //myPort = new Serial(this, portName, 9600);
          myPort.write("H");
          //delay(2000);
          //println(myPort.readString());
      
if(scanning==false)
   exportPly('0');
        //  serialEvent(myPort);
          //myPort.write("H");
          //leer();          
      break;
      case 'c':
      // Clear the object points
     currentShot=0;
          objectPoints.clear();
          objectColors.clear();
      break;
      case 'e': // Export the object points
           exportPly('0');
           break;
      case '+': // Increment the number of scanned lines
            scanLines++;
            println(scanLines);
            break;
      case '-': // Decrease the number of scanned lines
            scanLines--;
            println(scanLines);
            break;
      }
}

public void draw()
{
     kinect.update();
     background(0);
     myOrbit.pushOrbit(this);
     drawPointCloud(2);
     updateObject(scanLines, scanRes);
    
if(scanning==false)
   exportPly('0');
 if (arrived && scanning) { scan(); }
    
     drawObjects();
     drawBoundingBox();
     //kinect.drawCamFrustrum();
     myOrbit.popOrbit(this);

}


