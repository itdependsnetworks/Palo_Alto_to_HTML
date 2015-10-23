<?php 
/*
 * Mysql Ajax Table Editor
 *
 * Copyright (c) 2008 Chris Kitchen <info@mysqlajaxtableeditor.com>
 * All rights reserved.
 * 
 * See COPYING file for license information.
 *
 * Download the latest version from
 * http://www.mysqlajaxtableeditor.com
 */
// LANGUAGE variables
class LangVars
{
	//Class Common
	var $errNoSelect   = 'Errore in connessione MySql: impossibile selezionare il database %s';
	var $errNoConnect  = 'Errore in connessione MySql: impossibile connettere il server';
	var $errInScript   = '&Egrave; avvenuto un errore nello script %s alla linea %s: %s';
	
	//Class AjaxTableEditor
	//function setDefaults
	var $optLike       = 'Contiene';
	var $optNotLike    = 'Non Contiene';
	var $optEq         = 'Esattamente uguale a';
	var $optNotEq      = 'Differente da';
	var $optGreat      = 'Maggiore di';
	var $optLess       = 'Minore di';
	var $optGreatEq    = 'Maggiore o uguale a';
	var $optLessEq     = 'Minore o uguale a';
	
	var $ttlAddRow     = 'Aggiungi riga';
	var $ttlEditRow    = 'Modifica Riga';
	var $ttlEditMult   = 'Modifica pi&ugrave; righe';
	var $ttlViewRow    = 'Visualizza riga';
	var $ttlShowHide   = 'Mostra/Cela Colonne';
	var $ttlOrderCols  = 'Ordina Colonne';
	//function doDefault
	var $errNoAction   = 'Errore nel programma %s azione non trovata';
	//function doQuery
	var $errQuery      = 'Errore durante l\'esecuzione della query seguente:';
	var $errMysql      = 'Messaggio mysql:';
	// function editMultRows
	var $edit1Row      = 'Puoi modificare solo una riga per volta.';
	// function updateRow
	var $errVal        = 'I campi in rosso devono essere corretti';
	// function updateRowInPlace
	var $errValInPlace = 'Si prega di correggere i seguenti campi';
	// function formatIcons
	var $ttlInfo       = 'Info';
	var $ttlEdit       = 'Modifica';
	var $ttlCopy       = 'Copia';
	var $ttlDelete     = 'Cancella';
	// function getAdvancedSearchHtml
	var $lblSelect     = 'Seleziona il campo desiderato';
	// All Buttons
	var $btnBack       = 'Indietro';
	var $btnCancel     = 'Annulla';
	var $btnEdit       = 'Modifica';
	var $btnAdd        = 'Aggiungi';
	var $btnUpdate     = 'Aggiorna';
	var $btnView       = 'Visualizza';
	var $btnCopy       = 'Copia';
	var $btnDelete     = 'Cancella';
	var $btnExport     = 'Esporta';
	var $btnSearch     = 'Cerca';
	var $btnCSearch    = 'Fine ricerca';
	var $btnASearch    = 'Ricerca Avanzata';
	var $btnQSearch    = 'Ricerca Veloce';
	var $btnReset      = 'Reset';
	var $btnAddCrit    = 'Aggiungi Condizioni';
	var $btnShowHide   = 'Mostra/Cela Colonne';
	var $btnOrderCols  = 'Ordina Colonne';
	var $btnCFilters   = 'Annulla Filtri';
	var $btnFilters    = 'Applica Filtri';
	// function displayTableHtml
	var $ttlDispRecs   = 'Visualizzazione <span id="%sstart_rec_num">%s</span> - <span id="%send_rec_num">%s</span> di <span id="%stotal_rec_num">%s</span> Righe';
	var $ttlDispNoRecs = 'Visualizza 0 Righe';
	var $ttlRecords    = 'Righe';
	var $ttlNoRecord   = 'Non Sono Stati Trovati Record';
	var $lblSearch     = 'Cerca';
	var $lblPage       = 'Pag. n.:';
	var $lblDisplay    = 'Visualizzazione n.:';
	var $lblMatch      = 'Le condizioni devono essere verificate:';
	var $lblAllCrit    = 'Simultaneamente (AND)';
	var $lblAnyCrit    = 'Singolarmente (OR)';
	// function showHideColumns
	var $ttlColumn     = 'Colonna';
	var $ttlCheckBox   = 'Visualizza';
	// function handleFileUpload
	var $errFileSize   = '%s era troppo grande';
	var $errFileReq   = '%s &egrave; un campo necessario';
}
?>
