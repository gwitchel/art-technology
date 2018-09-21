
import processing.sound.*;
// Declare the processing sound variables 
SoundFile sample;
Amplitude rms;
float scale = 5.0;// Declare a scaling factor
float smoothFactor = 0.25;// Declare a smooth factor
float sum; // Used for smoothing 
int x = 0; 
float[] prev = {0,0} ;
ArrayList slopes = new ArrayList();
ArrayList mainPnts = new ArrayList();
Flock flock;
boolean instantiate = false; 
void setup() {
  flock = new Flock();
  size(1000, 600);
  background(#6D6875);
  //Load and play a soundfile and loop it
  sample = new SoundFile(this, "beat.aiff");
  sample.loop();

  // Create and patch the rms tracker
  rms = new Amplitude(this);
  rms.input(sample);
}      

void draw() {
  // Set background color, noStroke and fill color
  //noStroke();
  stroke(255, 0, 150);
  // Smooth the rms data by smoothing factor
  sum += (rms.analyze() - sum) * smoothFactor;  
  // rms.analyze() return a value between 0 and 1. It's
  // scaled to height/2 and then multiplied by a scale factor
  float rmsScaled = sum * (height/2) * scale;
  // Draw an ellipse at a size based on the audio analysis
  FlockPoint a = new FlockPoint(prev[0],prev[1]); 
  FlockPoint b = new FlockPoint(x,rmsScaled); 
  line(prev[0],prev[1], x,  rmsScaled );
  prev[0] = x; 
  prev[1] =  rmsScaled;
  if(x == width){   
    sample.stop();
    findchangePoints(); 
    x ++;  
  } else if(x <= width) {
    slopes.add(new FlockPointJoiner(a,b)); 
    x++; 
  } else {
    background(255);
    for(int i = 0; i < mainPnts.size()-1; i++){
       FlockPointChange c = (FlockPointChange) mainPnts.get(i);
       c.draw(); 
    }
    flock.run();
  }
}
class FlockPoint {
  // make sure its in terms of a vector centered around the origin.
  float x;
  float y; 
  boolean isMajor = false; 
  FlockPoint(float xpos, float ypos){
    x = xpos; 
    y = ypos; 
  }
}
class FlockPointJoiner {
  FlockPoint child;
  FlockPoint parent; 
  float slope; 
  float magnitude; 
  FlockPointJoiner(FlockPoint c, FlockPoint p){
    child = c; 
    parent = p; 
    slope = (child.y - parent.y)/(child.x-parent.x);
    magnitude = sqrt(pow((child.y - parent.y),2) + pow((child.x - parent.x),2));
  }
}
class FlockPointChange {
  // make sure its in terms of a vector centered around the origin.
  float x;
  float y;
  float mag = 5; 
  FlockPointChange(float xpos, float ypos,float m ){
    x = xpos; 
    y = ypos;
    mag = m/5; 
   for (int i = 0; i < mag; i++) {
    flock.addBoid(new Boid(x,y));
   }
  }
  void draw(){
    fill(#E5989B); 
    stroke(#B5838D); 
    ellipse(x,y,1,1);
  }
}
void findchangePoints(){
  mainPnts.clear(); 
  for(int i = 1; i < slopes.size()-1; i++){
    FlockPointJoiner a = (FlockPointJoiner) slopes.get(i);
    FlockPointJoiner b = (FlockPointJoiner) slopes.get(i-1);
     if(a.slope > 0 && b.slope < 0 || a.slope < 0 && b.slope > 0) {
       mainPnts.add(new FlockPointChange(a.child.x, a.child.y,a.magnitude));
     } 
  }
}













class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids
  Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }
  void run() {
    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }
  void addBoid(Boid b) {
    boids.add(b);
  }
}

class Boid {
  float fill = random(0,255); 
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
    Boid(float x, float y) {
    acceleration = new PVector(0, 0);
    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();
    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    position = new PVector(x, y);
    r = 2.0;
    maxspeed = 2;
    maxforce = 0.03;
  }
  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }
  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }
  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    
    fill(fill);
    noStroke(); 
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    //ellipse(0,0,5,5); 
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
}
