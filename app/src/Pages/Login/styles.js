import {StyleSheet} from 'react-native';

const styles = StyleSheet.create({

    container:{
        flex:1,
        backgroundColor: '#fff',
        alignItems:'center',
        justifyContent:'center',
        paddingBottom:50,
    },

    containerLogo:{
        flex:1,
        justifyContent:'center',
        alignItems:'center',
        width:'90%',
    },

    containerInput:{
        flex:1,
        justifyContent:'center',
        alignItems:'center',
        width:'90%',
    },

    input:{
        backgroundColor:'#fff',
        width:'90%',
        marginBottom:15,
        color:'#222',
        fontSize:17,
        borderWidth:2,
        borderRadius:7,
        padding:10,
        borderColor:'#2F8BD8',
        shadowColor:'#000000',
        shadowOffset:{width:5,height:5},
        shadowOpacity:0.30,
        shadowRadius:3.5,
        elevation:5,
    },

    containerInpuPass:{
        width:'90%',
        flexDirection:'row',
        backgroundColor:'#fff',
        marginBottom:15,        
        borderWidth:2,
        borderRadius:7,
        borderColor:'#2F8BD8',
        alignItems:'center',
        shadowColor:'#000000',
        shadowOffset:{width:5,height:5},
        shadowOpacity:0.30,
        shadowRadius:3.5,
        elevation:5,
    },
        
    inputPass:{
        color:'#222',
        fontSize:17,
        width:'90%',
        padding:10,
    },

    button:{
        backgroundColor:'#2F8BD8',
        width:'90%',
        height:45,
        alignItems:'center',
        justifyContent:'center',
        borderRadius:7,
        shadowColor:'#000000',
        shadowOffset:{width:5,height:5},
        shadowOpacity:0.30,
        shadowRadius:3.5,
        elevation:5,
    },

    buttonText:{
        color:'#fff',
        fontSize:20,
        fontWeight:'bold',
    },
    
});

export default styles;