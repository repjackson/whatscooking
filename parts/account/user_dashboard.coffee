if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'


    Template.user_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'
        # @autorun => Meteor.subscribe 'model_docs', 'ingredient'
        @autorun => Meteor.subscribe 'model_docs', 'dish'
        @autorun => Meteor.subscribe 'user_orders', Router.current().params.username

    Template.user_dashboard.events
        'click .offer_new_meal': ->
            new_meal_id =
                Docs.insert
                    model:'meal'
                    published:false
            Router.go("/meal/#{new_meal_id}/edit")


    Template.user_dashboard.helpers
        user_dishes: ->
            user = Meteor.users.findOne username:Router.current().params.username
            console.log user
            Docs.find
                model:'dish'
                _author_id:user._id


        authored_meals: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'meal'
                _author_id:user._id

        offered_meals: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'meal'
                _author_id:user._id

        cooked_meals: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'meal'
                _author_id:user._id

        recent_orders: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'order'
                _author_id:user._id
            }, sort: _timestamp: -1



if Meteor.isServer
    Meteor.publish 'user_orders', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'order'
            _author_id:user._id
