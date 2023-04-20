var validate_email = function(email) {
    var re = /\S+@\S+\.\S+/;
    return re.test(email);
}

var validate_form = function(ids_to_validate){
    var safe_flag = true
    for (const element of ids_to_validate){

	var containerElement = document.getElementById(element+'_container');
	var containerValue = document.getElementById(element).value;
	
	// Check if there's no data in given field
	if ((containerValue.length==0)
	    || (element=='email' && !validate_email(containerValue))) {
	    containerElement.classList.add('has-error');
	    safe_flag = false	    
	} else {
	    containerElement.classList.add('has-success');
	}
	
	containerElement.addEventListener('change', function() {
	    this.classList.remove('has-error');
	    this.classList.remove('has-success');
	})

	containerElement.onselect = function() {
	    this.classList.remove('has-error');
	    this.classList.remove('has-success');
	}
    }

    return safe_flag
}

var create_signature = function(){

    if (document.getElementById('signature_container').style.display != 'inline') {
	document.getElementById('signature_container').style.display = 'inline';
	
	// const SignaturePad = require("signature_pad").default;
	var signaturePad = new SignaturePad(document.getElementById('signature-pad'), {
	    backgroundColor: 'rgba(255, 255, 255)',
	    penColor: 'rgb(0, 0, 0)',
	    minDistance: 5
	});

	var submitButton = document.getElementById('submit-signature');	
	submitButton.addEventListener('click', function (event) {
	    // const data = signaturePad.toData() // saves more detailed data
	    const data = signaturePad.toDataURL("image/jpeg", 0.5) // save as jpeg base64
	    document.getElementById('signature-data').value = data;
	    
	    var letter_id = document.querySelector('#pdf_view').getAttribute('value');
	    
	    update_pdf(letter_id);
	    // save data to backend
	    // load data for PDF
	});
	
	var cancelButton = document.getElementById('reset-signature');	
	cancelButton.addEventListener('click', function (event) {
	    signaturePad.clear();
	});

	attach_stripe_checkout_on_click();
    }
    window.location.hash = "#signature_container";
}

var generate_concerns = function(letter_id=null){

    if(!letter_id){ return false }
    
    // Ensure name, email, address are present
    const form_element_ids = ['name', 'email', 'address']
    if(!validate_form(form_element_ids)){ return false; }
    
    update_pdf(letter_id);
    
    // Hide bottom buffer once communications_selection displayed
    $("#concerns_selection_bottom_buffer").attr('style', 'display:none');
    $('#communications_selection').attr('style', 'display:block');
    // $("#edit-letter-container").attr('style', 'display:block');
    document.getElementById("share_button").onclick = function(){
	copyLetterToClipboard();
    }
    $('#edit-letter').click()

    return true

}

var create_sender = function(){
    var sender_name = document.getElementById('name').value;
    var sender_email = document.getElementById('email').value;
    var sender_zipcode = document.querySelector('#sender_zipcode').getAttribute('value');
    var sender_state = document.querySelector('#sender_state').getAttribute('value');
    var sender_county = document.querySelector('#sender_county').getAttribute('value');
    var sender_district_federal = document.querySelector('#sender_district_federal').getAttribute('value');

    $.ajax({
        type: "POST",
	url: '/sender.json',	
	cache: false,
	data: {
	    'name': sender_name,
	    'email': sender_email,
	    'zipcode': sender_zipcode,
	    'state': sender_state,
	    'county': sender_county,
	    'district': sender_district_federal
	},
	success: function(response) {
	    console.log(response)
	}
    });
}


