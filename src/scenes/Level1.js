import { Player } from "../entities/Player.js";
import { Torch } from "../entities/Torch.js";
import { Lamp } from "../entities/Lamp.js";
import { WindowLight } from "../entities/Window.js";
import { SkyManager } from "../entities/SkyManager.js";
import { Soldier } from "../entities/Soldier.js";
import { Rat } from "../entities/Rat.js";
import { playerInAnyHazard } from "../utils/hazard.js";

const WORLD_WIDTH = 4200;
const GROUND_Y = 470;

export class Level1Scene extends Phaser.Scene {
  constructor() {
    super("Level1");
  }

  create() {
    this.deathCount = 0;
    this.physics.world.setBounds(0, 0, WORLD_WIDTH, 540);
    this.cameras.main.setBounds(0, 0, WORLD_WIDTH, 540);

    this.buildParallax();
    this.buildGroundAndProps();

    this.torches = [];
    this.lamps = [];
    this.windows = [];
    this.rats = [];

    for (let x = 260; x < WORLD_WIDTH - 200; x += Phaser.Math.Between(420, 560)) {
      if (Math.random() < 0.55) {
        this.torches.push(new Torch(this, x, GROUND_Y));
      } else {
        this.lamps.push(new Lamp(this, x, GROUND_Y));
      }
    }

    for (let x = 180; x < WORLD_WIDTH - 150; x += Phaser.Math.Between(220, 340)) {
      this.windows.push(new WindowLight(this, x, GROUND_Y - 150 - Math.random() * 60));
    }

    const ratKinds = ["normal", "plague", "skeleton"];
    for (let i = 0; i < 9; i++) {
      const cx = 300 + i * 420 + Math.random() * 100;
      this.rats.push(new Rat(this, ratKinds[i % 3], cx, GROUND_Y, cx - 70, cx + 70));
    }

    this.soldiers = [
      new Soldier(this, 900, GROUND_Y, 760, 1180),
      new Soldier(this, 2200, GROUND_Y, 2000, 2480),
      new Soldier(this, 3300, GROUND_Y, 3100, 3600),
    ];

    this.sky = new SkyManager(this, WORLD_WIDTH, GROUND_Y, [500, 1400, 2100, 2900, 3700]);

    // tavern / level exit
    this.add.image(WORLD_WIDTH - 140, GROUND_Y, "tavern").setOrigin(0.5, 1);
    this.exitZone = new Phaser.Geom.Rectangle(WORLD_WIDTH - 200, GROUND_Y - 160, 120, 160);

    this.player = new Player(this, 80, GROUND_Y - 40);
    this.physics.add.collider(this.player.container, this.groundCollider);
    this.physics.add.collider(this.player.container, this.obstacleCollider);

    this.cameras.main.startFollow(this.player.container, true, 0.1, 0.1);

    this.checkpoint = { x: 80, y: GROUND_Y - 40 };
    this.checkpointTimer = 0;

    this.buildHud();
  }

  buildParallax() {
    this.add.tileSprite(0, 0, WORLD_WIDTH, 540, "sky_stars").setOrigin(0, 0).setScrollFactor(0.05);
    this.add.tileSprite(0, 120, WORLD_WIDTH, 420, "castle_far").setOrigin(0, 0).setScrollFactor(0.3).setAlpha(0.9);
    this.add.tileSprite(0, 180, WORLD_WIDTH, 360, "buildings_far").setOrigin(0, 0).setScrollFactor(0.5).setAlpha(0.95);
    this.add.tileSprite(0, 120, WORLD_WIDTH, 420, "buildings_mid").setOrigin(0, 0).setScrollFactor(0.75);
    this.nearLayer = this.add.tileSprite(0, 20, WORLD_WIDTH, 520, "buildings_near").setOrigin(0, 0).setScrollFactor(1).setDepth(-5);
  }

