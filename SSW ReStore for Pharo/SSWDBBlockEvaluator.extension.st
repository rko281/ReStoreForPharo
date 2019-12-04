Extension { #name : #SSWDBBlockEvaluator }

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> debugPrintString [

	^'<ReStore block evaluator>'
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> gtDisplayString [

	^self debugPrintString
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> printStringLimitedTo: anInteger [

	| string |
	
	string := self debugPrintString.
	
	^string size > anInteger
		ifTrue: [ string first: anInteger ]
		ifFalse: [ string ]
]

{ #category : #'*SSW ReStore for Pharo' }
SSWDBBlockEvaluator >> yourself [

	^self
]
