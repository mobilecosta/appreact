import React,{useState,useContext,useRef} from 'react';
import {
    SafeAreaView,
    View,
    Text,
    Image,
    TouchableOpacity,
    TextInput,
    FlatList,
    Keyboard,
    ActivityIndicator,
    ScrollView,
    KeyboardAvoidingView,
    Platform,
} from 'react-native';

import { RadioButton } from 'react-native-paper';

import _ from 'underscore';

import styles from './styles';

import {decode, encode} from 'base-64';
import typeIcons from '../../utils/typeIcons';
import { Ionicons } from '@expo/vector-icons';

import api from '../../services/api'
import axios from "axios";

import ModFilter from '../../Modal/modFilter';

import { useForm, Controller, set } from 'react-hook-form';
import {yupResolver} from '@hookform/resolvers/yup';
import * as yup from 'yup';

import Section from '../../Sections/index';

import {CartContext} from '../../Contexts/cart';

import {Modalize} from 'react-native-modalize'

import * as WebBrowser from 'expo-web-browser';

if (!global.btoa) { global.btoa = encode }
if (!global.atob) { global.atob = decode }


export async function getClientByCNPJ(cnpj) {
    const result = await axios.get(`https://brasilapi.com.br/api/cnpj/v1/${cnpj}`);
    return result.data;
}

