const SPEED = 55;
const CONE_LENGTH = 210;
const CONE_HALF_ANGLE = 0.33; // radians

export class Soldier {
  constructor(scene, x, groundY, patrolMin, patrolMax) {
    this.scene = scene;
    this.y = groundY;
    this.patrolMin = patrolMin;
    this.patrolMax = patrolMax;
    this.dir = 1;

    const body = scene.add.image(0, 2, "soldier_body").setOrigin(0.5, 1);
    const armLeft = scene.add.image(-13, -22, "soldier_arm_left").setOrigin(0.5, 0);
    const lantern = scene.add.image(13, -18, "soldier_lantern").setOrigin(0.5, 0);
    armLeft.setDepth(0);
    lantern.setDepth(1);

    this.cone = scene.add.image(18, -10, "light_cone").setOrigin(0, 0.5).setBlendMode(Phaser.BlendModes.ADD);

    this.container = scene.add.container(x, groundY, [this.cone, body, armLeft, lantern]);

    scene.tweens.add({
      targets: lantern,
      angle: { from: -6, to: 6 },
      duration: 900,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });
  }

  update(time, delta) {
    this.container.x += this.dir * SPEED * (delta / 1000);
    if (this.container.x > this.patrolMax) this.dir = -1;
    if (this.container.x < this.patrolMin) this.dir = 1;
    this.container.scaleX = this.dir;
  }

  getConeHazard() {
    const apexX = this.container.x + this.dir * 18;
    const apexY = this.container.y - 10;
    const ang = this.dir > 0 ? 0 : Math.PI;
    const p1 = { x: apexX, y: apexY };
    const p2 = {
      x: apexX + Math.cos(ang - CONE_HALF_ANGLE) * CONE_LENGTH,
      y: apexY + Math.sin(ang - CONE_HALF_ANGLE) * CONE_LENGTH,
    };
    const p3 = {
      x: apexX + Math.cos(ang + CONE_HALF_ANGLE) * CONE_LENGTH,
      y: apexY + Math.sin(ang + CONE_HALF_ANGLE) * CONE_LENGTH,
    };
    return new Phaser.Geom.Polygon([p1, p2, p3]);
  }
}
