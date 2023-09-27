import {StyleSheet} from 'react-native';

const styles = StyleSheet.create({

    contSafe:{
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'flex-start',
    },

    container:{
        flex:1,
        alignItems:'center',
        width:'100%',
    },

    contScrow:{
        flex:1,
        top:15
    },


    contPage:{
        flex:1,
        flexDirection:'row',
    },

    subContPage:{
        flex:1,
        flexDirection:'row',
        justifyContent:'space-around',
        marginTop:15,
        marginBottom:30
    },

    textNPage:{
        top:5,
        fontSize:20,
    },

    input: {
        width:'80%',
        height: 50,
        marginVertical: 30,
        fontSize: 21,
        paddingHorizontal: 15,
        color: '#2F8BD8',
        borderColor:'#2F8BD8',
        borderBottomWidth:2,
      },

      containerInput:{
        width:'90%',
        flexDirection:'row',
        alignItems:'center',
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


    //modal
    
    modalBackGround: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.5)',
        justifyContent: 'center',
        alignItems: 'center',
      },
      modalContainer: {
        width: '80%',
        backgroundColor: 'white',
        paddingHorizontal: 20,
        paddingVertical: 20,
        borderRadius: 20,
        elevation: 20,
      },
      
      headerPed: {
        flexDirection:'row',
        justifyContent:'space-between',
        marginBottom:15
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


    //footer

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
      bottom: Platform.OS === 'ios' ? 32 : 10,
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
      marginTop:3
  }

});

export default styles;