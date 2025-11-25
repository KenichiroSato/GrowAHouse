local Types = {}

--=========== Client module ========================

export type SingleTapDetector_ = {
	new:() -> SingleTapDetector_,
	Start:(self: SingleTapDetector_, callback: (InputObject) -> ()) -> (),
	Stop:(self: SingleTapDetector_) -> ()	
}

export type ColorMaterialSetter = {
	Set:(instance: Instance, color: Color3?, material: Enum.Material?, ignoreTag: string? ) -> (),
}

return Types