var letter_selection = function(){

    var generation_flag = document.getElementById('generation_option').getAttribute('value');
    if(generation_flag === 'true'){ return }
    
    var org_id = $('#referral_org_id').attr('value')
    var letter_selection_url = '/letter_selection?org_id='+org_id
    letter_selection_url += '&layout=false'
    $.ajax({
	url: letter_selection_url,
	cache: false,
	success: function(html){
	    $("#letter_selection").html(html);
	    var letter_cards = document.getElementsByClassName('letter_card');
	    for (var i=0; i < letter_cards.length; i++) {
		
		letter_cards[i].onclick = function(card) {
		    var id = document.getElementById(card.srcElement.id).getAttribute('value');

		    disableCommunications();
		    // update_prices();
		    // update_checkout_price();
		    
		    generate_concerns(id);
		    var letter_id = document.querySelector('#pdf_view').getAttribute('value')
		    update_pdf(id);

		    var letter_cards = document.getElementsByClassName('letter_card');
		    for (var i=0; i < letter_cards.length; i++) {
			if(letter_cards[i].classList.contains('selected_letter')){
			    letter_cards[i].classList.remove('selected_letter');
			}
		    }
		    card.srcElement.classList.add('selected_letter');
		}
	    }
	}
    });
}

var find_selected_target_positions = function(){
    var selected_letters = document.getElementsByClassName('selected_letter');
    if(selected_letters.length != 1){ return }
    var letter_id = selected_letters[0].getAttribute('value');
    var target_positions = document.getElementById(
	'letter_target_'+letter_id).getAttribute('value').split(';');
    var target_level = document.getElementById(
	'letter_level_'+letter_id).getAttribute('value').split(';');    

    var recipient_cards = document.getElementsByClassName('recipient_card');
    
    // Remove anything selected
    for (var i=0; i < recipient_cards.length; i++) {
	if(recipient_cards[i].classList.contains('selected_card')){
	    recipient_cards[i].classList.remove('selected_card');	    
	}		
    }

    // Add any selected
    for (var i=0; i < recipient_cards.length; i++) {
	var recipient_id = recipient_cards[i].getAttribute('value');
	var position = document.getElementById(
	    'recipient_position_'+recipient_id).getAttribute('value');
	var level = document.getElementById(
	    'recipient_level_'+recipient_id).getAttribute('value');

	var level_flag = target_level == level || target_level == "all"	
	if(target_positions.includes(position) && level_flag){
	    recipient_cards[i].click();
	}
    }
    window.location.hash = "#communications_selection";
}

function find_legislators(){
    var sender_name = document.getElementById('name').value;
    var sender_email = document.getElementById('email').value;
    var sender_address = document.getElementById('address').value;
    var lookup_url = '/govlookup?'+'name='+sender_name+'&address='+sender_address
    lookup_url+= '&layout=false'

    $('#concerns_selection').attr('style', 'display:block');
    window.location.hash = "#concerns_selection";
    
    letter_selection();    

    $.ajax({
	url: lookup_url,
	cache: false,
	success: function(html){
	    
	    document.querySelector("#privacy_terms_box").classList.add("hidden");

	    $("#legislator_selection").html(html);
	    document.getElementById('legislator_button').disabled = false;
	    document.getElementById('legislator_button').innerText = "Lookup Legislators"

	    $('.send_button').click(function(e) {

		// Clear any old selections
		var selected_buttons = document.getElementsByClassName("selected_button");
		for (var i = 0; i < selected_buttons.length; i++) {
		    selected_buttons[i].classList.remove('selected_button');
		}
		
		// Add selected button to later retrieve 
		e.currentTarget.classList.add('selected_button');

		create_signature();
	    });
	    
	    var sender_address = document.getElementById('sender_address').getAttribute('value')
	    var sender_state = document.getElementById('sender_state').getAttribute('value')
	    var sender_district_federal = document.getElementById('sender_district_federal').getAttribute('value')

	    var recipient_cards = document.getElementsByClassName('recipient_card');
	    for (var i=0; i < recipient_cards.length; i++) {
		if (i == 0) {
		    var id = recipient_cards[i].getAttribute('value')
		    var recipient_name = document.getElementById('recipient_name_'+id).getAttribute('value')
		    var recipient_position = document.getElementById('recipient_position_'+id).getAttribute('value')
		    var recipient_level = document.getElementById('recipient_level_'+id).getAttribute('value')
		}
		
		recipient_cards[i].onclick = function(card) {

		    var id = document.getElementById(card.srcElement.id).getAttribute('value')
		    var recipient_name = document.getElementById('recipient_name_'+id).getAttribute('value')
		    var recipient_position = document.getElementById('recipient_position_'+id).getAttribute('value')
		    var recipient_level = document.getElementById('recipient_level_'+id).getAttribute('value')
		    
		    /* Select the recipient cards */
		    if (card.srcElement.classList.contains('selected_card')) {
			card.srcElement.classList.remove('selected_card')
		    }else{
			card.srcElement.classList.add('selected_card')
		    }

		    disableCommunications();
		    update_prices();
		    update_checkout_price();
		    var shared_letter_id = document.getElementById('shared_letter_id').getAttribute('value')
		    if (shared_letter_id) {
			generate_concerns(shared_letter_id)
		    }else{
			generate_concerns();
		    }
		    window.location.hash = "#communications_selection";
		    var letter_id = document.querySelector('#pdf_view').getAttribute('value')
		    update_pdf(letter_id);		    
		}	 
	    }	    
	}
    });
    
    document.getElementById('legislator_button').disabled = true;
    document.getElementById('legislator_button').innerText = "Please wait..."
}

