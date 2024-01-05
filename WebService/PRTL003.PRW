#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"

#Define Enter Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL003
Descricao: Servico API Rest Evento Geracao de Pedidos

@author Alexandre Ven‚ncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL003()
Return

// Servico.
WsRestFul PRTL003 DESCRIPTION "API REST - EVENTO GERACAO PEDIDOS | PORTAL ROBSOL " 
	
	WsMethod POST Description "API REST - EVENTO GERACAO PEDIDOS - METODO POST "  WsSyntax "PRTL003"

End WsRestFul
//-------------------------------------------------------------------
/*/{Protheus.doc} Metodo Post | Evento Implantacao 
Descricao: 	Servi√ßo Rest contendo o Metodo POST do evento de 
				Portal Robsol

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
WsMethod POST WsReceive RECEIVE WsService PRTL003

	Local cCode			As Character 
	Local cMessage		As Character
	Local cEmp			As Character 
	Local cFil			As Character 
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
	Local oJsonIM
	Local cCondPg
	Local nX
	Local cBarra
	Local aSld 				:=	{}
	
	
	Local aItens			:=	{}
	Local aCliente			:=	{}

	Private cUser			As Character
	Private cUserCod		As Character

	cCode					:= ''
	cCodUsu					:= ''
	cNomUsu					:= ''
	cCodVnd					:= ''
	cCodClt					:= ''
	cLojCli					:= ''
 	cEmp					:= '01'
	cFil					:= '0103'
	cMessage				:= ''
	cAcesso					:= ''

	aTitulos				:= {}
	aTitTrans			    := {}
	aRetExec				:= {}
	aRastro				    := {}
	aErro					:= {}

	lRet					:= .T.

	cBody := ::GetContent()
	cBody := upper(cbody)
	conout("chegou aqui PRTL003")
	conout("o que veio = "+cBody)
	conout("")
	conout("")
	IF FWJsonDeserialize(cBody,@oJsonIM)
		// recupera o body da requisicao
		oBody  := JsonObject():New()
		oBody:fromJson(oJsonIM:Body)
		cUser 		:= oBody:getJsonText("VENDEDOR")
		cCondPg		:= oBody:getJsonText("CONDPAGTO")
		aItens		:= oBody:getJsonText("ITEMS")
		aCliente	:= oBody:getJsonText("CLIENTE")
		cUserCod	:= oBody:getJsonText("USUARIO")
	ENDIF
	
	/*If AllTrim( self:getContent() ) != 'U' //ValType(oBody:fromJson( AllTrim( self:getContent() ) )) != 'U'	
		cCode 	:= "#500"
		cMessage	:= "Formato Json nao reconhecido. Revisar a estrutura e layout informado."
		lRet		:= .F.
	Else*/
		lRet		:= .T.

		conout(cUser)
		conout(cCondPg)
		

		// Verifica se os campos Obrigatorios para abertura da Empresa/Filial foram preenchidos.
		If (Empty(cUser) .Or. AllTrim(cUser)=='null')
			cCode 	:= "#500"
			cMessage	:= "Campos Obrigatorios de Preenchimento nao informados: VENDEDOR"
			lRet		:= .T.
			conout(cCode+CHR(13)+CHR(10)+cMessage)
		
		Else
			RPCSetType(3)  
			RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ }) 
		EndIf

		CFILANT := cFil
		// Chama Rotina que ir√° analisar os dados recebidos.
		If lRet .And. Empty(cCode) .And. Empty(cMessage)
            StatPed(oBody,@aRetExec, @aErro,@aSld)
			conout("passou statped")
			
            cCode 		:= aRetExec[1]
            cCodUsu		:= aRetExec[2]
			cProdsld	:= aRetExec[3]
			
			conout("retornou "+ccode)
			conout(ccodusu)
			conout(cProdsld)

			If len(aSld) > 0
				cJsonRet := '{"codigo": "410",
				cJsonRet += '"mensagem": "Itens sem saldo",'
				cJsonRet += '"produtos": ['
				//aSld := separa(cProdsld,",")
				cBarra := ''
				For nX := 1 to len(aSld)
					If !Empty(aSld[nX,01])
						cJsonRet += cBarra+'{'
						cJsonRet += '"codigo":"'+cvaltochar(aSld[nX,01])+' / Saldo '+cvaltochar(aSld[nX,02])+'",
						cJsonRet += '"saldo": "'+cvaltochar(aSld[nX,02])+'" }'
						cBarra := ','
					EndIf
				Next nX
				cJsonRet += ']'
				cJsonRet += '}'
			else
				cJsonRet := '{"code" : "200",
				cJsonRet += '"pedido": "'+cCode+'",'
				cJsonRet += '"mensagem": "'+cCodUsu+'"}'				
			EndIf
			conout(cJsonret)
		EndIf 

	//EndIf

	//-> Mensagem de Retorno da Requisi√ß√£o
	self:setContentType("application/json")
	//self:setResponse(fwJsonSerialize(StatReq(cCode,cCodUsu,cNomUsu,cCodVnd,cAcesso,cCodClt,cLojCli)))
    //self:setResponse(fwJsonSerialize(StatReq(cCode,cCodUsu,cProdsld)))
	self:setResponse(cJsonRet)
	// Realiza o fechamento do Ambiente
	RpcClearEnv()
	Freeobj(oBody)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} StatReq
