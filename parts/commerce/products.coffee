if Meteor.isClient
    # Router.route '/product/:doc_id/edit', (->
    #     @layout 'layout'
    #     @render 'product_edit'
    #     ), name:'product_edit'
    Router.route '/product/:doc_id/view', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'


    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'



    Template.product_view.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                product_ids: $in: [@_id]
