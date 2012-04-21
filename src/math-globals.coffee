# Makes an angle be in the interval -PI <= x < PI
window.wrapAngle = (radians) ->
  if radians >= Math.PI
    return (radians + Math.PI) % (2 * Math.PI) - Math.PI
  else if radians < -Math.PI
    return -((-radians + Math.PI) % (2 * Math.PI) - Math.PI)

  return radians

window.toRadians = (degrees) -> degrees / 360 * 2 * Math.PI

window.toDegrees = (radians) -> radians / 2 / Math.PI * 360

# Get the squared distance between two points given in latitude/longitude.
# Based on "Equirectangular approximation"
# from http://www.movable-type.co.uk/scripts/latlong.html
window.distanceSquared = (lat1, lon1, lat2, lon2) ->
	x = (lon2 - lon1) * Math.cos((lat1 + lat2) / 2);
	y = lat2 - lat1
	return x * x + y * y
