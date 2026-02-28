package org.ethelred.my3d;

import java.util.stream.Stream;

public record Triangle(Vector3f pointA, Vector3f pointB, Vector3f pointC, short attributes, Vector3f readNormal) {
    public Stream<Vector3f> points() {
        return Stream.of(pointA, pointB, pointC);
    }
}
