
class window.Map
  constructor: (collisionImage) ->
    @createCollisionMap(collisionImage)

  createCollisionMap: (image) ->
    canvas = document.createElement('canvas')
    canvas.width = image.width;
    canvas.height = image.height;
    context = canvas.getContext('2d')
    context.drawImage image, 0, 0
    @collisionData = context.getImageData(0, 0, image.width, image.height)

  isWater: (latitude, longitude) ->
    x = @longitudeToX(longitude)
    y = @latitudeToY(latitude)
    return @collisionData.data[(x + y * @collisionData.width) * 4] > 128

  longitudeToX: (longitude) ->
    normalized = (longitude + Math.PI) / (Math.PI * 2)
    return Math.floor(normalized * @collisionData.width)

  latitudeToY: (latitude) ->
    normalized = (latitude + Math.PI / 2) / Math.PI
    return @collisionData.height - 1 - Math.floor(normalized * @collisionData.height)
