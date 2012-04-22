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

  animate: (time) ->
    if @pickup
      @mesh.scale.x = @mesh.scale.y = .7 + .4 * (.5 + .5 * Math.sin(time * PORT_PULSATE_SPEED))
    else
      @mesh.scale.x = @mesh.scale.y = 1