function update_pdf(letter_id) {

    var signature = document.getElementById('signature-data').value
    var sender_name = document.getElementById('name').value;
    var sender_state = document.querySelector('#sender_state').getAttribute('value');

    var recipient_id = null;
    var recipient_district ="N/A"
    var recipient_name = "Select a Rep"
    var recipient_position = "N/A"
    var recipient_level = "N/A"
    var selected_cards = document.getElementsByClassName('recipient_card selected_card');
    if(selected_cards.length > 0) {
	recipient_id = selected_cards[0].getAttribute('value');
	recipient_district = document.querySelector('#recipient_district_'+recipient_id).getAttribute('value');
	recipient_name = document.querySelector('#recipient_name_'+recipient_id).getAttribute('value');
	recipient_position = document.querySelector('#recipient_position_'+recipient_id).getAttribute('value');	
	recipient_level = document.querySelector('#recipient_level_'+recipient_id).getAttribute('value');
    }
    
    var sender_address_line_1 = document.querySelector('#sender_line_1').getAttribute('value');
    var sender_address_line_2 = document.querySelector('#sender_line_2').getAttribute('value');
    var sender_address_city = document.querySelector('#sender_city').getAttribute('value');
    var sender_address_zipcode = document.querySelector('#sender_zipcode').getAttribute('value');
    var sender_district = document.querySelector('#sender_district_federal').getAttribute('value');
    
    var src_url  = '/letters/' + letter_id + '.pdf?sender_name=' + sender_name;
    src_url += '&sender_state='+sender_state;
    src_url += '&sender_district='+sender_district;

    src_url += '&sender_address_line_1='+sender_address_line_1;
    src_url += '&sender_address_line_2='+sender_address_line_2;
    src_url += '&sender_address_city='+sender_address_city;
    src_url += '&sender_address_zipcode='+sender_address_zipcode;
    
    src_url += '&recipient_name='+recipient_name;
    src_url += '&recipient_level='+recipient_level;
    src_url += '&recipient_position='+recipient_position;

    if (signature != null) {
	// Split: data:image/png <here, take --> base64,iVBOrw....
	src_url += '&signature='+JSON.stringify(signature).split(';')[1]
    }

    src_url += '&sender_verified=true'

    $('#pdf_view').attr('src', src_url);
    $('#pdf_view').attr('width', '100%');
    $('#pdf_view').attr('height', '780');
    $('#pdf_view').attr('value', letter_id);
    $('#iframe_container').attr('style', 'display:block');
    
    $('#referral_org_id').attr(
	'style',
	"padding:0.2em 0.2em 0.2em 0.2em;margin: 0.1em 0.1em 0.1em 0.1em;float:right;white-space:nowrap;display:inline;"
    );
}

