if Meteor.isClient
    Router.route '/dish/:doc_id/view', (->
        @layout 'layout'
        @render 'dish_view'
        ), name:'dish_view'


    Template.dish_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'
        @autorun => Meteor.subscribe 'model_docs', 'meal'
        @autorun => Meteor.subscribe 'users'
