
class window.Graphics
  constructor: (parentElement) ->
    @parentElement = parentElement
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize parentElement.clientWidth, parentElement.clientHeight

    @stats = new Stats()

  loadAssets: (onFinished) ->
    callbacks = new Callbacks(onFinished)
    @texture = THREE.ImageUtils.loadTexture('assets/earth-diffuse.jpg', {},
      callbacks.add ->
    )

    @material = new THREE.ShaderMaterial(
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
      uniforms:
        diffuseMap:
          type: 't'
          value: 0
          texture: @texture
    )

    #loader = new THREE.JSONLoader()
    #loader.load(
    #  'assets/box.js',
    #  callbacks.add (geometry) =>
    #    #console.log 'got geo', geometry
    #    #geometry.materials[0].shading = THREE.FlatShading
    #    #material = new THREE.MeshFaceMaterial()
    #    @object = new THREE.Mesh geometry, @material
    #    #mesh2.position.x = - 400;
    #    #mesh2.scale.x = mesh2.scale.y = mesh2.scale.z = 250;
    #    #@scene.add mesh
    #)

  createScene: ->
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

    @light = new THREE.PointLight 0xFFFFFF
    @light.position.set(10, 0, 10)
    @scene.add @light

    @planet = new THREE.Mesh(
      new THREE.SphereGeometry(
        5,  # radius
        25, # segmentsWidth
        50,  # segmentsHeight
      ),
      #new THREE.MeshLambertMaterial {color: 0xFF0000}
      @material
    )
    @planet.position.set(0, 0, 0)
    @scene.add @planet

    #@scene.add @object

  start: ->
    @parentElement.appendChild @renderer.domElement

    @stats.domElement.style.position = 'absolute';
    @stats.domElement.style.top = '0px';
    @stats.domElement.style.left = '0px';
    @parentElement.appendChild @stats.domElement

  render: ->
    @renderer.render @scene, @camera
    @stats.update()
