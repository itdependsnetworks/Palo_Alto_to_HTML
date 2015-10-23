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
	var $errNoSelect   = 'Erro connectando ao mysql: Não foi possível selecionar o banco de dados %s';
	var $errNoConnect  = 'Erro connectando ao mysql: Impossível conectar';
	var $errInScript   = 'Ocorreu um erro no script %s na linha %s: %s';
	
	//Class AjaxTableEditor
	//function setDefaults
	var $optLike       = 'Contém';
	var $optNotLike    = 'Não contém';
	var $optEq         = 'Corresponde exatamente';
	var $optNotEq      = 'Não corresponde exatamente';
	var $optGreat      = 'Maior';
	var $optLess       = 'Menor';
	var $optGreatEq    = 'Maior ou igual a';
	var $optLessEq     = 'Menor ou igual a';
	
	var $ttlAddRow     = 'Inserir Registro';
	var $ttlEditRow    = 'Editar Registro';
	var $ttlEditMult   = 'Editar Multiplos Registros';
	var $ttlViewRow    = 'Detalhar registro';
	var $ttlShowHide   = 'Mostrar/Esconder Colunas';
	var $ttlOrderCols  = 'Ordenar Colunas';
	//function doDefault
	var $errNoAction   = 'Erro no programa  %s action não encontrado.';
	//function doQuery
	var $errQuery      = 'Ocorreu um erro ao executar a consulta a seguir:';
	var $errMysql      = 'Erro do mysql:';
	// function editMultRows
	var $edit1Row  = 'Você só pode editar 1 linha por vez';
	// function updateRow
	var $errVal        = 'Corrija os campos em vermelho';
	// function updateRowInPlace
	var $errValInPlace = 'Por favor, corrija os seguintes campos';
	// function formatIcons
	var $ttlInfo       = 'Detalhes';
	var $ttlEdit       = 'Editar';
	var $ttlCopy       = 'Copiar';
	var $ttlDelete     = 'Excluir';
	// function getAdvancedSearchHtml
	var $lblSelect     = 'Selecione um';
	// All Buttons
	var $btnBack       = 'Voltar';
	var $btnCancel     = 'Cancelar';
	var $btnEdit       = 'Editar';
	var $btnAdd        = 'Inserir';
	var $btnUpdate     = 'Atualizar';
	var $btnView       = 'Detalhes';
	var $btnCopy       = 'Copiar';
	var $btnDelete     = 'Excluir';
	var $btnExport     = 'Exportar';
	var $btnSearch     = 'Pesquisar';
	var $btnCSearch    = 'Limpar critérios de pesquisa';
	var $btnASearch    = 'Pesquisa avançada';
	var $btnQSearch    = 'Pesquisa rápida';
	var $btnReset      = 'Limpar';
	var $btnAddCrit    = 'Inserir Critério';
	var $btnShowHide   = 'Mostrar/Esconder Colunas';
	var $btnOrderCols  = 'Ordenar Colunas';
	var $btnCFilters   = 'Limpar Filtros';
	var $btnFilters    = 'Aplicar Filtros';
	// function displayTableHtml
	var $ttlDispRecs   = 'Mostrando <span id="%sstart_rec_num">%s</span> - <span id="%send_rec_num">%s</span> of <span id="%stotal_rec_num">%s</span> Registros';
	var $ttlDispNoRecs = 'Mostrando 0 Registros';
	var $ttlRecords    = 'Registros';
	var $ttlNoRecord   = 'Nenhum registro encontrado';
	var $lblSearch     = 'Pesquisa';
	var $lblPage       = 'Página #:';
	var $lblDisplay    = 'Mostrar #:';
	var $lblMatch      = 'Correspondência:';
	var $lblAllCrit    = 'Todos os critérios';
	var $lblAnyCrit    = 'Qualquer critério';
	// function showHideColumns
	var $ttlColumn     = 'Coluna';
	var $ttlCheckBox   = 'Mostrar';
	// function handleFileUpload
	var $errFileSize   = 'O arquivo %s era muito grande';
	var $errFileReq   = '%s é uma campo obrigatório';
}
?>
