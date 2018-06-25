local BT = {}

BT.Action = import(".Action")
BT.ActiveSelector = import(".ActiveSelector")
BT.Behavior = import(".Behavior")
BT.Decorator = import(".Decorator")
BT.FailIfRunning = import(".FailIfRunning")
BT.Func = import(".Func")
BT.FuncWait = import(".FuncWait")
BT.Inverter = import(".Inverter")
BT.Parallel = import(".Parallel")
BT.Random = import(".Random")
BT.RepeatUntilFail = import(".RepeatUntilFail")
BT.Root = import(".Root")
BT.Selector = import(".Selector")
BT.Sequence = import(".Sequence")
BT.Timer = import(".Timer")
BT.Wait = import(".Wait")
BT.WaitUntil = import(".WaitUntil")

return BT