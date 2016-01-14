Action = {
  attempt_sign_in: ({username, password}) ->
    subject = new Rx.AsyncSubject()
    action =  (dispatch, getState) ->
      Parse.User.logIn(username, password, {
        success: (user) ->
          dispatch type: 'USER_CHANGE'
          subject.onNext(error: null, response: user)
          subject.onCompleted()
          subject.dispose()
        error: (user, error) ->
          subject.onNext(error: error, response: user)
          subject.onCompleted()
          subject.dispose()
      })
    action.subject = subject
    return action
  attempt_sign_up: ({username, password}) ->
    subject = new Rx.AsyncSubject()
    action =  (dispatch, getState) ->
      Parse.User.signUp(username, password, {ACL: new Parse.ACL()}, {
        success: (user) ->
          dispatch type: 'USER_CHANGE'
          subject.onNext(error: null, response: user)
          subject.onCompleted()
          subject.dispose()
        error: (user, error) ->
          subject.onNext(error: error, response: user)
          subject.onCompleted()
          subject.dispose()
      })
    action.subject = subject
    return action

  logout: ->
    (dispatch, getState) ->
      Parse.User.logOut()
      dispatch type: 'USER_CHANGE'
}
