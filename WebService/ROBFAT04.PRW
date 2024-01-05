#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lErro        As Logical
Static cChaveLog    As Character

/*/{Protheus.doc} ROBFAT04
	Importação CSV - Baixas Cielo MPN.
	Issue: TICONTIN-1534
	@author Alexandre Venâncio
	@since 07/08/2021

	
/*/
User Function ROBFAT04()

If Empty(FunName())
    RpcSetType(3)
    RPCSetEnv("01","0101")
EndIf

	cChaveLog := 'ROBFAT04'+'_'+DToS(Date())+'_'+Time()+'_'+cUserName
	lErro   := .F.

	fWizard()

Return

/*/{Protheus.doc} fWizard
	Criação do Wizard.
	Issue: TICONTIN-1534
	@author Alexandre Venâncio	
	@since 07/08/2021
/*/
Static Function fWizard()

	Private oStepWiz	As object
	Private oPage1	    As Object
	Private oPage2	    As Object
	Private oPage3	    As Object
	Private oPage4	    As Object

	Private cTargetFile As Character
	Private LNextP1 as Logical
	Private LNextP2 as Logical
	Private LNextP3 as Logical

    Private aItems := {'SB1','SA1','SA2'}
    Private oCombo1
    Private cCombo1:= aItems[1]
	
	
    oStepWiz := FWWizardControl():New(,{600,850})//Instancia a classe FWWizardControl
	oStepWiz:ActiveUISteps()
	LNextP1:= .T.
	LNextP2:= .F.
	LNextP3:= .F.
	//----------------------
	// Pagina 1
	//----------------------
	oPage1 := oStepWiz:AddStep("STEP1",{|Panel| cria_pn1(Panel)}) // Adiciona um Step
	oPage1:SetStepDescription("Importador de arquivos CSV - Robsol") // Define o título do "step"
	oPage1:SetNextTitle("Avancar") // Define o título do botão de avanço
	oPage1:SetNextAction({||LNextP1}) // Define o bloco ao clicar no botão Próximo
	oPage1:SetCancelAction({|| .T.}) // Define o bloco ao clicar no botão Cancelar

	//----------------------
	// Pagina 2
	//----------------------
	oPage2 := oStepWiz:AddStep("STEP2", {|Panel| cria_pn2(Panel)})
	oPage2:SetStepDescription("Selecao do Arquivo CSV")
	oPage2:SetNextTitle("Avançar")
	oPage2:SetPrevTitle("Voltar") // Define o título do botão para retorno
	oPage2:SetNextAction({|| LNextP2  })
	oPage2:SetCancelAction({|| .T.})
	oPage2:SetPrevAction({|| .T.}) //Define o bloco ao clicar no botão Voltar

	//----------------------
	// Pagina 3
	//----------------------
	oPage3 := oStepWiz:AddStep("STEP3", {|| Processa({|| cria_pn3()}, "Aguarde", "Preparando importação...") })
	oPage3:SetStepDescription("Processamento da Importacao")
	oPage3:SetNextTitle("Avançar")
	oPage3:SetNextAction({|| LNextP3  })
	oPage3:SetCancelAction({|| .T.})
	oPage3:SetPrevAction({|| .T.}) //Define o bloco ao clicar no botão Voltar

	//----------------------
	// Pagina 4
	//----------------------
	oPage4 := oStepWiz:AddStep("STEP4", {|Panel| cria_pn4(Panel)})
	oPage4:SetStepDescription("Log de processamento")
	oPage4:SetNextTitle("Finalizar")
	oPage4:SetCancelAction({|| .T.})
	oPage4:SetPrevWhen({||.F.})
	oPage4:SetCancelWhen({||.T.})

	oStepWiz:Activate()

	oStepWiz:Destroy()

Return

