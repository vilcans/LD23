class window.Port
  constructor: (mesh, latitude, longitude, name) ->
    @mesh = mesh
    @latitude = latitude
    @longitude = longitude
    @name = name
    @htmlName = '<span class="port">' + @name + '</span>'

    @mesh.eulerOrder = 'YXZ'
    @mesh.rotation.x = -@latitude
    @mesh.rotation.y = @longitude
    @mesh.rotation.z = 0
