if Meteor.isClient
    Router.route '/user/:username/ingredients', (->
        @layout 'profile_layout'
        @render 'user_ingredients'
        ), name:'user_ingredients'


    Template.user_ingredients.onCreated ->
        @autorun -> Meteor.subscribe 'user_authored_ingredients', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_liked_ingredients', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_disliked_ingredients', Router.current().params.username
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        Meteor.setTimeout ->
            $('.progress').progress();
        , 2000

if Meteor.isServer
    Meteor.publish 'user_authored_ingredients', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'ingredient'
            _author_id: user_id

    Meteor.publish 'user_liked_ingredients', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'ingredient'
            upvoter_ids: $in: [user_id]

    Meteor.publish 'user_disliked_ingredients', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'ingredient'
            downvoter_ids: $in: [user_id]
