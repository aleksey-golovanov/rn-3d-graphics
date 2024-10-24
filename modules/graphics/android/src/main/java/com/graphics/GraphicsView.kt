package com.graphics

import android.content.Context
import android.opengl.GLSurfaceView
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import android.opengl.GLES20

class GraphicsView(context: Context) : GLSurfaceView(context) {

    private val renderer: MyRenderer

    init {
        // Create an OpenGL ES 2.0 context
        setEGLContextClientVersion(2)

        // Set the Renderer for drawing on the GLSurfaceView
        renderer = MyRenderer()
        setRenderer(renderer)

        // Render the view only when there is a change
        renderMode = GLSurfaceView.RENDERMODE_WHEN_DIRTY
    }
}

class MyRenderer : GLSurfaceView.Renderer {
    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        // Set the background frame color (clear color)
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f)
    }

    override fun onDrawFrame(gl: GL10?) {
        // Redraw background color
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        // Adjust the viewport based on geometry changes
        GLES20.glViewport(0, 0, width, height)
    }
}