export default function SaleCli({route,navigation}){

    const {setCli,dataUser,copyPedido} = useContext(CartContext)

    const { nameSec,data,filter,dataBack } = route.params;

    const [searchText, setSearchText] = useState('');
    const [searchT,setSearchT] = useState(false);
    const [listSearch,setListSearch] = useState([]);
    const [list, setList] = useState(data);
    const [page, setPage] = useState(1);
    const [visibleFilter, setVisibleFilter] = useState(false);
    const [loadPrd, setLoadPrd] = useState(false)
    const [checked, setChecked] = useState(filter);
    const [load, setLoad] = useState(false);
    const [listTit, setListTit] = useState([]);
    const [cliTit, setCliTit] = useState('');

    const authBasic = 'YWRtaW46QVZTSTIwMjI';

    const modalizeRefCli = useRef(null);
    const modalizeRefEnt = useRef(null);
    const modalizeRefTit = useRef(null);


    function buttomSearch(option){
        if(searchT){ loadSec() } else { searchSec(option) }

        Keyboard.dismiss()
    };

    const loadSec = async() =>{
        if (searchT){
            setList(data)
            setSearchT(false)
            setSearchText('')
        }
        
        const response = await api.get(`/${nameSec}/`,{
            withCredentials: true,
            headers: {
                'Authorization': 'Basic '+authBasic,
                'VENDEDOR': dataUser.cod_vendedor,
                'page': page,
                'pageSize': 10
            } 
        })
        
        const aResult = getNewList(list,response.data["items"])

        setList(aResult)
        setPage(page+1)
    };


    function getNewList(current, data) {
        const newList = {}
        
        const listAux = [...current, ...data]

        listAux.forEach(item => {newList[item.id] = item})

        return Object.values(newList)
    }
    
    const searchSec = async(option) =>{
        if (searchText==='') return;

        setListSearch([])
        setList(data)

        let params = {
            'Authorization': 'Basic '+authBasic,
            'VENDEDOR': dataUser.cod_vendedor,
            'ORIGEMAPP': "S",
            'page': 1,
            'pageSize': 2000,
        };

        let opt_new = option.split(":");
        
        switch (opt_new[0]) {
            case "nome_fantasia":
                params.nome_fantasia = opt_new[1];
                break;
            case "razao_social":
                params.razao_social = opt_new[1];
                break;
            case "cnpj":
                params.cnpj = opt_new[1];
                break;
            case "cidade":
                params.cidade = opt_new[1];
                break;
            default:
                break;
        }

        let aResult = [];

        try{
            setLoad(true)
            const response = await api.get(`/${nameSec}/?pagesize=50`,{headers: params})

            if(_.has(response.data,"Erro")){
                aResult = [];
                
                if(opt_new[0] === 'cnpj'){
                    let responseSefaz = await getClientByCNPJ(opt_new[1]);

                    aResult.push({index: 1, ...responseSefaz});
                }

            }else{
                if(response.data.items){
                    response.data["items"].forEach((element, index) => {
                      aResult.push({index: index, ...element});
                    });
                  }else{
                    aResult.push(response.data);
                }
            }
            
        }catch(error){
            alert('Cliente não localizado na Sefaz')
        }

        setListSearch(aResult)
        setSearchT(true)
        setLoad(false)
    };

    const {control,handleSubmit,formState:{errors},reset,resetField,getValues,setValue} = useForm({ 
        resolver: yupResolver(
            yup.object({
                // contato: yup.string().required("Informe o Contato..."),
                // razao_social: yup.string().required("Informe a Razão Social..."),
                // nome_fantasia: yup.string().required("Informe o Nome Fantasia..."),
                // email: yup.string().required("Informe o Email..."),
                // celular: yup.string().required("Informe o Telefone..."),
                // fone2: yup.string().required("Informe o Telefone..."),
                // cep: yup.string().required("Informe o CEP..."),
                // endereco: yup.string().required("Informe o Endereço..."),
                // complemento: yup.string(),
                // bairro: yup.string().required("Informe o Bairro..."),
                // cidade: yup.string().required("Informe a Cidade..."),
                // uf: yup.string().required("Informe a UF..."),
                // cep1: yup.string()
            })
        )
    });

    function validateFields(obj) {

        const exclude = ["bloqueado", 
                         "cnpj", 
                         "codigo", 
                         "complemento", 
                         "filial", 
                         "fone2", 
                         "id", 
                         "insc_estadual", 
                         "limite_credito", 
                         "maior_atraso", 
                         "maior_compra", 
                         "primeira_compra", 
                         "qtd_atrasos", 
                         "qtd_compras", 
                         "qtd_pagto_atraso", 
                         "risco", 
                         "saldo", 
                         "saldo_dupl_aberto", 
                         "ultima_compra"]

        for (let chave in obj) {
            if (exclude.includes(chave)) {
                continue; // Ignora a chave e continua para a próxima iteração
            }
      
            if (obj[chave].trim() === "") {
                alert("O campo " + chave + " está vazio, corrija para prosseguir.");
                return true;
            }
            }
            return false;
        }

    const handleSignIn = async(dataCad) =>{

        if(!validateEmail(dataCad.email)){
            alert('Formato de e-mail inválido, corrija para prosseguir.')
            return
        }

        if (validateFields(dataCad)) {
            return
        }

        setCli(dataCad)
        setLoadPrd(true)

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
            dataBack: [nameSec,list,dataUser,filter],
            prdProd:true
        })

        setLoadPrd(false)
        handleCloseCli(false)
    };


    function validateEmail(email) {
        var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(String(email).toLowerCase());
      }
      

    const handleOpenCli = ()=>{modalizeRefCli.current?.open()};
    const handleCloseCli = ()=>{modalizeRefCli.current?.close()};

    const handleOpenTit = async(codigo)=>{

        const response = await api.get('/Financial',{
            withCredentials: true,
            headers: {
                'Authorization': 'Basic '+authBasic,
                'VENDEDOR': dataUser.cod_vendedor,
                'codigo': codigo
            } 
        })


        const aResult = [...response.data["items"]]

        if (aResult.length !== 0){
            setCliTit(aResult[0].cliente)
        }else {
            setCliTit('Nenhum titulo localizado')
        }

        setListTit(aResult)
        modalizeRefTit.current?.open()
    };

    const handleCloseTit = ()=>{
        modalizeRefTit.current?.close()
    };

    const handleOpenEnt = ()=>{
        modalizeRefEnt.current?.open()
        modalizeRefCli.current?.close()
    };
    
    const handleCloseEnt = ()=>{
        modalizeRefEnt.current?.close()
        modalizeRefCli.current?.open()
    };

    function setReset(receive){reset(receive)}

    function limparEnt(){
        resetField('cep1');
        resetField('endereco1');
        resetField('bairro1');
        resetField('cidade1');
        resetField('uf1');        
        handleCloseEnt();
    };

    const getCep = async(cep) =>{
        if (!!cep){
            try{
                const result = await axios.get(`https:/viacep.com.br/ws/${cep}/json/`);
                
                if(result.status === 200){
                    setValue('endereco1',result["data"].logradouro)
                    setValue('bairro1',result["data"].bairro)
                    setValue('cidade1',result["data"].localidade)
                    setValue('uf1',result["data"].uf)
                }

            }catch(err){}
        }
    
    };

    function loadPrdSet(receive){setLoadPrd(receive)};

    const handleDownload = async (doc) => {
        await WebBrowser.openBrowserAsync(doc);
      };

    return( 
        <>
        <SafeAreaView edges={["top"]} style={{ flex: 0, backgroundColor: "#175A93" }}/>
        <SafeAreaView
            edges={["left", "right", "bottom"]}
            style={{flex: 1, backgroundColor: "#fff",position: "relative",}}
        >
            <View style={styles.container}>
                <View style={styles.headerSales}>  
                    <TouchableOpacity onPress={()=>{copyPedido([]),navigation.navigate('Detail',{
                        nameSec:dataBack[0],
                        data:dataBack[1],
                        filter:dataBack[3],
                        dataBack: dataBack[4]
                    })}}>
                        <Ionicons style={{bottom:5,right:7}} name="arrow-back" size={40} color="white" />
                    </TouchableOpacity>

                    <Text style={{fontSize:24,fontWeight:'bold', color:'#fff'}}>Selecione o Cliente</Text>
                </View> 

                <View style={styles.containerInput}>
                    <TextInput
                        style={styles.input}
                        placeholder="Pesquisar..."
                        placeholderTextColor="#888"
                        value={searchText}
                        onChangeText={(t) => setSearchText(t)}
                    />

                    {load ? 
                        <View style={{flex:1,flexDirection:'row',top:5,right:30}}>
                            <ActivityIndicator color={'#000000'} size={30}/>
                        </View>
                        :
                        <TouchableOpacity style={{right:30}} onPress={()=>{buttomSearch(`${checked}:${searchText}`)}}>
                            <Ionicons name={searchT?"close":"search"} size={32} color='#175A93' />
                        </TouchableOpacity>
                    }

                    <TouchableOpacity onPress={() => { setVisibleFilter(true) }}>
                        <Image 
                            style={{resizeMode:'contain', width:30}}
                            source={checked==''?typeIcons[4]:typeIcons[5]}
                        />
                    </TouchableOpacity>
                </View>

                <FlatList
                    data={searchT 
                        ? listSearch
                        : list.sort((a, b) => b.id.localeCompare(a.id))
                    }
                    renderItem={({item})=> 
                        <Section
                            item={item}
                            nameSec={nameSec}
                            vendedor={dataUser.cod_vendedor}
                            prdProd={true}
                            dataBack={[nameSec,list,dataUser,filter]}
                            reset={setReset}
                            handleOpenCli={handleOpenCli}
                            handleCloseCli={handleCloseCli}
                            handleOpenTit={handleOpenTit}
                            loadPrdSet={loadPrdSet}
                        />
                    }

                    onEndReached={!searchT&&loadSec}
                    onEndReachedThreshold={0.1}
                    keyExtractor={(item) => item.id}
                    ListEmptyComponent={
                        <View style={styles.emptyContainer}>
                            <Text style={styles.emptyText}>Registro não encontrado</Text>
                        </View>
                    }
                />
                
            </View>


            <ModFilter visibleFilter={visibleFilter}>
                <View style={{alignItems: 'center'}}>
                    <View style={{flexDirection:'row',justifyContent:'space-between',width:'100%'}}>
                        <Text style={{ fontSize: 30,color:'#2F8BD8'}}>Filtro</Text>

                        <TouchableOpacity onPress={() => setVisibleFilter(false)}>
                            <Ionicons name="close" size={40} color="black" />
                        </TouchableOpacity>
                    </View>
                </View>
                
                <View style={{marginVertical:20}}>
                    <View style={{flexDirection:'row',alignItems:'center'}}>
                        <RadioButton
                            value="razao_social"
                            status={ checked === 'razao_social' ? 'checked' : 'unchecked' }
                            onPress={() => {setChecked('razao_social');setVisibleFilter(false)}}
                        />
                        <Text>Razão Social</Text>
                    </View>

                    <View style={{flexDirection:'row',alignItems:'center'}}>
                        <RadioButton
                            value="nome_fantasia"
                            status={ checked === 'nome_fantasia' ? 'checked' : 'unchecked' }
                            onPress={() => {setChecked('nome_fantasia');setVisibleFilter(false)}}
                        />
                        <Text>Nome Fantasia</Text>
                    </View>

                    <View style={{flexDirection:'row',alignItems:'center'}}>
                        <RadioButton
                            value="cidade"
                            status={ checked === 'cidade' ? 'checked' : 'unchecked' }
                            onPress={() => {setChecked('cidade');setVisibleFilter(false)}}
                        />
                        <Text>Cidade</Text>
                    </View>

                    <View style={{flexDirection:'row',alignItems:'center'}}>
                        <RadioButton
                            value="cnpj"
                            status={ checked === 'cnpj' ? 'checked' : 'unchecked' }
                            onPress={() => {setChecked('cnpj');setVisibleFilter(false)}}
                        />
                        <Text>CNPJ</Text>
                    </View>
                </View>
            </ModFilter>

            <Modalize
                adjustToContentHeight={600}
                ref={modalizeRefCli}
                snapPoint={600}
                withHandle={false}
            >
                <View style={{height:600,margin:20}}>
                    
                    <View style={styles.headerPed}>
                        <Text style={{fontSize:22, fontWeight:'bold'}}>Atualizar Cadastro</Text>

                        <View style={styles.closeModal}>
                            <TouchableOpacity onPress={handleCloseCli}>
                                <Ionicons style={{bottom:7}} name="close" size={40} color="black" />
                            </TouchableOpacity>
                        </View>
                    </View>


                    <KeyboardAvoidingView style={{marginBottom:70}}
                        behavior={Platform.OS == 'IOS' ? 'padding' : 'height'}
                        keyboardVerticalOffset={200}
                    >
                        <ScrollView >
                            <Controller
                                control={control}
                                name='cnpj'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>CNPJ *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.cnpj ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8',color:'#B2ADAD'}]}
                                            placeholder={errors.cnpj && errors.cnpj?.message}
                                            placeholderTextColor='#FA7E7E'
                                            editable={false}
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='insc_estadual'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Inscrição Estadual *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.insc_estadual ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8',color:'#B2ADAD'}]}
                                            placeholder={errors.insc_estadual && errors.insc_estadual?.message}
                                            placeholderTextColor='#FA7E7E'
                                            editable={false}
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='filial'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Filial *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.filial ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8',color:'#B2ADAD'}]}
                                            placeholder={errors.filial && errors.filial?.message}
                                            placeholderTextColor='#FA7E7E'
                                            editable={false}
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='contato'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Contato *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.contato ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.contato && errors.contato?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='razao_social'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Razão Social *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.razao_social ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.razao_social && errors.razao_social?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='nome_fantasia'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Nome Fantasia *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.nome_fantasia ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.nome_fantasia && errors.nome_fantasia?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='email'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>E-mail *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.email ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.email && errors.email?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />
                            
                            <Controller
                                control={control}
                                name='celular'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Telefone Contato 1 *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.celular ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.celular && errors.celular?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='fone2'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Telefone Contato 2</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.fone2 ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.fone2 && errors.fone2?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='cep'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>CEP *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.cep ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.cep && errors.cep?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='endereco'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Endereço *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.endereco ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.endereco && errors.endereco?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='complemento'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Complemento</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.complemento ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.complemento && errors.complemento?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />
                            
                            <Controller
                                control={control}
                                name='bairro'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Bairro *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.bairro ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.bairro && errors.bairro?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='cidade'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Cidade *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.cidade ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.cidade && errors.cidade?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='uf'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>UF *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.uf ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.uf && errors.uf?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <TouchableOpacity style={styles.submitAtualizar} onPress={handleSubmit(handleSignIn)}>
                                { loadPrd ?
                                    <View style={{flex:1,justifyContent:'center'}}>
                                        <ActivityIndicator color={'#fff'} size={35}/>
                                    </View>
                                    :
                                    <Text style={styles.submitTxtAtualizar}>Atualizar</Text>
                                }
                            </TouchableOpacity>

                            <TouchableOpacity 
                                style={{marginTop:35,justifyContent:'center',alignItems:'center'}}
                                onPress={handleOpenEnt}
                            >
                                <Text style={{color:'tomato', fontSize:18}}>Outro endereço de entrega</Text>
                            </TouchableOpacity>

                        </ScrollView>
                    </KeyboardAvoidingView>

                </View>
            </Modalize>

            <Modalize
                adjustToContentHeight={600}
                ref={modalizeRefEnt}
                snapPoint={600}
                withHandle={false}
            >
                <View style={{height:600,margin:20}}>
                    
                    <View style={styles.headerPed}>
                        <Text style={{fontSize:22,marginBottom:30,fontWeight:'bold'}}>Outro Endereço</Text>
                    </View>


                    <KeyboardAvoidingView style={{marginBottom:70}}
                        behavior={Platform.OS == 'IOS' ? 'padding' : 'height'}
                        keyboardVerticalOffset={200}
                    >
                        <ScrollView >

                            <View style={{flexDirection:'row',width:'100%',justifyContent:'space-between'}}>
                                
                                <View style={{width:'90%',justifyContent:'center'}}>
                                    <Controller
                                        control={control}
                                        name='cep1'
                                        render={({field: {onChange,onBlur,value}})=>(
                                            <View>
                                                <Text style={{color:'#AAADAE',fontWeight:'bold'}}>CEP *</Text>
                                                <TextInput
                                                    onChangeText={onChange}
                                                    value={value}
                                                    onBlur={onBlur}
                                                    style={[styles.inputForm, errors.cep1 ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'},{width:'100%'}]}
                                                    placeholder={errors.cep1 && errors.cep1?.message}
                                                    placeholderTextColor='#FA7E7E'
                                                />
                                            </View>
                                        )}
                                    />
                                </View>
                                
                                <TouchableOpacity style={{justifyContent:'center'}} onPress={()=>getCep(getValues('cep1'))}>
                                    <Ionicons name={searchT?"close":"search"} size={32} color='#175A93' />
                                </TouchableOpacity>
                            </View>

                            <Controller
                                control={control}
                                name='endereco1'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Endereço *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.endereco1 ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.endereco1 && errors.endereco1?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />
                            
                            <Controller
                                control={control}
                                name='bairro1'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Bairro *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.bairro1 ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.bairro1 && errors.bairro1?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='cidade1'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>Cidade *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.cidade1 ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.cidade1 && errors.cidade1?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <Controller
                                control={control}
                                name='uf1'
                                render={({field: {onChange,onBlur,value}})=>(
                                    <View>
                                        <Text style={{color:'#AAADAE',fontWeight:'bold'}}>UF *</Text>
                                        <TextInput
                                            onChangeText={onChange}
                                            value={value}
                                            onBlur={onBlur}
                                            style={[styles.inputForm, errors.uf1 ? { borderColor:'#D13434' } : { borderColor:'#2F8BD8'}]}
                                            placeholder={errors.uf1 && errors.uf1?.message}
                                            placeholderTextColor='#FA7E7E'
                                        />
                                    </View>
                                )}
                            />

                            <View style={{flexDirection:'row',justifyContent:'space-around',marginTop:50}}>
                                <TouchableOpacity 
                                    style={[styles.buttonEnt,{backgroundColor:'tomato'}]}
                                    onPress={handleSubmit(limparEnt)}
                                >
                                    <Text style={styles.submitTxtAtualizar}>Limpar</Text>
                                </TouchableOpacity>

                                <TouchableOpacity 
                                    style={[styles.buttonEnt,{backgroundColor:'black'}]}
                                    onPress={handleSubmit(handleCloseEnt)}
                                >
                                    <Text style={styles.submitTxtAtualizar}>Confirmar</Text>
                                </TouchableOpacity>
                            </View>


                        </ScrollView>
                    </KeyboardAvoidingView>

                </View>
            </Modalize>

            <Modalize
                adjustToContentHeight={600}
                ref={modalizeRefTit}
                snapPoint={600}
                withHandle={false}
            >
                <View style={{height:600,margin:15}}>
                    
                    <View style={styles.headerPed}>
                        <Text style={{fontSize:22, fontWeight:'bold'}}>Titulos Cliente</Text>

                        <View style={styles.closeModal}>
                            <TouchableOpacity onPress={handleCloseTit}>
                                <Ionicons style={{bottom:7}} name="close" size={40} color="black" />
                            </TouchableOpacity>
                        </View>
                    </View>

                    <Text style={{fontWeight:'bold',fontSize:16,color:"#175A93",marginBottom:20}}>{cliTit}</Text>


                    <ScrollView style={{marginBottom:30}}>

                    { listTit.sort((a, b) => b.id.localeCompare(a.id)).map((item) => (
                        
                        <View
                            key={item.id}
                            style={{
                                borderWidth:1,
                                marginVertical:5,
                                borderRadius:10,
                                paddingVertical:10,
                                borderColor:"#175A93" 
                            }}
                        >   
                            <View style={{
                                flexDirection:'row',
                                justifyContent:'space-between',
                                marginHorizontal:5,
                                marginBottom:20
                                }}
                            >
                                <Text style={{color:'#175A93',fontWeight:'bold'}}>{item.titulo}</Text>
                                <Text style={{fontWeight:'bold'}}>{'Vencto: '+item.vencimento}</Text>
                            </View>

                            <View style={{flexDirection:'row',justifyContent:'space-between'}}>
                                <View style={{marginHorizontal:5,alignItems:'center'}}>
                                    <Text style={{fontWeight:'bold'}}>Prefixo</Text>
                                    <Text>{item.prefixo}</Text>
                                </View>

                                <View style={{marginHorizontal:5,alignItems:'center'}}>
                                    <Text style={{fontWeight:'bold'}}>Parcela</Text>
                                    <Text>{item.parcela}</Text>
                                </View>

                                <View style={{marginHorizontal:5,alignItems:'center'}}>
                                    <Text style={{fontWeight:'bold'}}>Emissão</Text>
                                    <Text>{item.emissao}</Text>
                                </View>                  

                                <View style={{marginHorizontal:5,alignItems:'center'}}>
                                    <Text style={{fontWeight:'bold'}}>Status</Text>
                                    <Text style={item.status==="Pago" ? {color:'green'} : item.status==="Em Aberto" ?{color:'#F4C619'} : {color:'tomato'}}>
                                        {item.status}
                                    </Text>
                                </View>
                                
                                <View style={{marginHorizontal:7,alignItems:'center'}}>
                                    <Text style={{fontWeight:'bold'}}>Valor</Text>
                                    <Text>{item.valor.trim()}</Text>
                                </View>
                            </View>
                            
                            <View style={{flexDirection:'row',justifyContent:'flex-end',marginTop:22}}>
                                <TouchableOpacity 
                                    style={styles.buttonDownload}
                                    onPress={()=>{handleDownload(item.boleto)}}
                                >
                                    <Text style={{fontWeight:'bold',color:'white'}}>Boleto</Text>
                                </TouchableOpacity>

                                <TouchableOpacity 
                                    style={styles.buttonDownload}
                                    onPress={()=>{handleDownload(item.danfe)}}
                                >
                                    <Text style={{fontWeight:'bold',color:'white'}}>Danfe</Text>
                                </TouchableOpacity>
                            </View>

                        </View>
                    ))

                    }

                    </ScrollView>
                </View>
            </Modalize>

        </SafeAreaView>
        </>
    )
}