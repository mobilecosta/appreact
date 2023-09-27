#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL045
Descricao: Servico API Rest Evento Troca de Senha

@author Felipe Mayer
@since 27/09/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL045()
Return

// Servico.
WsRestFul PRTL045 DESCRIPTION "API REST - Troca Senha | PORTAL ROBSOL " 
	
	WsMethod POST Description "API REST - Troca Senha - METODO POST "  WsSyntax "PRTL045"

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantacao 
Descricao: 	Servico Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Felipe Mayer
@since 27/09/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod POST WsReceive RECEIVE WsService PRTL045

	Local cCode			As Character 
	Local cMessage		As Character
	Local cUser			As Character
	Local cNewPass		As Character
	Local lRet			As Logical 
	Local oBody			As J 

	cCode	:= ''
	cMessage	:= ''
	lRet	:= .T.

	conout("chegou aqui PRTL045")

	// recupera o body da requisicao
	oBody  := JsonObject():New()

	If ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 		:= "#500"
		cMessage	:= "Formato Json nao reconhecido. Revisar a estrutura e layout informado."
		lRet		:= .T.
	Else
		cUser 		:= oBody:getJsonText("USUARIO")
		cNewPass	:= oBody:getJsonText("NEWPASS")

		If !Empty(cNewPass)
			RPCSetType(3)  
			RpcSetEnv('01','0101',,,,GetEnvServer(),{ })
			
			DbSelectArea("AI3")
			AI3->(DbsetOrder(2))
			If AI3->(Dbseek(xFilial("AI3")+cUser))
				conout('senha atual: '+AI3->AI3_PSW)
				RecLock('AI3', .F.)
					AI3->AI3_PSW := cNewPass
				AI3->(MsUnlock())
				conout('nova senha: '+cNewPass)

				cCode 	 := "#200"
				cMessage := "Senha Alterada"
				lRet 	 := .T.
			Else
				cCode 	 := "#500"
				cMessage := "Senha nao foi alterada"
				lRet 	 := .F.
			EndIf
		EndIf
	EndIf

	//-> Mensagem de Retorno da requisicao
	self:setContentType("application/json")
	self:setResponse(fwJsonSerialize(StatReq(cCode,cMessage)))

	// Realiza o fechamento do Ambiente
	RpcClearEnv()
	Freeobj(oBody)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StatReq
Descricao: 	Realiza o Tratamento para envio de Mensagem de Retorno 
				da API 

@author Felipe Mayer
@since 27/09/2022
@version 1.0

@Param: 
	cCode 	= 	Codigo do Erro que sera informado no Retorno da API
	cMessage	= 	Mensagem de Retorno que sera informado no Retorno 
					da API

/*/
//-------------------------------------------------------------------
Static Function StatReq(cCode As Character, cMessage As Character) As J

	Local oJsonBody	As J
	Local oJsonRet 	As J

	Default cCode		:= ''
	Default cMessage	:= ''

	//Cria o Objeto de Retono da Requisição.
	oJsonRet  := JsonObject():New()
	oJsonRet["statusrequest"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["code"]      := cCode
	oJsonBody["message"]   := cMessage

	AAdd( oJsonRet["statusrequest"], oJsonBody )

Return oJsonRet
