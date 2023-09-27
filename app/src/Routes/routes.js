import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';

import Login from '../Pages/Login/index'
import Home from '../Pages/Home/index'
import Detail from '../Pages/Detail/index'
import SaleCli from '../Pages/Sale/saleCli'
import SalePrd from '../Pages/Sale/salePrd'
import SalePay from '../Pages/Sale/salePay'
import Sections from '../Sections/index'
import Profile from '../Pages/Profile/index'

const Stack = createStackNavigator();

export default function Routes(){
    return(
        <Stack.Navigator headerMode='none' screenOptions={{gestureEnabled: false}}>
            <Stack.Screen name="Login" component={Login}/>
            <Stack.Screen name="Home" component={Home}/>
            <Stack.Screen name="Detail" component={Detail}/>
            <Stack.Screen name="Sections" component={Sections}/>
            <Stack.Screen name="SaleCli" component={SaleCli}/>
            <Stack.Screen name="SalePrd" component={SalePrd}/>
            <Stack.Screen name="SalePay" component={SalePay}/>
            <Stack.Screen name="Profile" component={Profile}/>
        </Stack.Navigator>
    )
};