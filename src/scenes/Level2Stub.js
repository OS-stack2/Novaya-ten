export class Level2StubScene extends Phaser.Scene {
  constructor() {
    super("Level2Stub");
  }

  create() {
    this.cameras.main.setBackgroundColor("#0c0814");
    this.add.text(480, 240, "Таверна позади...", {
      fontFamily: "monospace",
      fontSize: "28px",
      color: "#e8d9ff",
    }).setOrigin(0.5);
    this.add.text(480, 290, "Уровень 2 — скоро.", {
      fontFamily: "monospace",
      fontSize: "18px",
      color: "#9c86c9",
    }).setOrigin(0.5);

    this.input.keyboard.once("keydown", () => this.scene.start("Level1"));
    this.add.text(480, 340, "(нажми любую клавишу, чтобы вернуться на уровень 1)", {
      fontFamily: "monospace",
      fontSize: "13px",
      color: "#6b5a8a",
    }).setOrigin(0.5);
  }
}
