part of threecsg;

class BSP {
  Matrix4 matrix;
  CSG.Node tree;

  BSP._internal(this.matrix, this.tree);

  /// Convert THREE.Geometry to BSP
  factory BSP(var geometryOrMesh) {

    Matrix4 matrix;
    CSG.Node tree;
    THREE.Geometry geometry;

    if ( geometryOrMesh is THREE.Geometry ) {
      matrix = new Matrix4.identity();
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

    List<List> faces3 = [];
    
    for(var face in geometry.faces){
      if ( face is THREE.Face3 ) {
        faces3.add([face.a, face.b, face.c]);
      } else if ( face is THREE.Face4 ) {
        faces3.add([face.a, face.b, face.d]);
        faces3.add([ face.c, face.d, face.b]);
      } else {
        throw 'Invalid face type $face';
      }
    }
    
    List<CSG.Polygon> polygons = faces3.map((face) {
     
      List vertices = face.map( (idx) {
          Vector3 vector = geometry.vertices[ idx].clone();
          vector.applyProjection(matrix);
          return new CSG.Vertex(new CSG.Vector(vector.x, vector.y, vector.z));
      }).toList(growable: true);
      
      return new CSG.Polygon(vertices);
    }).toList(growable: true);

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

    var matrix = this.matrix.clone();
    matrix.invert();
    var geometry = new THREE.Geometry();
    var vertex, vector, face;
    var maxVertex = tree.allPolygons.map((p) => p.vertices.length).toList().reduce((a,b) => Math.max(a,b));
    
    print("[BSP] MAX VERTEXES : ${maxVertex}");
        
    tree.allPolygons.forEach((polygon) {

      var polygon_vertice_count = polygon.vertices.length;


      if ( polygon_vertice_count == 47) { // Use THREE.Face4
         //print("[BSP] face4");
         for (var i = 0; i < 4; i ++ ) {

          vertex = polygon.vertices[i].pos;
          vector = new Vector3( vertex.x, vertex.y, vertex.z );
          vector.applyProjection(matrix);
          geometry.vertices.add( vector );

        }

        face = new THREE.Face4(
          geometry.vertices.length - 4,
          geometry.vertices.length - 3,
          geometry.vertices.length - 2,
          geometry.vertices.length - 1,
          new Vector3( polygon.normal.x, polygon.normal.y, polygon.normal.z )
        );

        geometry.faces.add( face );

      } else { // Use THREE.Face3
        //print("[BSP] face3 - ${polygon_vertice_count}");
        for ( var j = 2; j < polygon_vertice_count; j++ ) {
          vertex = polygon.vertices[0].pos;
          vector = new Vector3( vertex.x, vertex.y, vertex.z );
          vector.applyProjection(matrix);
          geometry.vertices.add( vector );
          
          vertex = polygon.vertices[j-1].pos;
          vector = new Vector3( vertex.x, vertex.y, vertex.z );
          vector.applyProjection(matrix);
          geometry.vertices.add( vector );
          
          vertex = polygon.vertices[j].pos;
          vector = new Vector3( vertex.x, vertex.y, vertex.z );
          vector.applyProjection(matrix);
          geometry.vertices.add( vector );
          
          face = new THREE.Face3(
              geometry.vertices.length - 3,
              geometry.vertices.length - 2,
              geometry.vertices.length - 1,
              new Vector3( polygon.normal.x, polygon.normal.y, polygon.normal.z )
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
    
    mesh.applyMatrix( this.matrix );

    return mesh;
  }
}
