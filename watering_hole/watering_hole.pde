Water[] water = new Water[7]; 
Animal[] animals = new Animal[20]; 

void setup() {
  size(displayWidth, displayHeight);
  //center shape in windo
  noStroke();
  smooth();
  frameRate(30);
    for(int i = 0; i < water.length; i++){
    water[i] = new Water();
  }
  for(int i = 0; i < animals.length; i++){
    animals[i] = new Animal();
  }
} //<>//

void draw() {

  //fade background
  fill(255); 
  rect(0,0,width, height);
  for(int i = 0; i < animals.length; i++){
    animals[i].drawShape();
    animals[i].moveShape();
  }
   for(int i = 0; i < water.length; i++){
    water[i].drawShape();
  }
}


class Animal {
  //center point
  Water target = closestWater(); 
  float centerX = 0, centerY = 0;
  float radius = random(10,20), rotAngle = random(-50,-100);
  float accelX, accelY;
  float springing = .0085, damping = .98;
  //corner nodes
  int nodes = 5;
  float nodeStartX[] = new float[nodes];
  float nodeStartY[] = new float[nodes];
  float[]nodeX = new float[nodes];
  float[]nodeY = new float[nodes];
  float[]angle = new float[nodes];
  float[]frequency = new float[nodes];
  int[]fills = new int[255];
  // soft-body dynamics
  float organicConstant = 1;
  Animal(){   
    centerX = random(0,width); 
    centerY = random(0,height);
    // iniitalize frequencies for corner nodes
    for (int i=0; i<nodes; i++){
      frequency[i] = random(0, 7);
    }
  }
  void drawShape() {
    //  calculate node  starting locations
    for (int i=0; i<nodes; i++){
      nodeStartX[i] = centerX+cos(radians(rotAngle))*radius;
      nodeStartY[i] = centerY+sin(radians(rotAngle))*radius;
      rotAngle += 360.0/nodes;
    }
    // draw polygon
    curveTightness(organicConstant);
    fill(130);
    beginShape();
    for (int i=0; i<nodes; i++){
      curveVertex(nodeX[i], nodeY[i]);
    }
    for (int i=0; i<nodes-1; i++){
      curveVertex(nodeX[i], nodeY[i]);
    }
    endShape(CLOSE);
  }
  void moveShape() {
    //move center point
    float deltaX = mouseX-centerX;
    float deltaY = mouseY-centerY;
    // create springing effect
    deltaX *= springing;
    deltaY *= springing;
    accelX += deltaX;
    accelY += deltaY;
    // move predator's center
    centerX += accelX;
    centerY += accelY;
    // slow down springing
    accelX *= damping;
    accelY *= damping;
    // change curve tightness
    organicConstant = 1-((abs(accelX)+abs(accelY))*.1);
    //move nodes
    for (int i=0; i<nodes; i++){
      nodeX[i] = nodeStartX[i]+sin(radians(angle[i]))*(accelX*2);
      nodeY[i] = nodeStartY[i]+sin(radians(angle[i]))*(accelY*2);
      angle[i]+=frequency[i];
    }
  }
  Water closestWater(){
    
    float closestDist = Integer.MAX_VALUE;
    Water closestWater = new Water(); 
    for(int i = 0; i < water.length; i++){
      float dist =  sqrt(Math.round(Math.pow((water[i].centerX - centerX), 2) + Math.pow((water[i].centerY - centerY), 2)));
      println(dist);
      if(dist < closestDist){
        closestDist = dist; 
        closestWater = water[i]; 
      }
    }
    return closestWater;
  }
} 

class Water {
  //center point
  float centerX = 0, centerY = 0;
  float radius = random(10,20), rotAngle = random(-50,-100);
  float accelX, accelY;
  float springing = .0085, damping = .98;
  //corner nodes
  int nodes = 5;
  float nodeStartX[] = new float[nodes];
  float nodeStartY[] = new float[nodes];
  float[]nodeX = new float[nodes];
  float[]nodeY = new float[nodes];
  float[]angle = new float[nodes];
  float[]frequency = new float[nodes];
  int[]fills = new int[255];
  // soft-body dynamics
  float organicConstant = 1;
  Water(){
    centerX = random(0,width);
    centerY = random(0,height);

    // iniitalize frequencies for corner nodes
  
    for (int i=0; i<nodes; i++){
      frequency[i] = random(0, 7);
    }
  }
  
  void drawShape() {
  //  calculate node  starting locations
  for (int i=0; i<nodes; i++){
    nodeStartX[i] = centerX+cos(radians(rotAngle))*radius;
    nodeStartY[i] = centerY+sin(radians(rotAngle))*radius;
    rotAngle += 360.0/nodes;
  }
  // draw polygon
  curveTightness(organicConstant);
  fill(0,0,255);
  beginShape();
  for (int i=0; i<nodes; i++){
    curveVertex(nodeX[i], nodeY[i]);
  }
  for (int i=0; i<nodes-1; i++){
    curveVertex(nodeX[i], nodeY[i]);
  }
   organicConstant = 1-((abs(accelX)+abs(accelY))*.1);
  //move nodes
  for (int i=0; i<nodes; i++){
    nodeX[i] = nodeStartX[i]+sin(radians(angle[i]))*(accelX*2);
    nodeY[i] = nodeStartY[i]+sin(radians(angle[i]))*(accelY*2);
    angle[i]+=frequency[i];
  }
  endShape(CLOSE);
} 
}
