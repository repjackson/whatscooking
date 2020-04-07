if Meteor.isClient
    Router.route '/service/:doc_id/edit', (->
        @layout 'layout'
        @render 'service_edit'
        ), name:'service_edit'
    Router.route '/service/:doc_id/view', (->
        @layout 'layout'
        @render 'service_view'
        ), name:'service_view'


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
