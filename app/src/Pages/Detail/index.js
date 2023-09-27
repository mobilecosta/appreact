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
    ScrollView
} from 'react-native';
import { RadioButton } from 'react-native-paper';

import _ from 'underscore';

import styles from './styles';

import {decode, encode} from 'base-64';
import typeIcons from '../../utils/typeIcons';
import { Ionicons } from '@expo/vector-icons';
import api from '../../services/api'

import ModFilter from '../../Modal/modFilter';
import {Modalize} from 'react-native-modalize'

import Section from '../../Sections/index';

import {CartContext} from '../../Contexts/cart'

if (!global.btoa) { global.btoa = encode }
if (!global.atob) { global.atob = decode }


export default function Detail({route,navigation}){

    const { addCart,dataUser,descontoCart } = useContext(CartContext)

    const { nameSec,data,filter,icon,prdProd } = route.params;

    const [searchText, setSearchText] = useState('');
    const [searchT,setSearchT] = useState(false);
    const [listSearch,setListSearch] = useState([]);
    const [list, setList] = useState(data);
    const [page, setPage] = useState(1);
    const [footerEnable,setFooterEnable] = useState(true)
    const [visibleFilter, setVisibleFilter] = useState(false);
    const [checked, setChecked] = useState(filter);
    const [load, setLoad] = useState(false);
    const [listTit, setListTit] = useState([]);
    const [cliTit, setCliTit] = useState('');

    const authBasic = 'YWRtaW46QVZTSTIwMjI';
    const modalizeRefTit = useRef(null);

    function buttomSearch(option){
        if(searchT){ loadSec() } else { searchSec(option) }

        Keyboard.dismiss()
        setFooterEnable(true)
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
            case "CODIGO":
                params.codigo = opt_new[1];
                break;
            case "DESCRICAO":
                params.descricao = opt_new[1];
                break;
            case "LINHA":
                params.linha = opt_new[1];
                break;
            case "MARCA":
                params.marca = opt_new[1];
                break;
            case "MATERIAL":
                params.material = opt_new[1];
                break;
            case "GENERO":
                params.genero = opt_new[1];
                break;
            case "RAZAO":
                params.razao = opt_new[1];
                break;
            default:
                break;
        }

        if(nameSec === 'Sales'){params.filtro = 'S'}

        let aResult = [];

        try{
            setLoad(true)
            const response = await api.get(`/${nameSec}/`,{headers: params})
            if(_.has(response.data,"Erro")){
                aResult = [];
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
            console.log(error)
        }
        
        setListSearch(aResult)
        setSearchT(true)
        setLoad(false)
    };


    const apiSale = async() =>{

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

        navigation.navigate('SaleCli',{
            nameSec:'Customers',
            data:response.data["items"],
            filter:'cnpj',
            dataBack: [nameSec,data,dataUser,filter,icon]
        })
    };


    function getNewList(current, data) {
        const newList = {}
        
        const listAux = [...current, ...data]

        listAux.forEach(item => {newList[item.id] = item})

        return Object.values(newList)
    }


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

    return( 

        <SafeAreaView style={styles.contSafe}>
            <View style={[styles.container,footerEnable && { marginBottom:100,} ]}>
                <View style={styles.containerInput}>
                    <TextInput
                        style={styles.input}
                        placeholder="Pesquisar..."
                        placeholderTextColor="#888"
                        value={searchText}
                        onFocus={()=>{setFooterEnable(false)}}
                        onSubmitEditing={()=>{setFooterEnable(true)}}
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

                    <TouchableOpacity onPress={() =>  setVisibleFilter(true) }> 
                        <Image 
                            style={{resizeMode:'contain', width:30}}
                            source={checked==''?typeIcons[4]:typeIcons[5]}
                        />
                    </TouchableOpacity>
                </View>

                <FlatList
                    data={searchT 
                        ? listSearch
                        : nameSec=='Sales' 
                            ? list.sort((a, b) => b.dtemisped.localeCompare(a.dtemisped))
                            : list.sort((a, b) => b.id.localeCompare(a.id))
                    }
                    renderItem={({item})=> 
                        <Section
                            item={item}
                            nameSec={nameSec}
                            vendedor={dataUser.cod_vendedor}
                            prdProd={prdProd}
                            dataBack={[nameSec,data,filter,icon,prdProd]}
                            handleOpenTit={handleOpenTit}
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

            { footerEnable ? 
                <View style={styles.footerContent}>
                    <TouchableOpacity style={styles.imageContent} onPress={()=>{navigation.navigate('Home')}}>
                        <Ionicons name="home" size={35} color="white" />
                        <Text style={styles.titleButtom}>Home</Text>
                    </TouchableOpacity>

                    { icon != null ?
                        <TouchableOpacity onPress={()=>{apiSale()}} style={styles.imageConfirm}>
                            <Image source={icon =='add' ? typeIcons[1] : typeIcons[2]}/>
                        </TouchableOpacity>
                        : 
                        <></>
                    }
                    <TouchableOpacity style={styles.imageContent} onPress={()=>{navigation.navigate('Profile')}}>
                        <Ionicons style={{marginBottom:3}} name="person" size={35} color="white" />
                        <Text style={styles.titleButtom}>Perfil</Text>
                    </TouchableOpacity>
                </View>

            : <></> 
            }

            <ModFilter visibleFilter={visibleFilter}>
                <View style={{alignItems: 'center'}}>
                    <View style={{flexDirection:'row',justifyContent:'space-between',width:'100%'}}>
                        <Text style={{ fontSize: 30,color:'#2F8BD8'}}>Filtro</Text>

                        <TouchableOpacity onPress={() => setVisibleFilter(false)}>
                            <Ionicons name="close" size={40} color="black" />
                        </TouchableOpacity>
                    </View>
                </View>
                
                { nameSec == 'Customers' &&
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
                }

                { nameSec == 'Products' &&
                    <View style={{flexDirection:'row',justifyContent:'space-between',marginHorizontal:7}}>
                        <View style={{marginVertical:20}}>
                            <View style={{flexDirection:'row',alignItems:'center'}}>
                                <RadioButton
                                    value="CODIGO"
                                    status={ checked === 'CODIGO' ? 'checked' : 'unchecked' }
                                    onPress={() => {setChecked('CODIGO');setVisibleFilter(false)}}
                                />
                                <Text>Código</Text>
                            </View>
                            <View style={{flexDirection:'row',alignItems:'center'}}>
                                <RadioButton
                                    value="DESCRICAO"
                                    status={ checked === 'DESCRICAO' ? 'checked' : 'unchecked' }
                                    onPress={() => {setChecked('DESCRICAO');setVisibleFilter(false)}}
                                />
                                <Text>Descrição</Text>
                            </View>
                            <View style={{flexDirection:'row',alignItems:'center'}}>
                                <RadioButton
                                    value="LINHA"
                                    color='#000'
                                    status={ checked === 'LINHA' ? 'checked' : 'unchecked' }
                                    onPress={() => {setChecked('LINHA');setVisibleFilter(false)}}
                                />
                                <Text>Linha</Text>
                            </View>
                        </View>

                        <View style={{marginVertical:20}}>
                            <View style={{flexDirection:'row',alignItems:'center'}}>
                                <RadioButton
                                    value="MARCA"
                                    status={ checked === 'MARCA' ? 'checked' : 'unchecked' }
                                    onPress={() => {setChecked('MARCA');setVisibleFilter(false)}}
                                />
                                <Text>Marca</Text>
                            </View>
                            <View style={{flexDirection:'row',alignItems:'center'}}>
                                <RadioButton
                                    value="MATERIAL"
                                    status={ checked === 'MATERIAL' ? 'checked' : 'unchecked' }
                                    onPress={() => {setChecked('MATERIAL');setVisibleFilter(false)}}
                                />
                                <Text>Material</Text>
                            </View>
                            <View style={{flexDirection:'row',alignItems:'center'}}>
                                <RadioButton
                                    value="GENERO"
                                    status={ checked === 'GENERO' ? 'checked' : 'unchecked' }
                                    onPress={() => {setChecked('GENERO');setVisibleFilter(false)}}
                                />
                                <Text>Gênero</Text>
                            </View>
                        </View>
                    </View>
                }

                { nameSec == 'Sales' &&
                    <View style={{marginVertical:20}}>
                        <View style={{flexDirection:'row',alignItems:'center'}}>
                            <RadioButton
                                value="CODIGO"
                                status={ checked === 'CODIGO' ? 'checked' : 'unchecked' }
                                onPress={() => {setChecked('CODIGO');setVisibleFilter(false)}}
                            />
                            <Text>Codigo</Text>
                        </View>

                        <View style={{flexDirection:'row',alignItems:'center'}}>
                            <RadioButton
                                value="RAZAO"
                                status={ checked === 'RAZAO' ? 'checked' : 'unchecked' }
                                onPress={() => {setChecked('RAZAO');setVisibleFilter(false)}}
                            />
                            <Text>Razão Social</Text>
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
                }
            </ModFilter>


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
        
    )
}

