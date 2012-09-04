#import("dart:html");

#import("../packages/three.dart/src/ThreeD.dart", prefix:'THREE');
#import("../three.csg.dart", prefix:'CSG');

var renderer, scene, camera;

/// Example #1 - Cube (mesh) subtract Sphere (mesh)
example1() {
  var cube_geometry = new THREE.CubeGeometry( 3, 3, 3 );
  var cube_mesh = new THREE.Mesh( cube_geometry );
  cube_mesh.position.x = -10;
  var cube_bsp = new CSG.BSP( cube_mesh );
  
  var sphere_geometry = new THREE.SphereGeometry( 1.8, 8, 8 );
  var sphere_mesh = new THREE.Mesh( sphere_geometry );
  sphere_mesh.position.x = -9.9;
  var sphere_bsp = new CSG.BSP( sphere_mesh );
  
  CSG.BSP subtract_bsp = cube_bsp.subtract( sphere_bsp );

  scene.add(subtract_bsp.toMesh( new THREE.MeshNormalMaterial(side: THREE.Three.DoubleSide) ));
}

/// Example #2 - Sphere (geometry) union Cube (geometry)
example2() {
  var sphere_geometry = new THREE.SphereGeometry( 2);
  var sphere_bsp = new CSG.BSP( sphere_geometry );
  
  var cube_geometry = new THREE.CubeGeometry( 7, .5, 3 );
  var cube_bsp = new CSG.BSP( cube_geometry );
  
  var union_bsp = sphere_bsp.union( cube_bsp );
  
  scene.add(
      union_bsp.toMesh( new THREE.MeshNormalMaterial() )
  );
}

// Example #3 - Sphere (geometry) intersect Sphere (mesh)
example3() {
  var sphere_geometry_1 = new THREE.SphereGeometry( 2);
  var sphere_bsp_1 = new CSG.BSP( sphere_geometry_1 );
  
  var sphere_geometry_2 = new THREE.SphereGeometry( 2);
  var sphere_mesh_2 = new THREE.Mesh( sphere_geometry_2 );
  sphere_mesh_2.position.x = 2;
  var sphere_bsp_2 = new CSG.BSP( sphere_mesh_2 );
  
  var intersect_bsp = sphere_bsp_1.intersect( sphere_bsp_2 );
  
  var result_mesh = intersect_bsp.toMesh( new THREE.MeshNormalMaterial() );
  result_mesh.position.x = 10;
  scene.add( result_mesh );
}


main() {
  
  renderer = new THREE.WebGLRenderer(); //{antialias: true});
  renderer.setSize( window.innerWidth, window.innerHeight );
  document.query('#viewport').elements.add(renderer.domElement);

  scene = new THREE.Scene();

  camera = new THREE.PerspectiveCamera(35, window.innerWidth / window.innerHeight, 1, 1000);
  camera.position.setValues(15, 15, 35);
  camera.lookAt(scene.position);

  example1();
  example2();
  example3();
 
  renderer.render(scene, camera);
}

/// Test #1 - Cube (mesh)
test1() {
  var cube_geometry = new THREE.CubeGeometry( 3, 3, 3 );
  var cube_mesh = new THREE.Mesh( cube_geometry );
  var cube_bsp = new CSG.BSP( cube_mesh );
  
  scene.add(cube_bsp.toMesh( new THREE.MeshNormalMaterial() ));
}

/// Test #2 - Sphere
test2() {
  var sphere_geometry = new THREE.SphereGeometry( 3);
  var sphere_mesh = new THREE.Mesh( sphere_geometry );
  var sphere_bsp = new CSG.BSP( sphere_mesh );
  
  scene.add(sphere_bsp.toMesh( new THREE.MeshNormalMaterial() ));
}

/// Test #3 - Transform
test3() {
  var cube_geometry = new THREE.CubeGeometry( 3, 3, 3 );
  var cube_mesh = new THREE.Mesh( cube_geometry, new THREE.MeshNormalMaterial() );
  cube_mesh.translateX(-10);
  var cube_bsp = new CSG.BSP( cube_mesh );
  scene.add(cube_bsp.toMesh( new THREE.MeshNormalMaterial() ));
}
