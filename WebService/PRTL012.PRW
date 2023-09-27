#Include 'Protheus.ch'
#include "Fileio.ch"
 
#define C_GRUPO  "99"
#define C_FILIAL "01"

User Function PRTL012()

/*Local cTexto := ""
Local aFiles := {} // O array receberá os nomes dos arquivos e do diretório
Local aSizes := {} // O array receberá os tamanhos dos arquivos e do diretorio*/

Local aArquivo  := {}
Local cPathL    := 'c:\afotos\'
Local cPath     :=  '\clientes\cnpj\fotos\' // '\Images\'
Local nCont     :=  1
Local cFile 

If Select("SM0") == 0
	RpcSetType(3)
	RPCSetEnv("01","0101")
EndIf


aArquivo	:= directory(cPathL+"*.jpg","D")		//Varredura no Diretorio padrao onde devem se encontrar os xmls para importacao

For nCont := 1 to len(aArquivo)
    cFile := Lower(aArquivo[nCont][1])
	If Alltrim(cFile) != "." .And. Alltrim(cFile) != ".." .And. aArquivo[nCont,05] <> "D"
		If File(cPathL+cFile,2)
			CpyT2S(cPathL+UPPER(cFile),cPath)
    
            cUrl := "http://portal.robsol.com.br/fotos/" //APIIMGDB(cPath+cFile)
            cImg := upper(substr(cfile,1,at(".",cfile)-1))
            imgReposit(cPath+cFile,cImg,cUrl)
        EndIf
    EndIf
Next nCont
/*

ADir("C:\tmp\download.jpg", aFiles, aSizes)//Verifica o tamanho do arquivo, parâmetro exigido na FRead.

nHandle := fopen('C:\tmp\bb.bmp' , FO_READWRITE + FO_SHARED )
cString := ""

FRead( nHandle, cString, aSizes[1] ) //Carrega na variável cString, a string ASCII do arquivo.

cTexto := Encode64(cString) //Converte o arquivo para BASE64*/

/*
fclose(nHandle)

//Cria uma cópia do arquivo utilizando cTexto em um processo inverso(Decode64) para validar a conversão.    
nHandle := fcreate("C:\tmp\img2.jpg")
FWrite(nHandle, Decode64(cTexto))
fclose(nHandle)*/

Return

/*/{Protheus.doc} APICustJur
    (long_description)
    @type  Static Function
    @author user
    @since 17/01/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function APIIMGDB(cFileName)

Local cRetorno  :=  ""

Local cUrlInt	:=	Alltrim(SuperGetmv('TI_APIIMG',.F.,"http://portal.robsol.com.br")) 

Local cPath     :=  Alltrim(SuperGetmv('TI_ENDIMG',.F.,"/fotos"))

//Local cUsrJ     :=  Alltrim(SuperGetmv('TI_TOKEN',.F.,"2b67a5b957c90906ad43a39a0f4d1249"))

Local nTimeOut := 120
Local aHeadOut := {}
Local cHeadRet := ""
Local cPostRet := ""
Local oJson 

aadd(aHeadOut,'Content-Type: multipart/form-data')

cPostParms := 'Content-Disposition: form-data; name="image"; filename= "'+cFileName+'"' +  CRLF                              //Envio de paramentos. Obrigatório Linha em branco antes do conteúdo

cPostRet := HTTPSPost( cUrlInt+cPath, "", "", "", "", cPostParms, nTimeOut, aHeadOut, @cHeadRet )

oJson := JsonObject():New()
oJson:FromJson(cPostRet)
oJson2 := JsonObject():New()
oJson2:FromJson(oJson:GetJsonText("data"))

cRetorno := oJson2:GetJsonText("display_url")

Return(cRetorno)



 
//-------------------------------------------------------------------
/*{Protheus.doc} imgReposit
Exemplo de utilização da classe FWBmpRep, classe responsável pela
manipulação do repositório de imagens
 
@author Daniel Mendes
@since 12/08/2020
@version 1.0
*/
//-------------------------------------------------------------------
static function imgReposit(cimagem,cfile,cUrl)

local oImgRepo as object
local lInluiu as logical
local cEntry as char
 
//RpcSetEnv(C_GRUPO, C_FILIAL)
 
oImgRepo := FWBmpRep():New()
 
if oImgRepo:OpenRepository()
    lInluiu := .F.
 
    ConOut("Quantidade de registros: ", oImgRepo:RecordCount())
 
    if oImgRepo:ExistBmp(cfile)
        oImgRepo:DeleteBmp(cfile)
    endif
 
    cEntry := oImgRepo:InsertBmp(cimagem ,cfile, @lInluiu)
 
    if lInluiu
        //FErase(cimagem)
        ConOut("Imagem " + cEntry + " inclusa")
        DbSelectArea("SB1")
        DbSetOrder(1)
        If Dbseek(xFilial("SB1")+cfile)
            Reclock("SB1",.F.)
            SB1->B1_BITMAP  := cfile
            SB1->B1_XURLIMG := Alltrim(cUrl)
            SB1->(Msunlock())
        EndIf
 
        /*if oImgRepo:Extract(cEntry, "xisto.jpg")
            ConOut("Imagem " + cEntry + " recuperada")
        else
            ConErr("Erro ao recuperar a imagem " + cEntry)
        endif*/
    else
        ConErr("Erro ao incluir a imagem xisto.jpg")
    endif
 
    oImgRepo:CloseRepository()
endif
 
FreeObj(oImgRepo)
 
//RpcClearEnv()
 
return

user function xfots

Local cTexto := ""
Local aSizes := {}
Local aFiles := {}

If Select("SM0") == 0
	RpcSetType(3)
	RPCSetEnv("01","0101")
EndIf

ADir("C:\afotos\sem_imagem.jpg", aFiles, aSizes)//Verifica o tamanho do arquivo, parâmetro exigido na FRead.

nHandle := fopen('C:\afotos\sem_imagem.jpg' , FO_READWRITE + FO_SHARED )
cString := ""

FRead( nHandle, cString, aSizes[1] ) //Carrega na variável cString, a string ASCII do arquivo.

cTexto := Encode64(cString) //Converte o arquivo para BASE64*/

fclose(nHandle)

//Cria uma cópia do arquivo utilizando cTexto em um processo inverso(Decode64) para validar a conversão.    
nHandle := fcreate("C:\afotos\img2.jpg")

FWrite(nHandle, Decode64(cTexto))

fclose(nHandle)

oImgRepo := FWBmpRep():New()
 
if oImgRepo:OpenRepository()
    lInluiu := .F.
 
    if oImgRepo:ExistBmp(cfile)
        oImgRepo:DeleteBmp(cfile)
    endif
    
ENDIF

return
