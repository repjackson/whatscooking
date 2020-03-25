if Meteor.isClient
    Router.route '/recipe/:doc_id/edit', (->
        @layout 'layout'
        @render 'recipe_edit'
        ), name:'recipe_edit'

    Template.recipe_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'


    Template.recipe_edit.helpers
        recipe_ingredients: ->
            recipe = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'ingredient'
                _id: $in:recipe.ingredient_ids

        ingredient_results: -> Session.get('ingredient_results')

    Template.recipe_edit.events
        'keyup .search_ingredient': ->
            val = $('.search_ingredient').val()
            console.log val
            results = Docs.find({
                title: {$regex:"#{val}", $options: 'i'}
                model:'ingredient'
                },{limit:10}).fetch()
            Session.set('ingredient_results', results)


        'click .select_ingredient': ->
            console.log @
