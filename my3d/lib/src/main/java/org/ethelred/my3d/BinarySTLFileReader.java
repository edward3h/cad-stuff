package org.ethelred.my3d;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.HashSet;

public class BinarySTLFileReader {
    public Mesh read(Path path) throws IOException {
        var fileChannel = FileChannel.open(path, StandardOpenOption.READ);
        // skip 80 byte header, 4 byte length
        fileChannel.position(84);
        // 3 float points = 3 * 4 * 3, float normal = 4 * 3, short attributes = total 50 bytes per triangle
        var buffer = ByteBuffer.allocate(50).order(ByteOrder.LITTLE_ENDIAN);
        var triangles = new HashSet<Triangle>();
        while (fileChannel.read(buffer) == 50)
        {
            buffer.flip();
            triangles.add(readTriangle(buffer));
            buffer.clear();
        }
        return new Mesh(triangles);
    }

    private Triangle readTriangle(ByteBuffer buffer) {
        var normal = readVector(buffer);
        var a = readVector(buffer);
        var b = readVector(buffer);
        var c = readVector(buffer);
        var attr = buffer.getShort();
        return new Triangle(a, b, c, attr, normal);
    }

    private Vector3f readVector(ByteBuffer buffer) {
        return new Vector3f(
                buffer.getFloat(),
                buffer.getFloat(),
                buffer.getFloat()
        );
    }
}
