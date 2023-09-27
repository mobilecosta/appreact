#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL001
Descricao: Servico API Rest Evento Usuarios

@author Alexandre Ven�ncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL001()
Return

// Serviço.
WsRestFul PRTL001 DESCRIPTION "API REST - EVENTO USUARIOS | PORTAL ROBSOL " 
	
	WsMethod POST Description "API REST - EVENTO USUARIOS - METODO POST "  WsSyntax "PRTL001"

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantacao 
Descricao: 	Serviço Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod POST WsReceive RECEIVE WsService PRTL001

	Local cCode			As Character 
	Local cMessage		As Character
	Local cEmp			As Character 
	Local cFil			As Character 
	Local cUser			As Character
	Local cPass			As Character
	Local cCodUsu		As Character
	Local cNomUsu		As Character
	Local cCodVnd		As Character 
	Local cCodClt 		As Character
	Local cLojCli		As Character
	Local cAcesso		As Character

	Local aRetExec		As Array
	Local aErro			As Array

	Local lRet			As Logical 
	
	Local oBody			As J 

	cCode					:= ''
	cCodUsu					:= ''
	cNomUsu					:= ''
	cCodVnd					:= ''
	cCodClt					:= ''
	cLojCli					:= ''
 	cEmp					:= '01'
	cFil					:= '0101'
	cMessage				:= ''
	cAcesso					:= ''
	cDtUltBn				:= ''
	cFlagBn					:= ''

	aTitulos				:= {}
	aTitTrans			    := {}
	aRetExec				:= {}
	aRastro				    := {}
	aErro					:= {}

	lRet					:= .T.

	conout("chegou aqui PRTL001")

	// recupera o body da requisição
	oBody  := JsonObject():New()

	If ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 	:= "#500"
		cMessage	:= "Formato Json nao reconhecido. Revisar a estrutura e layout informado."
		lRet		:= .T.
	Else
		cUser 		:= oBody:getJsonText("USUARIO")
		cPass 		:= oBody:getJsonText("SENHA")

		// Verifica se os campos Obrigatorios para abertura da Empresa/Filial foram preenchidos.
		If (Empty(cUser) .Or. AllTrim(cUser)=='null')
			cCode 	:= "#500"
			cMessage	:= "Campos Obrigatorios de Preenchimento nao informados: USUARIO"
			lRet		:= .T.
		
		ElseIf (Empty(cPass) .Or. AllTrim(cPass)=='null')
			cCode 	:= "#500"
			cMessage	:= "Campos Obrigatorios de Preenchimento nao informados: SENHA"
			lRet		:= .T.
		Else
			RPCSetType(3)  
			RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ }) 
		EndIf

		// Chama Rotina que irá analisar os dados recebidos.
		If lRet .And. Empty(cCode) .And. Empty(cMessage)
			conout(cPass)
			RetUser(oBody, @aRetExec, @aErro, cUser, cPass )
			
			// Se o array de Erro estiver vazio, segue com a ExecAuto
			If len(aErro) < 1
				// Chama a ExecAuto
				lRet		:= aRetExec[1]
				cCode		:= aRetExec[2]
				cCodUsu		:= aRetExec[3]
				cNomUsu		:= aRetExec[4]
				cCodVnd		:= aRetExec[5]
				cAcesso		:= aRetExec[6]
				cCodClt		:= aRetExec[7]
				cLojCli		:= aRetExec[8]
				cDtUltBn	:= aRetExec[9]
				cFlagBn		:= aRetExec[10]
				
			Else
				// Mostra o Erro no Retorno do Processamento.
				lRet		:= .F.
				cCode		:= aErro[2]
				cCodUsu		:= aErro[3]
				cNomUsu		:= ''
				cCodVnd		:= ''
				cAcesso  	:= ''
				cCodClt		:= ''
				cLojCli		:= ''
				cDtUltBn	:= ''
				cFlagBn		:= ''
			EndIf 

		EndIf 

	EndIf

	conout(ccode)
	conout(ccodusu)
	conout(cCodVnd)
	conout('cliente '+cCodClt)
	//-> Mensagem de Retorno da Requisição
	self:setContentType("application/json")
	self:setResponse(fwJsonSerialize(StatReq(cCode,cCodUsu,cNomUsu,cCodVnd,cAcesso,cCodClt,cLojCli,cDtUltBn,cFlagBn)))

	// Realiza o fechamento do Ambiente
	RpcClearEnv()
	Freeobj(oBody)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} StatReq
