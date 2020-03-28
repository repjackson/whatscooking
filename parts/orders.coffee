if Meteor.isClient
    Router.route '/orders', (->
        @layout 'layout'
        @render 'orders'
        ), name:'orders'


    Template.orders.onCreated ->
        @autorun => Meteor.subscribe 'docs', 'order'

        # @autorun => Meteor.subscribe 'model_docs', 'order'

    # Template.order_view.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # Template.order_edit.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.orders.helpers
        orders: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'order'
            }, sort:title:1


    # Template.order_reviews.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'review'
    # Template.order_reviews.helpers
    #     can_leave_review: ->
    #         found_review =
    #             Docs.findOne
    #                 _author_id:Meteor.userId()
    #                 model:'review'
    #                 parent_id:Router.current().params.doc_id
    #         if found_review then false else true
    #     reviews: ->
    #         Docs.find
    #             model: 'review'
    #             parent_id:Router.current().params.doc_id
    #


    Template.orders.onCreated ->
        @autorun => Meteor.subscribe 'asset_orders', Router.current().params.doc_id
        @editing = new ReactiveVar false
    Template.orders.events
        'click .new_order': ->
            Docs.insert
                model:'order'
                parent_id:Router.current().params.doc_id

        'click .toggle_editing': (e,t)->
            t.editing.set !t.editing.get()

    Template.orders.helpers
        taken_slots: ->
            asset = Docs.findOne Router.current().params.doc_id
            order_count = Docs.find(model:'order').count()
        money_earned: ->
            asset = Docs.findOne Router.current().params.doc_id
            order_count = Docs.find(model:'order').count()
            asset.slot_price*order_count
        available_slots: ->
            asset = Docs.findOne Router.current().params.doc_id
            order_count = Docs.find(model:'order').count()
            asset.slots_available - order_count
            # console.log asset.slots_available
        is_editing: -> Template.instance().editing.get()
        my_order: ->
            Docs.findOne
                _author_id:Meteor.userId()
                model:'order'
                parent_id:Router.current().params.doc_id

        can_reserve: ->
            found_order =
                Docs.findOne
                    _author_id:Meteor.userId()
                    model:'order'
                    parent_id:Router.current().params.doc_id
            if found_order then false else true
        existing_order: ->
            found_order =
                Docs.findOne
                    _author_id:Meteor.userId()
                    model:'order'
                    parent_id:Router.current().params.doc_id
        orders: ->
            Docs.find
                model: 'order'
                parent_id:Router.current().params.doc_id





if Meteor.isServer
    Meteor.publish 'asset_orders', (asset_id)->
        asset = Docs.findOne asset_id
        Docs.find
            model:'order'
            parent_id:asset_id
    #     # console.log model
    #     # console.log skip
    #     Docs.find {
    #         model:model
    #     }
