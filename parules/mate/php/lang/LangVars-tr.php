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
 *
 * Turkish Language File - Türkçe Dil Dosyası
 * Ibrahim PALA // Zogor CEO - ibrahim.pala@zogor.com
 * Zogor Tech. R&D and Informatics Co.Ltd. - http://www.zogor.com
 *
 */
// LANGUAGE variables
class LangVars
{
	//Class Common
	var $errNoSelect   = 'Mysql bağlantı hatası: Veritabanı %s bağlanılamıyor';
	var $errNoConnect  = 'Mysql bağlantı hatası: Bağlanılamıyor';
	var $errInScript   = '%s kodunun %s satırında hata: %s';
	
	//Class AjaxTableEditor
	//function setDefaults
	var $optLike       = 'İçinde Geçsin';
	var $optNotLike    = 'İçinde Geçmesin';
	var $optEq         = 'Birebir Eşleşsin';
	var $optNotEq      = 'Birebir Eşleşmesin';
	var $optGreat      = 'Büyük Olsun';
	var $optLess       = 'Küçük Olsun';
	var $optGreatEq    = 'Büyük yada Eşit Olsun';
	var $optLessEq     = 'Küçük yada Eşit Olsun';
	
	var $ttlAddRow     = 'Kayıt Ekle';
	var $ttlEditRow    = 'Kaydı Düzenle';
	var $ttlEditMult   = 'Çoklu Kayıt Düzenle';
	var $ttlViewRow    = 'Kaydı Gör';
	var $ttlShowHide   = 'Gösterilen/Gizlenen Sütunlar';
	var $ttlOrderCols  = 'Sütun Sıralaması';
	//function doDefault
	var $errNoAction   = '%s ile ilgili birşey mevcut değil.';
	//function doQuery
	var $errQuery      = 'Aşağıda ki işleyiş ile ilgili problem var:';
	var $errMysql      = 'mysql der ki:';
	// function editMultRows
	var $edit1Row      = 'Aynı anda 1 satır düzenleyebilirsiniz.';
	// function updateRow
	var $errVal        = 'İşaretli alanları düzeltiniz';
	// function updateRowInPlace
	var $errValInPlace = 'Aşağıdaki alanları düzeltin lütfen';
	// function formatIcons
	var $ttlInfo       = 'Bilgi';
	var $ttlEdit       = 'Düzenle';
	var $ttlCopy       = 'Kopyala';
	var $ttlDelete     = 'Sil';
	// function getAdvancedSearchHtml
	var $lblSelect     = 'Seçiniz';
	// All Buttons
	var $btnBack       = 'Geri';
	var $btnCancel     = 'İptal';
	var $btnEdit       = 'Düzenle';
	var $btnAdd        = 'Ekle';
	var $btnUpdate     = 'Düzenle';
	var $btnView       = 'Göster';
	var $btnCopy       = 'Kopyala';
	var $btnDelete     = 'Sil';
	var $btnExport     = 'Dosya Olarak Al';
	var $btnSearch     = 'Arama';
	var $btnCSearch    = 'Aramayı Sıfırla';
	var $btnASearch    = 'Gelişmiş Arama';
	var $btnQSearch    = 'Hızlı Arama';
	var $btnReset      = 'sıfırla';
	var $btnAddCrit    = 'Yeni Kriter';
	var $btnShowHide   = 'Gösterilen/Gizlenen Sütunlar';
	var $btnOrderCols  = 'Sütun Sıralaması';
	var $btnCFilters   = 'Filtreyi Sıfırla';
	var $btnFilters    = 'Filtreyi Uygula';
	// function displayTableHtml
	var $ttlDispRecs   = '<span id="%sstart_rec_num">%s</span> ile <span id="%send_rec_num">%s</span> Arasındaki <span id="%stotal_rec_num">%s</span> Kayıt Gösteriliyor';
	var $ttlDispNoRecs = 'Gösterilecek Kayıt Yok';
	var $ttlRecords    = 'Kayıtlar';
	var $ttlNoRecord   = 'Herhangi Bir Kayıt Bulunmamaktadır';
	var $lblSearch     = 'Arama';
	var $lblPage       = 'Sayfa #:';
	var $lblDisplay    = 'Gösterilen #:';
	var $lblMatch      = 'Eşleşen:';
	var $lblAllCrit    = 'Bütün Kriterler';
	var $lblAnyCrit    = 'Herhangi Bir Kriter';
	// function showHideColumns
	var $ttlColumn     = 'Sütun';
	var $ttlCheckBox   = 'Göster';
	// function handleFileUpload
	var $errFileSize   = '%s çok büyüktü';
	var $errFileReq   = '%s doldurulması gerekmektedir';
}
?>
