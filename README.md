WebGL based game, made for Ludum Dare 23, April 21-22, 2012

# Notes to self

## Blender Exporter

Install Blender exporter for three.js:

    git clone https://github.com/mrdoob/three.js.git
    mkdir -p ~/.blender/2.62/scripts/addons/2.62
    cp -r scripts/addons/io_mesh_threejs ~/.blender/2.62/scripts/addons/

File->User Preferences->Addons
Search for three, click the checkbox
Use the regular Import and Export menu within Blender, select `Three.js (js)`.

## Three.js

There's a non-minified version of Three.js here:

    http://chandler.prallfamily.com/threebuilds/
