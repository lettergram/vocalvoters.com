function validate_email(email) {
    var re = /\S+@\S+\.\S+/;
    return re.test(email);
}

function validate_form(ids_to_validate){
    safe_flag = true
    for (const element of ids_to_validate){

	containerElement = document.getElementById(element+'_container');
	containerValue = document.getElementById(element).value;
	
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

function create_signature(){

    if (document.getElementById('signature_container').style.display != 'inline') {
	document.getElementById('signature_container').style.display = 'inline';
	
	const SignaturePad = require("signature_pad").default;
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

	    sender_name = document.getElementById('name').value;
	    sender_state = document.querySelector('#sender_state').getAttribute('value');
	    selected_cards = document.getElementsByClassName('recipient_card selected_card');
	    
	    recipient_id = selected_cards[0].getAttribute('value');
	    
	    district = document.querySelector('#recipient_district_'+recipient_id).getAttribute('value');
	    name = document.querySelector('#recipient_name_'+recipient_id).getAttribute('value');
	    position = document.querySelector('#recipient_position_'+recipient_id).getAttribute('value');	
	    level = document.querySelector('#recipient_level_'+recipient_id).getAttribute('value');
	    signature = data;
	
	    update_pdf(letter_id, sender_name, sender_state,
		       district, name, position, level, signature);
	    
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

/* If enter, update   */
$('#address,#name').keyup(function(e) {
    if (e.which == 13) {
	form_element_ids = ['name', 'email', 'address']
	if(validate_form(form_element_ids)){
	    find_legislators()
	}
    }
})

$('#legislator_button').click(function(e) {
    // 'category', 'sentiment', 'policy_or_law',
    form_element_ids = ['name', 'email', 'address']
    if(validate_form(form_element_ids)){
	find_legislators()
    }
})

$("#category").change(function(e) {
    
    policy_or_law = $("#policy_or_law");
    if (policy_or_law.prop("selectedIndex", 0).val() != '') {
	policy_or_law.empty()	
    }else{
	policy_or_law.find('option').not(':first').remove();
    }

    sentiment = $("#sentiment");
    if (sentiment.prop("selectedIndex", 0).val() != '') {
	sentiment.empty()
    }else{
	sentiment.find('option').not(':first').remove();
    }

    category = $("#category").find(":selected").text()
    
    update_options(category);
    
})

$("#policy_or_law").change(function(e) {

    /*
    category_val = $("#category").find(":selected").text()
    policy_or_law = $("#policy_or_law").find(":selected").text()

    sentiment = $("#sentiment");
    if (sentiment.prop("selectedIndex", 0).val() != '') {
	sentiment.empty()
    }else{
	sentiment.find('option').not(':first').remove();
    }

    update_options(category_val, sentiment_val=null, policy_or_law);
    */

    if(generate_concerns()) {
	
	// Display pdf & communication section
	org = $("#policy_or_law").find(":selected").attr('org')
	if (!!org) {
	    $('#org_letter').text("Template Created by " + org)
	} else {
	    $('#org_letter').text("")	    
	}
	window.location.hash = "#communications_selection";
    }
        
})

function generate_concerns() {
    
    form_element_ids = ['name', 'email', 'address']
    if(validate_form(form_element_ids)){

	category = $('#category').find(":selected").attr('value');
	sentiment = $('#sentiment').find(":selected").val();
	policy_or_law = $('#policy_or_law').find(":selected").val();

	if(!category){ return false }
	if(!sentiment){ return false }
	if(!policy_or_law){ return false }

	// Potentially error
	letter_id = $('#policy_or_law').find(":selected").attr('value')
	if (letter_id == '') {
	    letter_id = $('#category').find(":selected").attr('value')
	}

	sender_name = document.getElementById('name').value;
	sender_state = document.querySelector('#sender_state').getAttribute('value');
	selected_cards = document.getElementsByClassName('recipient_card selected_card');
	
	recipient_id = selected_cards[0].getAttribute('value');
	
	district = document.querySelector('#recipient_district_'+recipient_id).getAttribute('value');
	name = document.querySelector('#recipient_name_'+recipient_id).getAttribute('value');
	position = document.querySelector('#recipient_position_'+recipient_id).getAttribute('value');	
	level = document.querySelector('#recipient_level_'+recipient_id).getAttribute('value');
	signature = null;
	
	update_pdf(letter_id, sender_name, sender_state,
		   district, name, position, level, signature);

	// Hide bottom buffer once communications_selection displayed
	$("#concerns_selection_bottom_buffer").attr('style', 'display:none');
	$('#communications_selection').attr('style', 'display:block');	

	document.getElementById("share_button").onclick = function(){
	    copyLetterToClipboard();
	}

	return true
    }

    return false
}

$("#sentiment").change(function(e) {
    category_val = $("#category").find(":selected").text()
    sentiment_val = $("#sentiment").find(":selected").val()

    policy_or_law = $("#policy_or_law");
    if (policy_or_law.prop("selectedIndex", 0).val() != '') {
	policy_or_law.empty()
    }else{
	policy_or_law.find('option').not(':first').remove();
    }

    update_options(category_val, sentiment_val, policy_or_law=null);
})

function create_sender(){
    sender_name = document.getElementById('name').value;
    sender_email = document.getElementById('email').value;
    sender_zipcode = document.querySelector('#sender_zipcode').getAttribute('value');
    sender_state = document.querySelector('#sender_state').getAttribute('value');
    sender_county = document.querySelector('#sender_county').getAttribute('value');
    sender_district_federal = document.querySelector('#sender_district_federal').getAttribute('value');

    create_sender = '/sender'
    $.post({
	url: create_sender,
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
    })

}

function find_legislators(){
    sender_name = document.getElementById('name').value;
    sender_email = document.getElementById('email').value;
    sender_address = document.getElementById('address').value;
    lookup_url = '/govlookup?'+'name='+sender_name+'&address='+sender_address
    lookup_url+= '&layout=false'

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
		selected_buttons = document.getElementsByClassName("selected_button");
		for (var i = 0; i < selected_buttons.length; i++) {
		    selected_buttons[i].classList.remove('selected_button');
		}
		
		// Add selected button to later retrieve 
		e.currentTarget.classList.add('selected_button');

		create_signature();
	    });
	    
	    sender_address = document.getElementById('sender_address').getAttribute('value')
	    sender_state = document.getElementById('sender_state').getAttribute('value')
	    sender_district_federal = document.getElementById('sender_district_federal').getAttribute('value')
	    window.location.hash = "#legislator_selection";

	    recipient_cards = document.getElementsByClassName('recipient_card');
	    for (var i=0; i < recipient_cards.length; i++) {
		if (i == 0) {
		    id = recipient_cards[i].getAttribute('value')
		    recipient_name = document.getElementById('recipient_name_'+id).getAttribute('value')
		    recipient_position = document.getElementById('recipient_position_'+id).getAttribute('value')
		    recipient_level = document.getElementById('recipient_level_'+id).getAttribute('value')
		}
		
		recipient_cards[i].onclick = function(card) {

		    id = document.getElementById(event.srcElement.id).getAttribute('value')
		    recipient_name = document.getElementById('recipient_name_'+id).getAttribute('value')
		    recipient_position = document.getElementById('recipient_position_'+id).getAttribute('value')
		    recipient_level = document.getElementById('recipient_level_'+id).getAttribute('value')
		    
		    /* Select the recipient cards */
		    if (event.srcElement.classList.contains('selected_card')) {
			event.srcElement.classList.remove('selected_card')
		    }else{
			event.srcElement.classList.add('selected_card')
		    }

		    disableCommunications();
		    
		    update_prices();

		    update_checkout_price();

		    $('#concerns_selection').attr('style', 'display:block');
		    
		    generate_concerns();

		}	 
	    }	    
	}
    });
    
    document.getElementById('legislator_button').disabled = true;
    document.getElementById('legislator_button').innerText = "Please wait..."
}

