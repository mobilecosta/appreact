import React,{useState,useEffect,useContext} from 'react';
import {
    KeyboardAvoidingView, 
    View, 
    Keyboard, 
    TextInput, 
    Text, 
    TouchableOpacity,
    Animated,
    ActivityIndicator
} from 'react-native';
 
import { Ionicons } from '@expo/vector-icons';
import {decode, encode} from 'base-64'
import api from '../../services/api'
import {CartContext} from '../../Contexts/cart'

import styles from './styles';

if (!global.btoa) { global.btoa = encode }
if (!global.atob) { global.atob = decode }

export default function Login({navigation}){

    const [offSet] = useState(new Animated.ValueXY({x:0,y:90}))
    const [logo] = useState(new Animated.ValueXY({x:1,y:1}))
    const [opacity] = useState(new Animated.Value(0))
    
    const [user, setUser] = useState('');
    const [pass, setPass] = useState('');
    const [load, setLoad] = useState(false);

    const {setUserData} = useContext(CartContext)

    const [hidepass, setHidepass] = useState(false)

    const tentLogar = async() => {

        let result = {}

        setLoad(true)

        for (var i = 0; i < 5; i++) {
            console.log('tentativa de logar 8: '+i);
            result = await loadUser()
            
            if(result.retorno){
                setLoad(false)
                navigation.navigate('Home');
                break
            }
        }
        
        if(!result.retorno){
            alert(result.erro)
        }
        setLoad(false)
    }


    const loadUser = async() =>{
        Keyboard.dismiss()
        
        try{
            const response = await api.post("/PRTL001", {
                USUARIO: user.toUpperCase(),
                SENHA: pass, 
            });

            if (response.data.statusrequest[0].code === '#200') {
                console.log(response.data.statusrequest[0])

                setUserData(response.data.statusrequest[0])
                return {retorno: true, erro: ''}
                
            } else {
                //alert(response.data.statusrequest[0].Cod_Usuario)
                return {retorno: false, erro: response.data.statusrequest[0].Cod_Usuario}
            } 
        
        } catch(error){
            console.log(error)
            //alert('Usuário ou senha incorretos')
            return {retorno: false, erro: 'Usuário ou senha incorretos'}
        }
        
    };

    useEffect(()=>{
        keyboardDidShowListener = Keyboard.addListener('keyboardDidShow', keyboardDidShow);
        keyboardDidHideListener = Keyboard.addListener('keyboardDidHide', keyboardDidHide);

        Animated.parallel([
            Animated.spring(offSet.y,{
                toValue: 0,
                speed: 4,
                bounciness:20,
                useNativeDriver: true
            }),
            
            Animated.timing(opacity,{
                toValue: 1,
                duration:200,
                useNativeDriver: true
            })
        ]).start();
    },[]);

    function keyboardDidShow(){
        Animated.parallel([
            Animated.timing(logo.x,{
                toValue:0.7,
                duration:100,
                useNativeDriver: true
            }),
            Animated.timing(logo.y,{
                toValue:0.7,
                duration:100,
                useNativeDriver: true
            }),
        ]).start();
    };

    function keyboardDidHide(){
        Animated.parallel([
            Animated.timing(logo.x,{
                toValue:1,
                duration:100,
                useNativeDriver: true
            }),
            Animated.timing(logo.y,{
                toValue:1,
                duration:100,
                useNativeDriver: true
            }),
        ]).start();
    };

    return( 
        
        <KeyboardAvoidingView 
            style={styles.container}
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}>
            <View style={styles.containerLogo}>
                <Animated.Image
                    source={require('../../assets/logo.png')}
                    style={[{transform: [
                        {scaleX: logo.x},
                        {scaleY: logo.y},
                        ], 
                    }]}
                />
            </View>

            <Animated.View style={
                [styles.containerInput,
                    {   
                        opacity:opacity,
                        transform:[{ translateY: offSet.y }]
                    }
                ]
                }>
            <TextInput
                    style={styles.input}
                    placeholder="Login"
                    autoCorrect={false}
                    onChangeText={setUser}
                    value={user}
                />

                <View style={styles.containerInpuPass}>   
                    <TextInput
                        style={styles.inputPass}
                        placeholder="Senha"
                        autoCorrect={false}
                        onChangeText={setPass}
                        value={pass}
                        secureTextEntry={!hidepass}
                    />
                    <TouchableOpacity onPress={()=>{setHidepass(!hidepass)}}>
                        <Ionicons style={{right:10}} name={hidepass?"eye-off":"eye"} size={30} color="black" />
                    </TouchableOpacity>
                </View>


                <TouchableOpacity style={styles.button} onPress={tentLogar}>
                    {load ?
                    <View style={{flex:1,justifyContent:'center'}}>
                        <ActivityIndicator color={'#fff'} size={35}/>
                    </View>
                        :
                    <Text style={styles.buttonText}>Entrar</Text>
                    }
                </TouchableOpacity>
                
                <View style={{marginTop:40}}>
                    <Text>v120230330</Text>
                </View>
            </Animated.View>
            
        </KeyboardAvoidingView>
    )
}