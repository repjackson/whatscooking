if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'

    Template.user_ingredients.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'meal'

    Template.user_dashboard.events
        'click .offer_new_meal': ->
            new_meal_id =
                Docs.insert
                    model:'meal'
                    published:false
            Router.go("/meal/#{new_meal_id}/edit")


    Template.user_dashboard.helpers
        authored_meals: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'meal'
                _author_id:user._author_id

        cooked_meals: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'meal'
                _author_id:user._author_id
                
        bought_meals: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'meal'
                _author_id:user._author_id
