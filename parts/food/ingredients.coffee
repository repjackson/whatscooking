if Meteor.isClient
    Router.route '/ingredient/:doc_id/view', (->
        @layout 'layout'
        @render 'ingredient_view'
        ), name:'ingredient_view'


    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'

    Template.ingredient_view.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                ingredient_ids: $in: [@_id]