function update_pdf(letter_id, sender_name, sender_state, sender_district,
		    recipient_name, recipient_position, recipient_level,
		    signature) {

    src_url  = '/letters/' + letter_id + '.pdf?sender_name=' + sender_name;
    src_url += '&sender_state='+sender_state;
    src_url += '&sender_district='+sender_district;
    
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
}

function update_options(category=null, sentiment=null, policy_or_law=null) {
    
    policy_url  = '/find_policy.json?'
    if (!!category) {
	policy_url += 'category=' + category
    }
    if (!!sentiment) {
	policy_url += '&sentiment=' + sentiment
    }
    if (!!policy_or_law) {
	policy_url += '&policy_or_law=' + policy_or_law
    }

    sentiment_map = {}
    sentiment_map[-1] = "Very Opposed"
    sentiment_map[-0.5] = "Opposed"
    sentiment_map[0] = "Indifferent"
    sentiment_map[0.5] = "Supportive"
    sentiment_map[1] = "Very Supportive"

    $.ajax({
	url: policy_url,
	cache: false,
	success: function(policy_list){

	    policy_or_law_options = $("#policy_or_law");
	    sentiment_options = $("#sentiment");

	    if (policy_or_law === null) {

		/*
		// Can add organization references to policies 
		for (var i = 0, size = policy_list.length; i < size; i++ ) {
		    if(!!policy_list[i][4]) {
			policy_list[i][3] += ' - Written by ' + policy_list[i][4]
		    }
		}
		*/
		
		options = policy_list.map(x => [x[0], x[3], x[4]]);
		$.each(options, function(key, value) {
		    policy_or_law_options.append(
			$('<option></option>')
			    .val(value[0]).html(value[1]).attr('org', value[2])
		    );
		});
	    }

	    if (sentiment === null) {
		options = {}
		for (var i in policy_list) {
		    options[policy_list[i][1]] = policy_list[i]
		}
		
		$.each(options, function(key, value) {
		    sentiment_options.append(
			$('<option></option>').val(key).html(
			    sentiment_map[key]
			)
		    );
		});
	    }
	}
    });    
}

