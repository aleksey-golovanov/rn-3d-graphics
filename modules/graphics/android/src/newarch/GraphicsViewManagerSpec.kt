package com.graphics

import android.view.View

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.GraphicsViewManagerDelegate
import com.facebook.react.viewmanagers.GraphicsViewManagerInterface

abstract class GraphicsViewManagerSpec<T : View> : SimpleViewManager<T>(), GraphicsViewManagerInterface<T> {
  private val mDelegate: ViewManagerDelegate<T>

  init {
    mDelegate = GraphicsViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<T>? {
    return mDelegate
  }
}
