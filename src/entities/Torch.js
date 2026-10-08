const PHASES = [
  { tex: "torch_flame_bright", min: 1800, max: 3200, deadly: true, scale: 1 },
  { tex: "torch_flame_low", min: 400, max: 900, deadly: true, scale: 0.8 },
  { tex: "torch_flame_ember", min: 300, max: 700, deadly: false, scale: 0.5 },
];

export class Torch {
  constructor(scene, x, groundY) {
    this.scene = scene;
    this.x = x;
    this.flameY = groundY - 58;

    scene.add.image(x, groundY, "torch_pole").setOrigin(0.5, 1);
    this.flame = scene.add.image(x, this.flameY, "torch_flame_bright").setOrigin(0.5, 0.65);

    this.phaseIndex = 0;
    this.phaseTimer = Phaser.Math.Between(PHASES[0].min, PHASES[0].max);
    this.setPhase(0);

    // moths circling the flame
    this.moths = [];
    for (let i = 0; i < 3; i++) {
      const m = scene.add.image(x, this.flameY, "moth");
      m.orbitAngle = Math.random() * Math.PI * 2;
      m.orbitSpeed = 0.002 + Math.random() * 0.003;
      m.orbitR = 14 + Math.random() * 10;
      this.moths.push(m);
    }
  }

  setPhase(i) {
    const p = PHASES[i];
    this.flame.setTexture(p.tex);
    this.flame.setScale(p.scale + Math.random() * 0.08);
    this.deadly = p.deadly;
  }

  update(time, delta) {
    this.phaseTimer -= delta;
    this.flame.x = this.x + Math.sin(time * 0.01) * 1.2;
    if (this.phaseTimer <= 0) {
      this.phaseIndex = (this.phaseIndex + 1) % PHASES.length;
      const p = PHASES[this.phaseIndex];
      this.phaseTimer = Phaser.Math.Between(p.min, p.max);
      this.setPhase(this.phaseIndex);
    }
    for (const m of this.moths) {
      m.orbitAngle += m.orbitSpeed * delta;
      m.x = this.flame.x + Math.cos(m.orbitAngle) * m.orbitR;
      m.y = this.flameY + Math.sin(m.orbitAngle) * m.orbitR * 0.6 - 6;
    }
  }

  getHazard() {
    if (!this.deadly) return null;
    return new Phaser.Geom.Circle(this.flame.x, this.flameY, 34);
  }
}