function update_prices() {
    recipient_count = $('.recipient_card.selected_card').length;
    if(recipient_count == 0){
	document.getElementById('payment_container').style.display = 'none';
    }
    
    document.getElementById('email_price').innerText= recipient_count * 1;
    document.getElementById('fax_price').innerText= recipient_count * 2;
    document.getElementById('letter_price').innerText= recipient_count * 3;
    document.getElementById('priority_price').innerText= recipient_count * 5;
}

function attach_stripe_checkout_on_click() {

    $('#submit-signature,#skip-signature').click(function(e) {
		
	send_buttons = document.getElementsByClassName("send_button");
	for (var i = 0; i < send_buttons.length; i++) {
	    send_buttons[i].classList.remove('selected_card');
	}

	id = document.getElementsByClassName("selected_button")[0].id;
	document.getElementsByClassName("selected_button")[0].classList.add('selected_card');
	
	count = update_checkout_price(id);
	
	load_stripe_checkout(
	    document.getElementById('communication_mode').innerText,
	    document.getElementById('email').value,
	    $('.recipient_card.selected_card').length,
	    $("#policy_or_law").find(":selected").attr('org')
	);

	recipient_count = $('.recipient_card.selected_card').length;
	if(recipient_count == 0){
	    document.getElementById('payment_container').style.display = 'none';
	}
    })
    
}

