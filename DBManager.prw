#Include "Protheus.ch"
#Include "TopConn.ch"

User Function DBManager()

Private oDlgManager := Nil
Private cQuery      := Space(1)
Private oPanelQry   := Nil
Private oPanelBrw   := Nil
Private oPanelTree  := Nil
Private oPanelButt  := Nil

SetKey( VK_F5, {|| DBPrepStat() } )

DBShowDlg()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DbShowDlg
Monta a tela 
@author  Victor Andrade
@since   21/03/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function DBShowDlg()

Local oLayer     := FWLayer():New()
Local aSize	     := MsAdvSize(.T.)
Local oImgExcel  := Nil
Local oImgOpen   := Nil
Local oImgPlay   := Nil

DEFINE MSDIALOG oDlgManager FROM aSize[7], 0 TO aSize[6] , aSize[5] TITLE "Management Studio" OF oMainWnd PIXEL

oLayer:Init(oDlgManager, .F.)

oLayer:AddLine( "BOTOES"     , 10   , .F., )
oLayer:AddLine( "CONTEUDO"   , 90   , .F., )

oLayer:AddColumn( "FULLOPC"      , 100   , .F., "BOTOES"   )
oLayer:AddColumn( "LEFTTREE"     , 20    , .F., "CONTEUDO" )
oLayer:AddColumn( "RIGHTINFO"    , 80    , .F., "CONTEUDO" )

oLayer:AddWindow( "LEFTTREE"  , "WINSTRUCT", "Pesquisador Objetos"   , 100  , .F., .T., , "CONTEUDO", ) 
oLayer:AddWindow( "RIGHTINFO" , "WINQUERY" , "SQL Query"             , 35   , .F., .T., , "CONTEUDO", )
oLayer:AddWindow( "RIGHTINFO" , "WINRESULT", "Resultado"             , 65   , .F., .T., , "CONTEUDO", )

oPanelTree  := oLayer:GetWinPanel("LEFTTREE" , "WINSTRUCT", "CONTEUDO" )
oPanelQry   := oLayer:GetWinPanel("RIGHTINFO" , "WINQUERY", "CONTEUDO" )
oPanelBrw   := oLayer:GetWinPanel("RIGHTINFO" , "WINRESULT","CONTEUDO" )
oPanelButt  := oLayer:GetLinePanel( "BOTOES" )

oImgOpen   := TBitmap():New(05,05,32,32,,"",.T.,oPanelButt,{ ||Alert("Clique em Excel") },,.F.,.F.,,,.F.,,.T.,,.F.)
oImgOpen:cResName := "totvsprinter_disco.png"

oImgPlay   := TBitmap():New(05,30,32,32,,"",.T.,oPanelButt,{ ||Alert("Clique em Excel") },,.F.,.F.,,,.F.,,.T.,,.F.)
oImgPlay:cResName := "play.png"

oImgExcel   := TBitmap():New(03,50,32,32,,"",.T.,oPanelButt,{ ||Alert("Clique em Excel") },,.F.,.F.,,,.F.,,.T.,,.F.)
oImgExcel:cResName := "totvsprinter_excel.png"

tMultiget():New(001,001,{ |u| Iif( Pcount() > 0, cQuery := u ,cQuery ) },;
                oPanelQry,530,065,,,,,,.T.,,,,,,.F.,,,,,.T.,"",1,,CLR_GREEN)

ACTIVATE MSDIALOG oDlgManager CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DBPrepStat
Executa o "Preparede Stetemend"
@author  Victor Andrade
@since   03/04/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function DBPrepStat()

Local nRet       := 0
Local cNextAlias := ""

// Verifica se houve erro de syntaxe na query
nRet := TCSqlExec( cQuery )

If nRet < 0
    MsgAlert( TCSQLError() )
Else
    
    cNextAlias := GetNextAlias()

    If Select( cNextAlias ) > 0
        (cNextAlias)->( DbCloseArea() )
    EndIf

    TCQuery cQuery New Alias (cNextAlias)

    (cNextAlias)->( DbGoTop() )

    If !(cNextAlias)->( Eof() )
        DBViewResult( cNextAlias )
    EndIf

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DBViewResult
Monta a grid com os resultados da Query
@author  Victor Andrade
@since   03/04/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function DBViewResult( cNextAlias )

Local aStruct   := (cNextAlias)->( DbStruct() )
Local nI        := 0
Local aCmpQry   := {}
Local aResQry   := {}
Local aResult   := {}

For nI := 1 To Len( aStruct )
	If aStruct[ni,2] <> "C"
		aAdd( aCmpQry, { aStruct[ni,1], aStruct[ni,1], "@E", aStruct[ni,3], aStruct[ni,4]} )
	Else
		aAdd( aCmpQry, { aStruct[ni,1], aStruct[ni,1], "@!", aStruct[ni,3], aStruct[ni,4]} )
	Endif
Next nI

While (cNextAlias)->( !Eof() )
		
    aResQry := {}

	For nI := 1 To Len(aCmpQry)
		aAdd( aResQry, (cNextAlias)->&( aCmpQry[nI,1] ) )
	Next nI
	
    aAdd( aResQry, .F. )
	aAdd( aResult, aResQry )
	
    (cNextAlias)->( DbSkip() )

EndDo

MsNewGetDados():New(001,001,150,530,,,,,{''},,,,,,oPanelBrw, aCmpQry, aResult )

oPanelBrw:Refresh()

Return