  buildGroundAndProps() {
    this.add.tileSprite(0, GROUND_Y, WORLD_WIDTH, 90, "ground").setOrigin(0, 0).setDepth(-1);

    this.groundCollider = this.physics.add.staticGroup();
    const groundRect = this.add.rectangle(WORLD_WIDTH / 2, GROUND_Y + 45, WORLD_WIDTH, 90, 0x000000, 0);
    this.physics.add.existing(groundRect, true);
    this.groundCollider.add(groundRect);

    this.obstacleCollider = this.physics.add.staticGroup();
    for (let x = 400; x < WORLD_WIDTH - 300; x += Phaser.Math.Between(350, 650)) {
      const barrel = this.add.image(x, GROUND_Y, "barrel").setOrigin(0.5, 1);
      this.physics.add.existing(barrel, true);
      barrel.body.setSize(30, 36).setOffset(-15, -36);
      this.obstacleCollider.add(barrel);
    }

    // decorative cages hanging from unseen beams
    for (let x = 500; x < WORLD_WIDTH - 300; x += Phaser.Math.Between(700, 1100)) {
      const alive = Math.random() < 0.5;
      const cage = this.add.image(x, GROUND_Y - 150, alive ? "cage_prisoner_alive" : "cage_prisoner_dead").setOrigin(0.5, 0);
      this.tweens.add({
        targets: cage,
        angle: { from: -4, to: 4 },
        duration: 2200 + Math.random() * 800,
        yoyo: true,
        repeat: -1,
        ease: "Sine.easeInOut",
      });
    }

    for (let x = 650; x < WORLD_WIDTH - 300; x += Phaser.Math.Between(900, 1400)) {
      if (Math.random() < 0.5) {
        this.add.image(x, GROUND_Y, "gallows").setOrigin(0.5, 1).setDepth(-2);
      } else {
        this.add.image(x, GROUND_Y, "stocks").setOrigin(0.5, 1).setDepth(-2);
      }
    }
  }

  buildHud() {
    this.hudText = this.add.text(16, 16, "A/D или ←/→ — идти, Пробел — прыжок.\nДержись в тени: свет убивает.", {
      fontFamily: "monospace",
      fontSize: "16px",
      color: "#cbb8ff",
      backgroundColor: "#0c0814aa",
      padding: { x: 8, y: 6 },
    }).setScrollFactor(0).setDepth(100);

    this.tweens.add({
      targets: this.hudText,
      alpha: 0,
      delay: 4500,
      duration: 1200,
    });

    this.deathText = this.add.text(480, 270, "", {
      fontFamily: "monospace",
      fontSize: "28px",
      color: "#ff8888",
    }).setScrollFactor(0).setDepth(100).setOrigin(0.5).setAlpha(0);
  }

  collectHazards() {
    const hazards = [];
    for (const t of this.torches) {
      const h = t.getHazard();
      if (h) hazards.push(h);
    }
    for (const l of this.lamps) hazards.push(l.getHazard());
    for (const w of this.windows) {
      const h = w.getHazard();
      if (h) hazards.push(h);
    }
    for (const s of this.soldiers) hazards.push(s.getConeHazard());
    hazards.push(...this.sky.getHazards());
    return hazards;
  }

  handleDeath() {
    this.deathCount += 1;
    this.deathText.setText("Свет настиг тебя...").setAlpha(1);
    this.tweens.add({ targets: this.deathText, alpha: 0, delay: 700, duration: 700 });
    this.player.kill(() => {
      this.player.respawn(this.checkpoint.x, this.checkpoint.y);
    });
  }

  update(time, delta) {
    this.player.update();

    for (const t of this.torches) t.update(time, delta);
    for (const l of this.lamps) l.update(time, delta);
    for (const w of this.windows) w.update(time, delta);
    for (const s of this.soldiers) s.update(time, delta);
    for (const r of this.rats) r.update(time, delta);
    this.sky.update(time, delta);

    if (!this.player.dead) {
      const hazards = this.collectHazards();
      const inDanger = playerInAnyHazard(hazards, this.player.getBounds());
      if (inDanger) {
        this.handleDeath();
      } else {
        this.checkpointTimer -= delta;
        if (this.checkpointTimer <= 0) {
          this.checkpointTimer = 500;
          if (this.player.container.body.blocked.down) {
            this.checkpoint = { x: this.player.x, y: this.player.y };
          }
        }
        if (Phaser.Geom.Rectangle.Contains(this.exitZone, this.player.x, this.player.y)) {
          this.scene.start("Level2Stub");
        }
      }
    }
  }
}
