# TODO rename to form_submitter.coffee
$ = require("jquery")

module.exports = FormSubmitter =
  submitFromClick: (e) ->

    form = $(e.target).parent("form")

    # find the button and disable it immediately for feedback
    $(form.find("input[type=button]")).prop("disabled", true)
    $(form).addClass("submitting")

    # construct the query
    form_url = form.attr("action")
    values = $(form.find("input"))
    postData = {}
    values.each (i, e) ->
      postData[e.name] = e.value if e.name

    $.ajax
      type: 'POST'
      url: form_url
      data: postData
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
      success: ->
        $(form.find("input[type=button]")).prop("disabled", false)
        $(form).removeClass("submitting")
      error: (xhr, text, error) ->
        $(form.find("input[type=button]")).prop("disabled", false)
        $(form).removeClass("submitting")
        console.log error

    e.stopPropagation()
    e.preventDefault()
