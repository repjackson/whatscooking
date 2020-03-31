if Meteor.isClient
    Router.route '/ingredients', (->
        @layout 'layout'
        @render 'ingredients'
        ), name:'ingredients'
    Router.route '/ingredient/:doc_id/edit', (->
        @layout 'layout'
        @render 'ingredient_edit'
        ), name:'ingredient_edit'
    Router.route '/ingredient/:doc_id/view', (->
        @layout 'layout'
        @render 'ingredient_view'
        ), name:'ingredient_view'


    Template.ingredients.onCreated ->
        @autorun => Meteor.subscribe 'ingredients',
            selected_tags.array()
            Session.get('ingredient_query')

    Template.ingredient_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'
    Template.ingredient_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.ingredient_view.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                ingredient_ids: $in: [@_id]

    Template.ingredients.helpers
        ingredients: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'ingredient'
            }, sort:title:1

    Template.ingredients.events
        'keyup .ingredient_search': _.throttle((e,t)->
            query = $('.ingredient_search').val()
            Session.set('ingredient_query', query)
            # console.log Session.get('current_query')
        , 1000)



        'click .add_ingredient': ->
            new_ingredient_id =
                Docs.insert
                    model:'ingredient'
            Router.go("/ingredient/#{new_ingredient_id}/edit")





if Meteor.isServer
    Meteor.publish 'ingredients', (
        selected_tags
        query
    )->
        match = {model:'ingredient'}

        if query
            match.title = $regex:"#{query}", $options: 'i'

        Docs.find match
