import { BootScene } from "./scenes/Boot.js";
import { PreloadScene } from "./scenes/Preload.js";
import { Level1Scene } from "./scenes/Level1.js";
import { Level2StubScene } from "./scenes/Level2Stub.js";

const config = {
  type: Phaser.AUTO,
  width: 960,
  height: 540,
  parent: "game",
  backgroundColor: "#05040a",
  pixelArt: true,
  physics: {
    default: "arcade",
    arcade: {
      gravity: { y: 900 },
      debug: false,
    },
  },
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
  scene: [BootScene, PreloadScene, Level1Scene, Level2StubScene],
};

new Phaser.Game(config);
