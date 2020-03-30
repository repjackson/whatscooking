if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'


    Template.user_dashboard.events
        'click .offer_new_meal': ->
            new_meal_id =
                Docs.insert
                    model:'meal'
                    published:false
            Router.go("/meal/#{new_meal_id}/edit")

        'click .recalc_user_cloud': ->
            Meteor.call 'recalc_user_cloud', Router.current().params.username, ->
        'click .calc_test_sessions': ->
            Meteor.call 'calc_test_sessions', Router.current().params.username, ->
        'click .recalc_user_act_stats': ->
            Meteor.call 'recalc_user_act_stats', Router.current().params.username, ->

    Template.user_dashboard.helpers
        ssd: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.findOne
                model:'student_stats'
                user_id:user._id
        student_classrooms: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'classroom'
                student_ids: $in: [user._id]
        user_events: ->
            Docs.find {
                model:'log_event'
            }, sort: _timestamp: -1
        # user_credits: ->
        #     Docs.find {
        #         model:'log_event'
        #         event_type:'credit'
        #     }, sort: _timestamp: -1
        # user_debits: ->
        #     Docs.find {
        #         model:'log_event'
        #         event_type:'debit'
        #     }, sort: _timestamp: -1
        user_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids
