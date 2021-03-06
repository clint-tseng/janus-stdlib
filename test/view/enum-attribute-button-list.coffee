should = require('should')

{ Varying, Model, DomView, template, find, from, List, attribute, App, Library } = require('janus')
{ LiteralView } = require('../../lib/view/literal')
{ ListView } = require('../../lib/view/list')
{ ListSelectItemView, EnumAttributeListEditView, registerWith } = require('../../lib/view/enum-attribute-button-list')

$ = require('janus-dollar')

# register LiteralView for our tests to make our lives easier.
testLibrary = new Library()
testLibrary.register(Number, LiteralView, context: 'summary')
testLibrary.register(Number, ListSelectItemView, context: 'select-wrapper')
testLibrary.register(List, ListView)
testApp = new App( views: testLibrary )

checkListItem = (dom, inner) ->
  dom.is('div').should.equal(true)
  dom.hasClass('janus-list-selectItem').should.equal(true)

  contents = dom.children('.janus-list-selectItem-contents').children(':first')
  contents.length.should.equal(1)
  inner(contents)

checkLiteral = (dom, text) ->
  dom.is('span').should.equal(true)
  dom.hasClass('janus-literal').should.equal(true)
  dom.text().should.equal(text)

describe 'view', ->
  describe 'enum attribute (button list)', ->
    it 'should render an unordered list element of the appropriate classes (and a wrapper)', ->
      dom = (new EnumAttributeListEditView(new attribute.Enum(new Model(), 'test'), { app: testApp })).artifact()
      dom.is('div').should.equal(true)
      dom.children().length.should.equal(1)

      listDom = dom.children().eq(0)
      listDom.is('div').should.equal(true)
      listDom.children().length.should.equal(0)

    it 'should render a wrapper for each list item', ->
      class TestAttribute extends attribute.Enum
        _values: -> [ 1, 2, 3 ]
      dom = (new EnumAttributeListEditView(new TestAttribute(new Model(), 'test'), { app: testApp })).artifact()
      listDom = dom.children().eq(0)

      listDom.children().length.should.equal(3)
      for label, idx in [ 1, 2, 3 ]
        checkListItem(listDom.children().eq(idx), (inner) -> checkLiteral(inner, label.toString()))

    it 'should deal with from expressions', ->
      class TestAttribute extends attribute.Enum
        _values: -> from('options')

      model = new Model({ options: [ 1, 2, 3 ] })
      dom = (new EnumAttributeListEditView(new TestAttribute(model, 'test'), { app: testApp })).artifact()
      listDom = dom.children().eq(0)

      listDom.children().length.should.equal(3)
      for label, idx in [ 1, 2, 3 ]
        checkListItem(listDom.children().eq(idx), (inner) -> checkLiteral(inner, label.toString()))

    it 'should allow chaining on its item render mutator', ->
      library = new Library()
      library.register(Number, LiteralView, context: 'test')
      library.register(Number, ListSelectItemView, context: 'select-wrapper')
      library.register(List, ListView)
      app = new App( views: library )

      renderItem = (render) -> render.context('test')
      class TestAttribute extends attribute.Enum
        _values: -> [ 1, 2, 3 ]
      dom = (new EnumAttributeListEditView(new TestAttribute(new Model(), 'test'), { app, renderItem })).artifact()

      targets = dom.find('> div.janus-list > .janus-list-selectItem > .janus-list-selectItem-contents > .janus-literal')
      targets.length.should.equal(3)
      for idx in [0..2]
        checkLiteral(targets.eq(idx), (idx + 1).toString())

    it 'should allow chaining on its wrapper render mutator', ->
      library = new Library()
      library.register(Number, LiteralView, context: 'summary')
      library.register(Number, ListSelectItemView, context: 'test')
      library.register(List, ListView)
      app = new App( views: library )

      renderWrapper = (render) -> render.context('test')
      class TestAttribute extends attribute.Enum
        _values: -> [ 1, 2, 3 ]
      dom = (new EnumAttributeListEditView(new TestAttribute(new Model(), 'test'), { app, renderWrapper })).artifact()
      listDom = dom.children()

      for label, idx in [ 1, 2, 3 ]
        checkListItem(listDom.children().eq(idx), (inner) -> checkLiteral(inner, label.toString()))

    it 'should default the button label to "Select"', ->
      class TestAttribute extends attribute.Enum
        _values: -> [ 1, 2, 3 ]
      dom = (new EnumAttributeListEditView(new TestAttribute(new Model(), 'test'), { app: testApp })).artifact()

      dom.find('button:first').text().should.equal('Select')

    it 'should allow specifying the button label', ->
      class TestAttribute extends attribute.Enum
        _values: -> [ 1, 2, 3 ]
      v = new Varying('test')
      buttonLabel = -> v
      dom = (new EnumAttributeListEditView(new TestAttribute(new Model(), 'test'), { app: testApp, buttonLabel })).artifact()

      dom.find('button:first').text().should.equal('test')

      v.set('test 2')
      dom.find('button:first').text().should.equal('test 2')

    it 'should apply a selected class to the selected item', ->
      class TestAttribute extends attribute.Enum
        _values: -> [ 1, 2, 3 ]
      m = new Model({ test: 2 })
      dom = (new EnumAttributeListEditView(new TestAttribute(m, 'test'), { app: testApp })).artifact()

      wrappers = dom.find('> .janus-list > .janus-list-selectItem')
      wrappers.filter('.checked').length.should.equal(1)
      wrappers.eq(1).hasClass('checked').should.equal(true)

      m.set('test', 3)
      wrappers.filter('.checked').length.should.equal(1)
      wrappers.eq(2).hasClass('checked').should.equal(true)

    it 'should update the model value when select is clicked', ->
      class TestAttribute extends attribute.Enum
        _values: -> [ 1, 2, 3 ]
      m = new Model()
      view = new EnumAttributeListEditView(new TestAttribute(m, 'test'), { app: testApp })
      dom = view.artifact()
      view.wireEvents()

      wrappers = dom.find('> .janus-list > .janus-list-selectItem')

      wrappers.eq(1).find('button').click()
      m.get_('test').should.equal(2)

      wrappers.eq(2).find('button').click()
      m.get_('test').should.equal(3)

    it 'should register the wrapper against a basic set', ->
      library = new Library()
      registerWith(library)

      library.get(1, context: 'select-wrapper').should.equal(ListSelectItemView)
      library.get(true, context: 'select-wrapper').should.equal(ListSelectItemView)
      library.get(false, context: 'select-wrapper').should.equal(ListSelectItemView)
      library.get('test', context: 'select-wrapper').should.equal(ListSelectItemView)
      library.get(new Model(), context: 'select-wrapper').should.equal(ListSelectItemView)

    describe 'attach', ->
      it 'should leave the existing elements alone', ->
        class TestAttribute extends attribute.Enum
          _values: -> new List([ 1, 2, 3, 4, 5 ])
        view = new EnumAttributeListEditView(new TestAttribute(new Model(), 'test'), { app: testApp })
        dom = $('<div><div><div><span>dummy 1</span></div><div><span>dummy 2</span></div><div><span>dummy 3</span></div><div><span>dummy 4</span></div><div><span>dummy 5</span></div></div></div>')
        view.attach(dom)

        dom.children().children().eq(0).text().should.equal('dummy 1')
        dom.children().children().eq(4).text().should.equal('dummy 5')

      it 'should replace appropriate elements', ->
        l = new List([ 1, 2, 3, 4, 5 ])
        class TestAttribute extends attribute.Enum
          _values: -> l
        view = new EnumAttributeListEditView(new TestAttribute(new Model(), 'test'), { app: testApp })
        selectDom = (new ListSelectItemView()).dom()
        dom = $('<div><div><div>dummy 1</div><div>dummy 2</div><div></div><div>dummy 4</div><div>dummy 5</div></div></div>')
        dom.children().eq(2).append(selectDom)
        view.attach(dom)

        l.set(2, 33)
        checkListItem(dom.children().children().eq(2), (inner) -> checkLiteral(inner, '33'))