/*/{Protheus.doc} cria_pn1
	Criação da primeira página do Wizard.
	Issue: TICONTIN-1534
	@author Alexandre Venâncio	
	@since 07/08/2021
/*/
Static Function cria_pn1( oPanel As Object )

	Local oFont As Object
    
    oFont := TFont():New(,,-25,.T.,.T.,,,,,)

	TSay():New(10,15,{|| "Arquivo de Importacao CSV"},oPanel,,oFont,,,,.T.,CLR_BLUE,)
	TSay():New(45,15,{|| "Clique em proximo para:"},oPanel,,,,,,.T.,CLR_BLUE,)
	TSay():New(65,20,{|| "Selecionar o arquivo CSV a ser importado;"},oPanel,,,,,,.T.,CLR_BLUE,)
	TSay():New(75,20,{|| "Executar a importacao;"},oPanel,,,,,,.T.,CLR_BLUE,)
	TSay():New(85,20,{|| "Visualizar o log de processamento."},oPanel,,,,,,.T.,CLR_BLUE,) 	// '- Efetivar o envio das cartas conforme os dados selecionados.'
    TSay():New(95,20,{|| "O que deseja importar?"},oPanel,,,,,,.T.,CLR_BLUE,)
    
    cCombo1:= aItems[1]   
    oCombo1 := TComboBox():New(105,20,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,100,20,oPanel,,{|| },,,,.T.,,,,,,,,,'cCombo1')

Return

