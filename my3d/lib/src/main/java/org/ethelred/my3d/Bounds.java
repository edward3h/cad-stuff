package org.ethelred.my3d;

import static java.lang.Math.max;
import static java.lang.Math.min;

public class Bounds {
    private Vector3f min;
    private Vector3f max;

    public void merge(Vector3f point) {
        if (min == null) {
            min = point;
            max = point;
            return;
        }
        min = new Vector3f(
                min(min.x(), point.x()),
                min(min.y(), point.y()),
                min(min.z(), point.z())
        );
        max = new Vector3f(
                max(max.x(), point.x()),
                max(max.y(), point.y()),
                max(max.z(), point.z())
        );
    }

    public void merge(Bounds bounds) {
        merge(bounds.min);
        merge(bounds.max);
    }

    @Override
    public String toString() {
        return "x: %f to %f, y: %f to %f, z: %f to %f".formatted(min.x(), max.x(), min.y(), max.y(), min.z(), max.z());
    }
}
