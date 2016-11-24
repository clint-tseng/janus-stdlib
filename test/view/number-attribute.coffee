should = require('should')

{ Model, attribute } = require('janus')
{ NumberAttributeEditView } = require('../../lib/view/number-attribute')

$ = require('../../lib/util/dollar')

describe 'view', ->
  describe 'number attribute', ->
    it 'renders an input tag of the appropriate type', ->
      dom = (new NumberAttributeEditView(new attribute.NumberAttribute(new Model(), 'test'))).artifact()
      dom.is('input').should.equal(true)
      dom.attr('type').should.equal('number')