var update_prices = function() {
    var r_count = $('.recipient_card.selected_card').length;
    if(r_count == 0){
	document.getElementById('payment_container').style.display = 'none';
    }

    var fee = 2
    document.getElementById('email_price').setAttribute('value', r_count * 1 + fee);
    document.getElementById('fax_price').setAttribute('value', r_count * 1 + fee);
    document.getElementById('letter_price').setAttribute('value', r_count * 2 + fee);
    document.getElementById('priority_price').setAttribute('value', r_count * 3 + fee);
    
    document.getElementById('email_price').innerHTML = 'Price: $' + (r_count*1+fee).toString() + ' (x' + r_count.toString()+')';
    document.getElementById('fax_price').innerHTML = 'Price: $' + (r_count*1+fee).toString() + ' (x' + r_count.toString()+ ')';
    document.getElementById('letter_price').innerHTML = 'Price: $' + (r_count*2+fee).toString() + ' (x' + r_count.toString()+ ')';
    document.getElementById('priority_price').innerHTML = 'Price: $' + (r_count*3+fee).toString() + ' (x' + r_count.toString()+ ')';
}

var attach_stripe_checkout_on_click = function() {

    $('#submit-signature,#skip-signature').click(function(e) {
		
	var send_buttons = document.getElementsByClassName("send_button");
	for (var i = 0; i < send_buttons.length; i++) {
	    send_buttons[i].classList.remove('selected_card');
	}

	var id = document.getElementsByClassName("selected_button")[0].id;
	document.getElementsByClassName("selected_button")[0].classList.add('selected_card');
	
	var count = update_checkout_price(id);

	load_stripe_checkout(
	    document.getElementById('communication_mode').innerText,
	    document.getElementById('email').value,
	    $('.recipient_card.selected_card').length,
	    $('#referral_org_name').attr('value')
	);

	var recipient_count = $('.recipient_card.selected_card').length;
	if(recipient_count == 0){
	    document.getElementById('payment_container').style.display = 'none';
	}
    })
    
}

function update_checkout_price(id=null) {

    if (id == null) {
	var id = document.getElementById('communication_mode').getAttribute('value')
    }
    
    var recipient_count = $('.recipient_card.selected_card').length;
    var price = 0;
    var single_phrasing = "";
    var multiple_phrasing = "";
    
    if (id == 'email') {
	price = document.getElementById('email_price').getAttribute('value');
	single_phrasing = "Email";
	multiple_phrasing = "Emails";
    } else if (id == 'fax') {
	price = document.getElementById('fax_price').getAttribute('value');
	single_phrasing = "Fax";
	multiple_phrasing = "Faxes";
    } else if (id == 'letter') {
	price = document.getElementById('letter_price').getAttribute('value');
	single_phrasing = "Letter";
	multiple_phrasing = "Letters";
    } else if (id == 'priority') {
	price = document.getElementById('priority_price').getAttribute('value');
	single_phrasing = "Priority Mail";
	multiple_phrasing = "Priority Mail";
    }
    
    document.getElementById('price_to_send').innerText = '$'+price;

    if (recipient_count > 1) {
	document.getElementById('communication_mode').innerText = multiple_phrasing;
    } else {
	document.getElementById('communication_mode').innerText = single_phrasing;
    }

    document.getElementById('communication_mode').setAttribute("value", id)
}

// Disable communication modes based on the available options
var disableCommunications = function() {
    var selected_cards = document.getElementsByClassName('recipient_card selected_card');

    // const communication_option = ['email', 'fax', 'letter', 'priority'];
    const communication_option = ['fax', 'letter', 'priority'];
    
    for (var j = 0; j < communication_option.length; j++) {
	var c_option = communication_option[j];
	document.querySelector('button#'+c_option).disabled = false;
    }

    
    for (var i = 0; i < selected_cards.length; i++) {
	var id = selected_cards[i].getAttribute('value');
	
	for (var j = 0; j < communication_option.length; j++) {
	    var c_option = communication_option[j];	    
	    if(document.getElementById(
		c_option+'_'+id).getAttribute('value').length == 0) {
		document.querySelector('button#'+c_option).disabled = true;
		if (document.querySelector('button#'+c_option)
		    .classList.contains("selected_card")){
		    document.querySelector('button#'+c_option)
			.classList.remove("selected_card");
		    document.getElementById('payment_container').style.display = 'none';
		}
	    }
	}
    }

    // Always disable email for the moment
    document.querySelector('button#email').disabled = true;
}