Descricao: 	Realiza o Tratamento para envio de Mensagem de Retorno 
				da API 

@author Alexandre Venâncio
@since 12/05/2020
@version 1.0

@Param: 
	cCode 	= 	Codigo do Erro que sera informado no Retorno da API
	cMessage	= 	Mensagem de Retorno que sera informado no Retorno 
					da API

/*/
//-------------------------------------------------------------------
Static Function StatReq(cCode As Character, cCodUsu As Character, cNomUsu As Character , cCodVnd As Character, cAcesso As Character, cCodClt As Character, cLojCli As Character,cDtUltBn As Character,cFlagBn As Character) As J

	Local oJsonBody	As J
	Local oJsonRet 	As J

	Default cCode		:= ''
	Default cMessage	:= ''

	//Cria o Objeto de Retono da Requisição.
	oJsonRet  := JsonObject():New()
	oJsonRet["statusrequest"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["code"]          := cCode
	oJsonBody["Cod_Usuario"]   := cCodUsu

	If !Empty(cNomUsu)
		oJsonBody["nome_usuario"]   := cNomUsu
		oJsonBody["cod_vendedor"]   := cCodVnd
		oJsonBody["menu_acesso"]   	:= cAcesso
		oJsonBody["user_token"]   	:= Encode64(cCode+cCodUsu+cCodVnd)
		oJsonBody["cod_cliente"]   	:= cCodClt
		oJsonBody["loja_cliente"]	:= cLojCli
		oJsonBody["ult_benef"]		:= cDtUltBn
		oJsonBody["auth_benef"]		:= cFlagBn	
	EndIf

	AAdd( oJsonRet["statusrequest"], oJsonBody )

Return oJsonRet

/*/{Protheus.doc} RetDados
Descricao: 	Realiza o tratamento dos dados vindos do Json e ja prepara
				o array de geração dos Titulos do Contas a Pagar.

@author Alexandre Venâncio
@since 12/05/2020
@version 1.0

@Param:
	oBody		=	Objeto Json da Requisição da API
	aTitulos	=	Array que guardara os dados dos Titulos 
	aTitTrans=	Array que guardara os dados da Transferencia de Cart.
	aRastro 	=	Array que guardara os dados do Rastreio dos titulos.
	aErro		=	Array que guardara possiveis erros de processamentos
					e/ou tratamento dos dados.
/*/
//-------------------------------------------------------------------
Static Function RetUser(oBody As J, aRetExec as Array, aErro As Array, cUser As Character, cPass As Character) As Logical 

	Local lRet			As Logical
	Local cBenef := 'N'

	Default aRetExec	:= {}
	Default aErro		:= {}

	lRet := .T.

	DbSelectArea("AI3")
	DbsetOrder(2)
	If Dbseek(xFilial("AI3")+cUser)
		If Alltrim(AI3->AI3_PSW) <> Alltrim(cPass)
			aErro	:= {.F.,'#400', "Senha invalida"}
			lRet := .F.
		EndIf

		If lRet
			DbSelectArea("AI4")
			DbSetOrder(1)
			DbSeek(xFilial("AI4")+AI3->AI3_CODUSU)

			If Empty(AI3->AI3_ULTBEN) .Or. SubStr(DToS(AI3->AI3_ULTBEN),5,2) != SubStr(DToS(Date()),5,2)
				cBenef := 'S'
			EndIf

			aRetExec := {;
					.T.,;
					"#200",;
					AI3->AI3_CODUSU,;
					Alltrim(AI3->AI3_NOME),;
					AI3->AI3_VEND,;
					AI3->AI3_XACESS,;
					AI4->AI4_CODCLI,;
					AI4->AI4_LOJCLI,;
					DToS(AI3->AI3_ULTBEN),;
					cBenef;
				}
		EndIf
	else
		aErro	:= {.F.,'#400', "Usuario nao encontrado"}
	EndIf

Return lRet
