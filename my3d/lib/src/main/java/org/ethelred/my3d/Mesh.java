package org.ethelred.my3d;

import java.util.Set;

public record Mesh(Set<Triangle> triangles) {
    public Bounds bounds() {
        return triangles.stream().flatMap(Triangle::points).collect(Bounds::new, Bounds::merge, Bounds::merge);
    }
}
