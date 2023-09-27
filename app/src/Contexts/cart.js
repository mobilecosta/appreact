import React, { createContext, useState} from 'react'

export const CartContext = createContext({})

function CartProvider({children}){

    const [cart, setCart] = useState([]);

    const [desconto, setDesconto] = useState('');
    const [vlrTotalCart, setVlrTotalCart] = useState(0);
    const [qtdTotalCart, setQtdTotalCart] = useState(0);

    const [dataUser,setDataUser] = useState();
    const [cliente, setCliente] = useState([]);
    const [copy, setCopy] = useState([])

    const [imageProfile, setImageProfile] = useState(null);

    function addCart(cartReceive){
        setCart(cartReceive)
    };


    function totalCart(receive){
        setVlrTotalCart(receive)
    };

    function quantCart(receive){
        setQtdTotalCart(receive)
    };

    function descontoCart(receive){
        setDesconto(receive)
    };


    function setCli(receive){
        setCliente(receive)
    };

    function setUserData(receive){
        setDataUser(receive)
    };

    function addImageProfile(receive){
        setImageProfile(receive)
    };

    function copyPedido(receive){
        setCopy(receive)
    };


    return(
        <CartContext.Provider value={{
            addCart,cart,
            totalCart,vlrTotalCart,
            setCli,cliente,
            quantCart,qtdTotalCart,
            setUserData,dataUser,
            descontoCart,desconto,
            addImageProfile,imageProfile,
            copyPedido,copy
        }}>
            {children}
        </CartContext.Provider>
    )
}

export default CartProvider;