export function pointInHazard(hazard, x, y) {
  if (!hazard) return false;
  if (hazard instanceof Phaser.Geom.Circle) return Phaser.Geom.Circle.Contains(hazard, x, y);
  if (hazard instanceof Phaser.Geom.Rectangle) return Phaser.Geom.Rectangle.Contains(hazard, x, y);
  if (hazard instanceof Phaser.Geom.Ellipse) return Phaser.Geom.Ellipse.Contains(hazard, x, y);
  if (hazard instanceof Phaser.Geom.Polygon) return Phaser.Geom.Polygon.Contains(hazard, x, y);
  return false;
}

export function playerInAnyHazard(hazards, playerBody) {
  const chestX = playerBody.center.x;
  const chestY = playerBody.y + playerBody.height * 0.3;
  const feetX = playerBody.center.x;
  const feetY = playerBody.bottom - 2;
  for (const h of hazards) {
    if (!h) continue;
    if (pointInHazard(h, chestX, chestY) || pointInHazard(h, feetX, feetY)) return true;
  }
  return false;
}
