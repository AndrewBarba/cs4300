/* ---------------------------------------------------------------------------
 *
 * Basic Particle System
 *
 * --------------------------------------------------------------------------- */

// Settings
int PER_EMIT = 50;
int WIDTH  = 750 / 2;
int HEIGHT = 1334 / 2;
int MAX_PARTICLES = 100000;
float GRAVITY = 0.15;

// global system
ParticleSystem globalParticleSystem;

PFont f;

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

  // Font
  f = createFont("Arial",16,true);
}

void draw() {

  // white background
  background(255);

  textFont(f,16);                  // STEP 3 Specify font to be used
  fill(0);                         // STEP 4 Specify font color
  text("Particles: " + globalParticleSystem.getParticles().size(), 10, 50);   // STEP 5 Display Text

  for (int i = 0; i < PER_EMIT; i++) {
    globalParticleSystem.emitParticle();
  }

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

  ArrayList getParticles() {
    return particles;
  }

  /**
   * Adds a particle to the system
   *
   * @method emitParticle()
   */
  void emitParticle() {
    if (particles.size() > MAX_PARTICLES) return;

    PVector position = new PVector(WIDTH / 2, HEIGHT / 2);
    PVector velocity = new PVector(random(-3.0, 3.0), random(-7.0, -2.0));

    particles.add(new Particle(position, velocity));
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

      // draw this particle
      p.drawParticle();

      // move this particle for next iteration
      p.moveParticle();
    }
  }
}

public class Particle {

  float size = 6;
  color colour = color(0, 0, 200);

  PVector position;
  PVector velocity;
  PVector acceleration;

  // Constructor
  public Particle(PVector position, PVector velocity) {
    this.position = position;
    this.velocity = velocity;
    this.acceleration = new PVector(0.0, GRAVITY);
  }

  /**
   * Draws a single particle on screen
   *
   * @method drawParticle
   */
  public void drawParticle() {
    fill(colour, 255);
    ellipse(position.x, position.y, size, size);
  }

  /**
   * Moves a particle for next frame
   *
   * @method moveParticle
   */
  public void moveParticle() {
    velocity.add(acceleration);
    position.add(velocity);
  }

  /**
   * Should we remove this particle from the screen?
   *
   * @method shouldRemove
   */
  public boolean shouldRemove() {
    return position.y > HEIGHT || position.x < 0 || position.x > WIDTH;
  }
}
