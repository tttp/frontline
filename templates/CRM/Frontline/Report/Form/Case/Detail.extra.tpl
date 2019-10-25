<script>
   var caseURL= "{crmURL p='civicrm/contact/view/case' q='reset=1'}";

{literal}
cj(function($) {
  $('.crm-report-civicrm_case_subject a').click(function(){
    var href= $(this).attr('href');
    var ids = href.match(/javascript:viewCase\( (\d+),(\d+)/);
    window.open (caseURL+"&id="+ ids[1] + '&cid=' +ids[2]+"&action=view",'_blank');
    return false;
  }).attr('title','view the case in another window');
});
</script>
{/literal}
