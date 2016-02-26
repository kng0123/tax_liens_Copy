var Actions = {
  attempt_sign_in: function({username, password}) {
    let action =  function(dispatch, getState) {
      dispatch({type: 'FORM_SUBMIT', name:'sign_in'})
      Parse.User.logIn(username, password, {
        success: function(user){
          dispatch({type: 'FORM_RESPONSE', name:'sign_in'})
          dispatch({type: 'USER_CHANGE'})
        },
        error: function(user, error) {
          dispatch({type: 'FORM_RESPONSE', error:error, name:'sign_in'})
        }
      })
    }
    return action
  }
  // attempt_sign_up: ({username, password}) ->
  //   subject = new Rx.AsyncSubject()
  //   action =  (dispatch, getState) ->
  //     Parse.User.signUp(username, password, {ACL: new Parse.ACL()}, {
  //       success: (user) ->
  //         dispatch type: 'USER_CHANGE'
  //         subject.onNext(error: null, response: user)
  //         subject.onCompleted()
  //         subject.dispose()
  //       error: (user, error) ->
  //         subject.onNext(error: error, response: user)
  //         subject.onCompleted()
  //         subject.dispose()
  //     })
  //   action.subject = subject
  //   return action
  //
  // logout: ->
  //   (dispatch, getState) ->
  //     Parse.User.logOut()
  //     dispatch type: 'USER_CHANGE'
}

export default Actions;
