function RootMenuModelItem(name, role, visualElement, background, engine) {
    this.name = name
    this.role = role
    this.visualElement = visualElement
    this.background = background ? background : ""
    this.engine = engine
}

var activationHandlers = []
