WebGL based game, made for Ludum Dare 23, April 21-22, 2012

Planet textures from [JHT's Pixel Emporium](http://planetpixelemporium.com/earth.html).

# Notes to self

## Blender Exporter

Install Blender exporter for three.js:

    git clone https://github.com/mrdoob/three.js.git
    mkdir -p ~/.blender/2.62/scripts/addons/2.62
    cp -r scripts/addons/io_mesh_threejs ~/.blender/2.62/scripts/addons/

File->User Preferences->Addons
Search for three, click the checkbox
Use the regular Import and Export menu within Blender, select `Three.js (js)`.

Loading a mesh:

    loader = new THREE.JSONLoader()
    loader.load(
      'assets/box.js',
      callbacks.add (geometry) =>
        #console.log 'got geo', geometry
        #geometry.materials[0].shading = THREE.FlatShading
        #material = new THREE.MeshFaceMaterial()
        @object = new THREE.Mesh geometry, @material
        #mesh2.position.x = - 400;
        #mesh2.scale.x = mesh2.scale.y = mesh2.scale.z = 250;
        #@scene.add mesh
    )


## Three.js

There's a non-minified version of Three.js here:

    http://chandler.prallfamily.com/threebuilds/
