if Meteor.isClient
    Router.route '/meals', (->
        @layout 'layout'
        @render 'meals'
        ), name:'meals'

    Template.meal_widget.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'



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
