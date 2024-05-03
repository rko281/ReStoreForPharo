Extension { #name : 'SSWReStore' }

{ #category : '*SSW ReStore for Pharo' }
SSWReStore class >> proxyForObject: anObject ifNone: aBlock [

	"Locate and return the proxy wrapping anObject in the receiver's activeReStores.
	If none found, return the result of evaluating aBlock"

	activeReStores do:
		[ :aReStore |
		"Only interrogate aReStore if it stores instances of the class of anObject"
		((aReStore tableCache includesKey: anObject class) or: [anObject isKindOf: Collection]) ifTrue: [(aReStore activeProxyForObject: anObject ifNone: [nil]) ifNotNil: [ :proxy | ^proxy]]].

	^aBlock value
]
