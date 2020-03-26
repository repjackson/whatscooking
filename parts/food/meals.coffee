if Meteor.isClient
    Router.route '/meals', (->
        @layout 'layout'
        @render 'meals'
        ), name:'meals'
    Router.route '/meal/:doc_id/view', (->
        @layout 'layout'
        @render 'meal_view'
        ), name:'meal_view'


    Template.meal_widget.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'

    Template.meal_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id



    Template.meal_widget.events
        'click .set_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false
    Template.meal_widget.helpers
        meals: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'meal'
            }, sort:title:1


    Template.meals.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'
    Template.meals.events
        'click .add_meal': ->
            new_meal_id =
                Docs.insert
                    model:'meal'
            Router.go "/meal/#{new_meal_id}/edit"
    Template.meals.helpers
        meals: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'meal'
            }, sort:title:1


    Template.meal_card.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'
    Template.meal_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)


    Template.meal_card.helpers
        meal_card_class: ->
            if Session.get('quickbuying_id')
                if Session.equals('quickbuying_id', @_id)
                    'raised'
                else
                    'inverted'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        meals: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'meal'
            }, sort:title:1

    Template.quickbuying.helpers
        credit_needed: ->
            console.log @
            Meteor.user().credit - @price_per_serving
    Template.quickbuying.events
        'click .cancel_quickbuying': ->
            console.log @
            Session.set('quickbuying_id', null)

        'click .confirm': ->
            if Meteor.user().credit >= @price_per_serving
                if confirm 'confirm buy serving?'
                    Docs.insert
                        model:'order'
                        meal_id: @_id
                        order_price: @price_per_serving
                        buyer_id: Meteor.userId()
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@price_per_serving
                    Meteor.users.update @_author_id,
                        $inc:credit:@price_per_serving
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

                # Meteor.call 'buy_serving', @_id, ->
    Template.quickbuying.onCreated ->
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
                            # product_id:product._id
                        Meteor.users.update Meteor.userId(),
                            $inc: credit:10
                    
    	)

    # Template.quickbuying.events
    #     'click .buy_now': ->
    #         deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
    #         stripe_charge = parseFloat(deposit_amount)*100*1.02+20
    #         # stripe_charge = parseInt(deposit_amount*1.02+20)
    #
    #         # if confirm "add #{deposit_amount} credit?"
    #         Template.instance().checkout.open
    #             name: 'credit deposit'
    #             # email:Meteor.user().emails[0].address
    #             description: 'wc top up'
    #             amount: stripe_charge




    Template.meal_reviews.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'review'
    Template.meal_reviews.helpers
        can_leave_review: ->
            found_review =
                Docs.findOne
                    _author_id:Meteor.userId()
                    model:'review'
                    parent_id:Router.current().params.doc_id
            if found_review then false else true
        reviews: ->
            Docs.find
                model: 'review'
                parent_id:Router.current().params.doc_id







if Meteor.isServer
    Meteor.methods
        buy_serving: (meal_id)->
            meal = Docs.findOne meal_id
            console.log 'buying serving from meal', meal
    # Meteor.publish 'asset_reservations', (asset_id)->
    #     asset = Docs.findOne asset_id
    #     Docs.find
    #         model:'reservation'
    #         parent_id:asset_id
    #     # console.log model
    #     # console.log skip
    #     Docs.find {
    #         model:model
    #     }
