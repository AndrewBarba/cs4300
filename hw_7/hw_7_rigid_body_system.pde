/* ---------------------------------------------------------------------------
 * Rigid Body Particle System
 *
 * Reference: https://processing.org/examples/simpleparticlesystem.html
 * This reference helped me understand the PVector class and how it is
 * used to create a realistic fall for each particle.
 *
 *
 * Andrew Barba
 * CS4300 - Assignment 7
 * --------------------------------------------------------------------------- */

// Settings
int WIDTH  = 640;
int HEIGHT = 640;
int LIFETIME = 200;
int MAX_PARTICLES = 120;
float GRAVITY = 0.15;

// global system
ParticleSystem globalParticleSystem;

/* ---------------------------------------------------------------------------
/* Processing Setup
/* --------------------------------------------------------------------------- */

void setup() {

  // setup canvas
  size(WIDTH, HEIGHT);
  noStroke();
  smooth();

  // Start system
  globalParticleSystem = new ParticleSystem();
}

void draw() {

  // white background
  background(30);

  // Check if mouse moved at least a pixel
  // if so, emit a new particle
  if (abs(mouseX - pmouseX) > 1.0) {
    globalParticleSystem.emitParticle();
  }

  // Render the particle system on screen
  globalParticleSystem.drawSystem();
}

/* ---------------------------------------------------------------------------
/* Particle System
/* --------------------------------------------------------------------------- */

public class ParticleSystem {

  // Array of visible particles
  ArrayList particles;

  // Constructor
  ParticleSystem(){
     particles = new ArrayList();
  }

  /**
   * Adds a particle to the system
   *
   * @method emitParticle()
   */
  void emitParticle() {
    if (particles.size() > MAX_PARTICLES) return;

    PVector position = new PVector(mouseX, mouseY);
    PVector velocity = new PVector((mouseX - pmouseX) / 2, (mouseY - pmouseY) / 2);
    float mass = random(0.5, 4);

    particles.add(new Particle(position, velocity, mass));
  }

  /**
   * Draws the system on screen
   * and moves each particle to it's next position
   *
   * @method drawSystem
   */
  void drawSystem() {
    for (int i = 0; i < particles.size(); i++){

      Particle p = (Particle)particles.get(i);

      // Remove from system if it is off screen
      if(p.shouldRemove()) {
        particles.remove(i);
      }

      // Detect collisions
      for (int z = 0; z < particles.size(); z++){
        Particle p2 = (Particle)particles.get(z);
        if (p.hasCollision(p2)) p.collide();
      }

      // draw this particle
      p.drawParticle();

      // move this particle for next iteration
      p.moveParticle();
    }
  }
}

public class Particle {

  int lifetime = 0;
  float size = 12;
  color colour = color(220);
  float rotation = 0.0;
  float rVelocity = random(0.05, 0.2);
  boolean polygon = random(0.0, 10.0) >= 5.0;

  PVector position;
  PVector velocity;
  PVector acceleration;

  // Constructor
  public Particle(PVector position, PVector velocity, float mass) {
    this.position = position;
    this.velocity = velocity;
    this.acceleration = new PVector(0.0, mass * GRAVITY);
  }

  /**
   * Draws a single particle on screen
   *
   * @method drawParticle
   */
  public void drawParticle() {
    fill(colour, 255);

    // draw particle with rotation
    pushMatrix();
    translate(position.x, position.y);
    rotate(rotation);
    float offset = size / 2.0;
    if (polygon) {
      rect(-offset, -offset, size, size);
    } else {
      ellipse(-offset, -offset, size, size);
    }
    popMatrix();
  }

  /**
   * Marks a particle as collided by changing its color
   * and updating it's velocity in opposite direction
   *
   * @method collide
   */
  public void collide() {
    velocity = new PVector(velocity.x * -1, velocity.y, 0.0);
    colour = color(235, 134, 187);
  }

  /**
   * Moves a particle for next frame
   *
   * @method moveParticle
   */
  public void moveParticle() {
    velocity.add(acceleration);
    position.add(velocity);
    rotation += rVelocity;
    lifetime++;
  }

  /**
   * Is this particle colliding with the given particle?
   *
   * @method hasCollision
   */
  public boolean hasCollision(Particle p2) {
    if (this == p2) return false;
    if (lifetime < 20) return false;

    return position.dist(p2.position) < size;
  }

  /**
   * Should we remove this particle from the screen?
   *
   * @method shouldRemove
   */
  public boolean shouldRemove() {
    return position.y > HEIGHT || lifetime > LIFETIME;
  }
}
