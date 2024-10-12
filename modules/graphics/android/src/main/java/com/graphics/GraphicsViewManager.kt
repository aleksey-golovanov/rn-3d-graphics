package com.graphics

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp

@ReactModule(name = GraphicsViewManager.NAME)
class GraphicsViewManager :
  GraphicsViewManagerSpec<GraphicsView>() {
  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): GraphicsView {
    return GraphicsView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: GraphicsView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "GraphicsView"
  }
}
