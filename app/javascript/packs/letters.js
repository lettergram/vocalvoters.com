document.getElementById("share_button").onclick = function(){
    copyLetterLinkToClipboard();
}

function copyLetterLinkToClipboard(){

    letter_id = $('#letter_id').attr('value');
    referral_org_id = $('#referral_org_id').attr('value')

    var get_url = window.location;
    var base_url = get_url.protocol + "//" + get_url.host;

    var param_url = "?letter_id=" + encodeURIComponent(letter_id);
    param_url += "&referral_org_id=" + encodeURIComponent(referral_org_id);
    navigator.clipboard.writeText(base_url + param_url);

    document.getElementById("share_button").innerHTML = "Copied Link!"
}
