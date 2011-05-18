function RootMenuModelItem(name, role, visualElement, background) {
    this.name = name
    this.role = role
    this.visualElement = visualElement
    this.background = background ? background : ""
}

var activationHandlers = []
