/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {Dimensions, SafeAreaView} from 'react-native';

import {GraphicsView} from 'react-native-graphics';

function App(): React.JSX.Element {
  const {width} = Dimensions.get('screen');

  return (
    <SafeAreaView>
      <GraphicsView style={{width, height: width}} />
    </SafeAreaView>
  );
}

export default App;
