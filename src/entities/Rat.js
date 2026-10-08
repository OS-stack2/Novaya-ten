const KIND_SPEED = { normal: 30, plague: 22, skeleton: 38 };

export class Rat {
  constructor(scene, kind, x, groundY, patrolMin, patrolMax) {
    this.speed = KIND_SPEED[kind] ?? 28;
    this.dir = Math.random() < 0.5 ? 1 : -1;
    this.patrolMin = patrolMin;
    this.patrolMax = patrolMax;
    this.sprite = scene.add.image(x, groundY - 4, `rat_${kind}`).setOrigin(0.5, 1);
  }

  update(time, delta) {
    this.sprite.x += this.dir * this.speed * (delta / 1000);
    if (this.sprite.x > this.patrolMax) this.dir = -1;
    if (this.sprite.x < this.patrolMin) this.dir = 1;
    this.sprite.scaleX = this.dir > 0 ? 1 : -1;
  }
}