Descricao: 	Realiza o Tratamento para envio de Mensagem de Retorno 
				da API 

@author Alexandre Ven√¢ncio
@since 12/05/2020
@version 1.0

@Param: 
	cCode 	= 	Codigo do Erro que sera informado no Retorno da API
	cMessage	= 	Mensagem de Retorno que sera informado no Retorno 
					da API

/*/
//-------------------------------------------------------------------
Static Function StatReq(cCode As Character, cCodUsu As Character, cProds As Character ) As J

	Local oJsonBody	As J
	Local oJsonRet 	As J
	Local nX 			:= 0
	Local aSaldos		:=	{}
	Local aItens		:=	{}

	Default cCode		:= ''
	Default cCodUsu		:= ''
	Default cProds		:= ''


	//Cria o Objeto de Retono da Requisi√ß√£o.
	oJsonRet  := JsonObject():New()
	oJsonRet["statusrequest"] := {}
	oJsonRet["produtos"] := {}

	oJsonBody := JsonObject():New()
	oJsonBody["codigo"]      := cCode
	oJsonBody["mensagem"]   := cCodUsu

	If !Empty(cProds)
		aSaldos := Separa(cProds,",")
			
		For nX := 1 to len(aSaldos)
			Aadd(aItens,JsonObject():new())
			aItens[nX]['codigo'] := aSaldos[nX]
		Next nX
	EndIf

	AAdd( oJsonRet["statusrequest"], oJsonBody )
	AAdd( oJsonRet["produtos"],aItens )

Return oJsonRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StatReq
Descricao: 	Realiza o Tratamento para envio de Mensagem de Retorno 
				da API 

@author Alexandre Ven√¢ncio
@since 12/05/2020
@version 1.0

@Param: 
	cCode 	= 	Codigo do Erro que sera informado no Retorno da API
	cMessage	= 	Mensagem de Retorno que sera informado no Retorno 
					da API

/*/
//-------------------------------------------------------------------
Static Function StatPed(oBody As J, aRetExec as Array, aErro As Array, aSld As Array) As J

	//Local oJsonBody	As J
	Local aArea		:=	GetArea()
	Local oJsonRet 	As J

	Local lRet		:=	.F.
	Local aCabec    := {}
	Local aItens   	:= {}   
	Local aLinha    := {}
	Local cDoc 		:= GetSxeNum("SC5", "C5_NUM")
	Local nX		:=	0
	Local aDadCl		:=	{}
	Local nOpcAuto	:=	3
	Local aAI0Auto	:=	{}
	Local aItensCad :=  {}
	Local cPedido
	Local cMessage
	Local nDescon		:=	0
	Local aSaldos 		:=	{}
	Local cProdsSld		:=	''
	Local nCont
	Default oBody		:= 	nil
    Default aRetExec    :=  {}
    Default aErro       :=  {}

	cCodVnd := oBody:VENDEDOR
	cCondPg := STRZERO(VAL(oBody:CONDPAGTO),3)
	lForce  := If(UPPER(oBody:FORCE)=='TRUE',.T.,.F.)
	cObsApp := oBody:OBSERVATION
	nDescon := oBody:DESCONTO

	If !lForce .And. oBody:ORCAMENTO <> 'S'
		aSaldos := ValSald(oBody:ITEMS)
	ENDIF
	
	If len(aSaldos) > 0
		cPedido := '410'
		cMessage := 'Itens sem saldo'+CRLF
		cProdsSld := ''
		For nX := 1 to len(aSaldos)	
			cProdsSld += aSaldos[nX,01]+','
		Next nX
		aSld := aSaldos
		
	Else
		If cCondPg == "000"
			cCondPg := '001'
		EndIf

		DbSelectArea("CC2")
		DbSetOrder(4)
		
		If Valtype(oBody:Cliente) == "A"
			If Dbseek(xFilial("CC2")+upper(oBody:Cliente[1]:UF)+upper(oBody:Cliente[1]:CIDADE))
				codmun := CC2->CC2_CODMUN
			else
				codmun := '50308'
			endif
		else
			If Dbseek(xFilial("CC2")+upper(oBody:Cliente:UF)+upper(oBody:Cliente:CIDADE))
				codmun := CC2->CC2_CODMUN
			else
				codmun := '50308'
			EndIf
		endIf
		
		If Valtype(oBody:Cliente) == "A"
			DbSelectArea("SA1")
			If oBody:CLIENTE[1]:GetJsonObject("CNPJ") <> NIL //AttIsMemberOf(oBody:Cliente[1],"CNPJ")
				ccnpjx := oBody:Cliente[1]:cnpj
				DbSetOrder(3)
			Else
				ccnpjx := oBody:Cliente[1]:codigo
				DbSetOrder(1)
			EndIf
		else
			DbSelectArea("SA1")
			If oBody:CLIENTE:GetJsonObject("CNPJ") <> NIL //AttIsMemberOf(oBody:Cliente[1],"CNPJ")
				ccnpjx := oBody:Cliente:cnpj
				DbSetOrder(3)
			Else
				ccnpjx := oBody:Cliente:codigo
				DbSetOrder(1)
			EndIf
		EndIF 

		If Dbseek(xFilial("SA1")+ccnpjx)
			ccnpj 	:= SA1->A1_COD
			cloja 	:= SA1->A1_LOJA
			//CONTATO CELULAR ENDERECO BAIRRO CIDADE 
			Reclock("SA1",.F.)
			If Valtype(oBody:Cliente) == "A"
				If Alltrim(SA1->A1_CONTATO) <> Alltrim(oBody:Cliente[1]:CONTATO)
					SA1->A1_CONTATO := oBody:Cliente[1]:CONTATO
				EndIF

				If Alltrim(SA1->A1_EMAIL) <> Alltrim(oBody:Cliente[1]:EMAIL)
					SA1->A1_EMAIL := oBody:Cliente[1]:EMAIL
				EndIF

				If Alltrim(SA1->A1_END) <> Alltrim(oBody:Cliente[1]:ENDERECO)
					SA1->A1_END := Alltrim(oBody:Cliente[1]:ENDERECO)
				ENDIF

				If Alltrim(SA1->A1_TEL) <> substr(oBody:Cliente[1]:CELULAR,3) 
					SA1->A1_TEL := substr(oBody:Cliente[1]:CELULAR,3)
				ENDIF

				If Alltrim(SA1->A1_XTELEFO) <> substr(oBody:Cliente[1]:FONE2,3)
					SA1->A1_XTELEFO := substr(oBody:Cliente[1]:FONE2,3)
				ENDIF

				IF Alltrim(SA1->A1_XDDD) <> substr(oBody:Cliente[1]:FONE2,1,2)
					SA1->A1_XDDD := substr(oBody:Cliente[1]:FONE2,1,2)
				ENDIF
			ELSE
				If Alltrim(SA1->A1_CONTATO) <> Alltrim(oBody:Cliente:CONTATO)
					SA1->A1_CONTATO := oBody:Cliente:CONTATO
				EndIF

				If Alltrim(SA1->A1_EMAIL) <> Alltrim(oBody:Cliente:EMAIL)
					SA1->A1_EMAIL := oBody:Cliente:EMAIL
				EndIF

				If Alltrim(SA1->A1_END) <> Alltrim(oBody:Cliente:ENDERECO)
					SA1->A1_END := Alltrim(oBody:Cliente:ENDERECO)
				ENDIF

				If Alltrim(SA1->A1_TEL) <> substr(oBody:Cliente:CELULAR,3) 
					SA1->A1_TEL := substr(oBody:Cliente:CELULAR,3)
				ENDIF

				If Alltrim(SA1->A1_XTELEFO) <> substr(oBody:Cliente:FONE2,3)
					SA1->A1_XTELEFO := substr(oBody:Cliente:FONE2,3)
				ENDIF

				IF Alltrim(SA1->A1_XDDD) <> substr(oBody:Cliente:FONE2,1,2)
					SA1->A1_XDDD := substr(oBody:Cliente:FONE2,1,2)
				ENDIF

				If oBody:CLIENTE:GetJsonObject("OBSERVACAO_ENTREGA") <> Nil
					If Alltrim(SA1->A1_ENDENT) <> Alltrim(oBody:CLIENTE:GetJsonObject("ENDERECO_ENTREGA"))
						SA1->A1_ENDENT := oBody:CLIENTE:GetJsonObject("ENDERECO_ENTREGA")
					EndIf

					If Alltrim(SA1->A1_BAIRROE) <> oBody:CLIENTE:GetJsonObject("BAIRRO_ENTREGA")
						SA1->A1_BAIRROE := oBody:CLIENTE:GetJsonObject("BAIRRO_ENTREGA")
					EndIf 

					If Alltrim(SA1->A1_CEPE) <> oBody:CLIENTE:GetJsonObject("CEP_ENTREGA")
						SA1->A1_CEPE := oBody:CLIENTE:GetJsonObject("CEP_ENTREGA")
					EndIf
				ENDIF


			EndIF
			SA1->(MsUnlock())
			
		else
			
			ccnpj := SUBSTR(ccnpjx,1,If(len(ccnpjx)>11,8,9))
			cloja := SUBSTR(ccnpjx,If(len(ccnpjx)>11,9,10),If(len(ccnpjx)>11,4,2))

			Aadd(aDadCl,{"A1_CGC"   ,   ccnpjx              					, NIL})
			Aadd(aDadCl,{"A1_PESSOA",   If(len(ccnpjx)>11,'J','F')           	, NIL})
			Aadd(aDadCl,{"A1_TIPO"  ,   'R'                     				, NIL})
			Aadd(aDadCl,{"A1_COD_MUN",  codmun                 , NIL})
					
			If Valtype(oBody:Cliente) == "A"

				Aadd(aDadCl,{"A1_NOME"  ,   upper(oBody:Cliente[1]:RAZAO_SOCIAL)  			, NIL})
				Aadd(aDadCl,{"A1_NREDUZ",   upper(oBody:Cliente[1]:NOME_FANTASIA)  			, NIL})
				Aadd(aDadCl,{"A1_END"   ,   Alltrim(upper(oBody:Cliente[1]:ENDERECO))  		, NIL})
				Aadd(aDadCl,{"A1_CEP"   ,   oBody:Cliente[1]:CEP                    		, NIL})
				Aadd(aDadCl,{"A1_BAIRRO",   substr(upper(oBody:Cliente[1]:BAIRRO),1,30)    	, NIL})
				Aadd(aDadCl,{"A1_EST"   ,   upper(oBody:Cliente[1]:UF)               		, NIL})
				Aadd(aDadCl,{"A1_MUN"   ,   substr(UPPER(oBody:Cliente[1]:CIDADE),1,60)    	, NIL})
				Aadd(aDadCl,{"A1_EMAIL" ,   upper(oBody:Cliente[1]:EMAIL)                  	, NIL})
				Aadd(aDadCl,{"A1_DDD"   ,   Substr(oBody:Cliente[1]:CELULAR,1,2)            , NIL})
				Aadd(aDadCl,{"A1_TEL"   ,   substr(oBody:Cliente[1]:CELULAR,3)              , NIL})
				Aadd(aDadCl,{"A1_XDDD"   ,   Substr(oBody:Cliente[1]:FONE2,1,2)             , NIL})
				Aadd(aDadCl,{"A1_XTELEFO",   substr(oBody:Cliente[1]:FONE2,3)               , NIL})
				Aadd(aDadCl,{"A1_CONTATO",  oBody:Cliente[1]:CONTATO			          	, NIL})
				
			else
				Aadd(aDadCl,{"A1_NOME"  ,   upper(oBody:Cliente:RAZAO_SOCIAL)  				, NIL})
				Aadd(aDadCl,{"A1_NREDUZ",   upper(oBody:Cliente:NOME_FANTASIA)  			, NIL})
				Aadd(aDadCl,{"A1_END"   ,   Alltrim(upper(oBody:Cliente:ENDERECO))  		, NIL})
				Aadd(aDadCl,{"A1_CEP"   ,   oBody:Cliente:CEP                    			, NIL})
				Aadd(aDadCl,{"A1_BAIRRO",   substr(upper(oBody:Cliente:BAIRRO),1,30)    	, NIL})
				Aadd(aDadCl,{"A1_EST"   ,   upper(oBody:Cliente:UF)               			, NIL})
				Aadd(aDadCl,{"A1_MUN"   ,   substr(UPPER(oBody:Cliente:CIDADE),1,60)    	, NIL})
				Aadd(aDadCl,{"A1_EMAIL" ,   upper(oBody:Cliente:EMAIL)                  	, NIL})
				Aadd(aDadCl,{"A1_DDD"   ,   Substr(oBody:Cliente:CELULAR,1,2)               , NIL})
				Aadd(aDadCl,{"A1_TEL"   ,   substr(oBody:Cliente:CELULAR,3)                 , NIL})	
				Aadd(aDadCl,{"A1_XDDD"  ,   Substr(oBody:Cliente:FONE2,1,2) 	            , NIL})
				Aadd(aDadCl,{"A1_XTELEFO",  substr(oBody:Cliente:FONE2,3)	                , NIL})	
				Aadd(aDadCl,{"A1_CONTATO",  oBody:Cliente:CONTATO			                , NIL})
				
			EndIf

			Aadd(aDadCl,{"A1_PAIS"  ,   '105'                   , NIL})
			Aadd(aDadCl,{"A1_CODPAIS",  '01058'                 , NIL})
			Aadd(aDadCl,{"A1_TPESSOA",  'CI'    	             , NIL})

			Aadd(aDadCl,{"A1_VEND"	,   cCodVnd                 , NIL})
			
			If oBody:CLIENTE:GetJsonObject("ENDERECO_ENTREGA") <> Nil
				Aadd(aDadCl,{"A1_ENDENT"	,   oBody:CLIENTE:GetJsonObject("ENDERECO_ENTREGA")       , NIL})
				Aadd(aDadCl,{"A1_BAIRROE"	,   oBody:CLIENTE:GetJsonObject("BAIRRO_ENTREGA")         , NIL})
				Aadd(aDadCl,{"A1_CEPE"		,   oBody:CLIENTE:GetJsonObject("CEP_ENTREGA")            , NIL})
			ENDIF

			aAdd(aAI0Auto,{"AI0_SALDO" ,0 ,Nil})
			
			aAdd(aDadCl,{"A1_LOJA", cLoja , Nil})
			
			lMsErroAuto := .F.
			//------------------------------------
			// Chamada para cadastrar o cliente.
			//------------------------------------
			MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aDadCl, nOpcAuto, aAI0Auto)
			
			If lMsErroAuto 
				mostraerro('\system\erros_app\','cliente_'+dtos(ddatabase)+strtran(cvaltochar(time()),":"))
				//ccnpj := ''
				//cloja := ''
				//cPedido := '400'
				//cMessage := 'Erro ao cadastrar o cliente'
				//ForÁa criaÁ„o para quando der erro na rotina padr„o
				DbSelectArea("SA1")
				Reclock("SA1",.T.)
				SA1->A1_FILIAL 	:= xFilial("SA1")
				SA1->A1_COD 	:= ccnpj
				SA1->A1_LOJA 	:= cloja
				 
				For nCont := 1 to len(aDadCl)
					&("SA1->"+aDadCl[nCont,01]) := aDadCl[nCont,02]
				Next nCont 
				SA1->(Msunlock())

			else
				conout("cliente cadastrado")
				//ccnpj  := SA1->A1_COD
				//cLoja  := SA1->A1_LOJA
				DbSelectArea("SA1")
				DbSetOrder(3)
				DbSeek(xFilial("SA1")+ccnpjx)
			EndIf
			
		EndIf

		If !Empty(ccnpj) 
			If oBody:ORCAMENTO <> 'S'
				aItensCad := oBody:ITEMS
				aadd(aCabec, {"C5_NUM"		, cDoc			,Nil})
				aadd(aCabec, {"C5_TIPO"		, "N"			,Nil})
				aadd(aCabec, {"C5_CLIENTE"	, ccnpj			,Nil})
				aadd(aCabec, {"C5_LOJACLI"	, cloja			,Nil})
				aadd(aCabec, {"C5_LOJAENT"	, cloja			,Nil})
				aadd(aCabec, {"C5_EMISSAO"	, dDatabase		,Nil}) // Data de emissao
				aadd(aCabec, {"C5_TIPOCLI"	, SA1->A1_TIPO	,Nil}) // Tipo de cliente
				aadd(aCabec, {"C5_TIPOPV" 	, '1'			,Nil}) //
				aadd(aCabec, {"C5_MOEDA"  	, 1				,Nil})  // Moeda
				aadd(aCabec, {"C5_CONDPAG"	, cCondPg		,Nil})
				aadd(aCabec, {"C5_NATUREZ"  ,"11010007"     ,Nil})  
				aadd(aCabec, {"C5_VEND1"    , cCodVnd       ,Nil})
				aadd(aCabec, {"C5_X_OBS"    , cObsApp		,Nil})
				aadd(aCabec, {"C5_ZZSTATU"  , 'X'			,Nil})

				cItem := '01'

				FOR nX := 1 to len(aItensCad)  
					aLinha := {}
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+aItensCad[nX]:PRODUTO)
					
					nQtd := 0
					If valtype(aItensCad[nX]:QUANTIDADE) == "C"
						nQtd := val(aItensCad[nX]:QUANTIDADE)
					else
						nQtd := aItensCad[nX]:QUANTIDADE
					EndIf 
					aadd(aLinha,{"C6_ITEM"		, cItem				, Nil}) //STRZERO(nX,2)	
					aadd(aLinha,{"C6_PRODUTO"	, aItensCad[nX]:PRODUTO			, Nil})
					aadd(aLinha,{"C6_QTDVEN"	, nQtd							, Nil})
					aadd(aLinha,{"C6_PRCVEN"	, val(STRTRAN(aItensCad[nX]:VALOR,",","."))	, Nil})
					aadd(aLinha,{"C6_PRUNIT"	, val(STRTRAN(aItensCad[nX]:VALOR,",","."))	, Nil})
					aadd(aLinha,{"C6_VALOR"		, val(STRTRAN(aItensCad[nX]:VALOR,",",".")) * nQtd	, Nil})
					aadd(aLinha,{"C6_XQTDORI"	, nQtd							, Nil})
					
					cItem := Soma1(cItem)
					
					If aItensCad[nX]:GetJsonObject("BENEF") <> Nil
						If aItensCad[nX]:BENEF == "B"

							DbSelectArea("AI3")
							AI3->(DbsetOrder(1))
							
							If AI3->(Dbseek('0101'+AvKey(cUserCod,'AI3_CODUSU')))
								RecLock('AI3', .F.)
									AI3->AI3_ULTBEN := Date()
								AI3->(MsUnlock())
							EndIf

							aadd(aLinha,{"C6_TES"		, '627'			 				, Nil})
							aadd(aCabec, {"C5_MENNOTA"    , 'Produto '+Alltrim(aItensCad[nX]:PRODUTO)+' enviar como Brinde'		,Nil})
						Else
							aadd(aLinha,{"C6_TES"		, '502'			 				, Nil})
						EndIf 
					else
						aadd(aLinha,{"C6_TES"		, '502'			 				, Nil})
					EndIf 
					
					aadd(aLinha,{"C6_LOCAL"		, SB1->B1_LOCPAD	 			, Nil})
					aadd(aLinha,{"C6_DESCONT"	, VAL(nDescon)			  	 	, Nil})
					
					aadd(aItens, aLinha)

				NEXT      

				lMsErroAuto := .F.            

				Begin Transaction 

						
				MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 3)
				
				If !lMsErroAuto
					ConOut("IncluÌdo com sucesso! " + cDoc)
					ConfirmSX8()
					cPedido := SC5->C5_NUM
					GERHTML(cPedido)
					cMessage := 'Pedido gerado com sucesso'
					lRet := .T.
				Else
					cPedido := '400'
					cMessage := 'Erro ao gerar o pedido'
					mostraerro('\system\erros_app\','pedido_'+dtos(ddatabase)+strtran(cvaltochar(time()),":"))
					lRet := .F.
				EndIf

				End Transaction 
			else
				If Empty(oBody:NUMORC) 
					cDoc := GetSxeNum("SCJ","CJ_NUM")
				else
					cDoc := oBody:NUMORC 
				EndIf 
				aCabec := {}
				aItens := {}
				aItensCad := oBody:ITEMS
				
				aadd(aCabec,{"CJ_NUM"   	,cDoc			,Nil})
				aadd(aCabec,{"CJ_CLIENTE"	,ccnpj			,Nil})
				aadd(aCabec,{"CJ_LOJA"		,cloja			,Nil})
				aadd(aCabec,{"CJ_LOJAENT"	,cloja			,Nil})
				aadd(aCabec,{"CJ_CONDPAG"	,cCondPg		,Nil})

				FOR nX := 1 to len(aItensCad)  
					aLinha := {}
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+aItensCad[nX]:PRODUTO)
					
					nQtd := 0
					If valtype(aItensCad[nX]:QUANTIDADE) == "C"
						nQtd := val(aItensCad[nX]:QUANTIDADE)
					else
						nQtd := aItensCad[nX]:QUANTIDADE
					EndIf 

					aadd(aLinha,{"CK_ITEM"		,StrZero(nX,2)					,Nil})
					aadd(aLinha,{"CK_PRODUTO"	,aItensCad[nX]:PRODUTO			,Nil})
					aadd(aLinha,{"CK_QTDVEN"	,nQtd							,Nil})
					aadd(aLinha,{"CK_PRCVEN"	,val(STRTRAN(aItensCad[nX]:VALOR,",",".")),Nil})
					aadd(aLinha,{"CK_PRUNIT"	,val(STRTRAN(aItensCad[nX]:VALOR,",",".")),Nil})           
					aadd(aLinha,{"CK_VALOR"		,val(STRTRAN(aItensCad[nX]:VALOR,",",".")) * nQtd,Nil})
					
					If aItensCad[nX]:GetJsonObject("BENEF") <> Nil
						If aItensCad[nX]:BENEF == "B"
							aadd(aLinha,{"CK_TES"		, '626'			 				, Nil})
						Else
							aadd(aLinha,{"CK_TES"		, '502'			 				, Nil})
						EndIf 
					else
						aadd(aLinha,{"CK_TES"		, '502'			 				, Nil})
					EndIf 
					
					aadd(aLinha,{"CK_LOCAL"		, SB1->B1_LOCPAD	 			, Nil})
					aadd(aLinha,{"CK_DESCONT"	, VAL(nDescon)			  	 	, Nil})
					
					aadd(aItens, aLinha)

				NEXT      

				lMsErroAuto := .F.            

				Begin Transaction 

						
				MATA415(aCabec,aItens,If(Empty(oBody:NUMORC),3,4))

				If !lMsErroAuto .Or. SCJ->CJ_NUM =cDoc
					ConOut("IncluÌdo com sucesso! " + cDoc)
					ConfirmSX8()
					cPedido := SCJ->CJ_NUM
					//GERHTML(cPedido)
					cMessage := 'NUMORC:'+cDoc
					lRet := .T.
				Else
					cPedido := '400'
					cMessage := 'Erro ao gerar o orÁamento'
					mostraerro('\system\erros_app\','pedido_'+dtos(ddatabase)+strtran(cvaltochar(time()),":"))
					lRet := .F.
				EndIf

				End Transaction 
			EndIf
		

		EndIf
	EndIf
	
	aRetExec := {cPedido,cMessage,cProdsSld}

	RestArea(aArea)

Return oJsonRet


user function xxtes

Local cBody := '{"BODY":"{\"CLIENTE\":{\"CNPJ\":\"01152829000172\",\"INSC_ESTADUAL\":\"43971204          \",\"CODIGO\":\"01152829000172\",\"FILIAL\":\"0001\",\"RAZAO_SOCIAL\":\"OTICA VITORIA DE JUAZEIRO LTDA\",\"NOME_FANTASIA\":\"OTICA VITORIA\",\"ENDERECO\":\"AV. ADOLFO VIANA - ATE 200/201184\",\"BAIRRO\":\"CENTRO\",\"CIDADE\":\"JUAZEIRO\",\"UF\":\"BA\",\"CEP\":\"48903580\",\"CONTATO\":\"DORA\",\"EMAIL\":\"AUXILIADORA@BOL.COM.BR\",\"CELULAR\":\"74 36110325       \",\"FONE2\":\"74 36110325       \",\"ULTIMA_COMPRA\":\"  /  /  \",\"PRIMEIRA_COMPRA\":\"  /  /  \",\"RISCO\":\"A\",\"LIMITE_CREDITO\":\" 10.000,00\",\"SALDO\":\" 10.000,00\",\"MAIOR_COMPRA\":\"      0,00\",\"QTD_COMPRAS\":\"    0\",\"SALDO_DUPL_ABERTO\":\"      0,00\",\"QTD_ATRASOS\":\"   0\",\"MAIOR_ATRASO\":\"   0\",\"QTD_PAGTO_ATRASO\":\"   0\",\"ID\":\"179\"},\"CONDPAGTO\":\"005\",\"DESCONTO\":\"\",\"FORCE\":\"FALSE\",\"ITEMS\":[{\"ID\":6480,\"ITEM\":\"ID\",\"DESCONTO\":0,\"QUANTIDADE\":6,\"PRODUTO\":\"CV-H05 C2\",\"DESCRICAO\":\"ARM METAL 55-17-140/PROM / SALDO DISPONIVEL\",\"VALOR\":\"39,00\",\"TOTAL\":39}],\"VENDEDOR\":\"000019\",\"OBSERVATION\":\"TESTE APP\",\"ORCAMENTO\":\"N\",\"NUMORC\":\"000008\"}"}'
Local oJsonIM 
Local aItens	:=	{}
Local aCliente 	:=	{}
Local aRetExec	:=	{}
Local aErro		:=	{}

If Select("SM0") == 0
	RpcSetType(3)
	RPCSetEnv("01","0103")
EndIf

IF FWJsonDeserialize(cBody,@oJsonIM)
	//IF VALTYPE(oJsonIM:VENDEDOR) == "C"
		oBody  := JsonObject():New()
		oBody:fromJson(oJsonIM:Body)
		cUser 		:= oBody:getJsonText("VENDEDOR")
		cCondPg		:= oBody:getJsonText("CONDPAGTO")
		aItens		:=	oBody:getJsonText("ITEMS")
		aCliente	:=	oBody:getJsonText("CLIENTE")
		//AttIsMemberOf(AARRAY[nCont]:PEDIDO,"NOTA")

		// StatPed(oBody,@aRetExec, @aErro,@aCliente,@aItens,@cUser,@cCondPg)
		//conout(cUser)
		conout(aErro)
		cCode 	:= aRetExec[1]
		cCodUsu := aRetExec[2]
		cPrdSld := aRetExec[3]
		fwJsonSerialize(StatReq(cCode,cCodUsu,cPrdSld))
	//ENDIF
ENDIF

return


/*/{Protheus.doc} HTML
	(long_description)
	@type  Static Function
	@author user
	@since 24/02/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GERHTML(cPedido)

Local cHtml := ''
Local cRemete   := "Marketing Robsol <marketing@robsol.com.br>"                               
Local cSubject	:=	"Pedido de Venda"
Local aArquivos := {}           
Local cDestino	:=	"alexandre.venancio@avsipro.com.br;cnoculos@hotmail.com"
Local lEnviar	:=	.F.

cHtml := '<h1 style="color: #5e9ca0;">Pedido de Venda Gerado!</h1>'
cHtml += '<h2 style="color: #2e6c80;">Seu pedido foi gerado com sucesso!!!</h2>
cHtml += '<p>Seu pedido foi gerado em nossa base e logo estaremos realizando o atendimento para realiza&ccedil;&atilde;o da entrega das mercadorias.</p>
cHtml += '<h2 style="color: #2e6c80;">Informa&ccedil;&otilde;es do pedido: Pedido numero '+cPedido+'</h2>
cHtml += '<table class="editorDemoTable" style="width: 544px; height: 72px;">
cHtml += '<thead>
cHtml += '<tr style="height: 18px;">
cHtml += '<td style="width: 148.188px; height: 18px;">Produto</td>
cHtml += '<td style="width: 231.95px; height: 18px;">Descri&ccedil;&atilde;o</td>
cHtml += '<td style="width: 60.575px; height: 18px;">Qtd</td>
cHtml += '<td style="width: 77.2875px; height: 18px;">Valor</td>
cHtml += '</tr>
cHtml += '</thead>
cHtml += '<tbody>

DbSelectArea("SC6")
DbSetOrder(1)
If Dbseek(xFilial("SC6")+cPedido)
	While !EOF() .And. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cPedido
		cHtml += '<tr style="height: 18px;">
		cHtml += '<td style="width: 148.188px; height: 18px;">'+ALLTRIM(SC6->C6_PRODUTO)+'</td>'
		cHtml += '<td style="width: 231.95px; height: 18px;">'+ALLTRIM(SC6->C6_DESCRI)+'</td>'
		cHtml += '<td style="width: 60.575px; height: 18px;">'+TRANSFORM(SC6->C6_QTDVEN,"@E 9999")+'</td>'
		cHtml += '<td style="width: 77.2875px; height: 18px;">'+TRANSFORM(SC6->C6_PRCVEN,"@E 999,999,999.99")+'</td>'
		cHtml += '</tr>'
		lEnviar := .T.
		Dbskip()
	ENDDO
endif
cHtml += '</tbody>
cHtml += '</table>
cHtml += '<p><strong>&nbsp;</strong></p>
cHtml += '<p>&nbsp;</p>'

If lEnviar
	U_robmail(cRemete,cDestino,cSubject,cHtml,aArquivos,.T.)
EndIf 

Return 

/*/{Protheus.doc} ValSald(oBody:ITEMS)
	(long_description)
	@type  Static Function
	@author user
	@since 04/03/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ValSald(aProds)

Local aArea	:=	GetArea()
Local nX
Local aRet 	:=	{}
Local nSaldo := 0

FOR nX := 1 to len(aProds)  
	aLinha := {}
	nSaldo := 0
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+aProds[nX]:PRODUTO)
	
	DbSelectArea("SB2")
	DbSetOrder(1)
	If DbSeek('0103'+Avkey(aProds[nX]:PRODUTO,"B2_COD")+SB1->B1_LOCPAD)
		nSaldo += SaldoSb2()
	EndIf 
	If DbSeek('0103'+Avkey(aProds[nX]:PRODUTO,"B2_COD")+SB1->B1_LOCPAD)
		nSaldo += SaldoSb2()
	EndIf 

	If nSaldo > 0
		If nSaldo - 10 < If(valtype(aProds[nX]:QUANTIDADE)=="C",val(aProds[nX]:QUANTIDADE),aProds[nX]:QUANTIDADE)
			Aadd(aRet,{aProds[nX]:PRODUTO,nSaldo})
		EndIf
	else
		Aadd(aRet,{aProds[nX]:PRODUTO,0})
	EndIf
	/*If DbSeek(xFilial("SB2")+Avkey(aProds[nX]:PRODUTO,"B2_COD")+SB1->B1_LOCPAD)
		nSaldo := SaldoSb2()

		If nSaldo - 10 < If(valtype(aProds[nX]:QUANTIDADE)=="C",val(aProds[nX]:QUANTIDADE),aProds[nX]:QUANTIDADE)
			Aadd(aRet,{aProds[nX]:PRODUTO,nSaldo})
		EndIf
	Else
		Aadd(aRet,{aProds[nX]:PRODUTO,0})
	EndIf*/
Next nX

RestArea(aArea)
	
Return(aRet)