// Show a spinner on payment submission
var loading = function(isLoading) {
    if (isLoading) {
	// Disable the button and show a spinner
	document.querySelector("#submit").disabled = true;
	document.querySelector("#spinner").classList.remove("hidden");
	document.querySelector("#button-text").classList.add("hidden");
    } else {
	document.querySelector("#submit").disabled = false;
	document.querySelector("#spinner").classList.add("hidden");
	document.querySelector("#button-text").classList.remove("hidden");
    }
};

var load_stripe_checkout = function(id=null, email=null, count=null, org=null) {

    document.getElementById('payment_container').style.display = 'block';
    window.location.hash = "#payment_container";

    // A reference to Stripe.js initialized with your real test publishable API key.
    // stripe_pk = document.getElementById('stripe_pk').getAttribute('value');
    // var stripe = Stripe(stripe_pk);
    
    // The items the customer wants to buy
    // TODO: Confirm email as required
    var purchase = {
	item: id,
	email: email,
	count: count,
	org: org
    };
    
    // Disable the button until we have Stripe set up on the page
    document.querySelector("#submit").disabled = true;
    
    fetch("/create-payment-intent.json", {
	method: "POST",
	headers: {
	    "Content-Type": "application/json",
	    "dataType": "json"
	},
	body: JSON.stringify(purchase)
    }).then(function(result) {
	return result.json();
    }).then(function(data) {

	// A reference to Stripe.js initialized with your real test publishable API key.
	stripe_pk = document.getElementById('stripe_pk').getAttribute('value');
	var stripe = Stripe(stripe_pk);

	// Clear card elements in case anything is already there (happens on reload)
	var cardElements = document.getElementById("card-element");
	while (cardElements.firstChild) {
	    cardElements.removeChild(cardElements.lastChild);
	}
	var elements = stripe.elements();

	var style = {
	    base: {
		color: "#32325d",
		fontFamily: 'Arial, sans-serif',
		fontSmoothing: "antialiased",
		fontSize: "16px",
		"::placeholder": {
		    color: "#32325d"
		}
	    },
	    invalid: {
		fontFamily: 'Arial, sans-serif',
		color: "#fa755a",
		iconColor: "#fa755a"
	    }
	};
	
	var card = elements.create("card", { style: style });
	
	// Stripe injects an iframe into the DOM
	card.mount("#card-element");
	
	card.on("change", function (event) {
	    // Disable the Pay button if there are no card details in the Element
	    document.querySelector("#submit").disabled = event.empty;
	    document.querySelector("#card-error").textContent = event.error ? event.error.message : "";
	});

	var pay_with_card_on_submit = function(event) {
	    event.preventDefault();
	
	    // Complete payment when the submit button is clicked
	    payWithCard(stripe, card, data.clientSecret);
	}
	
	// clone should remove the event listeners 
	var form = document.getElementById("payment-form")

	// Remove and add new
	form.removeEventListener('submit', pay_with_card_on_submit);	
	form.addEventListener('submit', pay_with_card_on_submit);
    });
    
    // Calls stripe.confirmCardPayment
    // If the card requires authentication Stripe shows a pop-up modal to
    // prompt the user to enter authentication details without leaving your page.
    var payWithCard = function(stripe, card, clientSecret) {
	var method = document.querySelector('.send_button.selected_card').getAttribute('id');
	loading(true);	
	stripe
	    .confirmCardPayment(clientSecret, {
		payment_method: {
		    card: card,
		    billing_details: {
			name: document.querySelector('#name').value,
			email: document.querySelector('#email').value,
			address: {
			    postal_code: document.querySelector('#sender_zipcode').getAttribute('value')
			}
		    },
		    metadata: {
			method: method,
			letter_id: document.querySelector('#pdf_view').getAttribute('value')
		    }
		},
		receipt_email: document.querySelector('#email').value
	    })
	    .then(function(result) {
		if (result.error) {
		    // Show error to your customer
		    showError(result.error.message);
		} else {
		    // The payment succeeded!
		    sendCommunication(result.paymentIntent.id, method);
		    orderComplete(result.paymentIntent.id, method);
		}
	    });
    };
    
    /* ------- UI helpers ------- */
    
    // Shows a success message when the payment is complete
    var orderComplete = function(paymentIntentId) {
	loading(false);
	document.querySelector(".result-message").classList.remove("hidden");
	document.querySelector("#submit").classList.add("hidden");
	document.querySelector("#card-element").classList.add("hidden");
	document.querySelector("#submit").disabled = true;
	document.getElementById('share_container').style.display = 'block';
    };
    
    // Show the customer the error from Stripe if their card fails to charge
    var showError = function(errorMsgText) {
	loading(false);
	var errorMsg = document.querySelector("#card-error");
	errorMsg.textContent = errorMsgText;
	setTimeout(function() {
	    errorMsg.textContent = "";
	}, 4000);
    };
}

