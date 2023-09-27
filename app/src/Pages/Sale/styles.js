import {StyleSheet} from 'react-native';

const styles = StyleSheet.create({

    container:{
        alignItems:'center',
        justifyContent:'center',
        width:'100%',
        backgroundColor: '#fff',
        flex:1,
    },

    contScrow:{
        flex:1,
        top:15,
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
        fontSize: 21,
        paddingHorizontal: 10,
        color: '#2F8BD8',

      },

      containerInput:{
        width:'80%',
        flexDirection:'row',
        alignItems:'center',
        borderColor:'#2F8BD8',
        borderBottomWidth:2,
        marginBottom: 20,
        marginTop:5
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

    //formulario

    inputForm:{
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



    //footer

  footerContent:{
    flexDirection:'row',
    alignItems:'center',
    justifyContent:'space-around',
    backgroundColor:'#175A93',
    width:'100%',
    height:90,
    position:'absolute',
    bottom: 0,
  },

  footerContentS:{
    flexDirection:'row',
    alignItems:'center',
    justifyContent:'space-around',
    backgroundColor:'#175A93',
    width:'94%',
    height:90,
    borderRadius:12,
    marginVertical:60,
    bottom:50,
    shadowColor:'#fff',
    shadowOffset:{width:0,height:50},
    shadowOpacity:1,
    shadowRadius:3.5,
    elevation:5,
},

  imageContent:{
      alignItems:'center',
  },
  
  titleButtom:{
      fontSize:18,
      fontWeight:'bold',
      color:'#fff',
      bottom:10,
  },
  //

  headerSales:{
    width:'100%',
    paddingHorizontal:30,
    paddingVertical:15,
    paddingTop:30,
    backgroundColor:'#175A93',
    justifyContent:'space-between',
    flexDirection:'row',
  },

  
  barCodeBox:{
    alignItems:'center',
    justifyContent:'center',
    height:300,
    width:300,
  },

  scanBox:{
    height: '90%', 
    width: '90%',    
    borderRadius:30,
  },

  // flatlist

  cardP: {
    marginHorizontal:20,
    padding:10,
    borderColor:'#2F8BD8',
    borderWidth:2,
    borderRadius:10,
    marginBottom:10,
  },

  cardPInd: {
    marginHorizontal:20,
    padding:10,
    borderColor:'tomato',
    borderWidth:2,
    borderRadius:10,
    marginBottom:10,
    backgroundColor: 'rgba(208, 88, 88, 0.16)'
  },



cardTitleP:{
    fontWeight: 'bold',
    fontSize:20,
    color:'#000',
    marginBottom:8 
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

txtBold:{
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

buttonBack:{
  borderColor:'#175A93',
  borderWidth:2,
  borderRadius:5,
  height:35,
  width:'30%',
  justifyContent:'center',
  alignItems:'center'
},

buttonAddInitial:{
  backgroundColor:'#2F8BD8',
  justifyContent:'center',
  alignItems:'center',
  height:40,
  borderRadius:10,
  padding:10,
  marginHorizontal:10
},

txtAddInitial:{
  color:'#fff',
  fontSize:16,
  fontWeight:'bold'
},

buttonEnt:{
  height:50,
  padding:10,
  borderRadius:10,
  width:'35%',
  justifyContent:'center',
  alignItems:'center',
},

buttonDownload:{
  backgroundColor:'#2F8BD8',
  height:30,
  justifyContent:'center',
  alignItems:'center',
  marginHorizontal:5,
  paddingHorizontal:10,
  borderRadius:5
},







});

export default styles;