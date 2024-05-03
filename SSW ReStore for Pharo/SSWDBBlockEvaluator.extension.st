Extension { #name : 'SSWDBBlockEvaluator' }

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> _class [

	^super class
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> debugPrintString [

	^'<ReStore block evaluator>'
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> gtDisplayString [

	^self debugPrintString
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> perform: aSymbol [ 
	"Send the unary selector, aSymbol, to the receiver.
	Fail if the number of arguments expected by the selector is not zero.
	Primitive. Optional. See Object documentation whatIsAPrimitive."
	
	<reflective: #object:performMessageWith:>
	<primitive: 83>
	^ self perform: aSymbol withArguments: (Array new: 0)
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> perform: aSymbol with: anObject [ 
	"Send the selector, aSymbol, to the receiver with anObject as its argument.
	Fail if the number of arguments expected by the selector is not one.
	Primitive. Optional. See Object documentation whatIsAPrimitive."
	
	<reflective: #object:performMessageWith:>
	<primitive: 83>
	^ self perform: aSymbol withArguments: (Array with: anObject)
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> perform: selector withArguments: argArray [ 
	"Send the selector, aSymbol, to the receiver with arguments in argArray.
	Fail if the number of arguments expected by the selector 
	does not match the size of argArray.
	Primitive. Optional. See Object documentation whatIsAPrimitive."
	
	<reflective: #object:performMessageWithArgs:>
	<primitive: 84>
	^ self perform: selector withArguments: argArray inSuperclass: self _class
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> perform: selector withArguments: argArray inSuperclass: lookupClass [
	"NOTE:  This is just like perform:withArguments:, except that
	the message lookup process begins, not with the receivers's class,
	but with the supplied superclass instead.  It will fail if lookupClass
	cannot be found among the receiver's superclasses.
	Primitive. Essential. See Object documentation whatIsAPrimitive."

	<reflective: #object:performMessageInSuperclass:>
	<primitive: 100>
	selector isSymbol
		ifFalse: [ ^ nil error: 'selector argument must be a Symbol' ].
	selector numArgs = argArray size
		ifFalse: [ ^ nil error: 'incorrect number of arguments' ].
	(self class includesBehavior: lookupClass)
		ifFalse: [ ^ nil error: 'lookupClass is not in my inheritance chain' ].
	self primitiveFailed
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> printStringLimitedTo: anInteger [

	| string |
	
	string := self debugPrintString.
	
	^string size > anInteger
		ifTrue: [ string first: anInteger ]
		ifFalse: [ string ]
]

{ #category : '*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> yourself [

	^self
]
