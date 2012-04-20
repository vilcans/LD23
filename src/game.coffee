class window.Game
  constructor: ({parentElement}) ->
    @parentElement = parentElement
    @graphics = new Graphics(parentElement)

  init: (onFinished) ->
    @graphics.loadAssets(onFinished)

  start: ->
    @graphics.createScene()
    @graphics.start()

    $(@parentElement)
      .mousedown(@onMouseDown)
      .mouseup(@onMouseUp)

    window.setInterval @animate, 1000 / 60

  animate: =>
    @graphics.cube.translateX .01
    @graphics.render()

  onMouseDown: (event) =>
    @mouseX = event.clientX
    @mouseY = event.clientY

    $(@parentElement).mousemove @onMouseDrag

  onMouseUp: (event) =>
    $(@parentElement).off 'mousemove', @onMouseDrag

  onMouseDrag: (event) =>
    x = event.clientX
    y = event.clientY
    dx = x - @mouseX
    dy = y - @mouseY
    @graphics.camera.translateX dx * -.01
    @graphics.camera.translateY dy * .01
    @graphics.camera.updateMatrix()
    @mouseX = x
    @mouseY = y
