const STATE = { IDLE: 0, GLOWING: 1, OPEN: 2 };

export class WindowLight {
  constructor(scene, x, y) {
    this.scene = scene;
    this.x = x;
    this.y = y;

    this.closed = scene.add.image(x, y, "window_closed");
    this.glowSprite = scene.add.image(x, y, "window_curtain_glow").setAlpha(0);
    this.openSprite = scene.add.image(x, y, "window_open").setVisible(false);

    this.state = STATE.IDLE;
    this.timer = Phaser.Math.Between(2000, 9000);
  }

  update(time, delta) {
    this.timer -= delta;
    if (this.state === STATE.GLOWING) {
      const t = (Math.sin(time * 0.006) + 1) / 2;
      this.glowSprite.setAlpha(0.4 + t * 0.6);
    }

    if (this.timer > 0) return;

    if (this.state === STATE.IDLE) {
      this.state = STATE.GLOWING;
      this.timer = Phaser.Math.Between(900, 1600);
    } else if (this.state === STATE.GLOWING) {
      this.state = STATE.OPEN;
      this.glowSprite.setAlpha(0);
      this.closed.setVisible(false);
      this.openSprite.setVisible(true);
      this.timer = Phaser.Math.Between(2500, 5000);
    } else {
      this.state = STATE.IDLE;
      this.closed.setVisible(true);
      this.openSprite.setVisible(false);
      this.timer = Phaser.Math.Between(4000, 12000);
    }
  }

  getHazard() {
    if (this.state !== STATE.OPEN) return null;
    return new Phaser.Geom.Rectangle(this.x - 16, this.y, 32, 90);
  }
}
