Template.session_edit_button.events
    'click .edit_this': -> Session.set 'editing_id', @_id
    'click .save_doc': -> Session.set 'editing_id', null

Template.session_edit_button.helpers
    button_classes: -> Template.currentData().classes


Template.session_edit_icon.events
    'click .edit_this': -> Session.set 'editing_id', @_id
    'click .save_doc': -> Session.set 'editing_id', null

Template.session_edit_icon.helpers
    button_classes: -> Template.currentData().classes


Template.detect.events
    'click .detect_fields': ->
        # console.log @
        Meteor.call 'detect_fields', @_id


Template.buy_now_button.onCreated ->
	# Session.set 'giveAmount', ''
    if Meteor.isDevelopment
        pub_key = Meteor.settings.public.stripe_test_publishable
    else if Meteor.isProduction
        pub_key = Meteor.settings.public.stripe_live_publishable
    Template.instance().checkout = StripeCheckout.configure(
        key: pub_key
        image: 'https://res.cloudinary.com/facet/image/upload/v1571084876/mmmlogo.png'
        locale: 'auto'
        # zipCode: true
        token: (token) ->
            product = Docs.findOne Router.current().params.doc_id
            charge =
                amount: 1*100
                currency: 'usd'
                source: token.id
                description: token.description
                # receipt_email: token.email
            Meteor.call 'STRIPE_single_charge', charge, product, (error, response) =>
                if error then alert error.reason, 'danger'
                else
                    alert 'Payment received.', 'success'
                    Docs.insert
                        model:'transaction'
                        product_id:product._id
	)

Template.buy_now_button.events
    'click .buy_now': ->
        deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
        stripe_charge = parseFloat(deposit_amount)*100*1.02+20
        # stripe_charge = parseInt(deposit_amount*1.02+20)

        # if confirm "add #{deposit_amount} credit?"
        Template.instance().checkout.open
            name: 'credit deposit'
            # email:Meteor.user().emails[0].address
            description: 'wc top up'
            amount: stripe_charge
