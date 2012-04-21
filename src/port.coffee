class window.Port
  constructor: (mesh, latitude, longitude) ->
    @mesh = mesh
    @latitude = latitude
    @longitude = longitude

    @mesh.eulerOrder = 'YXZ'
    @mesh.rotation.x = -@latitude
    @mesh.rotation.y = @longitude
    @mesh.rotation.z = 0
