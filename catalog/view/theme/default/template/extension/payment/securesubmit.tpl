<link rel="stylesheet" type="text/css" href="<?php echo $base;?>catalog/view/stylesheet/securesubmit.css">

<?php if ($securesubmit_use_iframes): // help prevent flash of no fields ?>
  <link rel="dns-prefetch" href="https://hps.github.io" />
  <link rel="prefetch" href="https://hps.github.io" />
  <link rel="dns-prefetch" href="https://api.heartlandportico.com" />
  <link rel="prefetch" href="https://api.heartlandportico.com" />
<?php endif; ?>

<!-- The Payment Form -->
<div id="hpsPaymentForm">
	<fieldset id="payment">
		<legend><?php echo $text_credit_card; ?><br>
			<div class="ss-shield">  </div>
			<div class="visa-gray hidden-xs "></div>
			<div class="mc-gray hidden-xs"></div>
			<div class="amex-gray hidden-xs"></div>
			<div class="jcb-gray hidden-xs"></div>
			<div class="disc-gray hidden-xs"></div>
		</legend>
	</fieldset>
	<div class="form-group">
		<label class="control-label ss-label" for="input-cc-number"><?php echo $entry_cc_number; ?></label></br>

		<?php if ($securesubmit_use_iframes): ?>
		  <div id="iframesCardNumber" class="iframeholder"></div>
		<?php else: ?>
		  <input type="tel" value="" placeholder="•••• •••• •••• ••••" id="input-cc-number" class="form-control ss-form-control card-type-icon" />
		<?php endif; ?>
	</div>
	<div class="form-group">
		<label class="control-label ss-label" for="input-cc-expire-date"><?php echo $entry_cc_expire_date; ?></label></br>

		<?php if ($securesubmit_use_iframes): ?>
		  <div id="iframesCardExpiration" class="iframeholder"></div>
		<?php else: ?>
		  <input type="tel" name="cc_expire_date" id="input-cc-expire-date" class="form-control ss-form-control" placeholder="MM / YYYY" />
		<?php endif; ?>
	</div>
	<div class="form-group">
		<label class="control-label ss-label cvv-label" for="input-cc-cvv2"><?php echo $entry_cc_cvv2; ?></label></br>

		<?php if ($securesubmit_use_iframes): ?>
		  <div id="iframesCardCvv" class="iframeholder"></div>
		<?php else: ?>
		  <input type="tel" value="" placeholder="<?php echo $entry_cc_cvv2; ?>" id="input-cc-cvv2" class="form-control ss-form-control cvv-icon"  />
		<?php endif; ?>
	</div>

	<div class="buttons">
		<div class="pull-right">
			<input type="button" value="<?php echo $button_confirm; ?>" id="button-confirm" class="btn btn-primary" />
		</div>
	</div>
