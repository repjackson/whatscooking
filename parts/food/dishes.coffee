if Meteor.isClient
    Router.route '/dishes', (->
        @layout 'layout'
        @render 'dishes'
        ), name:'dishes'

    Template.dishes.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'dish'

        # @autorun => Meteor.subscribe 'model_docs', 'dish'

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
