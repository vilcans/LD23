
renderer = new THREE.WebGLRenderer()
renderer.setSize 800, 640
document.body.appendChild renderer.domElement

scene = new THREE.Scene()

camera = new THREE.PerspectiveCamera(
    35,         # Field of view
    800 / 640,  # Aspect ratio
    .1,         # Near
    10000       # Far
)
camera.position.set(-15, 10, 15)
camera.lookAt(scene.position)
scene.add(camera)

cube = new THREE.Mesh(
    new THREE.CubeGeometry(5, 5, 5),
    new THREE.MeshLambertMaterial(
        color: 0xFF0000
    )
)
scene.add( cube )

light = new THREE.PointLight 0xFFFF00
light.position.set 10, 0, 10
scene.add(light)

renderer.render(scene, camera);
