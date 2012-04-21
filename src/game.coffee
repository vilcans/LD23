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

    document.addEventListener 'mozvisibilitychange', @handleVisibilityChange, false
    if document.mozVisibilityState and document.mozVisibilityState == 'visible'
      @startAnimation()
    else
      console.log 'Not starting animation because game not visible'

  startAnimation: ->
    if @timer
      console.log 'animation already started!'
    else
      console.log 'starting animation'
      @timer = window.setInterval @animate, 1000 / 60

  stopAnimation: ->
    if not @timer
      console.log 'animation not running'
    else
      console.log 'stopping animation'
      window.clearInterval @timer
      @timer = null

  handleVisibilityChange: (e) =>
    if document.mozVisibilityState != 'visible'
      @stopAnimation()
    else
      @startAnimation()

  animate: =>
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
