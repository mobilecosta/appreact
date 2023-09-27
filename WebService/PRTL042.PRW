#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE "FWMVCDEF.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} PRTL042
Descricao: Serviço API Rest Evento Catalogos

@author Alexandre Venâncio
@since 21/09/2021
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
USER Function PRTL042()
Return

// Servico.
WsRestFul Mural DESCRIPTION "API REST - EVENTO MURAL | PORTAL ROBSOL " 
	
    WSDATA NOTICIA As String

	WsMethod GET Description "Retorna as noticias do mural disponíveis para visualização" WSSYNTAX "/Mural " 

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
WsMethod GET WsReceive NOTICIA WsService Mural

	
	Local cNoticia 	:= Self:NOTICIA
	Local aArea		:= GetArea()
	Local nCont		:= 0
	Local cVirg		:= ""
	Local aAux		:= {}
    Local cPage     := '1'
    Local cPathc    := '' 


	lRet					:= .T.

	::SetContentType("application/json")
	
	RpcSetType(3)
	RPCSetEnv("01","0101")
	
    conout("chegou aqui PRTL042")

	DbSelectArea("Z42")
	Z42->(DBSetOrder(1))
	Z42->(DBGoTOP())

    ::SetResponse('{')
    ::SetResponse('"items": [')
    
    cQuery := "SELECT 

    cQuery += " Z42_CODIGO,Z42_SUBJEC,Z42_DTINI,ISNULL(CAST(CAST(Z42_CONTEU AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS"
    cQuery += " FROM "+RetSQLName("Z42")+ " Z42"
    
    cQuery += " WHERE Z42.D_E_L_E_T_=' ' AND Z42_MSBLQL<>'1' AND Z42_DTINI<='"+dtos(ddatabase)+"'"
    
    cQuery += " AND (Z42_DTFIM>='"+dtos(ddatabase)+"' OR Z42_DTFIM=' ')"
    
    cQuery += " ORDER BY Z42_CODIGO DESC"

    If Select('TRB') > 0
        dbSelectArea('TRB')
        dbCloseArea()
    EndIf

    DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), "TRB", .F., .T. )

    DbSelectArea("TRB")

    While !EOF()
        Aadd(aAux,{	TRB->Z42_CODIGO,TRB->Z42_SUBJEC,TRB->OBS,cvaltochar(STOD(TRB->Z42_DTINI))})
        Dbskip()
    ENDDO

    Asort(aAux,,,{|x,y| x[1] < y[1]})

    For nCont := 1 to len(aAux)
        ::SetResponse(cVirg+'{')
        ::SetResponse('"codigo":"'+aAux[nCont,01]+'",')
        ::SetResponse('"assunto":"'+aAux[nCont,02]+'",')
        ::SetResponse('"conteudo":"'+Alltrim(aAux[nCont,03])+'",')
        ::SetResponse('"data_publicacao":"'+aAux[nCont,04]+'"')
        ::SetResponse('}')
        cVirg := ','
    Next nCont
    

    ::SetResponse(']')
    ::SetResponse('}')


	RestArea(aArea)

	
Return lRet
