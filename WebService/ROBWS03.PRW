#INCLUDE "RPTDEF.CH"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} ROBWS03
Efetua a consuta de fretes na API da Braspress.
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
User Function ROBWS03(cJson)

Local aHeader   :=  {}
Local cRetorno  :=  ""
Local oJson     := JsonObject():New()     

Local cUrlInt	:=	Alltrim(SuperGetmv('TI_APIJAD',.F.,"www.jadlog.com.br")) 

Local cPath     :=  Alltrim(SuperGetmv('TI_ENDPJAD',.F.,"/embarcador/api/frete/valor"))

Local cToken    :=  Alltrim(SuperGetmv('TI_TOKEJAD',.F.,"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOjExMjY4NCwiZHQiOiIyMDIxMTEyNiJ9.JXE9oSmH5zucROyyow1St8W8-TMgm2OEVhrde00iBo4"))
Local nTimeOut := 120
Local cHeadRet := ""

/*
Usuário: 23824405000140
Senha: BVj1QGf
Código Cliente: 112684
Número de TOKEN: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOjExMjY4NCwiZHQiOiIyMDIxMTEyNiJ9.JXE9oSmH5zucROyyow1St8W8-TMgm2OEVhrde00iBo4
Número de contrato (Se correntista):
Código da Franquia (ponto):1331

*/

aadd(aHeader,'Content-Type: application/json')
aadd(aHeader,'Authorization: Bearer ' + cToken)


sPostRet := HttpPost(cUrlInt+cPath,"",cJson,nTimeOut,aHeader,@cHeadRet)

/*oRest := FWREST():New(cUrlInt)
oRest:SetPath(cPath)
//Seta o JSON como parametro
If EncodeUtf8(cJson) <> Nil
    cJson := EncodeUtf8(cJson)
EndIf

oRest:SetPostParams(cJson)
lRet := oRest:Post(aHeader)
 
//Verifico se existe conteudo de retorno
If oRest:GetResult() == Nil

Else
    cResult := oRest:GetResult()
EndIf
*/
if !empty(sPostRet) .And. !'503 Service Unavailable' $ sPostRet
    //ret := oJson:FromJson(sPostRet)
    FWJsonDeserialize( sPostRet ,@oJSon)
    if ValType(oJSon) == "O"
        If AttIsMemberOf(oJson:FRETE[1], "ERROR")
            cRetorno := "1;ERRO"+oJson:FRETE[1]:ERROR:DESCRICAO+";0"
        Else
            cRetorno := cvaltochar(oJson:FRETE[1]:PRAZO) + ";" + cvaltochar(oJson:FRETE[1]:VLTOTAL)
        EndIf
    EndIf
else
    cRetorno := "1;ERRO_TENTAR_NOVAMENTE;0"
endif

Return(cRetorno)
