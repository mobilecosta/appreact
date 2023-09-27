import React, {useContext,useState,useEffect} from 'react';
import {SafeAreaView, View, Text, Image, TouchableOpacity, ScrollView} from 'react-native'

import styles from './styles'

import {Ionicons,MaterialCommunityIcons} from '@expo/vector-icons';

import * as ImagePicker from 'expo-image-picker';

import {CartContext} from '../../Contexts/cart';

import AsyncStorage from '@react-native-async-storage/async-storage'

export default function Profile ({route,navigation}){

    const { dataUser,addImageProfile,imageProfile} = useContext(CartContext);

    const [imageSelect, setImageSelect] = useState(false);
    const [image, setImage] = useState(imageProfile);


    const saveImageProfile = async () => {
        await AsyncStorage.setItem('@ImageProfile',image)
        setImageSelect(false)
        addImageProfile(image)
    };

    const deleteImageProfile = async () => {
        await AsyncStorage.removeItem('@ImageProfile')
        addImageProfile(null)
        setImage(null)
    };


    const selectImageProfile = async () => {
        const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
        if (status === 'granted') {
            let result = await ImagePicker.launchImageLibraryAsync({
                mediaTypes: ImagePicker.MediaTypeOptions.All,
                allowsEditing: true,
                aspect: [4, 3],
                quality: 1,
            });
        
            if (!result.cancelled) {
                setImage(result.uri);
                setImageSelect(true)
            }
        }
    };
    


    return(
        <SafeAreaView style={styles.contSafe}>
            <View style={styles.container}>

                <View style={{alignItems:'flex-end',width:'85%',marginTop:20}}>
                    <TouchableOpacity style={{}} onPress={()=>{navigation.navigate('Login')}}>
                        <MaterialCommunityIcons name="logout" size={35} color="#175A93" />
                    </TouchableOpacity>
                </View>

                {image 
                    ?
                    <TouchableOpacity onPress={() => selectImageProfile()}>
                        <Image source={{ uri: image }} style={{ width: 200, height: 200, borderRadius:200/2, marginTop:32,marginBottom:15 }} />
                    </TouchableOpacity>
                    :
                    <TouchableOpacity onPress={() => selectImageProfile()}>
                        <Ionicons name="person-circle" size={250} color="grey" />
                    </TouchableOpacity>
                }

                {image && imageSelect &&
                    <TouchableOpacity onPress={() => saveImageProfile()}>
                        <Text>Salvar</Text>
                    </TouchableOpacity>
                }

                {image && !imageSelect &&
                    <TouchableOpacity onPress={() => deleteImageProfile()}>
                        <Text>Excluir</Text>
                    </TouchableOpacity>
                }


                <ScrollView style={{
                    marginVertical:35
                }}>
                    <Text style={{
                        textTransform:'capitalize', 
                        fontWeight:'bold', 
                        fontSize:26,
                        marginHorizontal:10,
                        }}
                    >
                        {dataUser.nome_usuario}
                    </Text>

                    
                </ScrollView>

                <View style={styles.footerContent}>
                    <TouchableOpacity style={styles.imageContent} onPress={()=>{navigation.navigate('Home')}}>
                        <Ionicons name="home" size={35} color="white" />
                        <Text style={styles.titleButtom}>Home</Text>
                    </TouchableOpacity>

                    <TouchableOpacity style={styles.imageContent} onPress={()=>{navigation.navigate('Profile')}}>
                        <Ionicons style={{marginBottom:3}} name="person" size={35} color="white" />
                        <Text style={styles.titleButtom}>Perfil</Text>
                    </TouchableOpacity>
                </View>
            </View>
        </SafeAreaView>
    )
}