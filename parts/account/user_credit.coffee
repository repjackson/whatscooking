if Meteor.isClient
    Router.route '/user/:username/credit', (->
        @layout 'profile_layout'
        @render 'user_credit'
        ), name:'user_credit'

    Template.user_credit.onCreated ->
        @autorun => Meteor.subscribe 'user_transactions', Router.current().params.username

        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/wc_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) ->
                amount = parseInt(Session.get('topup_amount'))
                # product = Docs.findOne Router.current().params.doc_id
                charge =
                    amount: amount*100
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'strip_credit_topup', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        Swal.fire(
                            'topup processed',
                            ''
                            'success'
                        Docs.insert
                            model:'transaction'
                            transaction_type:'topup'
                            amount:amount
                        Meteor.users.update Meteor.userId(),
                            $inc: credit:amount
                        )
        )

    Template.user_credit.onRendered ->

    Template.user_credit.events
        'click .add_five_credits': ->
            # console.log Template.instance()
            # if confirm 'add 5 credits?'
            Session.set('topup_amount',5)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'wc top up'
                amount: 500


        'click .add_ten_credits': ->
            # console.log Template.instance()
            # if confirm 'add 10 credits?'
            Session.set('topup_amount',10)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'wc top up'
                amount: 1000


        'click .add_twenty_credits': ->
            # console.log Template.instance()
            # if confirm 'add 20 credits?'
            Session.set('topup_amount',20)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'wc top up'
                amount: 2000


        'click .add_fifty_credits': ->
            # console.log Template.instance()
            # if confirm 'add 50 credits?'
            Session.set('topup_amount',50)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'wc top up'
                amount: 5000


        'click .add_hundred_credits': ->
            # console.log Template.instance()
            # if confirm 'add 100 credits?'
            Session.set('topup_amount',100)
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'wc top up'
                amount: 10000



            # Swal.fire({
            #     title: 'add 5 credits?'
            #     text: "this will charge you $5"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result)=>
            #     if result.value
            #         Session.set('topup_amount',5)
            #         Template.instance().checkout.open
            #             name: 'credit deposit'
            #             # email:Meteor.user().emails[0].address
            #             description: 'wc top up'
            #             amount: 5
            #
            #         # Meteor.users.update @_author_id,
            #         #     $inc:credit:@order_price
            #         Swal.fire(
            #             'topup initiated',
            #             ''
            #             'success'
            #         )
            # )

    Template.user_credit.helpers
        user_credits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'transaction'
                _author_id: current_user._id


if Meteor.isServer
    Meteor.publish 'user_transactions', (username)->
        current_user = Meteor.users.findOne(username:username)
        Docs.find
            model:'transaction'
            _author_id: current_user._id
