{ Varying, DomView, mutators, from, template, find, Base, List } = require('janus')

$ = require('../util/dollar')
{ ListView } = require('./list')

class ListEditItemView extends DomView
  @_dom: -> $('
    <div class="janus-list-editItem">
      <a class="janus-list-editItem-moveUp">Move Up</a>
      <a class="janus-list-editItem-moveDown">Move Down</a>
      <a class="janus-list-editItem-remove">Remove</a>
      <div class="janus-list-editItem-dragHandle"></div>
      <div class="janus-list-editItem-contents"></div>
    </div>
  ')
  @_template: template(
    find('.janus-list-editItem-moveUp').classed('disabled',
      from.self().flatMap((view) -> view.options.list.watchAt(0))
        .and.self().map((view) -> view.subject)
        .all.map((first, item) -> first is item))

    find('.janus-list-editItem-moveDown').classed('disabled',
      from.self().flatMap((view) -> view.options.list.watchAt(-1))
        .and.self().map((view) -> view.subject)
        .all.map((last, item) -> last is item))
  )

  # we have to render ourselves, as we need to enable options.renderItem().
  # but, it's really not that bad. we just rely on a mutator anyway.
  _render: ->
    dom = this.constructor._dom()

    # render our inner contents.
    contentsBinding = this.options.renderItem(mutators.render(from(this.subject)))(dom.find('.janus-list-editItem-contents'), (x) => this.constructor._point(x, this))

    # now render the bindings actually defined in our own template.
    this._bindings = this.constructor._template(dom)((x) => this.constructor._point(x, this))
    this._bindings.push(contentsBinding)

    dom

  _wireEvents: ->
    dom = this.artifact()
    subject = this.subject
    list = this.options.list

    # handle remove button events.
    dom.children('.janus-list-editItem-remove').on('click', (event) =>
      event.preventDefault()
      list.remove(subject)
    )

    # handle move button events.
    moveHandler = (direction) -> (event) ->
      event.preventDefault()
      moveButton = $(this)
      return if moveButton.hasClass('disabled')

      # update the internal model.
      li = moveButton.closest('li')
      dest = li.prevAll().length + direction
      list.move(subject, dest)

      # List#move does not emit added/removed so manipulate the dom ourselves.
      parent = li.parent()
      li.remove()
      parent.children().eq(dest).before(li)
    dom.children('.janus-list-editItem-moveUp').on('click', moveHandler(-1))
    dom.children('.janus-list-editItem-moveDown').on('click', moveHandler(1))

    # handle external move notifications.
    # rather than handle the dragHandle ourselves and impose our opinion on how
    # it should be done, feel free to attach your own library, and all you have
    # to do is trigger 'janus-list-itemMoved' on the dom node that moved.
    this.on('appended', =>
      dom.closest('li').on('janus-itemMoved', =>
        list.move(subject, $(this).prevAll().length)
      )
    )

class ListEditView extends ListView
  @_dom: -> $('<ul class="janus-list janus-list-edit"/>')
  _initialize: ->
    super()

    # the magic here is in this shuffle: we save off the requested renderItem,
    # shunt it onto the wrapper child we request instead (which itself may be
    # overridden using renderWrapper), and default the child to an edit context
    # by default. (we also provide a reference to the subject list)
    oldRenderItem = this.options.renderItem
    modifiedRenderItem = (render) -> oldRenderItem(render.context('edit')) # default to edit
    this.options.renderWrapper ?= (x) -> x
    this.options.renderItem = (render) =>
      this.options.renderWrapper(
        render
          .context('edit-wrapper')
          .options({ renderItem: modifiedRenderItem, list: this.subject })
      )

module.exports = {
  ListEditItemView,
  ListEditView,
  registerWith: (library) ->
    # TODO: eventually possibly allow '*' or something.
    library.register(Number, ListEditItemView, context: 'edit-wrapper')
    library.register(Boolean, ListEditItemView, context: 'edit-wrapper')
    library.register(String, ListEditItemView, context: 'edit-wrapper')
    library.register(Base, ListEditItemView, context: 'edit-wrapper')
    library.register(List, ListEditView, context: 'edit')
}
