import React, {useState,useContext} from 'react';
import {Text,View,TouchableOpacity,Image,FlatList,ActivityIndicator,SafeAreaView,StatusBar} from 'react-native';

import styles from './styles';

import ModPreview from '../Modal/modPreview'
import ModSale from '../Modal/modSale'
import ModBack from '../Modal/modBack';


import api from '../services/api';
import axios from "axios";

import { Ionicons } from '@expo/vector-icons';
import _ from 'underscore';
import {CartContext} from '../Contexts/cart'
import { useNavigation } from '@react-navigation/native';
import AsyncStorage from '@react-native-async-storage/async-storage'
import Swipeable from 'react-native-gesture-handler/Swipeable'
import { printToFileAsync } from 'expo-print'
import { shareAsync } from 'expo-sharing'

export default function Sections({nameSec,item,vendedor,prdProd,dataBack,reset,handleOpenCli,handleCloseCli,handleOpenTit,loadPrdSet}){

    const {setCli,dataUser,addCart,totalCart,quantCart,descontoCart,copyPedido} = useContext(CartContext)

    const navigation = useNavigation();

    const authBasic = 'YWRtaW46QVZTSTIwMjI';

    const [visiblePreview, setVisiblePreview] = useState(false);
    const [visibleSale, setVisibleSale] = useState(false);
    const [visibleBack, setVisibleBack] = useState(false);
    
    const [listSearch,setListSearch] = useState([]);
    const [qtdTotal, setQtdTotal] = useState(0)
    const [vlrTotal, setVlrTotal] = useState(0)
    const [qtdTotalFat, setQtdTotalFat] = useState(0)
    const [vlrTotalFat, setVlrTotalFat] = useState(0)
    const [load, setLoad] = useState(false)
    const [loadPDF, setLoadPDF] = useState(false)
    const [loadCopy, setLoadCopy] = useState(false)



    const searchSec = async(option) =>{

        setLoad(true)
        setListSearch([])

        let params = {
            Authorization: 'Basic '+authBasic,
            VENDEDOR: vendedor,
            page: 1,
            pageSize: 1,
        };

        let opt_new = option.split(":");
        
        switch (opt_new[2]) {
            case "cli":
                params.cnpj = opt_new[1];
                handleOpenCli()
                break;
            case "ped":
                params.codigo = opt_new[1];
                setVisibleSale(true)
                break;
            case "copy":
                setLoadCopy(true)
                params.codigo = opt_new[1];
                params.copy = 'S';
                break;
            default:
                break;
        }

        let aResult = [];

        try{
            const response = await api.get(`/${nameSec}/`,{headers: params})
            if(_.has(response.data,"Erro")){
                aResult = [];

                if(opt_new[2] === 'cli'){
                    let responseSefaz = await getClientByCNPJ(opt_new[1]);
                    aResult.push(responseSefaz)
                };

            }else {
                if(response.data.items){
                    response.data["items"].forEach((element, index) => {
                      aResult.push({index: index, ...element});
                    });
                  }else {
                    aResult.push(response.data);
                }
            }
            
        }catch(error){
            console.log(error)
        }

        if(typeof reset === 'function') {reset(aResult[0])};

        if(opt_new[2] == 'ped' || opt_new[2] == 'copy'){
            let qtd = 0;
            let vlr = 0;
            let qtdFat = 0;
            let vlrFat = 0;
            
            aResult.forEach((item) => {
                
                qtd += parseInt(item.quantidade)
                vlr += parseFloat(item.valor_total.trim().replace('.','').replace(',','.'))

                qtdFat += parseInt(item.quant_fatura)
                vlrFat += parseFloat(item.valor_total_fatura.trim().replace('.','').replace(',','.'))
            })

            setQtdTotal(qtd)
            setVlrTotal(vlr)
            setQtdTotalFat(qtdFat)
            setVlrTotalFat(vlrFat)
        };

        if(opt_new[2] == 'copy'){
            copyPedido(aResult)

            if(aResult.length > 0){
                const response = await api.get(`/Customers/`,{
                    withCredentials: true,
                    headers: {
                        'Authorization': 'Basic '+authBasic,
                        'VENDEDOR': dataUser.cod_vendedor,
                        'page': 1,
                        'pageSize': 10
                    } 
                })
        
                addCart([])
                descontoCart('')
                setVisibleBack(false)
                setLoadCopy(false)
        
                navigation.navigate('SaleCli',{
                    nameSec:'Customers',
                    data:response.data["items"],
                    filter:'cnpj',
                    dataBack: dataBack
                })
            }else{
                alert('Não foi possível realizar a cópia')
            }
        }

        setLoad(false)
        setLoadCopy(false)
        setListSearch(aResult)
                
    };


    const removePedLocal = async(data) =>{
        const response = await AsyncStorage.getItem('@OpenOrders')
        const copyResponse = [...JSON.parse(response)]

        var remove = copyResponse.filter((index) => index.id !== data.id);

        await AsyncStorage.setItem('@OpenOrders',JSON.stringify(remove))
        
        navigation.navigate('Home')
        
    };


    const continuaPed = async(item) =>{
        setCli(item.cliItm);

        ()=>loadPrdSet(true)

        const response = await api.get(`/Products/`,{
            withCredentials: true,
            headers: {
                'Authorization': 'Basic '+authBasic,
                'VENDEDOR': dataUser.cod_vendedor,
                'page': 1,
                'pageSize': 10
            } 
        })

        navigation.navigate('SalePrd',{
            nameSec:'Products',
            data:response.data["items"],
            filter:'CODIGO',
            dataBack:dataBack,
            prdProd:true,
            continuaP:true,
            ItensContinua:item
        })

        addCart(item.items)
        totalCart(item.vlrTotal)
        quantCart(item.qtdTotal)
        descontoCart(item.desconto);
        ()=>loadPrdSet(false);
        ()=>handleCloseCli(false);
    };

    const handleDownload = async () => {    
        try{
            const response = await api.post("/PRTL047",{
                GERANOV: 'S',
                PEDIDO: item.codigo,
                VEND: dataUser.cod_vendedor,
                NVEND: dataUser.nome_usuario
            });

            if (response.data.statusrequest[0].code === '#200') {
                setLoadPDF(true)
                geraPdf(response.data.statusrequest[0].message)

            } else {
                console.log(response.data.statusrequest[0].message)
                alert('Erro ao gerar PDF')
            } 
        
        } catch(error){
            console.log(error)
            alert('Erro ao gerar PDF')
        }
        
      };

    const geraPdf = async(html) => {
        const file = await printToFileAsync({
            html:html,
            base64: true
        })

        try{
            const response = await api.post("/PRTL047",{
                CODE64: file.base64, 
                NOME:item.codigo+'_'+item.cnpj+'.pdf', 
                PEDIDO: item.codigo,
                EMAIL: '',
                GERANOV: 'N'
            });

            if (response.data.statusrequest[0].code === '#200') {
                await shareAsync(file.uri)
            } else {
                console.log(response.data.statusrequest[0].message)
                alert('Erro ao gerar PDF')
            } 
        
        } catch(error){
            console.log(error)
        }

        setLoadPDF(false)
    }


    function leftActions(){
        return(
            <View style={{
                flexDirection:'row',
                justifyContent:'center',
                alignItems:'center'
            }}>
                <TouchableOpacity
                    onPress={()=> setVisibleBack(true)}
                    style={{
                        justifyContent:'center',
                        alignItems:'center',
                        margin:10
                    }}
                >
                    <Ionicons name="md-copy" size={24} color="grey" />
                    <Text style={{
                        fontWeight:'bold',
                        fontSize:16,
                        marginTop:6,
                    }}>Copiar</Text>
                </TouchableOpacity>

                <View style={{
                    borderRightWidth:1.5,
                    height:30
                }}></View>

                <TouchableOpacity
                    onPress={()=> handleDownload()}
                    style={{
                        justifyContent:'center',
                        alignItems:'center',
                        margin:10
                    }}
                >   
                    { loadPDF 
                        ?
                        <ActivityIndicator color={'#000000'} size={24}/>
                        :
                        <Ionicons name="document-attach" size={24} color="grey" />
                    }
                    <Text style={{
                        fontWeight:'bold',
                        fontSize:16,
                        marginTop:6,
                    }}>Gerar PDF</Text>
                </TouchableOpacity>
            </View>
        )
    }

    function selectCli(){
        if(item.bloqueado === 'sim'){
            if(prdProd){
                alert('Cliente bloqueado, não é possível prosseguir com o pedido.')
            }

        } else {
            if (prdProd){
                searchSec(`cnpj:${item.cnpj}:cli`)
            }
        }
    }

    return (
        <SafeAreaView style={styles.content}>
            <StatusBar hidden={true}/>
            { nameSec == 'Products' && 
                <TouchableOpacity style={styles.cardP} onLongPress={() => { setVisiblePreview(true) }}>

                    <View style={{flexDirection:'row',justifyContent:'space-between'}}>
                        <Text style={styles.cardTitleP}>{item.codigo.trim()}</Text>

                        <Ionicons
                            name={item.genero.trim()==='Masculino'?"male":"female"} 
                            size={24} 
                            color={item.genero.trim()==='Masculino'?"#2F8BD8":"#ED52DD"}
                        />
                    </View>

                    <Text style={styles.cardDescP}>{item.descricao.trim().substr(0,35)}</Text>

                    <Text style={styles.cardSubTitleP}>{'R$ '+item.preco.trim()}</Text>
                    <Text style={styles.cardSubTitleP}>{'Saldo '+item.saldo.trim()}</Text>
                    <Text style={styles.cardSubTitleP}>{'Linha: '+item.linha.trim()}</Text>
                    <Text style={styles.cardSubTitleP}>{'Marca: '+item.marca.trim()}</Text>
                    <Text style={styles.cardSubTitleP}>{'Material: '+item.material.trim()}</Text>
                </TouchableOpacity>
            }

            { nameSec == 'Customers' &&
                <TouchableOpacity 
                    onPress={()=>selectCli()} 
                    style={styles.cardP}
                    onLongPress={()=>{handleOpenTit(item.codigo.trim())}}
                >
                    <View style={{
                        flexDirection:'row',
                        justifyContent:'space-between',
                        alignItems:'flex-start',
                        width:'100%',
                    }}>
                        
                        <View style={{width:'90%'}}>
                            <Text style={styles.cardDescP}>{item.nome_fantasia.trim()}</Text>
                        </View>

                        { item.bloqueado === 'sim' &&
                            <Ionicons name="lock-closed" size={24} color="tomato" />
                        }
                    </View>
                    
                    <Text style={styles.cardSubTitleP}>{item.razao_social.trim()}</Text>
                    <Text style={[styles.cardSubTitleP,{fontWeight:'bold'}]}>{item.cnpj.trim()}</Text>

                </TouchableOpacity>
            }

            { nameSec == 'Sales' &&

                <View style={{width:'100%'}}>
                    <Swipeable
                        renderLeftActions={leftActions}
                    >
                        <TouchableOpacity 
                            onPress={() => item.status.trim() === 'Editando' ? continuaPed(item) : searchSec(`CODIGO:${item.codigo}:ped`)} 
                            style={[styles.cardP, item.status.trim() === 'Editando'&&{backgroundColor:'#C1D7E5'}]}
                        >

                            <View style={{flexDirection:'row',justifyContent:'space-between'}}>
                                <Text style={styles.cardDescP}>{'Código: '+item.codigo.trim()}</Text>

                                {item.status.trim() === 'Editando' &&
                                    <TouchableOpacity onPress={()=>{removePedLocal(item)}}> 
                                        <Ionicons name="trash-outline" size={30} color="black" />
                                </TouchableOpacity>
                                } 
                            </View>

                            <Text style={styles.cardSubTitleP}>{'Cliente: '+item.cliente.trim()}</Text>
                            <Text style={styles.cardSubTitleP}>{'Emissão: '+item.emissao.trim()}</Text>
                            <Text style={[styles.cardSubTitleP,item.status.trim() === 'Editando'&&{fontWeight:'bold'}]}>{'Status: '+item.status.trim()}</Text>
                            <Text style={styles.cardSubTitleP}>{'CNPJ: '+item.cnpj.trim()}</Text>
                            
                            { (!!item.nota.trim()) ?
                                <Text style={styles.cardSubTitleP}>{'Nota: '+item.nota.trim()+' / Série: '+item.serie.trim()}</Text>
                                :
                                <Text style={styles.cardSubTitleP}>{'Nota: Não possui'}</Text>
                            }

                            <Text style={styles.cardSubTitleP}>{'Razão Social: '+item.razao_social.trim()}</Text>
                            
                            <View style={{marginTop:10}}>
                                <View style={{flexDirection:'row',justifyContent:'space-between'}}>
                                    <Text style={styles.cardSubTitleP}>{'Qtd. Vendida: '+item.quant_vendida}</Text>
                                    <Text style={styles.cardSubTitleP}>{'Vlr. Vendido: R$ '+item.valor_total_vendido}</Text>
                                </View>

                                <View style={{flexDirection:'row',justifyContent:'space-between'}}>
                                    <Text style={styles.cardSubTitleP}>{'Qtd. Faturada: '+item.quant_fatura}</Text>
                                    <Text style={styles.cardSubTitleP}>{'Vlr. Faturado: R$ '+item.valor_total_fatura}</Text>
                                </View>
                            </View>
                            
                            { item.status.trim() === 'Editando' &&
                                <Text style={{fontSize:18,fontWeight:'bold',marginTop:10}}>Clique aqui para continuar o Pedido</Text>
                            }

                        </TouchableOpacity>
                    </Swipeable>
                </View>
            }

            <ModPreview visiblePreview={visiblePreview}>
                <View style={styles.closeModal}>
                    <TouchableOpacity onPress={() => setVisiblePreview(false)}>
                        <Ionicons name="close" size={40} color="black" />
                    </TouchableOpacity>
                </View>

                <View style={{alignItems: 'center'}}>
                    <Image
                        source={{uri: item.imagem}}
                        style={styles.imgPreview}
                    />
                </View>

                <Text style={styles.txtPreview}>Image Preview</Text>
            </ModPreview>

            <ModSale visibleSale={visibleSale}>
                <View style={styles.headerPed}>
                    <Text style={{fontSize:22, fontWeight:'bold'}}>Itens do pedido</Text>
                    <View style={styles.closeModal}>
                        <TouchableOpacity onPress={() => setVisibleSale(false)}>
                            <Ionicons name="close" size={40} color="black" />
                        </TouchableOpacity>
                    </View>
                </View>

                <FlatList
                    data={listSearch.sort((a, b) => a.id.localeCompare(b.id))}
                    renderItem={({item})=> 
                        <View style={styles.contDetPed}>
                            <Text style={styles.txtBold}>{item.codigo.trim()}</Text>
                            <Text>{item.descricao.trim()}</Text>
        
                            <View style={styles.cabecDet}>
                                <Text>Quant.</Text>
                                <Text>Valor Unitario</Text>
                                <Text>Valor total</Text>
                            </View>

                            <View style={styles.itensDet}>
                                <Text style={{left:14}}>{item.quantidade.trim()}</Text>
                                <Text style={{left:8}}>{'R$'+item.valor_unit.trim()}</Text>
                                <Text>{'R$'+item.valor_total.trim()}</Text>
                            </View>

                            <View style={{justifyContent:'space-around',flexDirection:'row',marginTop:12,marginBottom:3}}>
                                <Text>{'Quant. Faturada: '+item.quant_fatura}</Text>
                                <Text>{'Valor Faturado: '+'R$'+item.valor_total_fatura.trim()}</Text>
                            </View>
                        </View>
                    }
                    onEndReached={null}
                    onEndReachedThreshold={0.1}
                    keyExtractor={(item, index) => String(index)}
                    ListEmptyComponent={ load ? 
                        <ActivityIndicator color={'#000000'} size={50}/>
                        :
                        <View style={styles.emptyContainer}>
                            <Text style={styles.emptyText}>Registro não encontrado</Text>
                        </View>
                    }
                />

                <View style={styles.totalPed}>
                    <View>
                        <Text style={styles.txtBold}>{'Quant.: '+qtdTotal}</Text>
                        <Text style={[styles.txtBold,{marginTop:5}]}>{'Qtd. Fatura.: '+qtdTotalFat}</Text>
                    </View>

                    <View>
                        <Text style={styles.txtBold}>{'Total: '+(vlrTotal).toLocaleString('pt-BR',{style: 'currency', currency: 'BRL'})}</Text>
                        <Text style={[styles.txtBold,{marginTop:5}]}>{'Tot. Fatur.: '+(vlrTotalFat).toLocaleString('pt-BR',{style: 'currency', currency: 'BRL'})}</Text>
                    </View>
                </View>
                
            </ModSale>

            <ModBack visibleBack={visibleBack}>
                <View style={{alignItems: 'center', marginBottom:26}}>
                    <View style={{flexDirection:'row',justifyContent:'space-between',width:'100%'}}>
                        <Text style={{ fontSize: 26,color:'#F4C619'}}>Atenção</Text>

                        <TouchableOpacity onPress={() => {setVisibleBack(false)}}>
                            <Ionicons name="close" size={40} color="black" />
                        </TouchableOpacity>
                    </View>
                </View>
                
                <Text style={{ fontSize: 18,color:'#000'}}>Deseja realizar a cópia completa do pedido?</Text>

                <View style={{flexDirection:'row', justifyContent:'flex-end',marginTop:60}}>
                    <TouchableOpacity 
                        style={styles.buttonBack}
                        onPress={() => {setVisibleBack(false)}}
                    >
                        <Text style={{fontWeight:'bold'}}>Não</Text>
                    </TouchableOpacity>

                    <View style={[styles.buttonBack,{backgroundColor:'#175A93',marginLeft:10}]}>
                    { loadCopy 
                        ? 
                        <ActivityIndicator color={'#fff'} size={50}/>
                        :
                        <TouchableOpacity onPress={() => {searchSec(`CODIGO:${item.codigo}:copy`)}}>
                            <Text style={{color:'white', fontWeight:'bold'}}>Sim</Text>
                        </TouchableOpacity>
                    }
                    </View>
                </View>
            </ModBack>

        </SafeAreaView>
        
    )
}


export async function getClientByCNPJ(cnpj) {
    const result = await axios.get(`https://brasilapi.com.br/api/cnpj/v1/${cnpj}`);

    let jsonClient = {
        cnpj: result.data.cnpj,
        insc_estadual: "N/A",
        codigo: result.data.cnpj,
        filial: "N/A",
        razao_social: result.data.razao_social,
        nome_fantasia: result.data.nome_fantasia,
        endereco: result.data.logradouro,
        bairro: result.data.bairro,
        cidade: result.data.municipio,
        uf: result.data.uf,
        cep: result.data.cep,
        contato: "",
        email: "",
        celular: "",
        fone2: "",
        id: result.data.cnpj
    }

    if(!!result.data.numero){
        jsonClient.endereco = jsonClient.endereco +', '+result.data.numero
    }

    if(!!result.data.complemento){
        jsonClient.endereco = jsonClient.endereco +' - '+result.data.complemento
    }

    return jsonClient;
}
