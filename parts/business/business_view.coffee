Router.route '/business/:business_slug', (->
    @layout 'business_layout'
    @render 'business_dashboard'
    ), name:'business_dashboard'
Router.route '/business/:business_slug/members', (->
    @layout 'business_layout'
    @render 'business_members'
    ), name:'business_members'
Router.route '/business/:business_slug/credit', (->
    @layout 'business_layout'
    @render 'business_credit'
    ), name:'business_credit'
Router.route '/business/:business_slug/meals', (->
    @layout 'business_layout'
    @render 'business_meals'
    ), name:'business_meals'
Router.route '/business/:business_slug/dishes', (->
    @layout 'business_layout'
    @render 'business_dishes'
    ), name:'business_dishes'
Router.route '/business/:business_slug/voting', (->
    @layout 'business_layout'
    @render 'business_voting'
    ), name:'business_voting'
Router.route '/business/:business_slug/events', (->
    @layout 'business_layout'
    @render 'business_events'
    ), name:'business_events'
Router.route '/business/:business_slug/food', (->
    @layout 'business_layout'
    @render 'business_food'
    ), name:'business_food'
Router.route '/business/:business_slug/products', (->
    @layout 'business_layout'
    @render 'business_products'
    ), name:'business_products'
Router.route '/business/:business_slug/services', (->
    @layout 'business_layout'
    @render 'business_services'
    ), name:'business_services'
Router.route '/business/:business_slug/stats', (->
    @layout 'business_layout'
    @render 'business_stats'
    ), name:'business_stats'
Router.route '/business/:business_slug/transactions', (->
    @layout 'business_layout'
    @render 'business_transactions'
    ), name:'business_transactions'
Router.route '/business/:business_slug/messages', (->
    @layout 'business_layout'
    @render 'business_messages'
    ), name:'business_messages'
Router.route '/business/:business_slug/posts', (->
    @layout 'business_layout'
    @render 'business_posts'
    ), name:'business_posts'
Router.route '/business/:business_slug/settings', (->
    @layout 'business_layout'
    @render 'business_settings'
    ), name:'business_settings'



if Meteor.isClient
    Template.business_layout.onCreated ->
        @autorun => Meteor.subscribe 'business_by_slug', Router.current().params.business_slug
        # @autorun => Meteor.subscribe 'children', 'business_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'business_dishes', Router.current().params.business_slug
    Template.business_layout.helpers
        current_business: ->
            Docs.findOne
                model:'business'
                slug: Router.current().params.business_slug

    Template.business_dashboard.events
        'click .refresh_business_stats': ->
            Meteor.call 'calc_business_stats', Router.current().params.business_slug, ->
        # 'click .join': ->
        #     Docs.update
        #         model:'business'
        #         _author_id: Meteor.userId()
        # 'click .business_leave': ->
        #     my_business = Docs.findOne
        #         model:'business'
        #         _author_id: Meteor.userId()
        #         ballot_id: Router.current().params.doc_id
        #     if my_business
        #         Docs.update my_business._id,
        #             $set:value:'no'
        #     else
        #         Docs.insert
        #             model:'business'
        #             ballot_id: Router.current().params.doc_id
        #             value:'no'


if Meteor.isServer
    Meteor.publish 'business_dishes', (business_slug)->
        business = Docs.findOne
            model:'business'
            slug:business_slug
        Docs.find
            model:'dish'
            _id: $in: business.dish_ids
