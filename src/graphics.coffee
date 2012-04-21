PI = Math.PI
Vector2 = THREE.Vector2
Vector3 = THREE.Vector3
Matrix4 = THREE.Matrix4
ORIGIN = new Vector3(0, 0, 0)

class window.Graphics
  constructor: (parentElement) ->
    @parentElement = parentElement
    @renderer = new THREE.WebGLRenderer()
    @dimensions = new THREE.Vector2(
      parentElement.clientWidth, parentElement.clientHeight)
    @renderer.setSize @dimensions.x, @dimensions.y

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

    @shipMaterial = new THREE.MeshLambertMaterial {color: 0xffffff}
    @portMaterial = new THREE.MeshBasicMaterial {color: 0xff8833}

  createScene: ->
    @scene = new THREE.Scene()

    @camera = new THREE.PerspectiveCamera(
      35,         # Field of view
      @dimensions.x / @dimensions.y,  # Aspect ratio
      .1,         # Near
      10000       # Far
    )
    @camera.lookAt @scene.position
    @scene.add @camera

    @light = new THREE.PointLight 0xFFFFFF
    @light.position.set(10, 0, 10)
    @scene.add @light

    @planet = new THREE.Mesh(
      new THREE.SphereGeometry(
        1,  # radius
        25, # segmentsWidth
        50,  # segmentsHeight
        -PI / 2,  # phiStart
        2 * PI, # phiLength
      ),
      #new THREE.MeshLambertMaterial {color: 0xFF0000}
      @material
    )
    @planet.position = ORIGIN
    @scene.add @planet

  addShip: ->
    mesh = new THREE.CubeGeometry(.1, .05, .15)
    # Move to planet's surface
    mesh.applyMatrix(new Matrix4().setTranslation(0, 0, 1))
    mesh = new THREE.Mesh(mesh, @shipMaterial)
    @scene.add mesh
    return mesh

  addPort: ->
    radius = .06
    mesh = new THREE.CylinderGeometry(radius * .67, radius, 0, 24, 1, true)
    # Move to planet's surface
    mesh.applyMatrix(new Matrix4().setRotationX(Math.PI / 2))
    mesh.applyMatrix(new Matrix4().setTranslation(0, 0, 1))
    mesh = new THREE.Mesh(mesh, @portMaterial)
    @scene.add mesh
    return mesh

  start: ->
    @parentElement.appendChild @renderer.domElement

    @stats.domElement.style.position = 'absolute';
    @stats.domElement.style.top = '0px';
    @stats.domElement.style.left = '0px';
    @parentElement.appendChild @stats.domElement

  render: ->
    @renderer.render @scene, @camera
    @stats.update()

  setCamera: (latitude, longitude, altitude) ->
    rotationY = new Matrix4().setRotationY(longitude)
    rotationX = new Matrix4().setRotationX(-latitude)
    translation = new Matrix4().setTranslation(0, 0, altitude + 1)

    matrix = new Matrix4().multiply(rotationY, rotationX).multiplySelf(translation)

    # Funny, Object3D doesn't have a way to just SET the matrix(?)
    @camera.matrix.identity()
    @camera.applyMatrix(matrix)
