Extension { #name : #SSWDBProtoObject }

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> basicClass [
	"Primitive. Answer the object which is the receiver's class. Essential. See 
	Object documentation whatIsAPrimitive."

	<primitive: 111>
	self primitiveFailed
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> debugPrintString [ 

	^'a ', self class name
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> error: aString [
	"Throw a generic Error exception."
	<debuggerCompleteToSender>
	^ Error new signal: aString
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> instVarAt: index [

	<primitive: 173 error: ec>
	self primitiveFailed
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> longPrintOn: aStream [

	aStream nextPutAll: self debugPrintString; cr
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> longPrintOn: aStream limitedTo: sizeLimit indent: indent [

	indent timesRepeat: [aStream tab].
	self longPrintOn: aStream
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> longPrintString [ 

	^self debugPrintString
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> longPrintStringLimitedTo: anInteger [

	^self debugPrintString
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> perform: aSymbol [ 

	<primitive: 83>
	^ self perform: aSymbol withArguments: #()
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> perform: aSymbol with: anObject [ 

	<primitive: 83>
	^ self perform: aSymbol withArguments: {anObject}
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> perform: aSymbol with: firstObject with: secondObject [ 

	<primitive: 83>
	^ self perform: aSymbol withArguments: {firstObject . secondObject}
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> perform: aSymbol with: firstObject with: secondObject with: thirdObject [ 

	<primitive: 83>
	^ self perform: aSymbol
		withArguments: {firstObject . secondObject . thirdObject}
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> perform: aSymbol with: firstObject with: secondObject with: thirdObject with: fourthObject [

	<primitive: 83>
	^ self perform: aSymbol
		withArguments: {firstObject . secondObject . thirdObject . fourthObject}
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> perform: selector withArguments: argArray [ 

	<primitive: 84>
	^ self perform: selector withArguments: argArray inSuperclass: self class
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> perform: selector withArguments: argArray inSuperclass: lookupClass [

	<primitive: 100>
	selector isSymbol
		ifFalse: [ ^ self error: 'selector argument must be a Symbol' ].
	selector numArgs = argArray size
		ifFalse: [ ^ self error: 'incorrect number of arguments' ].
	(self class includesBehavior: lookupClass)
		ifFalse: [ ^ self error: 'lookupClass is not in my inheritance chain' ].
	self primitiveFailed
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> stDisplayString [

	^self debugPrintString
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProtoObject >> stDisplayStringFull [

	^self debugPrintString
]
