export class SkyManager {
  constructor(scene, worldWidth, groundY, patchXs) {
    this.scene = scene;
    this.groundY = groundY;

    this.sky = scene.add.tileSprite(0, 0, worldWidth, 540, "sky_stars")
      .setOrigin(0, 0).setScrollFactor(0.05);

    this.moon = scene.add.image(worldWidth * 0.5, 90, "moon")
      .setScrollFactor(0.08).setScale(0.6);

    this.clouds = [];
    for (let i = 0; i < 10; i++) {
      const c = scene.add.image(
        Phaser.Math.Between(0, worldWidth),
        Phaser.Math.Between(40, 220),
        `cloud_${i % 4}`
      ).setScrollFactor(0.12).setAlpha(0.9).setScale(Phaser.Math.FloatBetween(0.8, 1.4));
      c.speed = 4 + Math.random() * 10;
      this.clouds.push(c);
    }

    this.patches = patchXs.map((x) => {
      const e = scene.add.ellipse(x, groundY - 6, 140, 34, 0xcfd6ff, 0.0);
      return { x, ellipse: e };
    });

    this.moonVisibility = 1;
  }

  update(time, delta) {
    this.sky.tilePositionX += 0.01 * delta * 0.05;

    let occluded = false;
    for (const c of this.clouds) {
      c.x += c.speed * (delta / 1000);
      if (c.x > this.sky.width + 200) c.x = -200;
      const dx = Math.abs(c.x - this.moon.x);
      const dy = Math.abs(c.y - this.moon.y);
      if (dx < 140 && dy < 90) occluded = true;
    }

    const target = occluded ? 0.15 : 1;
    this.moonVisibility = Phaser.Math.Linear(this.moonVisibility, target, 0.02);
    this.moon.setAlpha(this.moonVisibility);

    for (const p of this.patches) {
      p.ellipse.setFillStyle(0xcfd6ff, 0.12 * this.moonVisibility);
    }
  }

  getHazards() {
    if (this.moonVisibility < 0.6) return [];
    return this.patches.map((p) =>
      new Phaser.Geom.Ellipse(p.x, this.groundY - 6, 140, 34)
    );
  }
}
