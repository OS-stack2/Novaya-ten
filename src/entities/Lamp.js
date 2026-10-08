export class Lamp {
  constructor(scene, x, groundY) {
    this.scene = scene;
    this.x = x;
    this.postTopY = groundY - 140;

    scene.add.image(x, groundY, "lamp_post").setOrigin(0.5, 1);

    this.head = scene.add.image(x, this.postTopY + 20, "lamp_head").setOrigin(0.5, 0);
    scene.tweens.add({
      targets: this.head,
      angle: { from: -6, to: 6 },
      duration: 1800 + Math.random() * 600,
      yoyo: true,
      repeat: -1,
      ease: "Sine.easeInOut",
    });

    // shadow pool directly beneath the lamp (safe, cosmetic)
    this.shadow = scene.add.ellipse(x, groundY - 2, 70, 16, 0x000000, 0.35);

    this.lightY = this.postTopY + 40;
    this.glow = scene.add.ellipse(x, this.lightY, 150, 90, 0xffdd99, 0.08);

    this.moths = [];
    for (let i = 0; i < 2; i++) {
      const m = scene.add.image(x, this.lightY, "moth");
      m.orbitAngle = Math.random() * Math.PI * 2;
      m.orbitSpeed = 0.002 + Math.random() * 0.002;
      m.orbitR = 16 + Math.random() * 12;
      this.moths.push(m);
    }
  }

  update(time, delta) {
    const sway = Math.sin(time * 0.0012 + this.x) * 10;
    this.glow.x = this.x + sway * 0.3;
    for (const m of this.moths) {
      m.orbitAngle += m.orbitSpeed * delta;
      m.x = this.x + Math.cos(m.orbitAngle) * m.orbitR;
      m.y = this.lightY + Math.sin(m.orbitAngle) * m.orbitR * 0.5;
    }
  }

  getHazard() {
    return new Phaser.Geom.Rectangle(this.x - 90, this.lightY - 45, 180, 90);
  }
}
