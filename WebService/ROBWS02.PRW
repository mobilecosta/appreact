#INCLUDE "RPTDEF.CH"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} ROBWS02
Efetua a consuta de fretes na API do Correio.
@author AVSI Pro
@since 23/11/2021
@version 1
@param clUserID, C , Usuário da API
@param clPassword, C , Senha da API 
@return aRet , A , Array com o modelo a gravar 
@example
(examples)
@see (links_or_references)
/*/
User Function ROBWS02(cJson)

Local cRetorno  :=  ""
Local oXml
Local cError    :=  ""
Local cWarning  :=  ""
Local cGetRet 

Local cUrlInt	:=	Alltrim(SuperGetmv('TI_APICORR',.F.,"http://ws.correios.com.br/calculador/CalcPrecoPrazo.aspx")) 

cGetRet := Httpget(cUrlInt+cJson)

if !empty(cGetRet) 
    oXml := XmlParser(cGetRet , "_" , @cError , @cWarning )

    If valtype(oXml) == "O"
        If XmlChildEx( oXml:_SERVICOS:_CSERVICO,"_PRAZOENTREGA") != Nil
            cPrazo := oXml:_SERVICOS:_CSERVICO:_PRAZOENTREGA:TEXT
        EndIf
        If XmlChildEx( oXml:_SERVICOS:_CSERVICO,"_VALOR") != Nil
            nValor := strtran(oXml:_SERVICOS:_CSERVICO:_VALOR:TEXT,",",".")
        EndIf     
        
        cRetorno := cvaltochar(cPrazo) + ";" + cvaltochar(nValor)
    Else
        cRetorno := "ERRO_TENTAR_NOVAMENTE;0"
    EndIf
else    
    cRetorno := "ERRO_TENTAR_NOVAMENTE;0"
endif

Return(cRetorno)
