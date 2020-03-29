if Meteor.isClient
    Router.route '/meal/:doc_id/edit', (->
        @layout 'layout'
        @render 'meal_edit'
        ), name:'meal_edit'



    Template.meal_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'

    Template.meal_edit.helpers
        all_dishes: ->
            Docs.find
                model:'dish'
        can_delete: ->
            meal = Docs.findOne Router.current().params.doc_id
            if meal.reservation_ids
                if meal.reservation_ids.length > 1
                    false
                else
                    true
            else
                true


    Template.meal_edit.events
        'click .select_dish': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    dish_id: @_id


        'click .delete_meal': ->
            if confirm 'refund orders and cancel meal?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"