/*/{Protheus.doc} cria_pn2
	Criação da segunda página do Wizard.
	Issue: TICONTIN-1534
	@author Alexandre Venâncio	
	@since 07/08/2021
/*/
Static Function cria_pn2( oPanel As Object )

	cTargetFile := cGetFile('Arquivos CSV|*.CSV', 'Escolha o arquivo',,"C:\",.F., GETF_LOCALHARD,.F.)
	//cTargetFile := tFileDialog( '*.CSV', 'Selecao de Arquivos',, 'C:\', .F., GETF_MULTISELECT )

	TSay():New(35,10,{|| "Arquivo selecionado:"},oPanel,,,,,,.T.,CLR_BLUE,)
	TSay():New(55,15,{|| cTargetFile},oPanel,,,,,,.T.,CLR_BLUE,)

	IF FILE(cTargetFile)
		If !Empty(Alltrim(cTargetFile))
			LNextP2:= .T.
			oPage2:SetNextAction({|| LNextP2  })
			oStepWiz:NextPage()

		EndIf
	Else
 
		if !MsgYesNo("Arquivo selecionado nao encontrado!, Deseja Sair da rotina?")
			cria_pn2( oPanel )
		EndIF
	EndIF
Return .T.

/*/{Protheus.doc} cria_pn3
	Importação do arquivo CSV
    Issue: TICONTIN-1534
	@author Alexandre Venâncio	
	@since 22/04/2021
/*/
Static Function cria_pn3()

	Local cLinha    As Character
	Local nTot      As Numeric
	Local aCampos   As Array
	Local nL        As Numeric
	Local lRet      As Logical
	Local aAux      As Array
	Local aCpoRef	As Array
	// Local nCont 	As Numeric
	
	Private aDados    As Array
	
	aDados  := {}
	lRet    := .T.
	nL      := 1

	lErro := .F.

    If cCombo1 == "SB1"
        //obrigatorio {B1_COD;B1_DESC;B1_TIPO;B1_UM;B1_LOCPAD}  ;opcionais [B1_IPI;B1_POSIPI;B1_PESO;B1_ORIGEM;B1_CODBAR]
        aCpoRef := {'B1_COD',;
                    'B1_DESC',;
                    'B1_TIPO',;
                    'B1_UM',;
                    'B1_LOCPAD'}
					
	ElseIf cCombo1 == "SA1"
		//obrigatorio {A1_COD;A1_NOME}  ;opcionais [A1_XXX]
	Else
		MsgStop("Tipo de arquivo invalido")
		lErro := .T.
    EndIf

	
	If !lErro
		FT_FUSE(cTargetFile)
		FT_FGOTOP()

		nTot := FT_FLASTREC()
		ProcRegua(nTot)

		While !FT_FEOF()

			IncProc()
			cLinha := FT_FREADLN()

			If nL == 1
				aCampos := Separa(cLinha,";",.T.)
			Else
				aAux := aClone(Separa(cLinha,";",.T.))
				If Len(aAux) > 0
					AADD(aDados,aAux)
				EndIF
			EndIf
		
			nL++

			FT_FSKIP()
		EndDo

		For nL := 1 To Len(aCpoRef)

			If Ascan(aCampos,{|x| Alltrim(x) $ Alltrim(aCpoRef[nL]) }) == 0 
				MsgStop("Campo obrigatorio faltando no arquivo: "+aCpoRef[nL])
				lErro := .T.
			EndIf

		Next
	EndIf

	If lErro

		MsgALert("Corrija a(s) coluna(s) do arquivo e selecione-o novamente!")
		oStepWiz:PreviousPage()

	Else

		If cCombo1 == "SB1"
			//cIds := ""
			
            For nL := 1 to len(aDados)
                lRet := Processa({|| criasb1(aCampos,nL)},"Aguarde Processando linha "+cvaltochar(nL))
            Next nL
			
			LNextP3:= .T.
			oPage3:SetNextAction({|| LNextP3  })

			oStepWiz:NextPage()
		//ElseIF cCombo1 == "SA1"
		//ElseIF cCombo1 == "SA2"
		EndIf

	EndIf

Return Nil


/*/{Protheus.doc} cria_pn4
	Visualização do log de processamento.
    Issue: TICONTIN-1534
	@author Alexandre Venâncio	
	@since 24/04/2021
/*/
Static Function cria_pn4( oPanel As Object )

	Local oBtnLog	As Object
	Local oFont		As Object

	oFont := TFont():New(,,-25,.T.,.T.,,,,,)

	// Apresenta o tSay com a fonte Courier New
	If lErro

		TSay():New(10,15,{|| "Importação finalizada com erro"},oPanel,,oFont,,,,.T.,CLR_RED,)

	Else

		TSay():New(10,15,{|| "Importação finalizada com sucesso!"},oPanel,,oFont,,,,.T.,CLR_GREEN,)

	EndIf

	TSay():New(35,15,{|| "Clique no botão abaixo para visualizar o log de processamento."},oPanel,,,,,,.T.,CLR_BLUE,)

	oBtnLog := TButton():New(50,15, "Visualizar",oPanel,{|| ProcLogView(cFilAnt, AvKey(cChaveLog,"CV8_PROC"))}, 60,20,,,.F.,.T.,.F.,,.F.,,,.F. )

Return

 /*/{Protheus.doc} criasb1
    (long_description)
    @type  Static Function
    @author user
    @since 17/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function criasb1(aCampos,nLinha)

Local aArea :=  GetArea()
Local lRet  :=  .T.
Local aVetor:=  {}
Local nCont :=  1
Local aAux	:= 	{}

private lMsErroAuto := .F.

For nCont := 1 to len(aCampos)
	aAux := FWSX3Util():GetFieldStruct( aCampos[nCont] )
    Aadd(aVetor,{aCampos[nCont],If(aAux[2] == "N",val(aDados[nLinha,nCont]),aDados[nLinha,nCont]),Nil})
Next nCont

MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
 
If lMsErroAuto
    lRet := .F.
	mostraerro()
    fGravaLog("Falha na tentativa de criacao do produto na Linha do CSV: "+cvaltochar(nLinha+1), '', .F.)
Else
    lRet := .t.
    fGravaLog("Sucesso na criacao do produto na Linha do CSV: "+cvaltochar(nLinha+1), '', .T.)
Endif

RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} fGravaLog
	Gravação do log de processamento.
    Issue: TICONTIN-1534
	@author Alexandre Venâncio	
	@since 24/04/2021
/*/
Static Function fGravaLog(cMsg, cDetalhe, lOk)

	Local cIdMov := GetSXENum("CV8","CV8_IDMOV",,5)

	Default cDetalhe := ''

	CV8->(RecLock("CV8",.T.))

	CV8->CV8_FILIAL	:= xFilial("CV8")
	CV8->CV8_DATA	:= Date()
	CV8->CV8_HORA	:= SubStr(Time(),1,5)
	CV8->CV8_USER	:= cUserName
	CV8->CV8_MSG	:= cMsg
	CV8->CV8_DET	:= cDetalhe
	CV8->CV8_PROC	:= cChaveLog
	CV8->CV8_SBPROC	:= "ROBFAT04"
	CV8->CV8_IDMOV	:= cIdMov
	CV8->CV8_INFO	:= IIF(lOk, '6', '4')

	CV8->(MsUnlock())

	ConfirmSx8()

Return

/*/{Protheus.doc} SrvXGetMostraErro
Retorna conteudo da mensagem do MostraErro()
@author totvs
@since 13/08/2015
@version 1.0
/*/
User Function GetErro()
Local cPath	:= GetSrvProfString("Startpath","")
Local cArq	:= "Erro_Rot_Auto_"+Dtos(dDataBase)+"_"+StrTran(Time(),":","_")+Alltrim(Str(ThreadID()))+".txt"
Local cRet	:= ""

MostraErro( cPath , cArq )
cRet := StrTran(MemoRead(  cPath + '\' + cArq ),Chr(13) + Chr(10)," ")
cRet := StrTran(cRet, '"', "'")
fErase(cArq)

Return cRet
