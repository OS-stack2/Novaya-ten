const SPEED = 190;
const JUMP = 430;

export class Player {
  constructor(scene, x, y) {
    this.scene = scene;
    this.dead = false;

    const body = scene.add.image(0, 10, "player_body").setOrigin(0.5, 1);
    const armLeft = scene.add.image(-14, -24, "player_arm_left").setOrigin(0.5, 0);
    const armRight = scene.add.image(14, -24, "player_arm_right").setOrigin(0.5, 0);

    this.container = scene.add.container(x, y, [armLeft, armRight, body]);
    this.container.setSize(26, 56);
    scene.physics.world.enable(this.container);
    this.container.body.setSize(26, 56).setOffset(-13, -46);
    this.container.body.setMaxVelocity(SPEED, 900);
    this.container.body.setDragX(900);

    this.body = body;
    this.armLeft = armLeft;
    this.armRight = armRight;
    this.walkTween = null;
    this.facing = 1;

    this.keys = scene.input.keyboard.addKeys({
      left: Phaser.Input.Keyboard.KeyCodes.A,
      right: Phaser.Input.Keyboard.KeyCodes.D,
      left2: Phaser.Input.Keyboard.KeyCodes.LEFT,
      right2: Phaser.Input.Keyboard.KeyCodes.RIGHT,
      jump: Phaser.Input.Keyboard.KeyCodes.SPACE,
      jump2: Phaser.Input.Keyboard.KeyCodes.UP,
      jump3: Phaser.Input.Keyboard.KeyCodes.W,
    });
  }

  get x() { return this.container.x; }
  get y() { return this.container.y; }

  getBounds() {
    return this.container.body;
  }

  startWalkAnim() {
    if (this.walkTween) return;
    this.walkTween = this.scene.tweens.add({
      targets: [this.armLeft, this.armRight],
      angle: { from: -18, to: 18 },
      yoyo: true,
      repeat: -1,
      duration: 220,
      ease: "Sine.easeInOut",
    });
  }

  stopWalkAnim() {
    if (this.walkTween) {
      this.walkTween.stop();
      this.walkTween = null;
      this.armLeft.angle = 0;
      this.armRight.angle = 0;
    }
  }

  update() {
    if (this.dead) return;
    const b = this.container.body;
    const left = this.keys.left.isDown || this.keys.left2.isDown;
    const right = this.keys.right.isDown || this.keys.right2.isDown;
    const jump = this.keys.jump.isDown || this.keys.jump2.isDown || this.keys.jump3.isDown;

    if (left && !right) {
      b.setVelocityX(-SPEED);
      this.container.scaleX = -1;
      this.facing = -1;
      this.startWalkAnim();
    } else if (right && !left) {
      b.setVelocityX(SPEED);
      this.container.scaleX = 1;
      this.facing = 1;
      this.startWalkAnim();
    } else {
      b.setVelocityX(0);
      this.stopWalkAnim();
    }

    if (jump && b.blocked.down) {
      b.setVelocityY(-JUMP);
    }
  }

  kill(onDone) {
    if (this.dead) return;
    this.dead = true;
    this.stopWalkAnim();
    this.container.body.setVelocity(0, -120);
    this.scene.tweens.add({
      targets: this.container,
      alpha: 0,
      angle: this.facing * 40,
      duration: 500,
      onComplete: onDone,
    });
  }

  respawn(x, y) {
    this.dead = false;
    this.container.setPosition(x, y);
    this.container.alpha = 1;
    this.container.angle = 0;
    this.container.body.setVelocity(0, 0);
  }
}
