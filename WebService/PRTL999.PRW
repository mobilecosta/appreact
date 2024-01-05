#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL999
Descricao: Serviço API Rest Evento Menus Portal por usuario

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL999()

Return

// Servico.
WsRestFul ApiTotvsTeste DESCRIPTION "API REST - EVENTO MENUS | PORTAL ROBSOL " 
	
	//WsMethod POST Description "API REST - EVENTO PRODUTOS - METODO POST "  WsSyntax "PRTL010"
	WsMethod POST Description "Retorna o Menu do usuario" WSSYNTAX "/ApiTotvsTeste/" 

End WsRestFul

//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantacao 
Descricao: 	Servico Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod POST WsReceive RECEIVE WsService ApiTotvsTeste

	Local aArea		:= GetArea()
	Local cJson		:= ''
	// Local oJsonIM
	Local cBody
    Local cCode
    Local cloja
    Local cNome 

	lRet					:= .T.
	
    cBody := ::GetContent()
	cBody := upper(cbody)

    conout(cBody)
	
	//IF FWJsonDeserialize(cBody,@oJsonIM)
		// recupera o body da requisicao
		oBody  := JsonObject():New()
		oBody:fromJson(cBody) //oJsonIM:Body)
	    cCode 		:= oBody:getJsonText("CODIGO_DO_CLIENTE")
		cLoja		:= oBody:getJsonText("LOJA_DO_CLIENTE")
		cNome		:= oBody:getJsonText("NOME_DO_CLIENTE")
	//ENDIF
	
    RpcSetType(3)
	RPCSetEnv("01","0101")
	conout(cCode)
    conout(cLoja)
    conout(cNome)
	DbSelectArea("Z99")
	DbsetOrder(1)
	If !Dbseek(xFilial("Z99")+cCode+cLoja) 
        Reclock("Z99",.T.)
        Z99->Z99_FILIAL := xFilial("Z99")
		Z99->Z99_CODIGO := cCode
        Z99->Z99_LOJA   := cLoja
        Z99->Z99_NOME   := cNome
        Z99->(MsUnlock())
        cJson += '{ "codigo":"#200",'
		cJson += '"Sucesso": "Registro salvo com sucesso!!!",}'
	else
		cJson += '{ "codigo":"#400",'
		cJson += '"Erro": "Portal nao encontrado",}'
		
	EndIf
	
	::SetResponse(cJson)

RestArea(aArea)
	
Return lRet

