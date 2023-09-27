import React,{useContext, useState} from 'react';
import {
    SafeAreaView,
    View,
    Text,
    TouchableOpacity,
    FlatList,
    TextInput,
    ActivityIndicator,

} from 'react-native';

import AsyncStorage from '@react-native-async-storage/async-storage'

import api from '../../services/api'
import { printToFileAsync } from 'expo-print'
import { shareAsync } from 'expo-sharing'

import _ from 'underscore';

import styles from './styles';

import {decode, encode} from 'base-64';
import { Ionicons } from '@expo/vector-icons';

import {CartContext} from '../../Contexts/cart';

import ModObs from '../../Modal/modObs';


if (!global.btoa) { global.btoa = encode }
if (!global.atob) { global.atob = decode }


export default function SalePay({route,navigation}){

    const { data,dataBack,vendedor,continuaP,ItensContinua } = route.params;
    const { cart,cliente,desconto,qtdTotalCart,vlrTotalCart,dataUser,setUserData } = useContext(CartContext)
    
    const [visibleObs,setVisibleObs] = useState(false);
    const [txtObs,setTxtObs] = useState(continuaP?ItensContinua.txtObs:'')
    const [itensErrSld, setItensErrSld] = useState([]);
    const [payment,setPayment] = useState('');
    const [dPayment,setDPayment] = useState('');
    const [load1,setLoad1] = useState(false);
    const [load2,setLoad2] = useState(false);


    const geraPedido = async() =>{

        setLoad2(true)
        
        const copyCart = [...cart];
        const copyClient = {...cliente};

        let endereco1 = !!copyClient.endereco1?copyClient.endereco1:''
        let cep1 = !!copyClient.cep1?copyClient.cep1:''
        let bairro1 = !!copyClient.bairro1?copyClient.bairro1:''

        let paramPed = {
            CLIENTE: copyClient,
            CONDPAGTO: payment,
            DESCONTO: desconto,
            FORCE: 'FALSE',
            ITEMS: copyCart,
            VENDEDOR: vendedor,
            OBSERVATION: txtObs,
            ENDERECO_ENTREGA: endereco1,
            BAIRRO_ENTREGA: bairro1,
            CEP_ENTREGA: cep1,
            ORCAMENTO: 'N',
            NUMORC: '',
            USUARIO: dataUser.Cod_Usuario
        }

        let lSaldo = true
        
        await api.post("/prtl003", { body: JSON.stringify(paramPed) })
        .then(async (item) => {
            if (item.data.code == "200") {

                const data = new Date()

                let dia = data.getDate().toString().padStart(2, '0')
                let mes = (data.getMonth()+1).toString().padStart(2, '0')
                let ano = data.getFullYear().toString()


                const copyUserData = {...dataUser}
                
                copyCart.map((itemCart)=>{
                    console.log(itemCart)
                    if(itemCart.BENEF === 'B'){
                        console.log('entrou')
                        copyUserData.auth_benef = 'N',
                        copyUserData.ult_benef = ano+mes+dia
                    }
                })

                setUserData(copyUserData)
                console.log(copyUserData)

                alert('Seu pedido foi enviado com sucesso');
                geraPDF(item.data.pedido,paramPed,lSaldo)

            } else if(item.data.codigo == "410"){
                setItensErrSld(item.data)
                lSaldo = false
            }
            
        })
        .catch((err) => {
            //alert("Erro na geração do pedido")
            console.log(err);
        });
        
        if(continuaP){
            const response = await AsyncStorage.getItem('@OpenOrders')
            const copyResponse = [...JSON.parse(response)]

            var remove = copyResponse.filter((item) => item.id !== ItensContinua.id);

            await AsyncStorage.setItem('@OpenOrders',JSON.stringify(remove))
        };
        
    };


    const geraPDF = async(pedido,params,lSaldo) =>{
        const file = await printToFileAsync({
            html: PDFHTML(pedido,params),
            base64: true
        })

        try{
            const response = await api.post("/PRTL047",{
                CODE64: file.base64, 
                NOME:pedido+'_'+params.CLIENTE.cnpj+'.pdf', 
                PEDIDO: pedido,
                EMAIL: params.CLIENTE.email,
                GERANOV: 'N'
            });

            if (response.data.statusrequest[0].code === '#200') {
                console.log(response.data.statusrequest[0].message)

            } else {
                console.log(response.data.statusrequest[0].message)
            } 
        
        } catch(error){
            console.log(error)
        }

        setLoad2(false)

        if(lSaldo){
            await shareAsync(file.uri)
            navigation.navigate('Home')
        }
    }


    const salvaPedido = async() =>{

        setLoad1(true)

        const copyCart = [...cart]
        const copyClient = {...cliente};

        let idResponse = ''
        let codigoId = ''

        let paramPed = {
            CLIENTE: copyClient,
            CONDPAGTO: payment,
            DESCONTO: desconto,
            FORCE: 'FALSE',
            ITEMS: copyCart,
            VENDEDOR: vendedor,
            OBSERVATION: txtObs,
            ENDERECO_ENTREGA: !!copyClient.endereco1?copyClient.endereco1:'',
            BAIRRO_ENTREGA: !!copyClient.bairro1?copyClient.bairro1:'',
            CEP_ENTREGA: !!copyClient.cep1?copyClient.cep1:'',
            ORCAMENTO: 'S',
            NUMORC: continuaP?ItensContinua.codigo:''
        }

        await api.post("/prtl003", { body: JSON.stringify(paramPed) })
        .then(async (item) => {
            idResponse = item.data.pedido
        });

        if(!!idResponse){
            codigoId = idResponse
        }else {
            codigoId = Math.floor(Math.random() * (999999 - 900000 + 1) + 900000);
        }

        const data = new Date()

        let dia = data.getDate().toString().padStart(2, '0')
        let mes = (data.getMonth()+1).toString().padStart(2, '0')
        let ano = data.getFullYear().toString()

        let pedido = {
            id: '9'+codigoId.toString(),
            cliente: copyClient.nome_fantasia,
            cnpj: copyClient.cnpj,
            codigo: codigoId.toString(),
            emissao: dia+'/'+mes+'/'+ano.substring(2,4),
            dtemisped: ano+mes+dia,
            nota: "",
            serie: "",
            razao_social: copyClient.razao_social,
            status: "Editando",
            items: copyCart,
            cliItm: copyClient,
            desconto: desconto,
            qtdTotal: qtdTotalCart,
            vlrTotal: vlrTotalCart,
            txtObs: txtObs
        };


        const response = await AsyncStorage.getItem('@OpenOrders')

        if(response){

            const copyResponse = [...JSON.parse(response)]

            if(continuaP){

                var remove = copyResponse.filter((item) => item.id !== ItensContinua.id);

                let updPed = {
                    id: ItensContinua.id,
                    cliente: ItensContinua.cliente,
                    cnpj: ItensContinua.cnpj,
                    codigo: ItensContinua.codigo,
                    emissao: ItensContinua.emissao,
                    nota: "",
                    serie: "",
                    razao_social: ItensContinua.razao_social,
                    status: "Editando",
                    items: copyCart,
                    cliItm: ItensContinua.cliItm,
                    desconto: desconto,
                    qtdTotal: qtdTotalCart,
                    vlrTotal: vlrTotalCart,
                    dtemisped:ItensContinua.dtemisped,
                    txtObs: txtObs
                };

                remove.push(updPed)
                await AsyncStorage.setItem('@OpenOrders',JSON.stringify(remove))

            } else{
                copyResponse.push(pedido)
                await AsyncStorage.setItem('@OpenOrders',JSON.stringify(copyResponse))
            }

        } else {
            await AsyncStorage.setItem('@OpenOrders',JSON.stringify([pedido]))
        }

        setLoad1(false)

        alert('Pedido salvo localmente')
        navigation.navigate('Home')
    };






    return( 
        <>
        <SafeAreaView edges={["top"]} style={{ flex: 0, backgroundColor: "#175A93" }}/>
        <SafeAreaView
            edges={["left", "right", "bottom"]}
            style={{flex: 1, backgroundColor: "#fff",position: "relative",}}
        >
            <View style={{backgroundColor:'#fff',width:'100%',flex:1}}>
                <View style={[styles.headerSales,{marginBottom:30}]}>  
                    <TouchableOpacity onPress={()=>{navigation.navigate('SalePrd',{
                        nameSec:dataBack[0],
                        data:dataBack[1],
                        filter:dataBack[2],
                    })}}>
                        <Ionicons style={{bottom:5,right:7}} name="arrow-back" size={40} color="white" />
                    </TouchableOpacity>

                    <Text style={{fontSize:24,fontWeight:'bold', color:'#fff'}}>Cond. Pagamento</Text>
                </View> 

                <FlatList
                    data={data.sort((a, b) => a.codigo.localeCompare(b.codigo))}
                    renderItem={({item})=>

                        <View style={{
                            justifyContent:'center',
                            alignItems:'center',
                        }}>
                            <TouchableOpacity 
                                style={{
                                    marginVertical:5,
                                    borderWidth:2,
                                    borderColor:'#175A93',
                                    borderRadius:10,
                                    width:'90%',
                                    justifyContent:'center',
                                    paddingHorizontal:20,
                                    paddingVertical:10
                                }}
                                onPress={()=>{ setVisibleObs(true),setPayment(item.codigo), setDPayment(item.descricao) }}

                            > 
                                <Text>{'Codigo: ' + item.codigo.trim()}</Text>
                                <Text>{'Descrição: ' + item.descricao.trim()}</Text>
                                <Text>{'Forma: ' + item.forma.trim()}</Text>
                            </TouchableOpacity>
                        </View>
                    }

                    onEndReachedThreshold={0.1}
                    keyExtractor={(item, index) => String(index)}
                    ListEmptyComponent={
                        <View style={styles.emptyContainer}>
                            <Text style={styles.emptyText}>Registro não encontrado</Text>
                        </View>
                    }
                />
            
            </View>

    
            <ModObs visibleObs={visibleObs}>
                <View style={{flexDirection:'row',justifyContent:'space-between',marginBottom:50}}>
                    <Text style={{fontSize:22, fontWeight:'bold'}}>Observação</Text>

                    <TouchableOpacity onPress={() => {setVisibleObs(false),setTxtObs('')}}>
                        <Ionicons name="close" size={40} color="black" />
                    </TouchableOpacity>
                </View>

    
                <View style={{justifyContent:'space-between'}}>
                    <TextInput 
                        placeholder='digite a observação...'
                        placeholderTextColor={'#9E8989'}
                        multiline={true}
                        value={txtObs}
                        onChangeText={text => setTxtObs(text)}
                        style={{
                            borderWidth:2,
                            borderColor:'#2F8BD8',
                            borderRadius:10,
                            height:100,
                            padding:10,
                            paddingTop:10
                        }}
                    />
                </View>
                
                <View style={{flexDirection:'row', justifyContent:'space-between',marginHorizontal:30}}>
                    <TouchableOpacity 
                            style={{
                            justifyContent:'center',
                            alignItems:'center',
                            height:40,
                            backgroundColor:'#F4C619',
                            opacity:0.8,
                            borderRadius:10,
                            padding:10,
                            marginTop:30,
                            marginBottom:50,
                            width:'48%'
                        }}
                        onPress={()=>{salvaPedido()}}
                    >
                        {load1 
                            ? <ActivityIndicator color={'#000'} size={35}/>                        
                            :<Text style={{fontSize:18,color:'#000',fontWeight:'bold'}}>Salvar</Text>
                        }
                    </TouchableOpacity>
                            
                    <TouchableOpacity 
                        style={{
                            justifyContent:'center',
                            alignItems:'center',
                            height:40,
                            backgroundColor:'#000',
                            opacity:0.8,
                            borderRadius:10,
                            padding:10,
                            marginTop:30,
                            marginBottom:50,
                            width:'48%',
                        }}
                        onPress={()=>{geraPedido()}}
                    >
                        {load2
                            ? <ActivityIndicator color={'#fff'} size={35}/>                        
                            :<Text style={{fontSize:18,color:'#fff',fontWeight:'bold'}}>Enviar Pedido</Text>
                        }
                    </TouchableOpacity> 
                </View>
                
                { itensErrSld.length !== 0 &&
                    <Text style={{color:'tomato'}}>{'*** '+itensErrSld.mensagem+' ***' + '\n\nProdutos: '}</Text>
                }

                <FlatList
                    data={itensErrSld.produtos}
                    renderItem={({item})=>

                    <Text style={{color:'tomato'}}>{item.codigo}</Text>

                    }

                    onEndReachedThreshold={0.1}
                    keyExtractor={(item, index) => String(index)}
                />

            </ModObs>
        </SafeAreaView>
        </>
    )

    
    function PDFHTML(pedido,params){
        let cItems = ''
        let top = 1.76
        let desconto = 0 
        let total = 0
        let totalD = 0
        let totalDesconto = 0
        let vlrDesconto = 0
        let totAjust = 0

        const data = new Date()

        let dia = data.getDate().toString().padStart(2, '0')
        let mes = (data.getMonth()+1).toString().padStart(2, '0')
        let ano = data.getFullYear().toString()
        

        params.ITEMS.map((item) =>{

            if(typeof item.TOTAL === 'string'){
                totAjust = parseFloat(item.TOTAL.replace(',', '.'))
            } else {
                totAjust = item.TOTAL
            }

            cItems += `<div style="position:absolute;top:${top.toString()}in;left:0.41in;width:0.64in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">${item.PRODUTO}</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
            <div style="position:absolute;top:${top.toString()}in;left:1.85in;width:2.59in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">${(item.DESCRICAO.replace('/ Saldo Disponivel','')).substring(0,40)}</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
            <div style="position:absolute;top:${top.toString()}in;left:4.73in;width:0.20in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">PC</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
            <div style="position:absolute;top:${top.toString()}in;left:5.26in;width:0.26in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
            <div style="position:absolute;top:${top.toString()}in;left:5.94in;width:0.26in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">${item.QUANTIDADE.toString()}</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
            <div style="position:absolute;top:${top.toString()}in;left:6.62in;width:0.26in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
            <div style="position:absolute;top:${top.toString()}in;left:7.23in;width:0.33in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">${item.VALOR}</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
            <div style="position:absolute;top:${top.toString()}in;left:7.83in;width:0.26in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">${desconto.toString()}</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
            <div style="position:absolute;top:${top.toString()}in;left:8.45in;width:0.33in;line-height:0.16in;"><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000">${(totAjust - desconto).toLocaleString('pt-br', {minimumFractionDigits: 2})}</span><span style="font-style:normal;font-weight:normal;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>`

            vlrDesconto = (!!params.DESCONTO) ? (totAjust * (parseInt(params.DESCONTO)/100)) : 0
            desconto = vlrDesconto.toFixed(2)
            top = top + 0.15
            total += (totAjust)
            totalD += (totAjust - desconto)
            totalDesconto += vlrDesconto
        
        })
        
        return`<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
        <html>
           <head>
              <link rel="stylesheet" type="text/css" href="style.css"/>
           </head>
           <body>
              <img style="position:absolute;top:0.12in;left:0.41in;width:4.05in;height:1.14in" src="http://portal.robsol.com.br/PDF/vi_1.png" />
              <img style="position:absolute;top:0.12in;left:0.41in;width:4.05in;height:1.14in" src="http://portal.robsol.com.br/PDF/vi_2.png" />
              <img style="position:absolute;top:0.35in;left:0.41in;width:4.05in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_3.png" />
              <div style="position:absolute;top:0.14in;left:0.48in;width:0.74in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Emitente:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div>
              <img style="position:absolute;top:0.39in;left:0.48in;width:0.82in;height:0.82in" src="http://portal.robsol.com.br/PDF/ri_1.png" />
              <div style="position:absolute;top:0.36in;left:1.39in;width:1.72in;line-height:0.13in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Empresa: </span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">ROB SOL INDUSTRIA LTDA</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:0.47in;left:1.39in;width:1.22in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">CNPJ: </span></SPAN><br/></div>
              <div style="position:absolute;top:0.47in;left:1.39in;width:1.22in;line-height:0.13in;">
                 <DIV style="position:relative; left:0.33in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">23.824.405/0001-40</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
              </div>
              <div style="position:absolute;top:0.57in;left:1.39in;width:0.38in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Cidade:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:0.57in;left:1.85in;width:0.79in;line-height:0.13in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">SAO PAULO / SP</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:0.68in;left:1.39in;width:0.79in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">CEP: </span></SPAN><br/></div>
              <div style="position:absolute;top:0.68in;left:1.39in;width:0.79in;line-height:0.13in;">
                 <DIV style="position:relative; left:0.30in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">03021-060</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
              </div>
              <div style="position:absolute;top:0.79in;left:1.39in;width:1.01in;line-height:0.13in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Telefone: </span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">1150821955</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:1.00in;left:1.39in;width:1.37in;line-height:0.13in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">e-Mail: </span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">pedidos@robsol.com.br</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:1.10in;left:1.39in;width:1.69in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Home Page: </span></SPAN><br/></div>
              <div style="position:absolute;top:1.10in;left:1.39in;width:1.69in;line-height:0.13in;">
                 <DIV style="position:relative; left:0.61in;"><a href="http://www.robsol.com.br"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">http://www.robsol.com.br</span></a>
                    <span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN>
                 </DIV>
              </div>
              <img style="position:absolute;top:0.12in;left:4.55in;width:4.35in;height:1.14in" src="http://portal.robsol.com.br/PDF/vi_4.png" />
              <img style="position:absolute;top:0.12in;left:4.54in;width:4.35in;height:1.14in" src="http://portal.robsol.com.br/PDF/vi_5.png" />
              <img style="position:absolute;top:0.35in;left:4.54in;width:4.35in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_6.png" />
              <div style="position:absolute;top:0.14in;left:4.62in;width:0.61in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Pedido:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div>
              <div style="position:absolute;top:0.21in;left:5.26in;width:3.51in;line-height:0.13in;">
                 <DIV style="position:relative; left:1.97in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">No. ${pedido} - Emissão: ${dia+'/'+mes+'/'+ano.substring(0,4)}</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></DIV>
                 <DIV style="position:relative; left:0.03in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">${params.CLIENTE.codigo+' - '+params.CLIENTE.razao_social }</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
                 <span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">${params.CLIENTE.endereco+' - Bairro: '+params.CLIENTE.bairro }</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN>
              </div>
              <div style="position:absolute;top:0.36in;left:4.62in;width:0.38in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Cliente:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:0.47in;left:4.62in;width:0.49in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Endereço:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:0.57in;left:4.62in;width:2.20in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Cidade: </span></SPAN><br/></div>
              <div style="position:absolute;top:0.57in;left:4.62in;width:2.20in;line-height:0.13in;">
                 <DIV style="position:relative; left:0.39in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">${params.CLIENTE.cidade+' ('+params.CLIENTE.uf+') - CEP: '+params.CLIENTE.cep }</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
              </div>
              <div style="position:absolute;top:0.68in;left:4.62in;width:1.25in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">CNPJ: </span></SPAN><br/></div>
              <div style="position:absolute;top:0.68in;left:4.62in;width:1.25in;line-height:0.13in;">
                 <DIV style="position:relative; left:0.36in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">${params.CLIENTE.cnpj}</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
              </div>
              <div style="position:absolute;top:0.79in;left:4.62in;width:0.45in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Telefone:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:0.79in;left:5.29in;width:1.85in;line-height:0.13in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">${params.CLIENTE.celular.replace(' ','')}   -   Contato:${params.CLIENTE.contato}</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:0.89in;left:4.62in;width:0.36in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Tabela:</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:1.00in;left:4.62in;width:1.76in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Vendedor: </span></SPAN><br/></div>
              <div style="position:absolute;top:1.00in;left:4.62in;width:1.76in;line-height:0.13in;">
                 <DIV style="position:relative; left:0.55in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">${dataUser.cod_vendedor+' '+dataUser.nome_usuario}</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
              </div>
              <div style="position:absolute;top:1.10in;left:4.62in;width:1.30in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">Cond.Pagto.: </span></SPAN><br/></div>
              <div style="position:absolute;top:1.10in;left:4.62in;width:1.30in;line-height:0.13in;">
                 <DIV style="position:relative; left:0.67in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">${payment + ' - ' +dPayment}</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
              </div>
              <img style="position:absolute;top:1.33in;left:0.41in;width:8.48in;height:0.23in" src="http://portal.robsol.com.br/PDF/vi_7.png" />
              <img style="position:absolute;top:1.33in;left:0.41in;width:8.49in;height:0.23in" src="http://portal.robsol.com.br/PDF/vi_8.png" />
              <div style="position:absolute;top:1.36in;left:4.01in;width:1.33in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Pedido de Venda:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div>
              <div style="position:absolute;top:1.64in;left:0.41in;width:1.08in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Cód.Prod. No.Lote</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:1.64in;left:1.85in;width:0.60in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Descrição</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:1.64in;left:4.73in;width:0.79in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Unid. </span></SPAN><br/></div>
              <div style="position:absolute;top:1.64in;left:4.73in;width:0.79in;line-height:0.17in;">
                 <DIV style="position:relative; left:0.37in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Embal.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
              </div>
              <div style="position:absolute;top:1.64in;left:5.79in;width:0.41in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Quant.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:1.64in;left:6.36in;width:0.52in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Qtd Cxs.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:1.64in;left:7.12in;width:0.97in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Unit. </span></SPAN><br/></div>
              <div style="position:absolute;top:1.64in;left:7.12in;width:0.97in;line-height:0.17in;">
                 <DIV style="position:relative; left:0.48in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Desc.</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></DIV>
              </div>
              <div style="position:absolute;top:1.64in;left:8.32in;width:0.46in;line-height:0.17in;"><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000">Vl.Total</span><span style="font-style:normal;font-weight:bold;font-size:8pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              `+cItems+`
              <img style="position:absolute;top:${(top+parseFloat('0.33')).toString()}in;left:0.41in;width:8.48in;height:0.68in" src="http://portal.robsol.com.br/PDF/vi_9.png" />
              <img style="position:absolute;top:${(top+parseFloat('0.33')).toString()}in;left:0.41in;width:8.49in;height:0.68in" src="http://portal.robsol.com.br/PDF/vi_10.png" />
              <img style="position:absolute;top:${(top+parseFloat('0.55')).toString()}in;left:0.41in;width:8.49in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_11.png" />
              <div style="position:absolute;top:${(top+parseFloat('0.34')).toString()}in;left:0.48in;width:0.55in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Totais:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.56')).toString()}in;left:0.48in;width:1.10in;line-height:0.11in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Valor do Frete:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Percentual de Desconto :</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Peso.Líq.:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Peso.Bru:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.56')).toString()}in;left:2.87in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.56')).toString()}in;left:6.09in;width:1.11in;line-height:0.11in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Valor Total dos Produtos:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Valor Desconto:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Total de Itens:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">Valor Total do Pedido:</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.56')).toString()}in;left:8.37in;width:0.32in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">${(total.toFixed(2)).toString()}</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.66')).toString()}in;left:2.87in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.66')).toString()}in;left:8.48in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">${(totalDesconto.toFixed(2)).toString()}</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.77')).toString()}in;left:2.77in;width:0.32in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,0000</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.77')).toString()}in;left:8.48in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">${(params.ITEMS.length).toString()}</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.88')).toString()}in;left:2.77in;width:0.32in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,0000</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('0.88')).toString()}in;left:8.37in;width:0.32in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">${(totalD.toFixed(2)).toString()}</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <img style="position:absolute;top:${(top+parseFloat('1.38')).toString()}in;left:0.41in;width:8.48in;height:0.08in" src="http://portal.robsol.com.br/PDF/vi_12.png" />
              <img style="position:absolute;top:${(top+parseFloat('1.38')).toString()}in;left:0.41in;width:8.49in;height:0.08in" src="http://portal.robsol.com.br/PDF/vi_13.png" />
              <img style="position:absolute;top:${(top+parseFloat('1.60')).toString()}in;left:0.41in;width:8.49in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_14.png" />
              <div style="position:absolute;top:${(top+parseFloat('1.42')).toString()}in;left:0.48in;width:0.87in;line-height:0.22in;"><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce">Duplicatas:</span><span style="font-style:normal;font-weight:bold;font-size:10pt;font-family:Arial;color:#3eb3ce"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('1.64')).toString()}in;left:0.48in;width:0.82in;line-height:0.13in;"><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000">001, no dia   /  /    :</span><span style="font-style:normal;font-weight:normal;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <div style="position:absolute;top:${(top+parseFloat('1.64')).toString()}in;left:2.87in;width:0.21in;line-height:0.14in;"><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000">0,00</span><span style="font-style:normal;font-weight:bold;font-size:6pt;font-family:Arial;color:#000000"> </span><br/></SPAN></div>
              <img style="position:absolute;top:${(top+parseFloat('9.50')).toString()}in;left:0.41in;width:8.49in;height:0.00in" src="http://portal.robsol.com.br/PDF/vi_15.png" />           
              </body>
        </html>`
    }
}

