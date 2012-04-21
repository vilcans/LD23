class window.Port
  constructor: (mesh, latitude, longitude, name) ->
    @mesh = mesh
    @latitude = latitude
    @longitude = longitude
    @name = name

    @mesh.eulerOrder = 'YXZ'
    @mesh.rotation.x = -@latitude
    @mesh.rotation.y = @longitude
    @mesh.rotation.z = 0
