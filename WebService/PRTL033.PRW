#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL033
Descricao: Serviço API Rest Evento Tela Inicial portal

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL033()
Return

// Serviço.
WsRestFul Metas DESCRIPTION "API REST - EVENTO Metas | PORTAL ROBSOL " 
	
	WSDATA VENDEDOR As String
	
	WsMethod GET Description "Retorna o Cliente especifico ou cadastro todo" WSSYNTAX "/Metas || /Metas/{VENDEDOR}" 

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantação 
Descricao: 	Serviço Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod GET WsReceive VENDEDOR WsService Metas

	Local CodVend 	:= Self:VENDEDOR
	Local aArea		:= GetArea()
	Local cJson     := ''

	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	conout("chegou aqui PRTL033")
	conout("vendedor "+cvaltochar(CodVend))

	If !Empty(CodVend)
    	cJson := U_ROBMET01(CodVend)
	EndIf 
	
    If !Empty(cJson)
        ::SetResponse(cJson)
    else
        ::SetResponse('{Vendedor nao informado}')
    EndIf
    

	RestArea(aArea)

	
Return lRet
