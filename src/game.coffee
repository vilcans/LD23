
class window.Game
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

    uniforms = {
      diffuseMap:
        type: 't'
        value: 0
        texture: THREE.ImageUtils.loadTexture('assets/dummy.png', ->
          console.log 'texture loaded!'
        )
    }

    material = new THREE.ShaderMaterial(
      vertexShader: """
        varying vec2 vUv;
        void main() {
          vUv = uv;
          gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);
        }
        """
      fragmentShader: """
        uniform sampler2D diffuseMap;
        varying vec2 vUv;

        void main() {
          gl_FragColor = texture2D(diffuseMap, vUv);
        }
        """
      uniforms: uniforms
    )

    @cube = new THREE.Mesh(
      new THREE.CubeGeometry(5, 5, 5),
      #new THREE.MeshLambertMaterial {color: 0xFF0000}
      material
    )
    @cube.position.set(12, 0, 0)
    @scene.add @cube

    loader = new THREE.JSONLoader()
    console.log 'loading object'
    loader.load(
      'assets/box.js',
      (geometry) =>
        #console.log 'got geo', geometry
        #geometry.materials[0].shading = THREE.FlatShading
        #material = new THREE.MeshFaceMaterial()
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
    @cube.translateX .01
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