function update_checkout_price(id=null) {

    if (id == null) {
	id = document.getElementById('communication_mode').getAttribute('value')
    }
    
    recipient_count = $('.recipient_card.selected_card').length;
    price = 0;
    single_phrasing = "";
    multiple_phrasing = "";
    
    if (id == 'email') {
	price = document.getElementById('email_price').innerText;
	single_phrasing = "Email";
	multiple_phrasing = "Emails";
    } else if (id == 'fax') {
	price = document.getElementById('fax_price').innerText;
	single_phrasing = "Fax";
	multiple_phrasing = "Faxes";
    } else if (id == 'letter') {
	price = document.getElementById('letter_price').innerText;
	single_phrasing = "Letter";
	multiple_phrasing = "Letters";
    } else if (id == 'priority') {
	price = document.getElementById('priority_price').innerText;
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
    selected_cards = document.getElementsByClassName('recipient_card selected_card');

    // communication_option = ['email', 'fax', 'letter', 'priority'];
    communication_option = ['fax', 'letter', 'priority'];
    
    for (var j = 0; j < communication_option.length; j++) {
	c_option = communication_option[j];
	document.querySelector('button#'+c_option).disabled = false;
    }

    
    for (var i = 0; i < selected_cards.length; i++) {
	id = selected_cards[i].getAttribute('value');
	
	for (var j = 0; j < communication_option.length; j++) {
	    c_option = communication_option[j];	    
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

function load_stripe_checkout(id=null, email=null, count=null, org=null) {

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
	    "Content-Type": "application/json"
	},
	body: JSON.stringify(purchase)
    }).then(function(result) {
	return result.json();
    }).then(function(data) {

	// A reference to Stripe.js initialized with your real test publishable API key.
	stripe_pk = document.getElementById('stripe_pk').getAttribute('value');
	var stripe = Stripe(stripe_pk);

	// Clear card elements in case anything is already there (happens on reload)
	cardElements = document.getElementById("card-element");
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

	
	var form = document.getElementById("payment-form");


	// Remove and add new
	form.removeEventListener('submit', arguments.callee, false);
	
	form.addEventListener("submit", function(event) {
	    event.preventDefault();
	
	    // Complete payment when the submit button is clicked
	    payWithCard(stripe, card, data.clientSecret);
	});
    });
    
    // Calls stripe.confirmCardPayment
    // If the card requires authentication Stripe shows a pop-up modal to
    // prompt the user to enter authentication details without leaving your page.
    var payWithCard = function(stripe, card, clientSecret) {
	method = document.querySelector('.send_button.selected_card').getAttribute('id');
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
}

var sendCommunication = function(paymentIntentId, method) {

    data = {
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
	    'id': document.querySelector('#pdf_view').getAttribute('value'),
	    'category': $("#category").find(":selected").text(),
	    'sentiment': $("#sentiment").find(":selected").text(),
	    'policy_or_law': $("#policy_or_law").find(":selected").text()
	},
	'payment': {
	    'id': paymentIntentId
	}
    }
    
    selected_cards = document.getElementsByClassName('selected_card')
    for (const element of selected_cards){
	if(element.getAttribute('value') != null){
	    data['recipients'].push(element.getAttribute('value'));
	}
    }
        
    send_communication_url = '/send_communication'
    $.post({
        url: send_communication_url,
        cache: false,
	data: data
    })
    
}

function copyLetterToClipboard(){
    
    category = $('#category').find(":selected").attr('value');
    sentiment = $('#sentiment').find(":selected").text();
    policy_or_law = $('#policy_or_law').find(":selected").text();

    var get_url = window.location;
    var base_url = get_url.protocol + "//" + get_url.host + "?"
    
    var param_url = ""
    
    param_url += "category=" + encodeURIComponent(category) + "&";
    param_url += "sentiment=" +  encodeURIComponent(sentiment) + "&";
    param_url += "policy_or_law=" +  encodeURIComponent(policy_or_law);

    navigator.clipboard.writeText(base_url + param_url);

    document.getElementById("share_button").innerHTML = "Copied Link!"
}

function generate_letter(){
    topic = document.getElementById('topic_search_bar').value;
    lookup_url = '/generate/letter.json?topic='+topic
    console.log(lookup_url)
    
    document.getElementById('generate_letter_button').disabled = true;
    document.getElementById('generate_letter_button').innerText = "Please wait..."
    
    $.ajax({
        url: lookup_url,
	cache: false,
        success: function(json_obj){
	    console.log(json_obj)
	    document.getElementById('generate_letter_button').disabled = false;
	    document.getElementById('generate_letter_button').innerText = "Generate Letter"
	    
	    category=json_obj['topic']
	    sentiment=json_obj['sentiment']
	    policy_or_law=json_obj['policy_or_law']

	    update_options(
		category=category,
		sentiment=null,
		policy_or_law=null
	    );
	    
            document.getElementById('category').value = json_obj['topic']
            document.getElementById('sentiment').value = json_obj['sentiment']
            document.getElementById('policy_or_law').value = json_obj['policy_or_law']

	    console.log(category)
	    console.log(document.getElementById('sentiment').value)
	    console.log(policy_or_law)

	    $('#concerns_selection').attr('style', 'display:block');
	    generate_concerns()

	}
    })
}

$('#generate_letter_button').click(function(e) {
    generate_letter()
});

$("#topic_search_bar").on('keyup', function (e) {
    console.log(e)
    if (e.key === 'Enter' || e.keyCode === 13) {
	generate_letter()
    }
});
