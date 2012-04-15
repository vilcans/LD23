
class Game
  constructor: (parentElement) ->
    @parentElement = $(parentElement)

    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize 800, 640
    parentElement.appendChild @renderer.domElement

    @scene = new THREE.Scene()

    @camera = new THREE.PerspectiveCamera(
      35,         # Field of view
      800 / 640,  # Aspect ratio
      .1,         # Near
      10000       # Far
    )
    @camera.position.set(-15, 10, 15)
    @camera.lookAt @scene.position
    @scene.add @camera

    # @cube = new THREE.Mesh(
    #   new THREE.CubeGeometry(5, 5, 5),
    #   new THREE.MeshLambertMaterial {color: 0xFF0000}
    # )
    # @scene.add @cube

    loader = new THREE.JSONLoader()
    console.log 'loading object'
    loader.load(
      'assets/box.js',
      (geometry) =>
        console.log 'got geo', geometry
        geometry.materials[0].shading = THREE.FlatShading
        material = new THREE.MeshFaceMaterial()
        mesh = new THREE.Mesh geometry, material
        #mesh2.position.x = - 400;
        #mesh2.scale.x = mesh2.scale.y = mesh2.scale.z = 250;
        @scene.add mesh
    )

    @light = new THREE.PointLight 0xFFFFFF
    @light.position.set(10, 0, 10)
    @scene.add @light

    @parentElement
      .mousedown(@onMouseDown)
      .mouseup(@onMouseUp)

    window.setInterval @animate, 1000 / 60

  animate: =>
    @renderer.render @scene, @camera

  onMouseDown: (event) =>
    @mouseX = event.clientX
    @mouseY = event.clientY

    @parentElement.mousemove @onMouseDrag

  onMouseUp: (event) =>
    @parentElement.off 'mousemove', @onMouseDrag

  onMouseDrag: (event) =>
    x = event.clientX
    y = event.clientY
    dx = x - @mouseX
    dy = y - @mouseY
    @camera.translateX dx * -.01
    @camera.translateY dy * .01
    @camera.updateMatrix()
    @mouseX = x
    @mouseY = y

$(document).ready ->
  new Game(document.body)
