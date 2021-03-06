//--Path following with behaviors 3D--
//--Flocking, Wander, Separate are all active-- use keys to disable--
//--paths are not visible by default, use the 'd' key to show paths--

//--***This library depends on 2 external libraries (peasy, toxiclibs) which you can download below***
//--Peasy - http://mrfeinberg.com/peasycam/
//--Toxi - https://bitbucket.org/postspectacular/toxiclibs/downloads/

import java.util.List;
import culebra.objects.*;
import culebra.viz.*;
import culebra.data.*;

import toxi.geom.*;
import toxi.color.*;
import peasy.*;

Creeper creep;
List<Creeper> creeperSet;
PVector loc;
PVector vel;
// ---------------------Behavior Flags-----------------
boolean createTrails = true;
boolean cohFlag = false;
boolean sepFlag = true;
boolean aligFlag = false;
boolean flockFlag = true;
boolean wanderFlag = true;
boolean drawConn = true;
// --------------------Path Stuff--------------------
Path tempPath;
ArrayList<Path> pathList;
int pathCount = 10;
boolean drawPaths = false;
float scalarProjectionDist;
float pathRadius = 20.0f;
// -------------------Environ Stuff--------------------
int creepCount = 500;
PImage img0, img2;
int nHeight = 1000;
// ----------------------Camera-------------------------
PeasyCam cam;
Cameras cams;
CameraState state;
int camToggle = 0;
// -------------------Spawn Stuff--------------------
boolean spawnGround = false;
boolean spawnEdge = false;
// -----------------------Setup-----------------------
public void setup() {
  size(1400, 800, P3D);
  smooth();
  background(0);

  this.img0 = loadImage("LULZ.png");
  this.img2 = loadImage("SI.png");

  this.cams = new Cameras(this);
  if (this.camToggle < 1) {
    this.camToggle++;
    int[] lookat = new int[] { this.width / 2, this.height / 2, this.nHeight / 2 };
    this.cams.set3DCamera(1500, 100, 10000, lookat, true);
  }

  this.creeperSet = new ArrayList<Creeper>();
  scalarProjectionDist = 50.0f;
  pathList = new ArrayList<Path>();

  for (int pth = 0; pth < this.pathCount; pth++) {
    newPath();
  }

  for (int i = 0; i < creepCount; i++) {
      if (this.spawnGround) {
        this.loc = new PVector(random(width), random(height), 0);
        this.vel = new PVector(random(-1.5, 1.5), random(-1.5, 1.5), random(0, 2));
      } else if (this.spawnEdge) {
        this.loc = new PVector(random(width), random(height), 0);
        this.vel = new PVector(random(-1.5, 1.5), random(-1.5, 1.5), random(0, 2));
      } else {
        this.loc = new PVector(random(width), random(height), random(0, nHeight));
        this.vel = new PVector(random(-1.5, 1.5), random(-1.5, 1.5), random(-1.5, 1.5));
      }  
    this.creep = new Creeper(loc, vel, true, true, this);
    this.creeperSet.add(this.creep);
  }
}
// -----------------------Draw-----------------------
public void draw() {
  background(0);
  drawExtents();
  // -----------------------PATH STUFF-----------------------
  if (this.pathList != null) {
    for (Path pths : pathList) {
      pths.setPathRadius(pathRadius);
      if (drawPaths) {

        stroke(175, 0, 0, 50);
        strokeWeight(pths.getPathRadius() * 2);
        noFill();
        beginShape();
        for (PVector v : pths.getPathPoints()) {
          vertex(v.x, v.y, v.z);
        }
        endShape();

        // Draw thin line for center of path
        stroke(255);
        strokeWeight(1);
        noFill();
        beginShape();
        for (PVector v : pths.getPathPoints()) {
          vertex(v.x, v.y, v.z);
        }
        endShape();
      }
    }
  }
  // -----------------------------------------------------------------
  // -----------------------CREEPER AGENTS---------------------------
  // -----------------------------------------------------------------
  for (Creeper c : this.creeperSet) {
    c.setMoveAttributes(2.0f, 0.2f, 1.5f);
    c.behavior.pathFollower(this.pathList, 1000, scalarProjectionDist, pathRadius);

    if (this.aligFlag) {
      c.behavior.creeperAlign(30.0f, 0.045f, creeperSet);
    }
    if (this.sepFlag) {
      c.behavior.creeperSeparate(5.0f, creeperSet);
    }
    if (this.cohFlag) {
      c.behavior.creeperCohesion(30.0f, 0.045f, creeperSet);
    }
    if (this.wanderFlag) {
      float change = 100;
      //c.behavior.wander3D(change, 10.0f, 20.0f, 6.0f);
      //c.behavior.wander3D_subA(change, 10.0f, 20.0f, 6.0f);
      c.behavior.wander3D_subB(change, 10.0f, 20.0f, 6.0f);
      c.behavior.wander3D_Mod(change, 10.0f, 20.0f);
      c.behavior.wander3D_Mod2(change, 10.0f, 20.0f);
      c.behavior.wander3D_Mod3(change, 10.0f, 20.0f);
    }
    if (this.flockFlag) {
        c.behavior.creeperflock(30.0f, 0.14f, 0.09f, 0.045f,360.0f, creeperSet, this.drawConn);
    }      
    c.bounce(width, height);
    c.move(0, 1000);
    if (createTrails) {
      if (c instanceof Creeper) {  
        // --------Draw trails with color and with gradient--------
        float colorA[] = new float[] { 1f, 0f, 0f };
        float colorB[] = new float[] { 0.73f, 0.84f, 0.15f };
        c.viz.drawGradientTrails(c.getTrailPoints(), 1000, colorA, colorB, 255.0f, 1.0f);
      }
    }       
    pushStyle();
    stroke(255);
    strokeWeight(4);
    point(c.getLocation().x, c.getLocation().y, c.getLocation().z);
    popStyle();

    image(img2, width-290, height-85);
    image(img0, 0, height-105);
    textSize(20);
    text("Framerate: " + (frameRate), 80, height - 6);
  }
  surface.setSize(width, height);
}
// ------------------------Create Paths----------------------------------
public void keyPressed() {
  if (key == 'r')
    setup();
  if (key == 't')
    this.createTrails = !this.createTrails;
  if (key == 'd')
    drawPaths = !drawPaths;
  if (key == 'c')
    this.cohFlag = !this.cohFlag;
  if (key == 'a')
    this.aligFlag = !this.aligFlag;
  if (key == 's')
    this.sepFlag = !this.sepFlag;
  if (key == 'f')
    this.flockFlag = !this.flockFlag;
  if (key == 'w')
    this.wanderFlag = !this.wanderFlag; 
  if (key == '1')
    this.drawConn = !this.drawConn;
}
// ---------------------------------------Create
// StaticPaths---------------------------------
void newPath() {
  this.tempPath = new Path();
  this.tempPath.addPoint(random(0, 300), random(0, height), random(0, this.nHeight));
  this.tempPath.addPoint(random(0, width / 2), random(0, height), random(0, this.nHeight));
  this.tempPath.addPoint(random(0, width), random(0, height), random(0, this.nHeight));
  this.tempPath.addPoint(random(0, width), 0, random(0, this.nHeight));
  this.pathList.add(this.tempPath);
}
void drawExtents() {
  pushStyle();
  pushMatrix();
  strokeWeight(0.5f);
  stroke(200);
  noFill();
  translate(width / 2, height / 2, this.nHeight / 2);
  box(width, height, this.nHeight);
  popMatrix();
  popStyle();
}