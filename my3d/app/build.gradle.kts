plugins {
    id("buildlogic.java-application-conventions")
}

dependencies {
    implementation(project(":lib"))
}

application {
    // Define the main class for the application.
    mainClass = "org.ethelred.my3d.app.App"
}
