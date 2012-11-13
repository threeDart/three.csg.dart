/**
THREE.CSG (https://github.com/chandlerprall/ThreeCSG)

@author Chandler Prall <chandler.prall@gmail.com> http://chandler.prallfamily.com

Wrapper for Evan Wallace's CSG library (https://github.com/evanw/csg.js/)
Provides CSG capabilities for Three.js models.

Provided under the MIT License
*/

/**
 * based on commit/530aa70c49a84ed8f17cfa086860f23d2049f2ed
 *
 * Ported to Dart by:
 *
 * @author nelsonsilva - http://www.inevo.pt
 **/

library threecsg;

import "package:csg/csg.dart" as CSG;
import 'package:three/three.dart' as THREE;
import 'dart:math' as Math;

part "src/bsp.dart";