# Router.route '/business/:doc_id/edit', -> @render 'business_products'

if Meteor.isClient
    Template.business_products.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'business_products', Router.current().params.business_slug
    Template.business_products.events
        'click .add_product': ->
            business = 
                Docs.findOne
                    slug:Router.current().params.business_slug
                    model:'business'
            if business
                new_id = 
                    Docs.insert
                        model:'product'
                        business_id: business._id
                Router.go "/product/#{new_id}/edit"
    Template.business_products.helpers
        products: ->
            business = 
                Docs.findOne
                    slug:Router.current().params.business_slug
                    model:'business'
            Docs.find
                model:'product'
                business_id:business._id


if Meteor.isServer
    Meteor.publish 'business_products', (business_slug)->
        business = 
            Docs.findOne 
                model:'business'
                slug:business_slug
        Docs.find 
            model:'product'
            business_id:business._id