var sendCommunication = function(paymentIntentId, method) {

    var data = {
	'method': method,
	'sender': {
	    'name': document.querySelector('#name').value,
	    'email': document.querySelector('#email').value,
	    'line_1': document.querySelector('#sender_line_1').getAttribute('value'),
	    'line_2': document.querySelector('#sender_line_2').getAttribute('value'),
	    'city': document.querySelector('#sender_city').getAttribute('value'),
	    'state': document.querySelector('#sender_state').getAttribute('value'),
	    'zipcode': document.querySelector('#sender_zipcode').getAttribute('value'),
	    'country': document.querySelector('#sender_country').getAttribute('value'),
	    'county': document.querySelector('#sender_county').getAttribute('value'),
	    'district_federal': document.querySelector('#sender_district_federal').getAttribute('value'),
	    'district_state_senate': document.querySelector('#sender_district_senate').getAttribute('value'),
	    'district_state_representative': document.querySelector('#sender_district_representative').getAttribute('value'),
	    'signature': JSON.stringify(document.getElementById('signature-data').value)
	},
	'recipients': [],
	'letter': {
	    'id': document.querySelector('#pdf_view').getAttribute('value')
	},
	'payment': {
	    'id': paymentIntentId
	}
    }
    
    var selected_cards = document.getElementsByClassName('selected_card')
    for (const element of selected_cards){
	if(element.getAttribute('value') != null){
	    data['recipients'].push(element.getAttribute('value'));
	}
    }

    $.ajax({
        type: "POST", 
        url: '/send_communication.json',
        cache: false,
	data: data,
	success: function(response) {
	    console.log(response)
	}
    });
}


function copyLetterToClipboard(){

    var letter_id = $('#pdf_view').attr('value');
    var referral_org_id = $('#referral_org_id').attr('value')

    var get_url = window.location;
    var base_url = get_url.protocol + "//" + get_url.host;
    
    var param_url = "?letter_id=" + encodeURIComponent(letter_id);
    param_url += "&referral_org_id=" + encodeURIComponent(referral_org_id);
    navigator.clipboard.writeText(base_url + param_url);
    
    document.getElementById("share_button").innerHTML = "Copied Link!"
}

function generate_letter(){
    var topic = document.getElementById('topic_search_bar').value;
    var org_id = $('#referral_org_id').attr('value')
    var user_id = $('#current_user_id').attr('value')
    var lookup_url = '/generate/letter.json?topic='+topic+'&organization_id='+org_id
    
    document.getElementById('generate_letter_button').disabled = true;
    document.getElementById('generate_letter_button').innerHTML = '<span class="small-loader"></span> Please wait...'

    $.ajax({
        url: lookup_url,
	cache: false,
        success: function(json_obj){
	    document.getElementById('generate_letter_button').disabled = false;
	    document.getElementById('generate_letter_button').innerText = "Generate Letter";
	    var letter_id = json_obj['letter_id'];
	    generate_concerns(letter_id);
	}
    })
}

