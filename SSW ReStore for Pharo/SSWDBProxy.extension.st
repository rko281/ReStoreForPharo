Extension { #name : #SSWDBProxy }

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> _proxyClass [

	^super class
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> _proxyInstVarAt: index [

	<primitive: 173 error: ec>
	self primitiveFailed
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> _proxyInstVarAt: index put: value [

	<primitive: 174 error: ec>
	 (index isInteger 
		and: [ index between: 1 and: self _proxyClass instSize]) 
			ifFalse: [ ^ nil errorSubscriptBounds: index ]
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> asCollectionElement [

	^self
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> asSetElement [

	^self
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> enclosedElement [

	^self
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> enclosedSetElement [

	^self
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> gtDisplayString [

	^self debugPrintString 
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> notNil [

	^true
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBProxy >> printStringLimitedTo: anInteger [

	| string |
	
	string := self debugPrintString.
	
	^string size > anInteger
		ifTrue: [ string first: anInteger ]
		ifFalse: [ string ]
]
