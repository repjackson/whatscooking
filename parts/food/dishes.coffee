if Meteor.isClient
    Router.route '/dishes', (->
        @layout 'layout'
        @render 'dishes'
        ), name:'dishes'
    Router.route '/dish/:doc_id/view', (->
        @layout 'layout'
        @render 'dish_view'
        ), name:'dish_view'


    Template.dishes.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'dish'

        # @autorun => Meteor.subscribe 'model_docs', 'dish'

    Template.dish_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'
        @autorun => Meteor.subscribe 'model_docs', 'meal'

    Template.dishes.events
        'click .add_dish': ->
            new_dish_id =
                Docs.insert
                    model:'dish'
            Router.go "/dish/#{new_dish_id}/edit"

    Template.dishes.helpers
        dishes: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'dish'
            }, sort:title:1


    Template.dish_reviews.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'review'
    Template.dish_reviews.helpers
        can_leave_review: ->
            found_review =
                Docs.findOne
                    _author_id:Meteor.userId()
                    model:'review'
                    parent_id:Router.current().params.doc_id
            if found_review then false else true
        reviews: ->
            Docs.find
                model: 'review'
                parent_id:Router.current().params.doc_id
