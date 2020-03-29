if Meteor.isClient
    Router.route '/user/:username/credit', (->
        @layout 'profile_layout'
        @render 'user_credit'
        ), name:'user_credit'

    Template.user_credit.onRendered ->
        
