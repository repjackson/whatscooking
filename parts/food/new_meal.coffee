if Meteor.isClient
    Router.route '/new_meal', (->
        @layout 'layout'
        @render 'new_meal'
        ), name:'new_meal'

    Router.route '/meal_logistics/:doc_id', (->
        @layout 'layout'
        @render 'meal_logistics'
        ), name:'meal_logistics'


    Template.new_meal.onCreated ->
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'
        @autorun => Meteor.subscribe 'model_docs', 'dish'
        @autorun => Meteor.subscribe 'model_docs', 'meal'

    Template.new_meal.onRendered ->
        content =
            Docs.find(model:'dish').fetch()
        console.log content
        Meteor.setTimeout ->
            $('.ui.search')
              .search({
                source: content
              })
        , 1000

    Template.new_meal.helpers
        dish_ingredients: ->
            dish = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'ingredient'
                _id: $in:dish.ingredient_ids

        ingredient_results: -> Session.get('ingredient_results')

        recent_meals: ->
            Docs.find {
                model:'meal'
            }, limit:5

        your_dishs: ->
            Docs.find
                model:'dish'
                _author_id:Meteor.userId()
        possible_dishs: ->
            Docs.find
                model:'dish'



    Template.new_meal.events
        'keyup .search_ingredient': ->
            val = $('.search_ingredient').val()
            console.log val
            results = Docs.find({
                title: {$regex:"#{val}", $options: 'i'}
                model:'ingredient'
                },{limit:10}).fetch()
            Session.set('ingredient_results', results)

        'keyup .new_dish_title': (e,t)->
            if e.which is 13
                val = $('.new_dish_title').val()
                console.log val
                new_dish_id =
                    Docs.insert
                        title: val
                        model:'dish'
                Router.go("/dish/#{new_dish_id}/edit")

        'click .select_ingredient': ->
            console.log @

        'click .select_meal': ->
            console.log @
            if @dish_id
                new_meal_id =
                    Docs.insert
                        model:'meal'
            else
                new_meal_id =
                    Docs.insert
                        model:'meal'
                        dish_id:@dish_id
            Router.go("/meal_logistics/#{new_meal_id}")

        'click .select_dish': ->
            console.log @
            new_meal_id =
                Docs.insert
                    model:'meal'
                    dish_id:@_id
            Router.go("/meal_logistics/#{new_meal_id}")


    Template.meal_logistics.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'
        @autorun => Meteor.subscribe 'model_docs', 'meal'
        @autorun => Meteor.subscribe 'model_docs', 'dish'


    Template.meal_logistics.helpers
        meal_dish: ->
            meal = Docs.findOne Router.current().params.doc_id
            Docs.findOne(
                _id: meal.dish_id
            )
