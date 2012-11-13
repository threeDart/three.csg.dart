part of threecsg;

class BSP {
  THREE.Matrix4 matrix;
  CSG.Node tree;

  BSP._internal(this.matrix, this.tree);

  /// Convert THREE.Geometry to BSP
  factory BSP(var geometryOrMesh) {

    THREE.Matrix4 matrix;
    CSG.Node tree;
    THREE.Geometry geometry;

    if ( geometryOrMesh is THREE.Geometry ) {
      matrix = new THREE.Matrix4();
      geometry = geometryOrMesh;
    } else if ( geometryOrMesh is THREE.Mesh ) {
      var mesh = geometryOrMesh as THREE.Mesh;
      // #todo: add hierarchy support
      mesh.updateMatrix();
      matrix = mesh.matrix.clone();
      geometry = mesh.geometry;
    } else {
      throw 'ThreeBSP: Given geometry is unsupported';
    }

    var faces = [];

    for (var face in geometry.faces){
      if ( face is THREE.Face3 ) {
        faces.add([face.a, face.b, face.c]);
      } else if ( face is THREE.Face4 ) {
        faces.add([face.a, face.b, face.d]);
        faces.add([face.c, face.d, face.b]);
      } else {
        throw 'Invalid face type $face';
      }
    }

    var polygons = faces.map((face) {

      List vertices = (face as List).map( (idx) {
          THREE.Vector3 vector = geometry.vertices[ idx].clone();
          matrix.multiplyVector3(vector);
          return new CSG.Vertex(new CSG.Vector(vector.x, vector.y, vector.z));
      });

      return new CSG.Polygon(vertices);
    });

    tree = new CSG.Node( polygons );

    return new BSP._internal(matrix, tree);
  }


  subtract( BSP other_tree ) {
    CSG.Node a = this.tree.clone(),
             b = other_tree.tree.clone();

    a
    ..invert()
    ..clipTo( b );

    b
    ..clipTo( a )
    ..invert()
    ..clipTo( a )
    ..invert();

    a
    ..build( b.allPolygons )
    ..invert();

    return new BSP._internal(this.matrix, a);
  }

  union( BSP other_tree ) {
    CSG.Node a = this.tree.clone(),
             b = other_tree.tree.clone();

    a.clipTo( b );

    b
    ..clipTo( a )
    ..invert()
    ..clipTo( a )
    ..invert();

    a.build( b.allPolygons );

    return new BSP._internal(this.matrix, a);
  }

  intersect( BSP other_tree ) {
    CSG.Node a = this.tree.clone(),
             b = other_tree.tree.clone();

    a.invert();

    b
    ..clipTo( a )
    ..invert();

    a.clipTo( b );

    b.clipTo( a );

    a
    ..build( b.allPolygons)
    ..invert();

    return new BSP._internal(this.matrix, a);
  }

  THREE.Geometry toGeometry() {

    var matrix = new THREE.Matrix4().getInverse( this.matrix );
    var geometry = new THREE.Geometry();
    var vertex, vector, face;

    tree.allPolygons.forEach((polygon) {

      var polygon_vertice_count = polygon.vertices.length;

      if (polygon_vertice_count == 4) { // Use THREE.Face4

         for (var i = 0; i < 4; i ++ ) {

          vertex = polygon.vertices[i].pos;
          vector = new THREE.Vector3( vertex.x, vertex.y, vertex.z );
          matrix.multiplyVector3( vector );
          geometry.vertices.add( vector );

        }

        face = new THREE.Face4(
          geometry.vertices.length - 4,
          geometry.vertices.length - 3,
          geometry.vertices.length - 2,
          geometry.vertices.length - 1,
          new THREE.Vector3( polygon.normal.x, polygon.normal.y, polygon.normal.z )
        );

        geometry.faces.add( face );

      } else { // Use THREE.Face3

        for ( var j = 2; j < polygon_vertice_count; j++ ) {
          vertex = polygon.vertices[0].pos;
          vector = new THREE.Vector3( vertex.x, vertex.y, vertex.z );
          matrix.multiplyVector3( vector );
          geometry.vertices.add( vector );

          vertex = polygon.vertices[j-1].pos;
          vector = new THREE.Vector3( vertex.x, vertex.y, vertex.z );
          matrix.multiplyVector3( vector );
          geometry.vertices.add( vector );

          vertex = polygon.vertices[j].pos;
          vector = new THREE.Vector3( vertex.x, vertex.y, vertex.z );
          matrix.multiplyVector3( vector );
          geometry.vertices.add( vector );

          face = new THREE.Face3(
              geometry.vertices.length - 3,
              geometry.vertices.length - 2,
              geometry.vertices.length - 1,
              new THREE.Vector3( polygon.normal.x, polygon.normal.y, polygon.normal.z )
          );

          geometry.faces.add( face );
        }

      }

    });

    geometry.computeCentroids();
    geometry.computeFaceNormals();
    geometry.mergeVertices();

    return geometry;
  }

  THREE.Mesh toMesh( THREE.Material material ) {
    var geometry = this.toGeometry(),
        mesh = new THREE.Mesh( geometry, material );

    mesh.position.getPositionFromMatrix( this.matrix );
    mesh.rotation.setEulerFromRotationMatrix( this.matrix );

    return mesh;
  }
}
