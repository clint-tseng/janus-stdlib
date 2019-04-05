// Generated by CoffeeScript 1.11.1
(function() {
  var $, Base, DomView, Enum, EnumAttributeListEditView, List, ListSelectItemView, Varying, find, from, identity, mutators, ref, template,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  ref = require('janus'), Varying = ref.Varying, DomView = ref.DomView, from = ref.from, template = ref.template, find = ref.find, mutators = ref.mutators, Base = ref.Base, List = ref.List;

  Enum = require('janus').attribute.Enum;

  identity = require('janus').util.identity;

  $ = require('janus-dollar');

  ListSelectItemView = (function(superClass) {
    var base, ref1;

    extend(_Class, superClass);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    _Class.prototype._render = function() {
      return this._doRender(true);
    };

    _Class.prototype._attach = function(dom) {
      this._doRender(false);
    };

    _Class.prototype._doRender = function(immediate) {
      var contentBinding, contentWrapper, dom, point;
      dom = this.dom();
      contentWrapper = dom.children().eq(1);
      point = this.pointer();
      contentBinding = this.options.renderItem(mutators.render(from(this.subject)))(contentWrapper, point, immediate);
      this._bindings = this.preboundTemplate(dom, point);
      this._bindings.push(contentBinding);
      return dom;
    };

    return _Class;

  })(DomView.build($('<div class="janus-list-selectItem"> <button class="janus-list-selectItem-select"></button> <div class="janus-list-selectItem-contents"></div> </div>'), template(find('.janus-list-selectItem').classed('checked', from.self().flatMap(function(view) {
    return view.options["enum"].getValue().map(function(value) {
      return value === view.subject;
    });
  })), find('.janus-list-selectItem-select').text(from.self().flatMap(function(view) {
    return (ref1 = typeof (base = view.options).buttonLabel === "function" ? base.buttonLabel(view.subject) : void 0) != null ? ref1 : 'Select';
  })).on('click', function(_, subject, view) {
    return view.options["enum"].setValue(subject);
  }))));

  EnumAttributeListEditView = DomView.build($('<div class="janus-enumSelect"/>'), template(find('div').render(from.subject().flatMap(function(attr) {
    return attr.values();
  })).options(from.self().map(function(view) {
    var modifiedRenderItem, ogRenderItem, ref1, ref2, renderWrapper;
    ogRenderItem = (ref1 = view.options.renderItem) != null ? ref1 : identity;
    modifiedRenderItem = function(render) {
      return ogRenderItem(render.context('summary'));
    };
    renderWrapper = (ref2 = view.options.renderWrapper) != null ? ref2 : identity;
    return {
      renderItem: (function(_this) {
        return function(render) {
          return renderWrapper(render.context('select-wrapper').options({
            renderItem: modifiedRenderItem,
            "enum": view.subject,
            buttonLabel: view.options.buttonLabel
          }));
        };
      })(this)
    };
  }))));

  module.exports = {
    EnumAttributeListEditView: EnumAttributeListEditView,
    ListSelectItemView: ListSelectItemView,
    registerWith: function(library) {
      library.register(Number, ListSelectItemView, {
        context: 'select-wrapper'
      });
      library.register(Boolean, ListSelectItemView, {
        context: 'select-wrapper'
      });
      library.register(String, ListSelectItemView, {
        context: 'select-wrapper'
      });
      library.register(Base, ListSelectItemView, {
        context: 'select-wrapper'
      });
      return library.register(Enum, EnumAttributeListEditView, {
        context: 'edit',
        style: 'button-list'
      });
    }
  };

}).call(this);