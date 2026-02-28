package org.ethelred.my3d.app;

import org.ethelred.my3d.BinarySTLFileReader;

import java.io.IOException;
import java.nio.file.Path;

public class App {
    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.out.println("Usage: App <file path>");
            return;
        }
        var reader = new BinarySTLFileReader();
        var mesh = reader.read(Path.of(args[0]));
        var bounds = mesh.bounds();
        System.out.println(bounds);
    }
}
