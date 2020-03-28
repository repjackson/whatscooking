if Meteor.isClient
    Router.route '/meal/:doc_id/view', (->
        @layout 'layout'
        @render 'meal_view'
        ), name:'meal_view'


    Template.meal_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'
        @autorun => Meteor.subscribe 'model_docs', 'order'


    Template.meal_view.events
        'click .cancel_order': ->
            if confirm 'cancel?'
                Docs.remove @_id
    Template.meal_view.helpers
        can_order: ->
            unless @_author_id is Meteor.userId()
                order_count =
                    Docs.find(
                        model:'order'
                        meal_id:@_id
                    ).count()
                if order_count is @servings_amount
                    false
                else
                    true

        meal_orders: ->
            Docs.find
                model:'order'
                meal_id:@_id


    Template.order_button.onCreated ->
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/wc_logo.png'
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
                            # product_id:product._id
                        Meteor.users.update Meteor.userId(),
                            $inc: credit:10

    	)

    Template.order_button.events
        'click .order_meal': ->
            if Meteor.user().credit >= @price_per_serving
                if confirm 'confirm buy serving?'
                    Meteor.call 'order_meal', @_id, (err, res)->
                        if res
                            alert 'order processed'
            else
                alert 'need more credit'
                # deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
                # stripe_charge = parseFloat(deposit_amount)*100*1.02+20
                stripe_charge = 1000
                # stripe_charge = parseInt(deposit_amount*1.02+20)

                # if confirm "add #{deposit_amount} credit?"
                Template.instance().checkout.open
                    name: 'credit deposit'
                    # email:Meteor.user().emails[0].address
                    description: 'wc top up'
                    amount: stripe_charge


if Meteor.isServer
    Meteor.methods
        order_meal: (meal_id)->
            meal = Docs.findOne meal_id
            Docs.insert
                model:'order'
                meal_id: meal._id
                order_price: meal.price_per_serving
                buyer_id: Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $inc:credit:-meal.price_per_serving
            Meteor.users.update meal._author_id,
                $inc:credit:meal.price_per_serving
