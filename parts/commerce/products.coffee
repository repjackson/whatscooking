if Meteor.isClient
    Router.route '/products', (->
        @layout 'layout'
        @render 'products'
        ), name:'products'
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'
    Router.route '/product/:doc_id/view', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'


    Template.products.onCreated ->
        @autorun => Meteor.subscribe 'products',
            selected_tags.array()
            Session.get('product_query')

    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'
    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id



    Template.product_view.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                product_ids: $in: [@_id]




    Template.products.helpers
        products: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'product'
            }, sort:title:1

    Template.products.events
        'keyup .product_search': _.throttle((e,t)->
            query = $('.product_search').val()
            Session.set('product_query', query)
            # console.log Session.get('current_query')
        , 1000)



        'click .add_product': ->
            new_product_id =
                Docs.insert
                    model:'product'
            Router.go("/product/#{new_product_id}/edit")





if Meteor.isServer
    Meteor.publish 'products', (
        selected_tags
        query
    )->
        match = {model:'product'}

        if query
            match.title = $regex:"#{query}", $options: 'i'
        if selected_tags.length > 0
            match.tags = $all: selected_tags
        Docs.find match
