import {default as store} from './store.jsx'
import {default as reducer} from './reducer.jsx'
import {default as Root} from './component.coffee'

export default function(app) {
  app.store = store
  app.Root = Root
}
