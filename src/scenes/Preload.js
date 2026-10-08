const SPRITES = [
  "player_body", "player_arm_left", "player_arm_right",
  "soldier_body", "soldier_arm_left", "soldier_arm_right", "soldier_lantern",
  "light_cone",
  "sky_stars", "moon", "cloud_0", "cloud_1", "cloud_2", "cloud_3",
  "castle_far", "buildings_far", "buildings_mid", "buildings_near",
  "ground",
  "torch_pole", "torch_flame_bright", "torch_flame_low", "torch_flame_ember",
  "lamp_post", "lamp_head",
  "window_closed", "window_curtain_glow", "window_open",
  "barrel", "cage_prisoner_alive", "cage_prisoner_dead", "gallows", "stocks",
  "rat_normal", "rat_plague", "rat_skeleton", "moth",
  "tavern",
];

export class PreloadScene extends Phaser.Scene {
  constructor() {
    super("Preload");
  }

  preload() {
    const bar = this.add.graphics();
    this.load.on("progress", (v) => {
      bar.clear();
      bar.fillStyle(0x6b4a9e, 1);
      bar.fillRect(280, 265, 400 * v, 10);
    });

    for (const key of SPRITES) {
      this.load.image(key, `assets/sprites/${key}.png`);
    }
  }

  create() {
    this.scene.start("Level1");
  }
}
