if Meteor.isClient
    Router.route '/meal/:doc_id/edit', (->
        @layout 'layout'
        @render 'meal_edit'
        ), name:'meal_edit'



    Template.meal_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'recipe'
    Template.meal_edit.helpers
        # 'click .'
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
        'click .delete_meal': ->
            if confirm 'delete?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"