function insert_letter_text_into_edit_box(letter_id=null) {
    if (!letter_id){ return false; }
    var letter_url = "letters/"+letter_id+".json"
    $.ajax({
        url: letter_url,
	cache: false,
        success: function(letter_json_obj){
	    $('#edit-letter-sentiment').val(letter_json_obj['sentiment']);
	    $('#edit-letter-category').val(letter_json_obj['category']);
	    $('#edit-letter-body').val(letter_json_obj['body']);
	}
    });
}

var update_letter = function(e) {
    document.getElementById('letter_change_button').disabled = true;
    document.getElementById('letter_change_button').innerHTML = 'Please wait...'

    var copy_url = '/copy_and_update_body.json'
    var referral_org_id = $('#referral_org_name').attr('value')
    
    $("body").bind("ajaxSend", function(elm, xhr, s){
	if (s.type == "POST") {
	    xhr.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name="csrf-token"]').content);
	}
    });

    var data = {
	'derived_from': document.querySelector('#pdf_view').getAttribute('value'),
	'referral_org_id': referral_org_id,
	'sentiment': $('#edit-letter-sentiment').val(),		
	'category': $('#edit-letter-category').val(),	
	'body': $('#edit-letter-body').val(),	
	'email': document.querySelector('#email').value,
	'CSRF': document.querySelector('meta[name="csrf-token"]').content
    }

    $.ajax({
        type: "POST",
        url: copy_url,
	cache: false,
        data: data,
	success: function(json_obj){
	    document.getElementById('letter_change_button').disabled = false;
	    document.getElementById('letter_change_button').innerText = "Submit Changes"
	    document.getElementById("letter-edit-modal").style.display = "none";

	    // document.querySelector('#sender_state').getAttribute('value'),
	    update_pdf(json_obj['id']);
	}
    });
}

var pageSetUp = function(){
    
    $('#generate_letter_button').click(function(e) { generate_letter() });

    $("#topic_search_bar").on('keyup', function (e) {
	if (e.key === 'Enter' || e.keyCode === 13) {
	    generate_letter()
	}
    });
    
    $('#edit-letter').click(function(e) {
	var letter_id = document.querySelector('#pdf_view').getAttribute('value');
	insert_letter_text_into_edit_box(letter_id);
	document.getElementById("letter-edit-modal").style.display = "block";
    });
    
    // When the user clicks on <span> (x), close the modal
    $('#letter-edit-close').click(function(e) {
	document.getElementById("letter-edit-modal").style.display = "none";
    });
    
    // When the user clicks anywhere outside of the modal, close it
    window.onclick = function(event) {
	if (event.target == document.getElementById("letter-edit-modal")) {
	    document.getElementById("letter-edit-modal").style.display = "none";	
	}
    }
    
    /* If enter, update   */
    $('#address,#name,#email').keyup(function(e) {
	if (e.which == 13) {
	    const form_element_ids = ['name', 'email', 'address']
	    if(validate_form(form_element_ids)){ find_legislators(); }
	}
    })
    
    $('#legislator_button').click(function(e) {
	const form_element_ids = ['name', 'email', 'address']
	if(validate_form(form_element_ids)){ find_legislators(); }
    })

    document.querySelectorAll('form').forEach(function (element) {
	element.dataset.turbo = false
    })

    $('#no_letter_change_button').click(function(e) {
	document.getElementById("legislator_container").style.display = "block";
	window.location.hash = "#legislator_selection";
	document.getElementById("letter-edit-modal").style.display = "none";
	find_selected_target_positions();
    });
    $('#letter_change_button').click(function(e) {
	update_letter(e);
	document.getElementById("legislator_container").style.display = "block";	
	window.location.hash = "#legislator_selection";
	find_selected_target_positions();
    });
}

document.addEventListener("turbo:render", pageSetUp());

