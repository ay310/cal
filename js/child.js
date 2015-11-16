#
# Routerの定義
#
class Router extends Backbone.Router
  routes:
    ":id/:name": "close"

  close: (id, name) ->
    $("#parent_id", window.parent.document).val id
    $("#parent_name", window.parent.document).val name
    parent.$.fn.colorbox.close()

#
# インスタンスの生成
#
window.router = new Router()
Backbone.history.start()