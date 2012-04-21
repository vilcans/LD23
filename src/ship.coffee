class window.Ship
  constructor: (mesh, latitude, longitude) ->
    @mesh = mesh
    @latitude = latitude
    @longitude = longitude

  updateMesh: ->
    @mesh.eulerOrder = 'ZYX'
    @mesh.rotation.x = -@latitude
    @mesh.rotation.y = @longitude
