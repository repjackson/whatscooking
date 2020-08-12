Router.route '/business/:doc_id/edit', -> @render 'business_edit'

if Meteor.isClient
    Template.business_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'business_options', Router.current().params.doc_id
    Template.business_edit.events
        'click .add_option': ->
            Docs.insert
                model:'business_option'
                ballot_id: Router.current().params.doc_id
    Template.business_edit.helpers
        options: ->
            Docs.find
                model:'business_option'
