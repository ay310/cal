#
# Modelの定義
#
class ParentModel extends Backbone.Model
  defaults:
    iframe: true
    href:   "child.html"

#
# Viewの定義
#
class ParentView extends Backbone.View
  el: "#btnSearch"

  events:
    "click": "search"

  search: ->
    $.colorbox @model.toJSON()

#
# インスタンスの生成
#
mParent = new ParentModel()
vParent = new ParentView model:mParent