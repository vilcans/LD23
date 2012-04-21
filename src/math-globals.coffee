# Makes an angle be in the interval -PI <= x < PI
window.wrapAngle = (radians) ->
  if radians >= Math.PI
    return (radians + Math.PI) % (2 * Math.PI) - Math.PI
  else if radians < -Math.PI
    return -((-radians + Math.PI) % (2 * Math.PI) - Math.PI)

  return radians

window.toRadians = (degrees) -> degrees / 360 * 2 * Math.PI

window.toDegrees = (radians) -> radians / 2 / Math.PI * 360
