#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL031
Descricao: Serviço API Rest Evento Notas

@author Alexandre Venancio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL031()
Return

// Serviço.
WsRestFul Invoice DESCRIPTION "API REST - EVENTO Notas | PORTAL ROBSOL " 
	
	WSDATA CODIGO As String 
    WSDATA SERIE As String
	WSDATA PAGINA As String 
	WSDATA EMISSAO As String
	WSDATA COD_CLIENTE As String
	WSDATA NOME As String
	WSDATA VALOR As String
	WSDATA VENDEDOR As String

	WsMethod GET Description "Retorna o Cliente especifico ou cadastro todo" WSSYNTAX "/Invoice || /Invoice/{CODIGO}" 

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
WsMethod GET WsReceive CODIGO,SERIE,PAGINA,VENDEDOR,EMISSAO,COD_CLIENTE,NOME,VALOR WsService Invoice

	Local cCode 	:= Self:CODIGO
    Local cSerie    := Self:SERIE
	Local cEmissao 	:= Self:EMISSAO
	Local cCliente 	:= Self:COD_CLIENTE
	Local cNome 	:= Self:NOME
	Local nValor 	:= Self:VALOR
	Local CodVend 	:= Self:VENDEDOR
	Local cPage 	:= Self:PAGINA
	Local aArea		:= GetArea()
	Local nCont		:= 0
	Local cVirg		:= ''
	Local aAux		:= {}

	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
	conout("chegou aqui PRTL031")

	DbSelectArea("SF2")
	SF2->(DBSetOrder(1))
	SF2->(DBGoTOP())
    
	DbSelectArea("SD2")
	SD2->(DBSetOrder(3))
	SD2->(DBGoTOP())

	If !Empty(cSerie) .Or. !Empty(cEmissao) .Or. !Empty(cCliente) .Or. !Empty(cNome) .Or. !Empty(nValor)
		cCode := ""
	EndIf
    
	If !Empty(cCode)
		If SF2->(DBSeek(xFilial("SF2")+Avkey(cCode,"F2_DOC")+Avkey(cSerie,"F2_SERIE")))
			::SetResponse('{')
			            
            ::SetResponse('"items": [')
            
            SD2->(DBSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
            
            cVirg := ""

            While !EOF() .And. SD2->D2_FILIAL == SF2->F2_FILIAL .AND. SD2->D2_DOC == SF2->F2_DOC ;
                        .AND. SD2->D2_SERIE == SF2->F2_SERIE .AND. SD2->D2_CLIENTE == SF2->F2_CLIENTE
                ::SetResponse(cVirg+'{')
				::SetResponse('"filial":"'+Alltrim(SD2->D2_FILIAL)+'",')
                ::SetResponse('"codigo":"'+Alltrim(SD2->D2_COD)+'",')
                ::SetResponse('"descricao":"'+Alltrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC"))+'",')
                ::SetResponse('"quantidade":"'+cvaltochar(SD2->D2_QUANT)+'",')
                ::SetResponse('"valor_unit":"'+Transform(SD2->D2_PRCVEN,"@E 999,999,999.99")+'",')
                ::SetResponse('"valor_total":"'+Transform(SD2->D2_TOTAL,"@E 999,999,999.99")+'",')
                ::SetResponse('"valor_ipi":"'+Transform(SD2->D2_VALIPI,"@E 999,999,999.99")+'",')
                ::SetResponse('"valor_icms":"'+Transform(SD2->D2_VALICM,"@E 999,999,999.99")+'",')
				::SetResponse('"id":"'+cvaltochar(SD2->(Recno()))+'"')
                ::SetResponse('}')
                cVirg := ','
                DBSkip()
            EndDo
            
		    ::SetResponse(']')
			::SetResponse('}')
		Else
			::SetResponse('{"codigo":"'+cCode+'","Erro":"Nota nao encontrado"}')
		EndIf
	ELSE
		::SetResponse('{')
		::SetResponse('"items": [')

		If !Empty(cSerie) .Or. !Empty(cEmissao) .Or. !Empty(cCliente) .Or. !Empty(cNome) .Or. !Empty(nValor)
			cQuery := "SELECT *"
			cQuery += " FROM ( SELECT "
		Else
			cQuery := "SELECT TOP(50) *"
			cQuery += " FROM("
			cQuery += " SELECT TOP("+If(!Empty(cPage),cvaltochar(val(cPage)*50),'50')+")"
		EndIf

		cQuery += " F2_DOC,F2_SERIE,F2_CLIENTE,F2_LOJA,A1_NOME,A1_NREDUZ,A1_END,A1_MUN,F2_COND,"
		cQuery += " F2_VEND1,F2_EMISSAO,F2_VALBRUT,F2_FILIAL,F2.R_E_C_N_O_ AS RECF2"
		cQuery += " FROM "+RetSQLName("SF2")+" F2"
		cQuery += " INNER JOIN "+RetSQLName("SA1")+" A1 ON A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD=F2_CLIENTE AND A1_LOJA=F2_LOJA AND A1.D_E_L_E_T_=' '"
		
		If !Empty(cCliente)
			cQuery += " AND A1_COD+A1_LOJA = '"+cCliente+"'"
		endIf	

		If !Empty(cNome)
			cQuery += " AND A1_NOME LIKE '%"+upper(Alltrim(cNome))+"%'"
		EndIf

		cQuery += " WHERE F2_FILIAL='"+xFilial("SF2")+"' AND F2_VEND1='"+CodVend+"' AND F2.D_E_L_E_T_=' '"

		If !Empty(cEmissao)
			cQuery += " AND F2_EMISSAO='"+dtos(ctod(cEmissao))+"'"
		ENDIF

		If !Empty(cSerie)
			cQuery += " AND F2_SERIE='"+Alltrim(cSerie)+"'"
		EndIF

		If !Empty(nValor)
			cQuery += " AND F2_VALBRUT="+strtran(strtran(nValor,"."),",",".")
		EndIf

		If !Empty(cSerie) .Or. !Empty(cEmissao) .Or. !Empty(cCliente) .Or. !Empty(cNome) .Or. !Empty(nValor)
			cQuery += " ) TMP"
		ELSE
			cQuery += " ORDER BY F2_DOC) TMP"
		ENDIF

		cQuery += " ORDER BY F2_DOC DESC"

		If Select('TRB') > 0
			dbSelectArea('TRB')
			dbCloseArea()
		EndIf

		DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

		DbSelectArea("TRB")

		While !EOF()
			Aadd(aAux,{	TRB->F2_DOC,TRB->F2_SERIE,TRB->F2_CLIENTE+TRB->F2_LOJA,TRB->A1_NOME,;
						TRB->A1_NREDUZ,TRB->F2_EMISSAO,TRB->F2_VALBRUT,TRB->F2_FILIAL,TRB->RECF2})
			Dbskip()
		EndDo

		Asort(aAux,,,{|x,y| x[2] < y[2]})

		For nCont := 1 to len(aAux)
			::SetResponse(cVirg+'{')
			::SetResponse('"filial":"'+aAux[nCont,08]+'",')
			::SetResponse('"codigo":"'+aAux[nCont,01]+'",')
			::SetResponse('"serie":"'+aAux[nCont,02]+'",')
			::SetResponse('"emissao":"'+cvaltochar(stod(aAux[nCont,06]))+'",')
			::SetResponse('"cod_cliente":"'+aAux[nCont,03]+'",')
            ::SetResponse('"nome":"'+Alltrim(aAux[nCont,04])+'",')
            ::SetResponse('"valor":"'+Transform(aAux[nCont,07],"@E 999,999,999.99")+'",')
			::SetResponse('"id":"'+cvaltochar(aAux[nCont,09])+'"')
			::SetResponse('}')
			cVirg := ','
		Next nCont
		
		::SetResponse(']')
		::SetResponse('}')
	EndIf

	RestArea(aArea)

	
Return lRet
