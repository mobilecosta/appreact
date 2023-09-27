import {StyleSheet} from 'react-native';

const styles = StyleSheet.create({


    container:{
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'flex-start'
    },
    
    header: {
        justifyContent:'center',
        width:'100%',
        height:100,
        backgroundColor:'#175A93',
        borderBottomStartRadius:20,
        borderBottomEndRadius:20
    },

    contTextHeader:{
        flex:1,
        flexDirection:'row',
        justifyContent:'flex-start',
        alignItems:'center',
        marginLeft:20,
        marginRight:80
    },

    textHeader:{
        fontSize:26,
        color:'#ffffff',
        textTransform: 'capitalize'
    },    


    content:{
        flex: 1,
        justifyContent:'center',
        flexDirection: 'row',
        flexWrap:'wrap',
    },

    card: {
        width:'42%',
        padding:10,
        margin:10,
        height:130,
        borderColor:'#175A93',
        borderWidth:2,
        borderRadius:20,
    },

    cardTitle:{
        fontWeight: 'bold',
        fontSize:24,
        color:'#175A93', 
    },

    cardP: {
        flex:1,
        flexDirection:'row',
        alignItems:'center',
        justifyContent:'space-evenly',
        marginVertical:10,
        marginHorizontal:20,
        height:70,
        borderColor:'#175A93',
        borderWidth:2,
        borderRadius:10,
    },

    cardTitleP:{
        fontWeight: 'bold',
        fontSize:24,
        color:'#585450',
    },

    titleContent:{
        flex:1,
        flexDirection:'row',
        alignItems:'flex-end'
    },

    footerContent:{
        flex:1,
        flexDirection:'row',
        alignItems:'center',
        justifyContent:'center',
        backgroundColor:'#175A93',
        width:'94%',
        height:90,
        borderRadius:12,
        position:'absolute',
        bottom: 10,
        shadowColor:'#000',
        shadowOffset:{width:0,height:20},
        shadowOpacity:0.25,
        shadowRadius:3.5,
        elevation:5,
    },

    imageContent:{
        flex:1,
        alignItems:'center',
    
    },

    imageConfirm:{
        flex:1,
        alignItems:'center',
        bottom:30,
    },
    
    titleButtom:{
        fontSize:18,
        fontWeight:'bold',
        color:'#fff',
    },

});

export default styles;