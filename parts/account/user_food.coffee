if Meteor.isClient
    Router.route '/user/:username/ingredients', (->
        @layout 'profile_layout'
        @render 'user_ingredients'
        ), name:'user_ingredients'

    Router.route '/user/:username/dishes', (->
        @layout 'profile_layout'
        @render 'user_dishes'
        ), name:'user_dishes'


    Template.user_ingredients.onCreated ->
        @autorun -> Meteor.subscribe 'user_authored_ingredients', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_liked_ingredients', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_disliked_ingredients', Router.current().params.username

    Template.user_ingredients.helpers
        user_authored_ingredients: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'ingredient'
                _author_id: user._id
        user_liked_ingredients: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'ingredient'
                upvoter_ids: $in: [user._id]
        user_disliked_ingredients: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'ingredient'
                downvoter_ids: $in: [user._id]




    Template.user_dishes.onCreated ->
        @autorun -> Meteor.subscribe 'user_authored_dishes', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_liked_dishes', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_disliked_dishes', Router.current().params.username
    Template.user_dishes.helpers
        user_authored_dishes: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'dish'
                _author_id: user._id
        user_liked_dishes: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'dish'
                upvoter_ids: $in: [user._id]
        user_disliked_dishes: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'dish'
                downvoter_ids: $in: [user._id]












if Meteor.isServer
    Meteor.publish 'user_authored_ingredients', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'ingredient'
            _author_id: user._id

    Meteor.publish 'user_liked_ingredients', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'ingredient'
            upvoter_ids: $in: [user._id]

    Meteor.publish 'user_disliked_ingredients', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'ingredient'
            downvoter_ids: $in: [user._id]




    Meteor.publish 'user_authored_dishes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'dish'
            _author_id: user._id

    Meteor.publish 'user_liked_dishes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'dish'
            upvoter_ids: $in: [user._id]

    Meteor.publish 'user_disliked_dishes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'dish'
            downvoter_ids: $in: [user._id]