</div>
<!-- The SecureSubmit Javascript Library -->
<script type="text/javascript" src="https://api2.heartlandportico.com/SecureSubmit.v1/token/2.1/securesubmit.js"></script>
<!-- The Integration Code -->
<script type="text/javascript"><!--
$(document).ready(function () {
  $('#button-confirm').bind('click', secureSubmitFormHandler);
  $("#input-cc-number").keydown(function (e) {
    // Allow: backspace, delete, tab, escape, enter and .
    if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
       // Allow: Ctrl+A
      (e.keyCode == 65 && e.ctrlKey === true) ||
       // Allow: home, end, left, right
      (e.keyCode >= 35 && e.keyCode <= 39)) {
        // let it happen, don't do anything
        return;
    }
    // Ensure that it is a number and stop the keypress
    if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
      e.preventDefault();
    }
  });

  function secureSubmitFormHandler() {
    var publicKey = '<?php echo $publicKey;?>';

    if ($('input.securesubmitToken').size() === 0) {
      if (<?php echo ($securesubmit_use_iframes ? 'true' : 'false');?>) {
        window.hps.Messages.post(
          {
            accumulateData: true,
            action: 'tokenize',
            message: publicKey
          },
          'cardNumber'
        );
      } else {
        var card  = $('#input-cc-number').val().replace(/\D/g, '');
        var cvc   = $('#input-cc-cvv2').val();
        var exp   = $('#input-cc-expire-date').val().split(' / ');
        var month = exp[0];
        var year  = exp[1];
        (new Heartland.HPS({
          publicKey: publicKey,
          cardNumber: card,
          cardCvv: cvc,
          cardExpMonth: month,
          cardExpYear: year,
          success: secureSubmitResponseHandler,
          error: secureSubmitResponseHandler
        })).tokenize();
        return false;
      }
    }

    return true;
  }

  function secureSubmitResponseHandler(response) {
    var bodyTag = $('body').first();
    if (response.message) {
      alert(response.message);
      $('#button-confirm').button('reset');
    } else {
      bodyTag.append("<input type='hidden' class='securesubmitToken' name='securesubmitToken' value='" + response.token_value + "'/>");
      form_submit();
    }
  }

  function form_submit() {
    var ret = [];
    $(':input').each(function (index) {
      ret.push(encodeURIComponent(this.name) + "=" + encodeURIComponent($(this).val()));
    });

    $.ajax({
      url: 'index.php?route=extension/payment/securesubmit/send',
      type: 'post',
      data: ret.join("&").replace(/%20/g, "+"),
      dataType: 'json',
      cache: false,
      beforeSend: function () {
        $('#button-confirm').button('loading');
      },
      complete: function () {
        $('#button-confirm').button('reset');
      },
      success: function (json){
        if (json['error']) {
          alert(json['error']);
        }
        if (json['redirect']) {
          window.location = json['redirect'];
        }
      }
    });
  }

  function loadjsfile(filename, filetype, callback) {
    if (filetype === "js") { //if filename is a external JavaScript file
      var fileref = document.createElement('script');
      fileref.setAttribute("type","text/javascript");
      fileref.setAttribute("src", filename);
    }
    if (typeof fileref !== "undefined" && typeof callback !== 'undefined') {
      fileref.setAttribute('onload', callback);
    }
    if (typeof fileref !== "undefined") {
      document.getElementsByTagName("head")[0].appendChild(fileref);
    }
  }

  //dynamically load and add this .js file
  loadjsfile("https://api.heartlandportico.com/SecureSubmit.v1/token/2.1/securesubmit.js", "js", 'secureSubmitPrepareFields();');

  window.secureSubmitPrepareFields = function () {
    var publicKey = '<?php echo $publicKey;?>';    

    if (<?php echo ($securesubmit_use_iframes ? 'true' : 'false');?>) {
      // Create a new `HPS` object with the necessary configuration
      window.hps = new Heartland.HPS({
        publicKey: publicKey,
        type:      'iframe',
        // Configure the iframe fields to tell the library where
        // the iframe should be inserted into the DOM and some
        // basic options
        fields: {
          cardNumber: {
            target:      'iframesCardNumber',
            placeholder: '•••• •••• •••• ••••'
          },
          cardExpiration: {
            target:      'iframesCardExpiration',
            placeholder: 'MM / YYYY'
          },
          cardCvv: {
            target:      'iframesCardCvv',
            placeholder: 'CVV'
          }
        },
        // Collection of CSS to inject into the iframes.
        // These properties can match the site's styles
        // to create a seamless experience.
        style: {
			'input[type=text],input[type=tel]': {
				'box-sizing': 'border-box',
				'display': 'block',
				'width': '100%',
				'height': '45px',
				'padding': '6px 12px',
				'font-size': '14px',
				'line-height': '1.42857143',
				'color': '#555',
				'background-color': '#fff',
				'background-image': 'none',
				'border': '1px solid #ccc',
				'border-radius': '0px',
				'-webkit-box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075)',
				'box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075)',
				'-webkit-transition': 'border-color ease-in-out .15s,-webkit-box-shadow ease-in-out .15s',
				'-o-transition': 'border-color ease-in-out .15s,box-shadow ease-in-out .15s',
				'transition': 'border-color ease-in-out .15s,box-shadow ease-in-out .15s'
			},
			'input[type=text]:focus,input[type=tel]:focus': {
				'border-color': '#66afe9',
				'outline': '0',
				'-webkit-box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6)',
				'box-shadow': 'inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6)'
			},
			'input[type=submit]': {
				'box-sizing': 'border-box',
				'display': 'inline-block',
				'padding': '6px 12px',
				'margin-bottom': '0',
				'font-size': '14px',
				'font-weight': '400',
				'line-height': '1.42857143',
				'text-align': 'center',
				'white-space': 'nowrap',
				'vertical-align': 'middle',
				'-ms-touch-action': 'manipulation',
				'touch-action': 'manipulation',
				'cursor': 'pointer',
				'-webkit-user-select': 'none',
				'-moz-user-select': 'none',
				'-ms-user-select': 'none',
				'user-select': 'none',
				'background-image': 'none',
				'border': '1px solid transparent',
				'border-radius': '4px',
				'color': '#fff',
				'background-color': '#337ab7',
				'border-color': '#2e6da4'
			},
			'input[type=submit]:hover': {
				'color': '#fff',
				'background-color': '#286090',
				'border-color': '#204d74'
			},
			'input[type=submit]:focus, input[type=submit].focus': {
				'color': '#fff',
				'background-color': '#286090',
				'border-color': '#122b40',
				'text-decoration': 'none',
				'outline': '5px auto -webkit-focus-ring-color',
				'outline-offset': '-2px'
			},
			'input[name=cardNumber]': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-inputcard-blank@2x.png")',
			  'background-position':'right',
			  'background-size':'56px 33px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat'
			},
			'input[name=cardCvv]': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/cvv1.png")',
			  'background-position':'right',
			  'background-size':'56px 33px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat'
			},
			'.invalid.card-type-visa': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'86px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-47px'
			},
			'.valid.card-type-visa': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-1px'
			},
			'.invalid.card-type-discover': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-422px'
			},
			'.valid.card-type-discover': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-372px'
			},
			'.invalid.card-type-jcb': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-325px'
			},
			'.valid.card-type-jcb': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-281px'
			},
			'.invalid.card-type-amex': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-237px'
			},
			'.valid.card-type-amex': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-189px'
			},
			'.invalid.card-type-mastercard': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-142px'
			},
			'.valid.card-type-mastercard': {
			  'background-image':'url("<?php echo $base;?>catalog/view/image/ss-sprite.png")',
			  'background-position':'right',
			  'background-size':'85px 463px',
			  'display':'-webkit-inline-box',
			  'background-repeat':'no-repeat',
			  'background-position-y':'-98px'
			},
		},
		// Callback when a token is received from the service
        onTokenSuccess: secureSubmitResponseHandler,
        // Callback when an error is received from the service
        onTokenError: secureSubmitResponseHandler
      });
    } else {
      Heartland.Card.attachNumberEvents('#input-cc-number');
      Heartland.Card.attachExpirationEvents('#input-cc-expire-date');
      Heartland.Card.attachCvvEvents('#input-cc-cvv2');
    }
  }
});
</script>
