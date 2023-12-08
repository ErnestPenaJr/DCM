
// department search function
function departmentSearch(x){
    var str = x.split(" ");
    if (/\s/.test(str)) {
        var x = str[1] + '%' + str[0]
    }
    $.ajax({
        type: 'GET',
        dataType: 'json',
        url: "assets/CFCs/functions.cfc",
        data: {
            method: "searchDepartment",
            searchStr: x
        },
        beforeSend: function() {
            $('#searchingDept').html(' <span style="color: rgb(59, 91, 152)"><i class="fad fa-spinner fa-pulse"></i></span>');
        },
        success: function(response) {
            var x = response.items;
            var str = '<div class="list-group">';
            for (var i = 0; i < x.length; i++) {
                str += '<a href="#"  class="list-group-item list-group-item-action" id="searchDeptResults_' + x[i].orgcode + '" orgcode="' + x[i].orgcode + '" display = "' + x[i].orgname + '">(' + x[i].orgcode + ') <span style="color:royalblue; font-weight:bold">' + x[i].orgname + '</span></a>';
            }
            str += '</div>';
            $('#deptResults').css({'z-index':'100000','overflow-y':'scroll'}).html(str).show();
            $("a[id^='searchDeptResults_'").on('click', function() {
                var orgcode = $(this).attr('orgcode');
                var orgname = $(this).attr('orgname');
                $('#DEPTID').val(orgcode).removeClass('placeholder');
                $('#DEPTNAME').val(orgname).removeClass('placeholder');
                $('#deptResults').hide();
            });
        },
        complete: function() {
            $('#searchingDept').html('');
        }
    });
}