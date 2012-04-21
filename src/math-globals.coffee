# Makes an angle be in the interval -PI <= x < PI
window.wrapAngle = (radians) ->
  while radians >= Math.PI
    radians -= 2 * Math.PI

  while radians < -Math.PI
    radians += 2 * Math.PI

  return radians

window.toRadians = (degrees) -> degrees / 360 * 2 * Math.PI

window.toDegrees = (radians) -> radians / 2 / Math.PI * 360
