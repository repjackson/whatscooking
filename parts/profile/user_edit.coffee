if Meteor.isClient
    Router.route '/user/:user_id/edit/', (->
        @layout 'user_edit_layout'
        @render 'user_edit_info'
        ), name:'user_edit_home'
    Router.route '/user/:user_id/edit/info', (->
        @layout 'user_edit_layout'
        @render 'user_edit_info'
        ), name:'user_edit_info'
    Router.route '/user/:user_id/edit/friends', (->
        @layout 'user_edit_layout'
        @render 'user_edit_friends'
        ), name:'user_edit_friends'
    Router.route '/user/:user_id/edit/payment', (->
        @layout 'user_edit_layout'
        @render 'user_edit_payment'
        ), name:'user_edit_payment'
    Router.route '/user/:user_id/edit/account', (->
        @layout 'user_edit_layout'
        @render 'user_edit_account'
        ), name:'user_edit_account'
    Router.route '/user/:user_id/edit/styles', (->
        @layout 'user_edit_layout'
        @render 'user_edit_styles'
        ), name:'user_edit_styles'
    Router.route '/user/:user_id/edit/tutoring', (->
        @layout 'user_edit_layout'
        @render 'user_edit_tutoring'
        ), name:'user_edit_tutoring'
    Router.route '/user/:user_id/edit/alerts', (->
        @layout 'user_edit_layout'
        @render 'user_edit_alerts'
        ), name:'user_edit_alerts'
    Router.route '/user/:user_id/edit/coach', (->
        @layout 'user_edit_layout'
        @render 'user_edit_coach'
        ), name:'user_edit_coach'
    Router.route '/user/:user_id/edit/privacy', (->
        @layout 'user_edit_layout'
        @render 'user_edit_privacy'
        ), name:'user_edit_privacy'
    Router.route '/user/:user_id/edit/ads', (->
        @layout 'user_edit_layout'
        @render 'user_edit_ads'
        ), name:'user_edit_ads'
    Router.route '/user/:user_id/edit/tags', (->
        @layout 'user_edit_layout'
        @render 'user_edit_tags'
        ), name:'user_edit_tags'

    Template.user_edit_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_from_id', Router.current().params.user_id

    Template.user_edit_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.phone_editor.helpers
    #     'newNumber': ->
    #         Phoneformat.formatLocal 'US', Meteor.user().profile.phone

    Template.phone_editor.events
        'click .remove_phone': (event, template) ->
            Meteor.call 'UpdateMobileNo'
            return
        'click .resend_verification': (event, template) ->
            Meteor.call 'generateAuthCode', Meteor.userId(), Meteor.user().profile.phone
            bootbox.prompt 'We texted you a validation code. Enter the code below:', (result) ->
                code = result.toUpperCase()
                if Meteor.user().profile.phone_auth == code
                    Meteor.call 'updatePhoneVerified', (err, res) ->
                        if err
                            toastr.error err.reason
                        else
                            toastr.success 'Your phone was successfully verified!'
                        return
                else
                    toastr.success 'Your verification code does not match.'

        'click .update_phone': ->
            `var phone`
            phone = $('#phone').val()
            phone = Phoneformat.formatE164('US', phone)
            Meteor.call 'savePhone2', Meteor.userId(), phone, (error, result) ->
                if error
                    toastr.success 'There was an error processing your request.'
                else
                    if result.error
                        toastr.success result.message
                    else
                        bootbox.prompt result.message, (result) ->
                            code = result.toUpperCase()
                            if Meteor.user().profile.phone_auth == code
                                Meteor.call 'updatePhoneVerified'
                                toastr.success 'Your phone was successfully verified!'
                            else
                                toastr.success 'Your verification code does not match.'


    Template.user_edit_layout.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/users"

        "change input[name='profile_image']": (e) ->
            files = e.currentTarget.files
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.dir res
                    if err
                        console.error 'Error uploading', err
                    else
                        user = Meteor.users.findOne Router.current().params.user_id
                        Meteor.users.update user._id,
                            $set: "image_id": res.public_id
                    return


    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne Router.current().params.user_id
            if new_username
                if confirm "change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/user/#{new_username}")




    Template.password_edit.events
        'click .change_password': (e, t) ->
            Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
                if err
                    alert err.reason
                else
                    alert 'password changed'
                    # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            current_user = Meteor.users.findOne Router.current().params.user_id
            Meteor.call 'set_password', current_user._id, new_password, ->
                alert "password set to #{new_password}."

        'click .send_password_reset_email': (e,t)->
            current_user = Meteor.users.findOne Router.current().params.user_id
            Meteor.call 'send_password_reset_email', current_user._id, @address, ->
                alert 'password reset email sent'


        'click .send_enrollment_email': (e,t)->
            current_user = Meteor.users.findOne Router.current().params.user_id
            Meteor.call 'send_enrollment_email', current_user._id, @address, ->
                alert 'enrollment email sent'


    Template.emails_edit.helpers
        current_user: ->
            Meteor.users.findOne Router.current().params.user_id

    Template.emails_edit.events
        'click #add_email': ->
            new_email = $('#new_email').val().trim()
            current_user = Meteor.users.findOne Router.current().params.user_id

            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            valid_email = re.test(new_email)

            if valid_email
                Meteor.call 'add_email', current_user._id, new_email, (error, result) ->
                    if error
                        alert "error adding email: #{error.reason}"
                    else
                        # alert result
                        $('#new_email').val('')
                    return

        'click .remove_email': ->
            if confirm 'remove email?'
                current_user = Meteor.users.findOne Router.current().params.user_id
                Meteor.call 'remove_email', current_user._id, @address, (error,result)->
                    if error
                        alert "error removing email: #{error.reason}"


        'click .send_verification_email': (e,t)->
            current_user = Meteor.users.findOne Router.current().params.user_id
            Meteor.call 'verify_email', current_user._id, @address, ->
                alert 'verification email sent'
