import {StyleSheet} from 'react-native';

const styles = StyleSheet.create({

    content:{
        flex: 1,
        justifyContent:'center',
        flexDirection: 'row',
        flexWrap:'wrap',
        marginHorizontal:15
    },

    cardP: {
        width:'100%',
        padding:10,
        borderColor:'#2F8BD8',
        borderWidth:2,
        borderRadius:10,
        marginBottom:10,
    },
    

    cardTitleP:{
        fontWeight: 'bold',
        fontSize:20,
        color:'#000',
        marginBottom:8 
    },

    buttonBack:{
        borderColor:'#175A93',
        borderWidth:2,
        borderRadius:5,
        height:35,
        width:'30%',
        justifyContent:'center',
        alignItems:'center'
      },

    cardDescP:{
        fontWeight: 'bold',
        fontSize:16,
        color:'#585450',
        marginBottom:8 
    },

    cardSubTitleP:{
        fontSize:14,
        color:'#585450',
    },

    genero:{
        width:20,
        bottom:8,
        resizeMode:'contain'
    },

    imgPreview:{
        height: 250, 
        width: 250, 
        marginVertical: 10, 
        resizeMode:'contain'
    },

    txtPreview:{ 
        fontSize: 30, 
        textAlign: 'center'
    },

    closeModal: {
        height: 40,
        alignItems: 'flex-end',
    },

    emptyContainer: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
    },
    
    emptyText: {
        fontSize: 22,
        color:'red'
    },

    headerPed: {
        flexDirection:'row',
        justifyContent:'space-between',
        marginBottom:15,
    },

    contDetPed: {
        flex:1,
        height:'100%',
        justifyContent:'space-between',
        flexDirection:'column',
        borderBottomWidth:2,
        marginBottom:15,
        borderBottomColor:'#2F8BD8'
    },

    cabecDet:{
        marginTop:20,
        flexDirection:'row',
        justifyContent:'space-between',
        marginHorizontal:10,
    },

    itensDet:{
        marginTop:5,
        marginBottom:10,
        flexDirection:'row',
        justifyContent:'space-between',
        marginHorizontal:10
    },

    totalPed:{
        height:70,
        alignItems:'center',
        flexDirection:'row',
        justifyContent:'space-between',
        borderWidth:2,
        borderRadius:10,
        paddingHorizontal:5,
        backgroundColor:'#C5DBE3'
    },

    txtBold:{
        fontSize:16, 
        fontWeight:'bold'
    },


    //formulario

    input:{
        height:35,
        borderBottomWidth:2,
        marginBottom:20,
        paddingHorizontal:5,
        fontSize:16
    },

    submitAtualizar:{
        backgroundColor:'#2F8BD8',
        justifyContent:'center',
        alignItems:'center',
        height:50,
        marginHorizontal:70,
        borderRadius:15
    },

    submitTxtAtualizar:{
        fontSize:18,
        fontWeight:'bold',
        color:'#fff'
    },

    buttonAddInitial:{
        backgroundColor:'#2F8BD8',
        justifyContent:'center',
        alignItems:'center',
        marginHorizontal:100,
        marginTop:20,
        height:40,
        borderRadius:10
    },

    txtAddInitial:{
        color:'#fff',
        fontSize:16,
        fontWeight:'bold'
    },


    buttonQty:{
        width: 30,
        height: 30,
        borderRadius: 30/2,
        backgroundColor:'#2F8BD8',
        alignItems:'center',
        justifyContent:'center'
    },

    txtButtonQty:{
        color:'#fff',
        fontWeight:'bold',
        fontSize:16
    },
      
});

export default styles;