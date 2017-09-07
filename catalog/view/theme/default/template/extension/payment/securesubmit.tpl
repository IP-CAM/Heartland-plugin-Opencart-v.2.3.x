<link rel="stylesheet" type="text/css" href="catalog/view/stylesheet/securesubmit.css">

<!-- make iframes styled like other form -->
<style type="text/css">
    #iframes iframe{
        float:left;
        width:100%;
    }
    .iframeholder:after,
    .iframeholder::after{
        content:'';
        display:block;
        width:100%;
        height:0px;
        clear:both;
        position:relative;
    }
</style>


<!-- The Payment Form -->
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
<form id="iframes" action="" method="GET">
    <div class="form-group">
        <label for="iframesCardNumber">Card Number:</label>
        <div class="iframeholder" id="iframesCardNumber"></div>
    </div>
    <div class="form-group">
        <label for="iframesCardExpiration">Card Expiration:</label>
        <div class="iframeholder" id="iframesCardExpiration"></div>
    </div>
    <div class="form-group">
        <label for="iframesCardCvv">Card CVV:</label>
        <div class="iframeholder" id="iframesCardCvv"></div>
    </div>

    <input type="submit" class="btn btn-primary" value="Submit" />

</form>

<div class="buttons">
    <div class="pull-right">
        <input type="button" value="<?php echo $button_confirm; ?>" id="button-confirm" class="btn btn-primary" />
    </div>
</div>

<!-- The SecureSubmit Javascript Library -->
<script type="text/javascript" src="https://api2.heartlandportico.com/SecureSubmit.v1/token/2.1/securesubmit.js"></script>
<!-- The Integration Code -->
<script type="text/javascript">
    var secureSubmitKey = '<?php echo $publicKey ?>';
    'use strict';
    setTimeout(function () {
        'use strict';
        // Create a new `HPS` object with the necessary configuration
        var hps = new window.Heartland.HPS({
            publicKey: secureSubmitKey,
            type: 'iframe',
            // Configure the iframe fields to tell the library where
            // the iframe should be inserted into the DOM and some
            // basic options
            fields: {
                cardNumber: {
                    target: 'iframesCardNumber',
                    placeholder: '•••• •••• •••• ••••'
                },
                cardExpiration: {
                    target: 'iframesCardExpiration',
                    placeholder: 'MM / YYYY'
                },
                cardCvv: {
                    target: 'iframesCardCvv',
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
                    'height': '34px',
                    'padding': '6px 12px',
                    'font-size': '14px',
                    'line-height': '1.42857143',
                    'color': '#555',
                    'background-color': '#fff',
                    'background-image': 'none',
                    'border': '1px solid #ccc',
                    'border-radius': '4px',
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
                }
            },
            // Callback when a token is received from the service
            onTokenSuccess: function (resp) {
                alert('Here is a single-use token: ' + resp.token_value);
            },
            // Callback when an error is received from the service
            onTokenError: function (resp) {
                alert('There was an error: ' + resp.error.message);
            }
        });

        // Attach a handler to interrupt the form submission
        window.Heartland.Events.addHandler(document.getElementById('iframes'), 'submit', function (e) {
            // Prevent the form from continuing to the `action` address
            e.preventDefault();
            // Tell the iframes to tokenize the data
            hps.Messages.post(
                    {
                        accumulateData: true,
                        action: 'tokenize',
                        message: secureSubmitKey
                    },
                    'cardNumber'
                    );
        });

    }, 1000);
</script>
<!-- <script type="text/javascript" src="catalog/view/javascript/securesubmittoken.js"></script> -->