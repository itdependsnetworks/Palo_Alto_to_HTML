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
	var $errNoSelect   = '连接数据库错误：无法选择 % 数据库';
	var $errNoConnect  = '链接数据库错误：无法连接';
	var $errInScript   = '%s 脚本的第 %s 行错误：%s';
	
	//Class AjaxTableEditor
	//function setDefaults
	var $optLike       = '包含';
	var $optNotLike    = '不包含';
	var $optEq         = '完全匹配';
	var $optNotEq      = '完全不匹配';
	var $optGreat      = '大于';
	var $optLess       = '小于';
	var $optGreatEq    = '大于等于';
	var $optLessEq     = '小于等于';
	
	var $ttlAddRow     = '添加记录';
	var $ttlEditRow    = '编辑记录';
	var $ttlEditMult   = '编辑多条记录';
	var $ttlViewRow    = '查看记录';
	var $ttlShowHide   = '显示/隐藏列';
	var $ttlOrderCols  = '列顺序';
	//function doDefault
	var $errNoAction   = '程序 %s 错误：未找到action.';
	//function doQuery
	var $errQuery      = '执行以下查询错误：';
	var $errMysql      = 'mysql 错误：';
	// function editMultRows
	var $edit1Row      = '您同时只能编辑一条记录的数据。';
	// function updateRow
	var $errVal        = '请正确填写红色区域';
	// function updateRowInPlace
	var $errValInPlace = '請更正以下領域';
	// function formatIcons
	var $ttlInfo       = '查看';
	var $ttlEdit       = '编辑';
	var $ttlCopy       = '复制';
	var $ttlDelete     = '删除';
	// function getAdvancedSearchHtml
	var $lblSelect     = '选择查询条件';
	// All Buttons
	var $btnBack       = '返回';
	var $btnCancel     = '放弃';
	var $btnEdit       = '编辑';
	var $btnAdd        = '添加';
	var $btnUpdate     = '更新';
	var $btnView       = '查看';
	var $btnCopy       = '复制';
	var $btnDelete     = '删除';
	var $btnExport     = '导出';
	var $btnSearch     = '查询';
	var $btnCSearch    = '清除查询';
	var $btnASearch    = '高级查询';
	var $btnQSearch    = '快速查询';
	var $btnReset      = '重置';
	var $btnAddCrit    = '添加查询条件';
	var $btnShowHide   = '显示/隐藏列';
	var $btnOrderCols  = '列顺序';
	var $btnCFilters   = '清除过滤器';
	var $btnFilters    = '提交过滤器';
	// function displayTableHtml
	var $ttlDispRecs   = '显示 <span id="%sstart_rec_num">%s</span> - <span id="%send_rec_num">%s</span>，共 <span id="%stotal_rec_num">%s</span> 条记录';
	var $ttlDispNoRecs = '显示 0 条记录';
	var $ttlRecords    = '记录';
	var $ttlNoRecord   = '没有找到记录';
	var $lblSearch     = '查找';
	var $lblPage       = '当前页：';
	var $lblDisplay    = '显示 #:';
	var $lblMatch      = '满足：';
	var $lblAllCrit    = '所有查询条件';
	var $lblAnyCrit    = '任一查询条件';
	// function showHideColumns
	var $ttlColumn     = '列名';
	var $ttlCheckBox   = '是否显示';
	// function handleFileUpload
	var $errFileSize   = '%s 文件太大';
	var $errFileReq    = '%s 是必填项';
}
?>
