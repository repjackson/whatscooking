if Meteor.isClient
    Router.route '/product/:doc_id/view', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'


    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'business_from_product_id', Router.current().params.doc_id


    Template.product_view.events
        

    Template.product_view.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                product_ids: $in: [@_id]



if Meteor.isServer
    Meteor.publish 'business_from_product_id', (product_id)->
        product = Docs.findOne product_id
        Docs.find 
            model:'business'
            _id:product.business_id