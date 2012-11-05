import "dart:html";
import 'package:three.csg/three.csg.dart';
import 'package:three/three.dart' as THREE;


var renderer, scene, camera;

/// Example #1 - Cube (mesh) subtract Sphere (mesh)
example1() {
  var cube_geometry = new THREE.CubeGeometry( 3, 3, 3 );
  var cube_mesh = new THREE.Mesh( cube_geometry );
  cube_mesh.position.x = -10;
  var cube_bsp = new BSP( cube_mesh );

  var sphere_geometry = new THREE.SphereGeometry( 1.8, 80, 80 );
  var sphere_mesh = new THREE.Mesh( sphere_geometry );
  sphere_mesh.position.x = -9.9;
  var sphere_bsp = new BSP( sphere_mesh );

  BSP subtract_bsp = cube_bsp.subtract( sphere_bsp );

  scene.add(subtract_bsp.toMesh( new THREE.MeshNormalMaterial(side: THREE.DoubleSide) ));
}

/// Example #2 - Sphere (geometry) union Cube (geometry)
example2() {
  var sphere_geometry = new THREE.SphereGeometry( 2,80,80);
  var sphere_bsp = new BSP( sphere_geometry );

  var cube_geometry = new THREE.CubeGeometry( 7, .5, 3 );
  var cube_bsp = new BSP( cube_geometry );

  var union_bsp = sphere_bsp.union( cube_bsp );

  scene.add(
      union_bsp.toMesh( new THREE.MeshNormalMaterial() )
  );
}

// Example #3 - Sphere (geometry) intersect Sphere (mesh)
example3() {
  var sphere_geometry_1 = new THREE.SphereGeometry( 2,80,80);
  var sphere_bsp_1 = new BSP( sphere_geometry_1 );

  var sphere_geometry_2 = new THREE.SphereGeometry( 2,80,80);
  var sphere_mesh_2 = new THREE.Mesh( sphere_geometry_2 );
  sphere_mesh_2.position.x = 2;
  var sphere_bsp_2 = new BSP( sphere_mesh_2 );

  var intersect_bsp = sphere_bsp_1.intersect( sphere_bsp_2 );

  var result_mesh = intersect_bsp.toMesh( new THREE.MeshNormalMaterial() );
  result_mesh.position.x = 10;
  scene.add( result_mesh );
}

// Example #4 - Geometry Extrusion subtraaction (mesh)
example4() {
  
  var extrude_extrudePath =  new THREE.SplineCurve3( 
      [new THREE.Vector3(0,0,-1),
       new THREE.Vector3(0,0,1)]     
  );
  var tube = new THREE.TubeGeometry(extrude_extrudePath,10, 2, 50, false, false);
  var extrusion_mesh_1 = new THREE.Mesh( tube );
  var extrusion_1 = new BSP( tube );
  
  var extrude_extrudePath_2 =  new THREE.SplineCurve3( 
      [new THREE.Vector3(0,-1,0),
       new THREE.Vector3(0,1,0)]     
  );
  var tube_2 = new THREE.TubeGeometry(extrude_extrudePath_2, 10, 2, 5, false, false);
  var extrusion_mesh_2 = new THREE.Mesh( tube_2 );
  var extrusion_2 = new BSP( tube_2 );
  scene.add( extrusion_mesh_1 );
  scene.add( extrusion_mesh_2 );
  var intersect_bsp = extrusion_1.subtract( extrusion_2 );

  var result_mesh = intersect_bsp.toMesh(new THREE.MeshNormalMaterial(side: THREE.DoubleSide) );
  result_mesh.position.x = -5;
  scene.add( result_mesh );
}

onDocumentMouseMove(MouseEvent event) {
  var mouseX = event.clientX;
  //scene.position.x = mouseX ;
  camera.position.setValues(0, mouseX, 15);
  renderer.render(scene, camera);
}

main() {

  renderer = new THREE.WebGLRenderer(); //{antialias: true});
  renderer.setSize( window.innerWidth, window.innerHeight );
  document.query('#viewport').elements.add(renderer.domElement);

  scene = new THREE.Scene();

  camera = new THREE.PerspectiveCamera(35, window.innerWidth / window.innerHeight, 10, 100);
  camera.position.setValues(0, 10, 15);
  camera.lookAt(scene.position);

  //example1();
  //example2();
  //example3();
  example4();
  document.on.mouseMove.add(onDocumentMouseMove, false );  
  renderer.render(scene, camera);
}

/// Test #1 - Cube (mesh)
test1() {
  var cube_geometry = new THREE.CubeGeometry( 3, 3, 3 );
  var cube_mesh = new THREE.Mesh( cube_geometry );
  var cube_bsp = new BSP( cube_mesh );

  scene.add(cube_bsp.toMesh( new THREE.MeshNormalMaterial() ));
}

/// Test #2 - Sphere
test2() {
  var sphere_geometry = new THREE.SphereGeometry( 3);
  var sphere_mesh = new THREE.Mesh( sphere_geometry );
  var sphere_bsp = new BSP( sphere_mesh );

  scene.add(sphere_bsp.toMesh( new THREE.MeshNormalMaterial() ));
}

/// Test #3 - Transform
test3() {
  var cube_geometry = new THREE.CubeGeometry( 3, 3, 3 );
  var cube_mesh = new THREE.Mesh( cube_geometry, new THREE.MeshNormalMaterial() );
  cube_mesh.translateX(-10);
  var cube_bsp = new BSP( cube_mesh );
  scene.add(cube_bsp.toMesh( new THREE.MeshNormalMaterial() ));
}
