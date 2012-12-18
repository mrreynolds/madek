###

MediaSets

Controller for MediaSets

###

class MediaSetsController

  @create: ->
    ms = undefined
    dialog = App.render "media_sets/create_dialog"
    form = dialog.find("form")
    form.bind "submit", (e)-> 
      e.preventDefault()
      ms = App.MediaSet.fromForm form
      if ms.validate()
        dialog.remove()
        $(ms).bind "created", -> window.location = "/media_sets/#{ms.id}"
        ms.create()
      else
        App.FormErrors.set form, ms.errors
      return false
    App.modal dialog

window.App.MediaSetsController = MediaSetsController

jQuery ->
  $("[data-create-set]").bind "click", -> do MediaSetsController.create