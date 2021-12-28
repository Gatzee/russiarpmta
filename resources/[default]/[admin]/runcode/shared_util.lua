local classInfo = debug.getregistry( ).mt

classInfo.Element.__get.pos = classInfo.Element.__get.position
classInfo.Element.__get.rot = classInfo.Element.__get.rotation
classInfo.Element.__set.pos = classInfo.Element.__set.position
classInfo.Element.__set.rot = classInfo.Element.__set.rotation

V = Vector3