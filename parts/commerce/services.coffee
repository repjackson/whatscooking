if Meteor.isClient
    Router.route '/services', (->
        @layout 'layout'
        @render 'services'
        ), name:'services'
    Router.route '/service/:doc_id/edit', (->
        @layout 'layout'
        @render 'service_edit'
        ), name:'service_edit'
    Router.route '/service/:doc_id/view', (->
        @layout 'layout'
        @render 'service_view'
        ), name:'service_view'


    Template.services.onCreated ->
        @autorun => Meteor.subscribe 'services',
            selected_tags.array()
            Session.get('service_query')

    Template.service_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'
    Template.service_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.service_view.helpers
        meal_inclusions: ->
            Docs.find
                model:'meal'
                service_ids: $in: [@_id]

    Template.services.helpers
        services: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'service'
            }, sort:title:1

    Template.services.events
        'keyup .service_search': _.throttle((e,t)->
            query = $('.service_search').val()
            Session.set('service_query', query)
            # console.log Session.get('current_query')
        , 1000)



        'click .add_service': ->
            new_service_id =
                Docs.insert
                    model:'service'
            Router.go("/service/#{new_service_id}/edit")





if Meteor.isServer
    Meteor.publish 'services', (
        selected_tags
        query
    )->
        match = {model:'service'}

        if query
            match.title = $regex:"#{query}", $options: 'i'
        if selected_tags.length > 0
            match.tags = $all: selected_tags
        Docs.find match
