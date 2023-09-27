#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL032
Descricao: Serviço API Rest Evento Notas do cliente para chamado

@author Alexandre Venancio
@since 13/01/2022
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL032()
Return

// Serviço.
WsRestFul FieldService DESCRIPTION "API REST - EVENTO Notas | PORTAL ROBSOL " 
	
	WSDATA CODIGO As String 
    WSDATA COD_CLIENTE As String
	WSDATA LOJA_CLIENTE As String
	WSDATA NOTA As String

	WsMethod GET Description "Retorna o Cliente especifico ou cadastro todo" WSSYNTAX "/FieldService || /FieldService/{CODIGO}" 

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
WsMethod GET WsReceive CODIGO,COD_CLIENTE,LOJA_CLIENTE,NOTA WsService FieldService

	Local cCode 	:= Self:CODIGO
    Local cCliente 	:= Self:COD_CLIENTE
	Local cLojCli 	:= Self:LOJA_CLIENTE
	Local cNota 	:= Self:NOTA
	Local aArea		:= GetArea()
	Local nCont		:= 0
	Local cVirg		:= ''
	Local aAux		:= {}

	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	conout("chegou aqui PRTL032")
	conout(cCode)
	conout(cCliente)
	conout(cLojCli)

	IF valtype(cNota) == 'U'
		cNota := ''
	ENDIF 

	DbSelectArea("SF2")
	SF2->(DBSetOrder(1))
	SF2->(DBGoTOP())
    
	DbSelectArea("SD2")
	SD2->(DBSetOrder(3))
	SD2->(DBGoTOP())

    

	::SetResponse('{')
	::SetResponse('"items": [')

	cQuery := "SELECT D2_DOC,D2_SERIE,D2_QUANT,D2_PRCVEN,D2_CF,D2_FILIAL,D2_EMISSAO,D2_COD,D2_ITEM,"
	cQuery += " X5_DESCRI,D2_BASEICM,D2_VALICM,D2_VALIPI,F2_CHVNFE,M0_NOMECOM,"
	cQuery += " M0_ENDENT,M0_COMPENT,M0_BAIRENT,M0_CIDENT,M0_ESTENT,M0_CGC,M0_INSC,M0_CEPENT "
	cQuery += " FROM "+RetSQLName("SD2")+" D2"
	cQuery += " INNER JOIN "+RetSQLName("SF2")+" F2 ON F2_FILIAL=D2_FILIAL"
	cQuery += "    AND F2_DOC=D2_DOC AND F2_SERIE=D2_SERIE AND F2_CLIENT=D2_CLIENTE"
	cQuery += "    AND F2_LOJA=D2_LOJA AND F2.D_E_L_E_T_=' '"
	cQuery += " INNER JOIN "+RetSQLName("SX5")+" X5 ON X5_FILIAL='"+xFilial("SX5")+"'"
	cQuery += "    AND X5_TABELA='13' AND X5_CHAVE=D2_CF AND X5.D_E_L_E_T_=' '"
	cQuery += " INNER JOIN SYS_COMPANY M0 ON M0_CODIGO='01' AND M0_CODFIL=D2_FILIAL AND M0.D_E_L_E_T_=' '"
	cQuery += " WHERE D2_FILIAL BETWEEN ' ' AND 'ZZ'"
	cQuery += " AND D2_COD='"+cCode+"'"
	cQuery += " AND D2_CLIENTE='"+cCliente+"' AND D2_LOJA='"+cLojCli+"'"
	//cQuery += " AND D2_CLIENTE = '44667313'" //05290313
	If !Empty(cNota)
		cQuery += " AND D2_DOC='"+cNota+"'"
	EndIf
	
	cQuery += " AND D2.D_E_L_E_T_=' '"

	CONOUT(cQuery)
	
	If Select('TRB') > 0
		dbSelectArea('TRB')
		dbCloseArea()
	EndIf

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

	DbSelectArea("TRB")

	While !EOF()
		Aadd(aAux,{ TRB->D2_DOC,;
					TRB->D2_EMISSAO,;
					TRB->D2_SERIE,;
					TRB->D2_QUANT,;
					TRB->D2_PRCVEN,;
					TRB->D2_CF+"-"+Alltrim(TRB->X5_DESCRI),;
					TRB->D2_BASEICM,;
					TRB->D2_VALICM,;
					TRB->D2_VALIPI,;
					TRB->F2_CHVNFE,;
					Alltrim(TRB->M0_NOMECOM),;
					Alltrim(TRB->M0_ENDENT)+', '+Alltrim(TRB->M0_COMPENT),;
					Alltrim(TRB->M0_BAIRENT),;
					Alltrim(TRB->M0_CIDENT),;
					TRB->M0_ESTENT,;
					TRB->M0_CGC,;
					TRB->M0_INSC,;
					TRB->D2_FILIAL,;
					TRB->D2_COD,;
					TRB->D2_ITEM,;
					TRB->M0_CEPENT})
		Dbskip()
	EndDo

	cQuery := "SELECT Z53_DOC,Z53_SERIE,Z53_QUANT,Z53_PRCVEN,Z53_CF,Z53_FILIAL,Z53_EMISSA,Z53_COD,Z53_ITEM,"
	cQuery += " ' ' AS X5_DESCRI,Z53_BASEIC,Z53_VALICM,Z53_VALIPI,Z52_CHVNFE,M0_NOMECOM,"
	cQuery += " M0_ENDENT,M0_COMPENT,M0_BAIRENT,M0_CIDENT,M0_ESTENT,M0_CGC,M0_INSC,M0_CEPENT "
	cQuery += " FROM "+RetSQLName("Z53")+" Z53"
	cQuery += " INNER JOIN "+RetSQLName("Z52")+" Z52 ON Z52_FILIAL=Z53_FILIAL"
	cQuery += "    AND Z52_DOC=Z53_DOC AND Z52_SERIE=Z53_SERIE AND Z52_CLIENT=Z53_CLIENT"
	cQuery += "    AND Z52_LOJA=Z53_LOJA AND Z52.D_E_L_E_T_=' '"
	cQuery += " INNER JOIN SYS_COMPANY M0 ON M0_CODIGO='01' AND M0_CODFIL=Z53_FILIAL AND M0.D_E_L_E_T_=' '"
	cQuery += " LEFT JOIN "+RetSQLName("SX5")+" X5 ON X5_FILIAL='"+xFilial("SX5")+"'"
	cQuery += "    AND X5_TABELA='13' AND X5_CHAVE=Z53_CF AND X5.D_E_L_E_T_=' '"
	cQuery += " WHERE Z53_FILIAL BETWEEN ' ' AND 'ZZ'"
	cQuery += " AND Z53_COD='"+cCode+"'"
	cQuery += " AND Z53_CLIENT='"+cCliente+"' AND Z53_LOJA='"+cLojCli+"'"
	If !Empty(cNota)
		cQuery += " AND Z53_DOC='"+cNota+"'"
	EndIf

	cQuery += " AND Z53.D_E_L_E_T_=' '"

	CONOUT(cQuery)

	If Select('TRB') > 0
		dbSelectArea('TRB')
		dbCloseArea()
	EndIf

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

	DbSelectArea("TRB")

	While !EOF()
		Aadd(aAux,{ TRB->Z53_DOC,;
					TRB->Z53_EMISSA,;
					TRB->Z53_SERIE,;
					TRB->Z53_QUANT,;
					TRB->Z53_PRCVEN,;
					TRB->Z53_CF+"-"+Alltrim(TRB->X5_DESCRI),;
					TRB->Z53_BASEIC,;
					TRB->Z53_VALICM,;
					TRB->Z53_VALIPI,;
					TRB->Z52_CHVNFE,;
					Alltrim(TRB->M0_NOMECOM),;
					Alltrim(TRB->M0_ENDENT)+', '+Alltrim(TRB->M0_COMPENT),;
					Alltrim(TRB->M0_BAIRENT),;
					Alltrim(TRB->M0_CIDENT),;
					TRB->M0_ESTENT,;
					TRB->M0_CGC,;
					TRB->M0_INSC,;
					TRB->Z53_FILIAL,;
					TRB->Z53_COD,;
					TRB->Z53_ITEM,;
					TRB->M0_CEPENT})
		Dbskip()
	EndDo
	
	Asort(aAux,,,{|x,y| x[1] < y[1]})

	For nCont := 1 to len(aAux)
		::SetResponse(cVirg+'{')
		::SetResponse('"nota":"'+aAux[nCont,01]+'",')
		::SetResponse('"emissao":"'+cvaltochar(stod(aAux[nCont,02]))+'",')
		::SetResponse('"serie":"'+aAux[nCont,03]+'",')
		::SetResponse('"quantidade":"'+cvaltochar(aAux[nCont,04])+'",')
		::SetResponse('"preco":"'+transform(aAux[nCont,05],"@E 999,999,999.99")+'",')
		::SetResponse('"desc_cfop":"'+aAux[nCont,06]+'",')
		::SetResponse('"base_icm":"'+Transform(aAux[nCont,07],"@E 999,999,999.99")+'",')
		::SetResponse('"valor_icm":"'+Transform(aAux[nCont,08],"@E 999,999,999.99")+'",')
		::SetResponse('"valor_ipi":"'+Transform(aAux[nCont,09],"@E 999,999,999.99")+'",')
		::SetResponse('"chave_nfe":"'+aAux[nCont,10]+'",')
		::SetResponse('"nome_empresa":"'+aAux[nCont,11]+'",')
		::SetResponse('"endereco_empresa":"'+aAux[nCont,12]+'",')
		::SetResponse('"bairro_empresa":"'+aAux[nCont,13]+'",')
		::SetResponse('"cidade_empresa":"'+aAux[nCont,14]+'",')
		::SetResponse('"cep_empresa":"'+aAux[nCont,21]+'",')
		::SetResponse('"estado_empresa":"'+aAux[nCont,15]+'",')
		::SetResponse('"cnpj":"'+aAux[nCont,16]+'",')
		::SetResponse('"inscr_estadual":"'+aAux[nCont,17]+'",')
		::SetResponse('"filial_faturamento":"'+aAux[nCont,18]+'",')
		::SetResponse('"cod_produto":"'+aAux[nCont,19]+'",')
		::SetResponse('"item":"'+aAux[nCont,20]+'"')
		::SetResponse('}')

		cVirg := ','
	Next nCont
	
	::SetResponse(']')
	::SetResponse('}')


	RestArea(aArea)

	
Return lRet
